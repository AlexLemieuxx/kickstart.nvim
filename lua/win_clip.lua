local ffi = require("ffi")
ffi.cdef[[
  int OpenClipboard(void* hwnd);
  int CloseClipboard(void);
  int EmptyClipboard(void);
  void* GetClipboardData(unsigned int uFormat);
  int IsClipboardFormatAvailable(unsigned int format);
  void* GlobalLock(void* hMem);
  int GlobalUnlock(void* hMem);
  void* GlobalAlloc(unsigned int uFlags, size_t dwBytes);
  void* SetClipboardData(unsigned int uFormat, void* hMem);
  int memcpy(void* dest, const void* src, size_t n);
  size_t wcslen(const wchar_t *str);
  int MultiByteToWideChar(unsigned int cp, unsigned int flags,
                          const char* mb, int mb_len,
                          wchar_t* wc, int wc_len);
  int WideCharToMultiByte(unsigned int cp, unsigned int flags,
                          const wchar_t* wc, int wc_len,
                          char* mb, int mb_len,
                          const char* defchar, int* used_default);
]]

local C = ffi.C
local CF_UNICODETEXT = 13
local GMEM_MOVEABLE   = 0x0002
local GMEM_ZEROINIT   = 0x0040
local GHND            = GMEM_MOVEABLE + GMEM_ZEROINIT
local CP_UTF8         = 65001

local M = {}

-- Helper: join lines into one string
local function lines_to_str(lines)
  return table.concat(lines, "\n")
end

-- copy(lines: table, regtype: string)
function M.copy(lines, regtype)
  local text = lines_to_str(lines)
  -- get size including NUL (mb_len = -1)
  local wchar_count = C.MultiByteToWideChar(CP_UTF8, 0, text, -1, nil, 0)
  local wchar_buf   = ffi.new("wchar_t[?]", wchar_count)
  C.MultiByteToWideChar(CP_UTF8, 0, text, -1, wchar_buf, wchar_count)

  -- allocate movable, zero‑init memory
  local hGlobal = C.GlobalAlloc(GHND, wchar_count * 2)
  local lp      = C.GlobalLock(hGlobal)
  C.memcpy(lp, wchar_buf, wchar_count * 2)  -- includes the terminating NUL
  C.GlobalUnlock(hGlobal)

  C.OpenClipboard(nil)
  C.EmptyClipboard()
  C.SetClipboardData(CF_UNICODETEXT, hGlobal)
  C.CloseClipboard()
end

-- paste() -> table of lines
function M.paste()
  if C.OpenClipboard(nil) == 0 then return {} end
  if C.IsClipboardFormatAvailable(CF_UNICODETEXT) == 0 then
    C.CloseClipboard()
    return {}
  end

  local hClip = C.GetClipboardData(CF_UNICODETEXT)
  local lp    = C.GlobalLock(hClip)
  if lp == nil then
    C.CloseClipboard()
    return {}
  end

  local wchar_len = C.wcslen(ffi.cast("wchar_t*", lp))
  local mb_len    = C.WideCharToMultiByte(CP_UTF8, 0,
                      ffi.cast("wchar_t*", lp), wchar_len,
                      nil, 0, nil, nil)
  local buf = ffi.new("char[?]", mb_len)
  C.WideCharToMultiByte(CP_UTF8, 0,
      ffi.cast("wchar_t*", lp), wchar_len,
      buf, mb_len, nil, nil)

  C.GlobalUnlock(hClip)
  C.CloseClipboard()

  -- turn the flat string into a table of lines
  local result = ffi.string(buf, mb_len)
  local lines  = {}
  for s in result:gmatch("([^\r\n]*)\r?\n?") do
    if s == "" then break end
    table.insert(lines, s)
  end
  return lines
end

return M
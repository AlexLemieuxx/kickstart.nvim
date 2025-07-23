-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'max397574/better-escape.nvim',
    config = function()
      require('better_escape').setup()
    end,
  },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup {}
      local harpoon_extensions = require 'harpoon.extensions'
      harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
      -- NOTE: The following block can tie telescope w/ harpoon
      -- local conf = require('telescope.config').values
      -- local function toggle_telescope(harpoon_files)
      --   local file_paths = {}
      --   for _, item in ipairs(harpoon_files.items) do
      --     table.insert(file_paths, item.value)
      --   end
      --
      --   require('telescope.pickers')
      --     .new({}, {
      --       prompt_title = 'Harpoon',
      --       finder = require('telescope.finders').new_table {
      --         results = file_paths,
      --       },
      --       previewer = conf.file_previewer {},
      --       sorter = conf.generic_sorter {},
      --     })
      --     :find()
      -- end
      --
      -- NOTE: update this if uncommented
      -- vim.keymap.set('n', '<C-e>', function()
      --   toggle_telescope(harpoon:list())
      -- end, { desc = 'Open harpoon window' })

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = '[a]dd to harpoon' })
      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)
      vim.keymap.set('n', '<a-1>', function()
        harpoon:list():select(1)
      end)
      vim.keymap.set('n', '<a-2>', function()
        harpoon:list():select(2)
      end)
      vim.keymap.set('n', '<a-3>', function()
        harpoon:list():select(3) --harpoon:list():select(3)
      end)
      vim.keymap.set('n', '<a-4>', function()
        harpoon:list():select(4)
      end)
      vim.keymap.set('n', '<a-5>', function()
        harpoon:list():prev()
      end)
      vim.keymap.set('n', '<a-6>', function()
        harpoon:list():next()
      end)
    end,
  },
}

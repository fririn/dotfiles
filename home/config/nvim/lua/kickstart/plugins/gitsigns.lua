-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '-' },
        topdelete = { text = '‾' },
        changedelete = { text = '_' },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 100,
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [r]eset hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = '[T]oggle git show [D]eleted' })

        -- Open commit in browser
        map('n', '<leader>go', function()
          local blame_info = gitsigns.get_current_line_blame_info and gitsigns.get_current_line_blame_info()
            or vim.b[bufnr].gitsigns_blame_line_dict

          if not blame_info then
            print 'No blame info available for this line yet.'
            return
          end

          local commit_hash = blame_info.sha
          if not commit_hash or commit_hash == '00000000' then
            print 'Line is not committed.'
            return
          end

          local handle = io.popen 'git config --get remote.origin.url'
          local remote_url = handle:read '*a'
          handle:close()
          remote_url = remote_url:gsub('[\n\r]', '')

          if remote_url:find 'git@' then
            remote_url = remote_url:gsub(':', '/'):gsub('git@', 'https://'):gsub('%.git', '')
          else
            remote_url = remote_url:gsub('%.git', '')
          end

          local final_url = remote_url .. '/commit/' .. commit_hash
          local open_cmd = vim.fn.has 'mac' == 1 and 'open' or vim.fn.has 'win32' == 1 and 'start' or 'xdg-open'
          print('Opening: ' .. final_url)
          os.execute(open_cmd .. ' ' .. final_url)
        end, { desc = 'Open commit in browser' })
      end,
    },
  },
}

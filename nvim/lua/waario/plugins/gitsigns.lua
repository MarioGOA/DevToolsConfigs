return {
  {
    "lewis6991/gitsigns.nvim",
    -- Load on buffer read or creation to ensure fast Neovim startup time
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Basic custom configurations
      signs = {
        add          = { text = "┃" },
        change       = { text = "┃" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        follow_files = true
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      
      -- Keymaps for navigating and handling hunks
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", blink = false })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "Next Git hunk" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", blink = false })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "Previous Git hunk" })

        -- Actions
        -- map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk" })
        -- map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
        -- map("v", "<leader>hs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage selected range" })
        -- map("v", "<leader>hr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset selected range" })
        -- map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage entire buffer" })
        -- map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Undo staged hunk" })
        -- map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset entire buffer" })
        -- map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
        -- map("n", "<leader>hb", function() gitsigns.blame_line({ full = true }) end, { desc = "Blame current line" })
        map("n", "<leader>gb", gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
        map("n", "<leader>gd", gitsigns.diffthis, { desc = "Diff against index" })
        map("n", "<leader>gD", function() gitsigns.diffthis("~") end, { desc = "Diff against last commit" })
        -- map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "Toggle deleted lines visual" })

        -- Text object map to target hunks (e.g. `ih` for "inner hunk")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Git hunk text object" })
      end
    }
  }
}


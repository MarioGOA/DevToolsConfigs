require('telescope').setup({
    defaults = {
        wrap_results = true,
        file_ignore_patterns = {
            "build/",
        },
    },
    pickers = {
        find_files = {
            hidden = true,
        },
    },
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Telescope git files' })
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search =  vim.fn.input("Search > ")});
end)

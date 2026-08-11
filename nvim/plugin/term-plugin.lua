local term_state = {
    win = -1,
    buf = -1,
}

local function toggle_floating_window()
    if vim.api.nvim_win_is_valid(term_state.win) then
        vim.api.nvim_win_close(term_state.win, true)
        return
    end

    -- Calc window size -- 
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.6)

    -- Window position --
    local pos_y = math.floor((vim.o.lines - height) / 2)
    local pos_x = math.floor((vim.o.columns - width) / 2)

    -- Buffer Management --
    if not vim.api.nvim_buf_is_valid(term_state.buf) then
        term_state.buf = vim.api.nvim_create_buf(false, true) -- no file
    end

    -- Windows options --
    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        row = pos_y,
        col = pos_x,
        style = "minimal",
        border = "rounded",
    }

    -- Open window --
    term_state.win = vim.api.nvim_open_win(term_state.buf, true, win_opts)

end

local function toggle_terminal()
    toggle_floating_window()

    -- Start Terminal --
    if vim.bo[term_state.buf].buftype ~= "terminal" then
        vim.cmd("terminal")
    end

    -- Enter Into Terminal --
    vim.cmd("startinsert")
end

-- Create keymap --
vim.keymap.set({ "n" }, "<leader>t", toggle_terminal, { desc = "Toggle Floating Terminal" })
vim.keymap.set({ "t" }, "<Esc><Esc>", toggle_terminal, { desc = "Toggle Floating Terminal" })

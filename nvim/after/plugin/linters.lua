local cached_checkstyle_config = nil

local function find_checkstyle_config_async()
    if cached_checkstyle_config then
        return cached_checkstyle_config
    end

    local root_dir = vim.fs.root(0, { 'packageInfo', 'Config', '.git' })
    if not root_dir then
        return nil
    end

    -- Pure Lua async search using vim.fs.find
    -- It stops immediately when encountering these blacklisted directories
    local found = vim.fs.find('checkstyle.xml', {
        path = root_dir,
        upward = false,
        limit = 1,
        stop = 'build'
    })

    if #found > 0 then
        cached_checkstyle_config = found[1]
        return cached_checkstyle_config
    else
        return nil
    end
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    pattern = "*.java", -- Only run this logic for Java files to save CPU
    callback = function()
        if cached_checkstyle_config then
            return
        end
        
        local config_path = find_checkstyle_config_async()
        local lint = require('lint')

        local out_message = "CheckStyle File NOT FOUND using default."
        if config_path then
            out_message = string.format("Found CheckStyle at: %s", config_path)
        end

        vim.notify(
            out_message,
            vim.log.levels.INFO,
            { title = "[CheckStyle Linters]" }
        )

        if config_path then
            lint.linters.checkstyle.args = { '-c', config_path }
            lint.linters_by_ft = { java = { 'checkstyle' } }
            -- Trigger the linter now that the configuration is ready
            lint.try_lint()
        else
            lint.linters_by_ft = { java = {} }
        end
    end,
})

local function find_checkstyle_config()
    local root_dir = vim.fs.root(0, {'packageInfo', 'Config', '.git'})
    if not root_dir then
        return nil
    end

    local checkstyle_files = vim.fn.globpath(root_dir, '**/checkstyle.xml', false, true)
    
    for _, file in ipairs(checkstyle_files) do
        if not string.match(file, '/build/') then
            print("Using checkstyle config: " .. file)
            return file
        end
    end
    
    print("No checkstyle.xml found")
    return nil
end

local checkstyle_config = find_checkstyle_config()

if checkstyle_config then
    require('lint').linters.checkstyle.args = {'-c', checkstyle_config}
    require('lint').linters_by_ft = {java = {'checkstyle'}}
else
    require('lint').linters_by_ft = {}
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

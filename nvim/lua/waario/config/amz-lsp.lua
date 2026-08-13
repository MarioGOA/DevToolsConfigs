-- This config is required to use LSP servers on Brazil Projects
function isBrazilWorkspace()
    local cwd = vim.fn.getcwd()
    local user = os.getenv("USER")
    if string.match(cwd, "^/Volumes/workplace") or string.match(cwd, "^/Users/" .. user .. "/workplace") then
        return true
    else
        return false
    end
end

function notify(out_message)
    vim.notify(
        out_message,
        vim.log.levels.INFO,
        { title = "[LSP Pre-Steps]" }
    )
end

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function ()
        local out_message = "Not in an Brazil Workplace"
        local workplace_found = isBrazilWorkspace()

        if workplace_found then
            out_message = "Brazil Workplace detected..."
        end
        notify(out_message)

        if not workplace_found then
            return
        end

        local root_dir = vim.fs.root(0, {'packageInfo', 'Config'})

        if root_dir and vim.fn.isdirectory(root_dir .. "/.bemol") == 0 then
            notify("Bemol folder not found - running it")
            vim.system({'bemol'}, {
                cwd = root_dir,
            }, function(obj)
                if obj.code == 0 then
                    notify("Bemol completed successfully")
                else
                    notify("Bemol failed: " .. (obj.stderr or "Unknown error"))
                end
            end)
        end
    end,
})


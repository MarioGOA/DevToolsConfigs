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

function initializeBemol()
    if isBrazilWorkspace() then
        print("Brazil Workplace detected...")
    else
        return
    end

    local root_dir = vim.fs.root(0, {'packageInfo', 'Config', '.git'})

    if root_dir and vim.fn.isdirectory(root_dir .. "/.bemol") == 0 then
        print("Bemol folder not found - running command")
        vim.system({'bemol'}, {
            cwd = root_dir,
        }, function(obj)
            if obj.code == 0 then
                print("Bemol completed successfully")
            else
                print("Bemol failed: " .. (obj.stderr or "Unknown error"))
            end
        end)
    end
end

vim.schedule(initializeBemol)

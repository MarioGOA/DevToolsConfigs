-- LSP Configs

-- Grammar LSP
vim.lsp.enable("codebook")

-- JAVA LSP
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- Brazil rootFiles:
-- packageInfo: Multi Package Project
-- Config: Single Package Project
-- .git: Final fallback
local root_dir = vim.fs.root(0, {'packageInfo', 'Config', '.git'})


local ws_folders_jdtls = {}
if root_dir then
    local file = io.open(root_dir .. "/.bemol/ws_root_folders")
    if file then
        for line in file:lines() do
            table.insert(ws_folders_jdtls, "file://" .. line)
        end
        file:close()
    end
end

vim.lsp.config("jdtls", {
    root_dir = root_dir,
    cmd = {
        "jdtls",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.level=ALL",
        "--jvm-arg=-javaagent:/Users/maario/.local/share/nvim/mason/share/jdtls/lombok.jar",
        "-Xmx1G",
        "--add-modules=ALL-SYSTEM",
        "--add-opens java.base/java.util=ALL-UNNAMED",
        "--add-opens java.base/java.lang=ALL-UNNAMED",
        "-jar /opt/homebrew/Cellar/jdtls/1.54.0/libexec/plugins/org.eclipse.equinox.launcher_1.7.100.v20251111-0406.jar",
        "-configuration /opt/homebrew/Cellar/jdtls/1.54.0/libexec/config_mac",
        "-data", workspace_dir
    },
    init_options = {
        workspaceFolders = ws_folders_jdtls,
    }
})
vim.lsp.enable("jdtls")

-- JavaScript / TypeScript LSP
vim.lsp.enable('ts_ls')

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		'nvim-telescope/telescope.nvim', tag = 'v0.2.1',
		dependencies = {
			'nvim-lua/plenary.nvim',
			-- optional but recommended
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		}
	},
	{
		'nvim-treesitter/nvim-treesitter',
		lazy = false,
		build = ':TSUpdate'
	},
	{
		'mbbill/undotree',
		lazy = false
	},
	{
		'nvim-lualine/lualine.nvim',
		lazy = true,
		dependencies = { 'nvim-tree/nvim-web-devicons' },
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" }
	},
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup {}
        end,
    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    },
}

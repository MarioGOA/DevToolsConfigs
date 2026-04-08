require('nvim-treesitter.configs').setup {
	ensure_installed = { 
		'java',
		'bash',
		'c',
		'cpp',
		'diff',
		'go',
		'json',
		'python',
		'ruby',
		'scala',
		'csv',
		'rust', 
		'javascript', 
		'lua' 
	},

	highlight = {
		enable = true,
	},
}

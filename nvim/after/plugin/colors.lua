function ColorMyVim(color)
	color = color or "tokyonight-night"
	vim.cmd.colorscheme(color)
end

ColorMyVim()

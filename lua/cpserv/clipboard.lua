local reg = require("cpserv.reg")

local M = {}

M.enabled = false

function M.setup()
	if M.enabled == false then
		M.prev = vim.g.clipboard
	end
	M.enabled = true
	vim.g.clipboard = {
		name = "cpserv",
		copy = {
			['+'] = reg.copy_func(),
			['*'] = reg.copy_func(),
		},
		paste = {
			['+'] = reg.paste_func(),
			['*'] = reg.paste_func(),
		},
	}
end

function M.undo()
	if M.enabled == true then
		vim.g.clipboard = M.prev

		M.prev = nil
		M.enabled = false
	end
end

return M

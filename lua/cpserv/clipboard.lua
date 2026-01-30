local reg = require("cpserv.reg")

local M = {}

function M.setup()
	if M.prev == nil then
		M.prev = vim.g.clipboard
	end
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
	if M.prev then
		vim.g.clipboard = M.prev
		M.prev = nil
	end
end

return M

local inst = require("cpserv.installer")
local ssh = require("cpserv.ssh")
local reg = require("cpserv.reg")
local clip = require("cpserv.clipboard")

local M = {}

local defaults = {
	autoinstall = true,
	ssh_autoconnect = true,
	remote = "",
}

function M.setup(opts)
	opts = vim.tbl_deep_extend("force", defaults, opts or {})
	M.config = opts

	if opts.autoinstall == true then
		M.install()
	end

	M.remote_info = ssh.get_remote_info()
	if M.remote_info.enabled and M.remote_info.remote and M.remote_info.remote ~= "" then
		if opts.ssh_autoconnect then
			clip.setup()
		end
	end

	if opts.remote ~= "" then
		M.remote_info = opts.remote
	end

	reg.remote_info = M.remote_info
end

--- @param enable boolean enable|disable cpserv.clipboard
function M.clipboard(enable)
	if enable then
		clip.setup()
	else
		clip.undo()
	end
end

--- @return boolean
function M.clipboard_status()
	if clip.prev == nil then
		return false
	else
		return true
	end
end

--- @param remote string example: 192.168.0.5
function M.set_remote(remote)
	M.remote_info = remote
	reg.remote_info = remote
end

function M.install()
	inst.install_all(false)
end

function M.install_force()
	inst.install_all(true)
end

return M

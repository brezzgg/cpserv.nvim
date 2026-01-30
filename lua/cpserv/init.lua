local inst = require("cpserv.installer")
local ssh = require("cpserv.ssh")
local reg = require("cpserv.reg")
local clip = require("cpserv.clipboard")

local M = {}

local defaults = {
	autoinstall = true,
	ssh_autoconnect = true,
}

function M.setup(opts)
	opts = vim.tbl_deep_extend("force", defaults, opts or {})
	M.config = opts

	if opts.autoinstall == true then
		M.install()
	end

	M.ssh_info = ssh.is_ssh()
	if M.ssh_info.is_ssh and M.ssh_info.remote and M.ssh_info.remote ~= "" then
		clip.setup()
	end
	reg.ssh_info = M.ssh_info
end

--- @param regname string
function M.read(regname)
	reg.paste(regname)
end

--- @param regname string
function M.write(regname)
	reg.copy(regname)
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

function M.install()
	inst.install_all()
end

return M

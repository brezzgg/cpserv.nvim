local M = {}

-- SSH_CLIENT=192.168.0.5 59667 22

--- @class SshInfo
--- @field is_ssh boolean
--- @field remote string?

--- @return SshInfo
function M.is_ssh()
	local ssh_client = vim.env.SSH_CLIENT
	if not ssh_client or ssh_client == "" then
		return { is_ssh = false }
	end

	local remote = string.match(ssh_client, "^(%S+)")

	return {
		is_ssh = true,
		remote = remote,
	}
end

return M

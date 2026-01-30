local M = {}

-- SSH_CLIENT=192.168.0.5 59667 22

--- @class RemoteInfo
--- @field enabled boolean
--- @field remote string?

--- @return RemoteInfo
function M.get_remote_info()
	local ssh_client = vim.env.SSH_CLIENT
	if not ssh_client or ssh_client == "" then
		return { enabled = false }
	end

	local remote = string.match(ssh_client, "^(%S+)")

	return {
		enabled = true,
		remote = remote,
	}
end

return M

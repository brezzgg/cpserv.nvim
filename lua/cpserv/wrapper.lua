local M = {}

local exe = "cpserv"

-- {"type":"response|error","msg":"msg"}

--- @class ExectueReturn
--- @field msg string?
--- @field error string?

--- @param args string[]
--- @param ssh_info SshInfo
--- @return ExectueReturn
function M.execute(args, ssh_info)
	local cmd = { exe }

	if ssh_info and ssh_info.is_ssh == true and ssh_info.remote ~= "" then
		table.insert(cmd, "-r")
		table.insert(cmd, string.format('"%s"', ssh_info.remote))
	end

	for _, value in ipairs(args) do
		table.insert(cmd, value)
	end

	local output = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	output = vim.trim(output)

	if exit_code ~= 0 then
		return { error = "failed to exectute cpserv: " .. output }
	end

	if not output or output == "" then
		return {}
	end

	local data = vim.json.decode(output)
	if not data or not data.type or not data.msg then
		return { error = "failed to deserialize data" }
	end

	if data.type == "error" then
		return { error = data.msg }
	end

	if data.type == "response" then
		if data.msg and data.msg ~= "" then
			return {
				msg = data.msg
			}
		else
			return {
				error = "text is nil"
			}
		end
	end

	return { error = "bad fields" }
end

return M

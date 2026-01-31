local M = {}

local exe = "cpserv"

-- {"type":"response|error","msg":"msg"}

--- @class ExectueReturn
--- @field msg string?
--- @field error string?

--- @param args string[]
--- @param remote_info RemoteInfo
--- @return ExectueReturn
function M.execute(args, remote_info)
	local cmd = { exe }

	if remote_info and remote_info.enabled == true and remote_info.remote and remote_info.remote ~= "" then
		table.insert(cmd, "-r")
		local remote = tostring(remote_info.remote)
		if not string.find(remote, ":") then
			remote = remote .. ":56384"
		end
		table.insert(cmd, remote)
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

--- @param args string[]
--- @param remote_info RemoteInfo
--- @param callback function(ExectueReturn)
function M.execute_async(args, remote_info, callback)
	local cmd = { exe }

	if remote_info and remote_info.enabled == true and remote_info.remote and remote_info.remote ~= "" then
		table.insert(cmd, "-r")
		local remote = tostring(remote_info.remote)
		if not string.find(remote, ":") then
			remote = remote .. ":56384"
		end
		table.insert(cmd, remote)
	end

	for _, value in ipairs(args) do
		table.insert(cmd, value)
	end

	vim.system(cmd, { text = true }, function(obj)
		vim.schedule(function()
			if obj.code ~= 0 then
				callback({ error = "failed to execute cpserv: " .. vim.trim(obj.stderr or "") })
				return
			end

			local output = vim.trim(obj.stdout or "")

			if not output or output == "" then
				callback({})
				return
			end

			local ok, data = pcall(vim.json.decode, output)
			if not ok or not data or not data.type or not data.msg then
				callback({ error = "failed to deserialize data" })
				return
			end

			if data.type == "error" then
				callback({ error = data.msg })
				return
			end

			if data.type == "response" then
				if data.msg and data.msg ~= "" then
					callback({ msg = data.msg })
				else
					callback({ error = "text is nil" })
				end
				return
			end

			callback({ error = "bad fields" })
		end)
	end)
end

return M

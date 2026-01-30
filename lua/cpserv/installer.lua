local M = {}

M.binaries = {
	cpserv = "github.com/brezzgg/cpserv@v1.0.3"
}

function M.is_installed(binary_name)
	return vim.fn.executable(binary_name) == 1
end

function M.get_gobin()
	local gobin = vim.fn.getenv("GOBIN")
	if gobin ~= vim.NIL and gobin ~= "" then
		return gobin
	end

	local gopath = vim.fn.getenv("GOPATH")
	if gopath ~= vim.NIL and gopath ~= "" then
		return gopath .. "/bin"
	end

	return vim.fn.expand("$HOME/go/bin")
end

function M.install_binary_async(binary_name, package_url, callback)
	if M.is_installed(binary_name) then
		if callback then callback(true) end
		return
	end

	vim.notify(
		string.format("Installing %s...", binary_name),
		vim.log.levels.INFO
	)

	local cmd = "go"
	local args = { "install", package_url }

	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local handle, _ = vim.loop.spawn(cmd, {
		args = args,
		stdio = { nil, stdout, stderr },
	}, function(code, _)
		if stdout then
			stdout:close()
		end
		if stderr then
			stderr:close()
		end

		vim.schedule(function()
			if code == 0 then
				if M.is_installed(binary_name) then
					vim.notify(
						string.format("%s installed", binary_name),
						vim.log.levels.INFO
					)
					if callback then callback(true) end
				else
					local gobin = M.get_gobin()
					vim.notify(
						string.format("%s installed, but not in PATH. Add: export PATH=$PATH:%s",
							binary_name, gobin),
						vim.log.levels.WARN
					)
					if callback then callback(false) end
				end
			else
				vim.notify(
					string.format("Installation failed  %s (exit code: %d)", binary_name, code),
					vim.log.levels.ERROR
				)
				if callback then callback(false) end
			end
		end)
	end)

	if not handle then
		vim.notify(
			string.format("Failed to start go install for %s", binary_name),
			vim.log.levels.ERROR
		)
		if callback then callback(false) end
	end
end

function M.install_all()
	local success = true
	for binary_name, package_url in pairs(M.binaries) do
		if not M.install_binary_async(binary_name, package_url) then
			success = false
		end
	end
	return success
end

return M

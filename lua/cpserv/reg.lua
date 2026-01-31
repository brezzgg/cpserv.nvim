local wrapper = require("cpserv.wrapper")

local M = {}

M.remote_info = nil

--- @class Format
--- @field text any
--- @field opts string

--- @param text string
--- @return Format
local function format(text)
	local res = {}
	res.text = {}

	if string.find(text, "\n", 1, true) then
		res.opts = "V"
	else
		res.opts = "v"
	end

	for _, value in ipairs(vim.split(text, "\n")) do
		table.insert(res.text, value)
	end

	return res
end

local function normalize_lines(lines)
	if not lines then
		return {}
	end

	if type(lines) == "table" then
		return lines
	end

	if type(lines) == "string" then
		return { lines }
	end

	return {}
end

--- @param err string
local function on_error(err)
	require("cpserv.clipboard").undo()
	vim.notify(err, vim.log.levels.WARN)
	vim.notify("Cpserv: an error occurred, cpserv  was automatically disabled. To enable it, use :CpservEnable", vim.log.levels.ERROR)
end

function M.paste_func()
	return function()
		local cached_result = { {}, "v" }

		local res = wrapper.execute({ "read" }, M.remote_info)
		if res.error then
			on_error("Cpserv: " .. res.error)
			return cached_result
		end

		local formatted = format(res.msg)
		return { formatted.text, formatted.opts }
	end
end

function M.copy_func()
	return function(lines)
		lines = normalize_lines(lines)

		if #lines == 0 then
			return
		end

		local text = table.concat(lines, "\n")
		wrapper.execute_async({ "write", "--", string.format('%s', text) }, M.remote_info, function(res)
			if res.error then
				on_error("Cpserv: " .. res.error)
			end
		end)
	end
end

return M

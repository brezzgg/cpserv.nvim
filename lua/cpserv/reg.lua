local wrapper = require("cpserv.wrapper")

local M = {}

M.ssh_info = nil

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

function M.paste_func()
	return function()
		local res = wrapper.execute({ "read" }, M.ssh_info)

		if res.error then
			vim.notify("Cpserv: " .. res.error, vim.log.levels.WARN)
			return { {}, "v" }
		end

		local formatted = format(res.msg)
		return { formatted.text, formatted.opts }
	end
end

function M.copy_func()
	return function(lines)
		lines = normalize_lines(lines)

		if #lines == 0 then
			vim.notify("Cpserv: nothing to copy", vim.log.levels.WARN)
			return
		end

		local text = table.concat(lines, "\n")
		local res = wrapper.execute({ "write", string.format('%s', text) }, M.ssh_info)

		if res.error then
			vim.notify("Cpserv: " .. res.error, vim.log.levels.WARN)
		end
	end
end

function M.paste(name)
	local res = wrapper.execute({ "read" }, M.ssh_info)
	if res.error ~= nil then
		vim.notify("Cpserv: " .. res.error, vim.log.levels.WARN)
		return
	end

	local formatted = format(res.msg)
	if formatted.opts == "v" then
		vim.fn.setreg(name, formatted.text[1], formatted.opts)
	else
		vim.fn.setreg(name, formatted.text, formatted.opts)
	end
end

function M.copy(name)
	local val = vim.fn.getreg(name)
	local text
	if type(val) == "table" then
		text = table.concat(val, "\n")
	else
		text = val
	end

	local res = wrapper.execute({ "write", string.format('"%s"', text) }, M.ssh_info)
	if res.error ~= nil then
		vim.notify("Cpserv: " .. res.error, vim.log.levels.WARN)
	end
end

return M

vim.api.nvim_create_user_command("CpservEnable", function(_)
	require("cpserv").clipboard(true)
end, {})


vim.api.nvim_create_user_command("CpservDisable", function(_)
	require("cpserv").clipboard(false)
end, {})

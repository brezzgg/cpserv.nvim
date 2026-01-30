vim.api.nvim_create_user_command("CPSRead", function(args)
	require("cpserv").read()
end, {})

vim.api.nvim_create_user_command("CPSWrite", function (args)
	require("cpserv").write()
end, {})

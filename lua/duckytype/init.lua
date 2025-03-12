local gameloop = require'duckytype.gameloop'

local Plugin = {
  Start = gameloop.Start,
  NewGame = gameloop.NewGame,
}

Plugin.setup = function()
	vim.api.nvim_create_user_command("DuckyType", function(input)
		local option = input.args
		if #option == 0 then
			option = nil
		end
		gameloop.start()
	end, {
	force = true,
	nargs = '*',
	complete = function()
		--TODO make this better	
		local names = {'russian_common'}
		return names
	end})

		-- silly keymap to re-start a NewGame
	-- local command = ''
	-- vim.api.nvim_buf_set_keymap(buffer, 'n', [[<CR>]], command, { noremap = true, silent = true,
	--})
	--vim.api.nvim_buf_set_keymap(buffer, 'i', [[<CR>]], [[<Space>]], {
	--	noremap = true, silent = true,
	--})
end


return Plugin

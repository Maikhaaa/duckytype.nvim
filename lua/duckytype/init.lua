local methods = require'duckytype.methods'
local settings = require'duckytype.settings'
local gameloop = require'duckytype.gameloop'

local Plugin = {
  Start = methods.Start,
  NewGame = methods.NewGame,
  load_language = methods.load_language
}


Plugin.setup = function()
	methods.update(settings)
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
		local names = {'english_common'}
		return names
	end})
end


return Plugin

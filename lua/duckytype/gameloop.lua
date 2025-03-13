local gameloop = {}

local settings = require'duckytype.settings'
local methods = require'duckytype.methods'
local language_manager = require'duckytype.language'
local window_manager = require'duckytype.window'

local States = {
	start = 0,
	typing = 2,
	summary = 3
}
local state = States.Start

local start_time
local finish_time

gameloop.start = function()
	window_manager.create_window()

	gameloop.new_game()
	-- local events = {}
	-- TODO fix the entire mess, currently the virtual text is redrawn in
	-- full every keystroke, and things that result in a new newline are hardwired
	-- to redraw just to not have the virtual text shuffle back and forth
	--local vocabulary = language_manager.get_vocabulary()
	--window_manager.draw(vocabulary)
end


gameloop.new_game = function()
	gameloop.change_state(States.start)

	--language_manager.generate_vocabulary()
	--local vocabulary = language_manager.get_vocabulary()

	--local line = string.format("%s ", table.concat(vocabulary, " "))
	--table.insert(vocabulary, line)

	--local empty = { "", "", "" }
	--for _, _ in ipairs(vocabulary) do
	--	table.insert(empty, "")
	--end

	-- TODO proper timing, starts on first keystroke instead of when window shows
	--start_time = os.time()
	--finish_time = nil
end


gameloop.summarize = function()
	if finish_time == nil then
		finish_time = os.time()
	end
	local elapsed_time = finish_time - start_time
	local total = 0

	local expected = language_manager.get_vocabulary()

	for _, line in ipairs(expected) do
		total = total + #line
	end

	local wpm_estimate = (total / settings.average_word_length) / (elapsed_time / 60.0)

	local m1 = string.format( "%d characters in %d seconds", total, elapsed_time)
	local m2 = string.format("roughly %d wpm!",wpm_estimate)

	methods.HighlightLine(#expected, ":: ", m1)
	methods.HighlightLine(#expected + 1, ":: ", m2)
	-- TODO this is probably sensitive to user-defined keybindings?
	vim.api.nvim_input("<Esc>jj")
	-- window_manager.draw()
end


gameloop.is_state = function(state_enum)
	return state == state_enum
end


gameloop.change_state = function(new_state)
	state = new_state
end


return gameloop

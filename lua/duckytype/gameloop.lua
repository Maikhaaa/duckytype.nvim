local Gameloop = {}

local settings = require'duckytype.settings'
local methods = require'duckytype.methods'
local language_manager = require'duckytype.langauge_manager'

local States = {
	start = 0,
	typing = 2,
	summary = 3
}
local state = States.Start

local window

local start_time
local finish_time

Gameloop.new_game = function()
	local buffer = methods.get_buffer()
	if buffer == nil then
		error('missing buffer')
	end
	if window == nil then
		error('missing window')
	end

	Gameloop.change_state(States.start)

	language_manager.generate_vocabulary()
	language_manager.get_vocabulary()
	-- insert whatever was still remaining (it did not meet the line_width wrap)
	local line = string.format("%s ", table.concat(line, " "))
	table.insert(expected, line_text)

	-- remove the last trailing space from expected lines
	local lastline = expected[#expected]
	expected[#expected] = lastline:sub(1, #lastline - 1)

	-- pad the current buffer with some empty strings, so the virtual text
	-- highlighting shows. and +3 more just for good measure.
	local empty = { "", "", "" }
	for _, _ in ipairs(expected) do
		table.insert(empty, "")
	end
	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {'yo', 'mama'})

	-- TODO proper timing, starts on first keystroke instead of when window shows
	start_time = os.time()
	finish_time = nil
end


Gameloop.start = function()
	local buffer = vim.api.nvim_create_buf(false, true)
	methods.set_buffer(buffer)
	window = vim.api.nvim_open_win(buffer, true, settings.window_config)
	if settings.centered then
		local columns = (vim.api.nvim_get_option("columns") - settings.window_config.width) / 2 local rows = (vim.api.nvim_get_option("lines") - settings.window_config.height) / 2
		settings.window_config.col = columns
		settings.window_config.row = rows
	end
	-- silly keymap to re-start a NewGame
	-- local command = ''

	-- vim.api.nvim_buf_set_keymap(buffer, 'n', [[<CR>]], command, { noremap = true, silent = true,
	--})
	--vim.api.nvim_buf_set_keymap(buffer, 'i', [[<CR>]], [[<Space>]], {
	--	noremap = true, silent = true,
	--})

	Gameloop.NewGame()
	-- local events = {}
	vim.api.nvim_buf_attach(buffer, false, {
		on_lines = function()
			--[[
			TODO parse changes here instead so we don't re-fill the entire buffer
			on every single keystroke. check `nvim_buf_attach` documentation
			]]

			local done = methods.draw_buffer()
			if done then
				Gameloop.summarize()
			end
		end
	})
	-- TODO fix the entire mess, currently the virtual text is redrawn in
	-- full every keystroke, and things that result in a new newline are hardwired
	-- to redraw just to not have the virtual text shuffle back and forth

	methods.draw_buffer()
	vim.cmd('startinsert')
end


Gameloop.summarize = function()
	if finish_time == nil then
		finish_time = os.time()
	end
	local elapsed_time = finish_time - start_time
	local total = 0

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
	methods.draw_buffer()
end


Gameloop.is_state = function(state_enum)
	return state == state_enum
end


Gameloop.change_state = function(new_state)
	state = new_state
end


return Gameloop

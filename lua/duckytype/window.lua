local settings = require'duckytype.settings'
local buffer
local window
local namespace = vim.api.nvim_create_namespace('typing_game')
local target_text = "what's the meaning of life?"

local window_manager = {}


local function check_typing_progress()
	local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	local user_input = table.concat(lines, "")
	if user_input == target_text then
		return true
	end
	return false
end


local function highlight_typing()
	local highlight = settings.highlight

	local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	local user_input = table.concat(lines, "")

	for i = 1, #user_input do
		local user_letter = user_input:sub(i, i)
		local target_letter = target_text:sub(i, i)
		local hl_group = (user_letter == target_letter) and highlight.good  or highlight.bad
		vim.api.nvim_buf_add_highlight(buffer, -1, hl_group, 0, i - 1, i)
	end
end


window_manager.update = function()
	local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	local user_text = table.concat(lines, '')
	local text = target_text:sub(#user_text + 1)

	vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)
	vim.api.nvim_buf_set_extmark(buffer, namespace, 0, #user_text, {
		virt_text = {{text, settings.highlight.remaining}}, -- Light gray text
		virt_text_pos = "overlay" -- Show over the text
	})

	highlight_typing()

	if check_typing_progress() then
		vim.notify('You typed correctly!', vim.log.levels.INFO)
		--vim.api.nvim_buf_delete(buffer, { force = true })
		vim.api.nvim_input("<Esc>")
		vim.api.nvim_set_option_value("modifiable", false, {buf = buffer})

		buffer = nil
	end
end


window_manager.create_window = function()
	if buffer ~= nil then
		error('window already created... stupid')
		return
	end

	buffer = vim.api.nvim_create_buf(false, true)

--------local events = {}
--------vim.api.nvim_buf_attach(buffer, false, {
--------	on_lines = function(...)
--------		table.insert(events, {...})
--------		local content = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
--------		print(content)
--------	end
--------})

	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {''})
    	vim.api.nvim_set_option_value("buftype", '', {buf = buffer})
    	vim.api.nvim_set_option_value("modifiable", true, {buf = buffer})

    	vim.api.nvim_create_autocmd("TextChangedI", {
        	buffer = buffer,
        	callback = window_manager.update
    	})

	if settings.centered then
		local columns = (vim.api.nvim_get_option("columns") - settings.window_config.width) / 2
		local rows = (vim.api.nvim_get_option("lines") - settings.window_config.height) / 2
		settings.window_config.col = columns
		settings.window_config.row = rows
	end

	window = vim.api.nvim_open_win(buffer, true, settings.window_config)
	vim.cmd('startinsert')
end

return window_manager

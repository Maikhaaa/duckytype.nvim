local settings = require'duckytype.settings'
local buffer

local window = {
	window = nil
}

window.draw = function(vocabulary)
	if window.window == nil then
		error('No window found')
	end

	local done = true
	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {table.concat(vocabulary, ' ')})
	--error(vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
	local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

	error(lines)
	for index = 1, #vocabulary do
		local line = lines[index]
		local prefix = vocabulary[index]

		--local okay = methods.highlight_line(index - 1, line, prefix)
		--done = done and okay

		local cursor = vim.api.nvim_win_get_cursor(window.window)
		local row = cursor[1]
		if done and row == index then
			-- jump to next line if current line is okay
			vim.api.nvim_input('<Esc>jI')
			-- TODO (?)
			-- vim.api.nvim_win_set_cursor(window, { row + 1, 0 })
		end
	end
end

window.create_window = function()
	buffer = vim.api.nvim_create_buf(false, true)

	local events = {}
	vim.api.nvim_buf_attach(buffer, false, {
		on_lines = function(...)
			table.insert(events, {...})
			local content = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
			print(content)
		end
	})

	--[[
	if settings.centered then
		local columns = (vim.api.nvim_get_option("columns") - settings.window_config.width) / 2
		local rows = (vim.api.nvim_get_option("lines") - settings.window_config.height) / 2
		settings.window_config.col = columns
		settings.window_config.row = rows
	end
	]]

	window.window = vim.api.nvim_open_win(buffer, true, settings.window_config)
end


window.get_buffer = function()
	return buffer
end


return window

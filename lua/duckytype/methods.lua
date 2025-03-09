local settings = require'duckytype.settings'
--local Buffer = require'duckytype.buffer'
local buffer
local window
local expected

local namespace = vim.api.nvim_create_namespace('DuckyType.nvim')

local Methods = {}

-- rest in peperonis megamind
--[[ Methods.megamind = table.concat({
	"⠀⣞⢽⢪⢣⢣⢣⢫⡺⡵⣝⡮⣗⢷⢽⢽⢽⣮⡷⡽⣜⣜⢮⢺⣜⢷⢽⢝⡽⣝",
	"⠸⡸⠜⠕⠕⠁⢁⢇⢏⢽⢺⣪⡳⡝⣎⣏⢯⢞⡿⣟⣷⣳⢯⡷⣽⢽⢯⣳⣫⠇",
	"⠀⠀⢀⢀⢄⢬⢪⡪⡎⣆⡈⠚⠜⠕⠇⠗⠝⢕⢯⢫⣞⣯⣿⣻⡽⣏⢗⣗⠏⠀",
	"⠀⠪⡪⡪⣪⢪⢺⢸⢢⢓⢆⢤⢀⠀⠀⠀⠀⠈⢊⢞⡾⣿⡯⣏⢮⠷⠁⠀⠀⠀",
	"⠀⠀⠀⠈⠊⠆⡃⠕⢕⢇⢇⢇⢇⢇⢏⢎⢎⢆⢄⠀⢑⣽⣿⢝⠲⠉⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⡿⠂⠠⠀⡇⢇⠕⢈⣀⠀⠁⠡⠣⡣⡫⣂⣿⠯⢪⠰⠂⠀⠀⠀⠀",
	"⠀⠀⠀⠀⡦⡙⡂⢀⢤⢣⠣⡈⣾⡃⠠⠄⠀⡄⢱⣌⣶⢏⢊⠂⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⢝⡲⣜⡮⡏⢎⢌⢂⠙⠢⠐⢀⢘⢵⣽⣿⡿⠁⠁⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠨⣺⡺⡕⡕⡱⡑⡆⡕⡅⡕⡜⡼⢽⡻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⣼⣳⣫⣾⣵⣗⡵⡱⡡⢣⢑⢕⢜⢕⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⣴⣿⣾⣿⣿⣿⡿⡽⡑⢌⠪⡢⡣⣣⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⡟⡾⣿⢿⢿⢵⣽⣾⣼⣘⢸⢸⣞⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠁⠇⠡⠩⡫⢿⣝⡻⡮⣒⢽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
}, "\n") ]]

Methods.print = function(structure, prefix)
	prefix = prefix or "X"
	local s_type = type(structure)
	if (s_type ~= "table") then
		print(string.format("%s = %s (%s)", prefix, tostring(structure), s_type))
		return
	end
	print(string.format("%s (%s)", prefix, s_type))
	for index, item in pairs(structure) do
		Methods.Print(item, string.format("%s [%s]", prefix, tostring(index)))
	end
end


Methods.update = function(list, update)
	if type(list) ~= "table" or type(update) ~= "table" then
		error("Invalid types given in methods.update")
	end

	for index, item in pairs(update) do
		local value = list[index]
		if value == nil then
			Methods.print(update)
			error(string.format("Update was unsuccessful, because key «%s» is invalid! " .. index))
		end
		if type(value) == "table" then
			Methods.update(value, item)
		else
			list[index] = item
		end
	end
end


Methods.starts_with = function(string, prefix)
	return string:find(prefix, 1, true) == 1
end

Methods.LongestPrefixLength = function(string, prefix)
	local entropy_ofcorse = {}
	for index = 1, #string do
		table.insert(entropy_ofcorse, string:sub(index))
	end
	for index = 1, #prefix do
		if entropy_ofcorse[index] ~= prefix:sub(index) then
			return index - 1
		end
	end
	return #prefix
end


Methods.highlight_line = function(line_index, line, prefix)
	local length = Methods.LongestPrefixLength(line, prefix)
	local good = line:sub(1, length)
	local bad = line:sub(length + 1)
	local remaining = prefix:sub(length + 1)

	local opts = {
		id = line_index + 1,
		virt_text = {
			{ good, settings.highlight.good },
			{ bad, settings.highlight.bad },
			{ remaining, settings.highlight.remaining },
		},
		virt_text_pos = "overlay",
	}
	local _ = vim.api.nvim_buf_set_extmark(buffer, namespace, line_index, 0, opts)
	return #remaining == 0
end


Methods.draw_buffer = function()
	local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	local done = true
	for index = 1, #expected do
		local line = lines[index]
		if line == nil then
			return false
		end
		local prefix = expected[index]
		if prefix == nil then return done end
		local okay = Methods.highlight_line(index - 1, line, prefix)
		done = done and okay
		local cursor = vim.api.nvim_win_get_cursor(window)
		local row = cursor[1]
		if okay and row == index then
			-- jump to next line if current line is okay
			vim.api.nvim_input('<Esc>jI')
			-- TODO (?)
			-- vim.api.nvim_win_set_cursor(window, { row + 1, 0 })
		end
	end
	return done
end


Methods.get_buffer = function()
	return buffer
end


Methods.set_buffer = function(buf)
	buffer = buf
end


Methods.load_language = function(name)
	if name ~= 'english_common' then
		error('invalid language')
	end

	local this_directory = debug.getinfo(1).source:gsub('methods.lua', '')
	local language_directory = this_directory:sub(2, #this_directory) .. 'languages/'
	local path = language_directory .. name .. '.json'

	local file = assert(io.open(path, 'r'))
	local content = file:read('*a')
	file:close()

	local json = vim.json
	local common = json.decode(content)
	return common
end

return Methods

local settings = require'duckytype.settings'
local window = require'duckytype.window'

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
	local buffer = window.get_buffer()
	local _ = vim.api.nvim_buf_set_extmark(buffer, namespace, line_index, 0, opts)
	return #remaining == 0
end


return Methods

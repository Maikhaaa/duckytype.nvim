local settings = require'duckytype.settings'

local language_manager = {}
local vocabulary = {} 

language_manager.load_language = function(name)
	if name ~= 'english_common' then
		error('invalid language')
	end

	local this_directory = debug.getinfo(1).source:gsub('language_manager.lua', '')
	local language_directory = this_directory:sub(2, #this_directory) .. 'languages/'
	local path = language_directory .. name .. '.json'

	local file = assert(io.open(path, 'r'))
	local content = file:read('*a')
	file:close()

	local json = vim.json
	local common = json.decode(content)
	return common
end


language_manager.generate_challange = function()
	local name = 'english_common'
	local lookup_table = language_manager.load_language(name)

	for _ = 1, settings.number_of_words do
		local random_number = math.ceil(math.random() * #lookup_table)
		local word = lookup_table[random_number]
		table.insert(vocabulary, word)
	end
end


language_manager.get_vocabulary = function()
	return vocabulary
end


return language_manager

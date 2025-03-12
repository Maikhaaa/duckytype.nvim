local settings = require'duckytype.settings'

local language = {}
local vocabulary = {}

local available_languages = {}

language.load_language = function(name)
	available_languages['english_common'] = true
	available_languages['russian_common'] = true
	available_languages['polish_common'] = true

	if not available_languages[name] then
		error('invalid language')
	end

	local this_directory = debug.getinfo(1).source:gsub('language.lua', '')
	local language_directory = this_directory:sub(2, #this_directory) .. 'languages/'
	local path = language_directory .. name .. '.json'

	local file = assert(io.open(path, 'r'))
	local content = file:read('*a')
	file:close()

	local json = vim.json
	local common = json.decode(content)
	return common
end


language.generate_vocabulary = function()
	local name = 'russian_common'
	local lookup_table = language.load_language(name)

	for _ = 1, settings.number_of_words do
		local random_number = math.ceil(math.random() * #lookup_table)
		local word = lookup_table[random_number]
		table.insert(vocabulary, word)
	end
	return vocabulary
end


language.get_vocabulary = function()
	return vocabulary
end


return language

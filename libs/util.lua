local escape_translations = { -- https://www.php.net/manual/en/function.htmlspecialchars.php
	["&"] 	= "&amp;",
	["\""] 	= "&quot;",
	["'"] 	= "&apos;",
	["<"] 	= "&lt;",
	[">"] 	= "&gt;"
}

local escape_translations_str = require("string.buffer").new()
	escape_translations_str:put("[")
	for k in pairs(escape_translations) do
		escape_translations_str:put(k)
	end
	escape_translations_str:put("]")
escape_translations_str = escape_translations_str:get()

return function(luaTemplate)
	luaTemplate.util = {}

	function luaTemplate.util.escape(str) -- prevent XSS
		str:gsub(escape_translations_str, escape_translations)
	end
end
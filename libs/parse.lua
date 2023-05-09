local fs = require("coro-fs")
require("coro-fs-extend")(fs)

local function parse_includes(self, code)
	local contents = {}
	for path in code:gmatch("<include>(.-)</include>") do
		local succ, result = self:eval(path) -- if src includes <lua></lua> or ${}

		if succ then
			if fs.exists(result) then
				contents[path] = fs.readFile(result)
			else
				if self.debug then p("<include> file doesnt exists", result) end
				contents[path] = "<include> file \"".. result .."\" doesnt exists"
			end
		else
			contents[path] = "<include> parse error \"".. path .."\" ".. result
		end
	end

	return code:gsub("<include>(.-)</include>", contents)
end

local parser = require("./src/parser")

return function(luaTemplate)
	function luaTemplate:parse(code)
		code = parse_includes(self, code)
		return parser(code)
	end
end

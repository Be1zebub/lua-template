local stdout = require("string.buffer").new()
local fs = require("coro-fs")
require("coro-fs-extend")(fs)

local function parse(data, raw_cback)
	local prev_f = 1

	if data.code:find(data.tag_open, prev_f, true) == nil then
		raw_cback(data.code)
		return
	end

	while true do
		local tag_start, tag_end = data.code:find(data.tag_open, prev_f, true)
		if tag_start == nil then break end

		if tag_start > prev_f then
			raw_cback(data.code:sub(prev_f, tag_start - 1))
		end

		local close_f, close_t = data.code:find(data.tag_close, tag_end + 1, true)
		assert(close_f, data.assert_error:format(tag_end))

		local code2 = data.code:sub(tag_end + 1, close_f - 1)
		stdout:put(data.format and data.format:format(code2) or code2)
		prev_f = close_t + 1
	end

	if prev_f <= #data.code then
		stdout:put(data.raw2code:format(
			data.code:sub(prev_f)
		))
	end
end

local function format_print(code)
	local delim_open, delim_close

	for i = 0, 31 do
		local delim = string.rep("=", i)
		delim_open 	= "[" .. delim .. "["
		delim_close = "]" .. delim .. "]"

		if (code:find(delim_open, 1, true) and code:find(delim_close, 1, true)) == nil then break end
	end

	return "print(".. delim_open .."%s".. delim_close ..");"
end

local echo_open, echo_close = "${", "}"

--[[
local function lua_gsub(str, pattern, replacement, maxReplaces)
	maxReplaces = maxReplaces or #str + 1
	local start = 1

	for _ = 1, maxReplaces do
		local find_start, find_end = str:find(pattern, start)
		if find_start == nil then break end

		local found = str:sub(find_start, find_end)

		str = str:sub(1, find_start - 1) .. (
			type(replacement) ~= "function" and replacement or replacement(found:match(pattern)) -- table unimplemented yet
		) .. str:sub(find_end + 1)
		start = find_end + 1
	end

	return str
end
]]--

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
--[[
	code = lua_gsub(code, "<include src=\"(.-)\">(.-)</include>", function(path, inner) -- string.gsub callback doesnt works with coroutines
		local succ
		succ, path = self:eval(path, getfenv(0)) -- if src includes <lua></lua> or ${}

		if succ == false then
			return "<include> src parse error \"".. path .."\""
		end

		if fs.exists(path) == false then
			if self.debug then p("doesnt exists", path) end
			return "<include> src file \"".. path .."\" doesnt exists"
		end

		return fs.readFile(path):format(inner)
	end)
]]--
end

return function(luaTemplate)
	function luaTemplate:parse(code, tag_open, tag_close)
		tag_open 	= tag_open or "<lua>"
		tag_close 	= tag_close or "</lua>"

		code = parse_includes(self, code)
		code = code:gsub("<!%-%-.-%-%->", ""):gsub("/%*.-%*/", "") -- strip comments
		local raw2code = format_print(code)

		parse({
			code 			= code,
			raw2code 		= raw2code,
			tag_open 		= tag_open,
			tag_close 		= tag_close,
			format 			= nil,
			assert_error 	= "Syntax error: %s closing tag '".. tag_close .."' expected after '".. tag_open .."'",
		}, function(raw)
			parse({
				code 			= raw,
				raw2code 		= raw2code,
				tag_open 		= echo_open,
				tag_close 		= echo_close,
				format 			= "print(%s);",
				assert_error 	= "Syntax error: %s closing string interpolation '".. echo_close .."' expected after '".. echo_open .."'",
			}, function(raw2)
				stdout:put(raw2code:format(raw2))
			end)
		end)

		code = stdout:get()
		stdout:free()

		return code
	end
end

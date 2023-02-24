local buff = require("string.buffer").new()

return function(luaTemplate)
	function luaTemplate:parse(code, stdout, tag_open, tag_close)
		tag_open 	= tag_open or "<lua>"
		tag_close 	= tag_close or "</lua>"

		local delim_open, delim_close
		for i = 0, 31 do
			local delim = string.rep("=", i)
			delim_open 	= "[" .. delim .. "["
			delim_close = "]" .. delim .. "]"

			if (code:find(delim_open, 1, true) and code:find(delim_close, 1, true)) == nil then break end
		end
		local raw2code = (stdout or "print") .."(".. delim_open .."%s".. delim_close ..");"

		local prev_f = 1
		while true do
			local tag_start, tag_end = code:find(tag_open, prev_f, true)
			if tag_start == nil then break end

			if tag_start > prev_f then
				buff:put(raw2code:format(
					code:sub(prev_f, tag_start - 1)
				))
			end

			local close_f, close_t = code:find(tag_close, tag_end + 1, true)
			assert(close_f, "Syntax error:".. tag_end .." closing tag '".. tag_close .."'' expected after '".. tag_open .."'")

			buff:put(code:sub(tag_end + 1, close_f - 1))
			prev_f = close_t + 1
		end

		local tail_f = prev_f
		if tail_f <= code:len() then
			buff:put(raw2code:format(
				code:sub(tail_f)
			))
		end

		code = buff:get()
		buff:free()

		return code
	end
end
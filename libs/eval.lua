local stdout_buff = require("string.buffer").new() -- get-lit is a bit deprecated, you can get latest release here: https://github.com/truemedian/luvit-bin
local function print_buffer(...)
	local data = {...}
	if #data == 1 then
		stdout_buff:put(data[1])
		return
	end

	for i = 1, #data - 1 do
		stdout_buff:put(data[i])
		stdout_buff:put("\t")
	end

	stdout_buff:put(data[#data])
end

return function(luaTemplate)
	function luaTemplate:compile(code, env, tag_open, tag_close)
		setmetatable(env or {}, {__index = _G})
		env.print = print_buffer
		env.require = require
		env.luaTemplate = self

		code = self:parse(code, tag_open, tag_close)
		local fn, syntaxError = load(code, "luaTemplate", "t", env)
		if not fn then return false, syntaxError end

		return fn
	end

	function luaTemplate:eval(code, env, tag_open, tag_close)
		stdout_buff:free()

		if type(code) == "string" then
			local fn, syntaxError = self:compile(code, env, tag_open, tag_close)
			if not fn then return false, syntaxError end

			code = fn
		end

		local success, runtimeError = pcall(code)
		if not success then return false, runtimeError end

		return true, stdout_buff:get()
	end
end
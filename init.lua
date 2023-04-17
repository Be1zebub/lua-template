-- string buffer support required! you can get latest luvit build here: https://github.com/truemedian/luvit-bin

local luaTemplate = {
	version = 1.0,
	license = "GNU GPL 3",
	source = "https://github.com/Be1zebub/lua-template"
}

require("util")(luaTemplate)
require("parse")(luaTemplate)
require("cache")(luaTemplate)
require("eval")(luaTemplate)
require("include")(luaTemplate)

function luaTemplate:load(code, uid, ttl, env, tag_open, tag_close)
	return self:eval(
		self:cache(code, uid, ttl, env, tag_open, tag_close),
		env, tag_open, tag_close
	)
end

setmetatable(luaTemplate, {
	__call = function(_, code, uid, ttl, env, tag_open, tag_close)
		luaTemplate:load(code, uid, ttl, env, tag_open, tag_close)
	end
})

function luaTemplate:weblit(path, ttl, env, tag_open, tag_close)
	return function(request, response)
		env.request = request
		env.response = response

		local succ, stdout = self:include(path, ttl, env, tag_open, tag_close)

		if succ then
			response.code = 200
			response.body = stdout
		else
			response.code = 500
			response.body = "Internal Server Error"

			p("Weblit template `".. path .."` error!", stdout)
		end
	end
end

return luaTemplate
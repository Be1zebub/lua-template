-- from incredible-gmod.ru with <3

-- string buffer support required!
-- you can get luvit build with latest luajit here: https://github.com/truemedian/luvit-bin

local luaTemplate = {
	version = 1.0,
	license = "GNU GPL 3",
	source = "https://github.com/Be1zebub/lua-template"
}

require("parse")(luaTemplate)
require("cache")(luaTemplate)
require("eval")(luaTemplate)
require("include")(luaTemplate)
require("weblit")(luaTemplate)

function luaTemplate:load(code, uid, ttl, env)
	return self:eval(
		self:cache(code, uid, ttl, env),
		env, tag_open, tag_close
	)
end

setmetatable(luaTemplate, {
	__call = function(_, code, uid, ttl, env)
		luaTemplate:load(code, uid, ttl, env)
	end
})

return luaTemplate
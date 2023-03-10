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

return luaTemplate
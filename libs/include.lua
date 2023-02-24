local fs = require("coro-fs")
require("coro-fs-extend")(fs)

return function(luaTemplate)
	function luaTemplate:include(path, ttl, env)
		local cache = self:getCache(path)
		if cache then return self:eval(cache, env) end

		if fs.exists(path) == false then return false, "file doesnt exists" end
		return self:load(fs.readFile(path), path, ttl, env)
	end
end
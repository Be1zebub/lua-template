local fs = require("coro-fs")
require("coro-fs-extend")(fs)

return function(luaTemplate)
	function luaTemplate:include(path, ttl, env)
		local cache = self:getCache(path)
		if cache then
			if self.debug then p("eval from cache", path) end
			return self:eval(cache, env)
		end

		if fs.exists(path) == false then
			if self.debug then p("doesnt exists", path) end
			return false, "file doesnt exists"
		end
		if self.debug then p("refresh cache", path) end
		return self:load(fs.readFile(path), path, ttl, env)
	end
end
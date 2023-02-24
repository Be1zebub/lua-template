local cache = {}
local time = require("uv").uptime

return function(luaTemplate)
	function luaTemplate:getCache(uid)
		if uid == nil then return cache end

		if cache[uid] and cache[uid].aliveUntil > time() then
			return cache[uid].func
		end
	end

	function luaTemplate:cache(code, uid, ttl, env)
		if uid == nil then
			uid = debug.traceback()
		end

		local compiled = self:getCache(uid)
		if compiled then return compiled end

		compiled = self:compile(code, env)
		cache[uid] = {
			func = compiled,
			aliveUntil = time() + (ttl or 10)
		}

		return compiled
	end
end
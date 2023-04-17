local cache = {}
local time = require("uv").uptime

return function(luaTemplate)
	function luaTemplate:getCache(uid)
		if uid == nil then return cache end

		if cache[uid] and cache[uid].aliveUntil > time() then
			return cache[uid].func
		end
	end

	function luaTemplate:cache(code, uid, ttl, env, tag_open, tag_close)
		local shouldCache = ttl and ttl > 0

		if shouldCache then
			if uid == nil then
				uid = debug.traceback()
			end

			local compiled = self:getCache(uid)
			if compiled then return compiled end
		end

		compiled = self:compile(code, env, tag_open, tag_close)

		if shouldCache then
			cache[uid] = {
				func = compiled,
				aliveUntil = time() + (ttl or 10)
			}
		end

		return compiled
	end
end
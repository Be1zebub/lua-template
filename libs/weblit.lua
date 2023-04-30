-- read file, compile, repeat on fs change event
-- return callback for weblit listener

--[[ example:
	app.route({
		method = "GET",
		path = "/"
	}, require("lua-template"):weblit("views/index.html", {app = app}))
]]--

local uv = require("uv")
local fs = require("coro-fs")
require("coro-fs-extend")(fs)

return function(luaTemplate)
	function luaTemplate:weblit(path, env, tag_open, tag_close)
		if fs.exists(path) == false then
			p("luaTemplate:weblit", path, "doesnt exists")

			return function(_, response)
				response.code = 404
				response.body = "luaTemplate file doesnt exists"
			end
		end

		env = env or {}

		local run
		local function recompile()
			run = self:compile(fs.readFile(path), env, tag_open, tag_close)
		end
		recompile()

		local watcher = assert(uv.new_fs_event())
		local success, err = watcher:start(path, {}, function(err, _, event)
			if err == nil and event and event.change then
				coroutine.wrap(recompile)()
			end
		end)

		if not success then
			p(path, "fs watcher:start error", err)
		end

		return function(request, response)
			env.request = request
			env.response = response

			local succ, result = self:eval(run)

			if succ then
				response.code = 200
				response.body = result
			else
				response.code = 500
				response.body = "Internal Server Error"

				p("Weblit template `".. path .."` error!", result)
			end
		end
	end
end
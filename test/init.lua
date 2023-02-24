local luaTemplate = require("lua-template")
local relative = require("relative")

require("http").createServer(function (req, res)
	coroutine.wrap(function()
		local succ, stdout = luaTemplate:include(relative("index.html"), 10, {
			req = req,
			res = res
		})

		if succ then
			res:setHeader("Content-Type", "text/html")
			res:setHeader("Content-Length", #stdout)
			res:finish(stdout)
		elseif luaTemplate.onError then
			luaTemplate:onError(stdout)
		else
			error(stdout)
		end
	end)()
end):listen(5535, "127.0.0.1")

print("Test server running at http://127.0.0.1:5535/")

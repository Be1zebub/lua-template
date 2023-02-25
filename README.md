# lua-template
php style html+lua inline templater for luvit

# usage
```lua
local luaTemplate = require("lua-template")

local succ, stdout = luaTemplate:include("index.html", 10, { -- file-path, cache-ttl, environment-table
	req = req,
	res = res
})
```
```html
<lua>
	function Hex(r, g, b)
		return string.format("#%x", (r * 0x10000) + (g * 0x100) + b):upper()
	end
</lua>
<html>
<head>
	<style type="text/css">
		h1 {
			color: <lua>
				print(Hex(44, 62, 80))
			</lua>
		}

		.user {
			display: table;
		}

		.avatar {
			width: 96px;
			height: 96px;
			border-radius: 50%;
		}

		.user > span {
			display: table-cell;
			vertical-align: middle;
		}

		.name {
			font-size: 24px;
		}
	</style>
</head>
<body>
	<h1>Current time: <lua> print(os.time()) </lua></h1>

	<lua>
		local users = {
			{id = 1, name = "Beelzebub", avatar = "https://avatars.githubusercontent.com/u/34854689", admin = true},
			{id = 2, name = "John Doe", avatar = "https://i.imgur.com/gQMQB7e.jpeg"}
		}

		for i, user in ipairs(users) do
	</lua>
		<div class="user" id="user-<lua> print(user.id) </lua>">
			<img class="avatar" src="<lua> print(user.avatar) </lua>">
			<span class="name"><lua> print(user.name) </lua></span>
			<lua>
				if user.admin then
			</lua>
				<span> (admin)</span>
			<lua>
				end
			</lua>
		</div>
	<lua>
		end
	</lua>
</body>
</html>
```

# notes
string buffer support required!
you can get latest luvit build here: https://github.com/truemedian/luvit-bin
 
dont like `<lua> ... </lua>` xml tag style? 
you can pass `"<?lua"` in `tag_open` & `?>` in `tag_close` arguments

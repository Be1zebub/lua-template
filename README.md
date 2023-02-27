# lua-template
php style html+lua inline templater for luvit

# usage
```lua
local luaTemplate = require("lua-template")

local succ, stdout = luaTemplate:include("index.html", 10, { -- file-path, cache-ttl, environment-table
	req = req,
	res = res
})

res:setHeader("Content-Type", "text/html")
res:setHeader("Content-Length", #stdout)
res:finish(stdout)
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
			color: ${ Hex(22, 160, 133) };
		}

		.user {
			display: table;
			margin-top: 16px;
		}

		.avatar {
			width: 96px;
			height: 96px;
			border-radius: 50%;
		}

		.user > span {
			display: table-cell;
			vertical-align: middle;
			white-space: pre;
		}

		.name {
			font-size: 24px;
		}

		.admin {
			color: #c0392b;
		}
	</style>
</head>
<body>
	<h1>Current time: ${os.time()}</h1>

	<lua>
		local users = {
			{id = 1, name = "Beelzebub", avatar = "https://avatars.githubusercontent.com/u/34854689", admin = true},
			{id = 2, name = "John Doe", avatar = "https://i.imgur.com/gQMQB7e.jpeg"}
		}

		for i, user in ipairs(users) do
	</lua>
		<div class="user" id="user-${user.id}">
			<img class="avatar" src="${user.avatar}">
			<span class="name"> ${user.name}</span>
			<lua>
				if user.admin then
			</lua>
				<span class="admin"> (admin)</span>
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
![image](https://user-images.githubusercontent.com/34854689/221267968-61452ddc-7f4d-476a-af30-0ca8346c215b.png)
# notes
string buffer support required!
you can get latest luvit build here: https://github.com/truemedian/luvit-bin
 
dont like `<lua> ... </lua>` xml tag style? 
you can pass `"<?lua"` in `tag_open` & `?>` in `tag_close` arguments
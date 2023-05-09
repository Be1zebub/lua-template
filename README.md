# lua-template
php style html+lua inline templater for luvit
deps: jit `string.buffer`, luvit `uv` (used in `:weblit` for fs watch), luvit `coro-fs` (used in `:include` & `:weblit`)

# usage
```lua
-- /init.lua
local app = require("weblit-app")

app.bind({
	host = "127.0.0.1",
	port = 80
})

app.route({
		method = "GET",
		path = "/"
	}, require("lua-template"):weblit("views/index.html", {app = app}))

app.start()
```
```html
<!-- /views/index.html -->

<?lua <!-- lua codeblock -->
	function Hex(r, g, b)
		return string.format("#%x", (r * 0x10000) + (g * 0x100) + b):upper()
	end
?>
<html>
<head>
	<style type="text/css">
		h1 {
			color: ${ Hex(22, 160, 133) }; <!-- echo codeblock -->
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

	<?lua
		local users = {
			{id = 1, name = "Beelzebub", avatar = "https://avatars.githubusercontent.com/u/34854689", admin = true},
			{id = 2, name = "John Doe", avatar = "https://i.imgur.com/gQMQB7e.jpeg"}
		}

		for i, user in ipairs(users) do
	?>
		<div class="user" id="user-${user.id}">
			<img class="avatar" src="${user.avatar}">
			<span class="name"> ${user.name}</span>
			<?lua
				if user.admin then
			?>
				<span class="admin"> (admin)</span>
			<?lua
				end
			?>
		</div>
	<?lua
		end
	?>
</body>
</html>
```
![Preview](https://user-images.githubusercontent.com/34854689/221614096-5cbb3d1c-e70a-46d3-81a8-76e48e1fa1a7.png)
![DOM Preview](https://user-images.githubusercontent.com/34854689/221614401-37bcf860-554f-466c-a7a0-abf5d3da3407.png)

# notes
string buffer support required! 
to got string buffer support, you can get latest luvit build here: https://github.com/truemedian/luvit-bin
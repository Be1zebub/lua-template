local parser = setmetatable({}, {
	__call = function(self, code)
		return self:parse(code)
	end
})

function parser:parse(code)
	code = code:gsub("<!%-%-.-%-%->", ""):gsub("/%*.-%*/", "") -- strip comments

	self:commit(code, self:parseTags(code))

	return self:pull()
end

do
	local stdout = require("string.buffer").new()

	local put_type = {
		[0] = function(content, raw2code) -- plain
			stdout:put(
				raw2code:format(content)
			)
		end,
		[1] = function(content) -- <lua></lua>
			stdout:put(content)
		end,
		[2] = function(content) -- ${}
			stdout:put(
				("print(%s);"):format(content)
			)
		end,
	}

	function parser:commit(code, tags)
		local raw2code = self:formatPrint(code)

		for i = 1, #tags do
			local data = tags[i]
			put_type[data.type](data.content, raw2code)
		end
	end

	function parser:pull()
		local compiled = stdout:get()
		stdout:reset()

		return compiled
	end
end

function parser:formatPrint(code)
	local delim_open, delim_close

	for i = 0, 31 do
		local delim = string.rep("=", i)
		delim_open 	= "[" .. delim .. "["
		delim_close = "]" .. delim .. "]"

		if (code:find(delim_open, 1, true) and code:find(delim_close, 1, true)) == nil then break end
	end

	return "print(".. delim_open .."%s".. delim_close ..");"
end

do
	local function find_tag(code, cursor, tag)
		local tag_open, tag_open_end = code:find(tag.open, cursor, true)
		if tag_open == nil then return end

		local tag_close, tag_close_end = code:find(tag.close, tag_open_end + 1, true)
		assert(tag_close, "Syntax error: %s closing tag '".. tag.close .."' expected after '".. tag.open .."'")

		return {
			type = tag.type,
			content = code:sub(tag_open_end + 1, tag_close - 1),
			len = tag_close_end - tag_open,
			bounds = {
				tag_open,
				tag_close_end
			}
		}, tag_close_end + 1
	end

	local function parse_tag(code, tags, tag)
		local cursor = 1

		while true do
			local data, new_cursor = find_tag(code, cursor, tag)
			if data == nil then break end

			tags[#tags + 1] = data
			cursor = new_cursor
		end
	end

	local function commit_plain(code, tags, cursor)
		if cursor[1] > #code or cursor[2] <= cursor[1] then return end

		tags[#tags + 1] = {
			type = 0,
			content = code:sub(cursor[1], cursor[2]),
			len = cursor[2] - cursor[1],
			bounds = {
				cursor[1],
				cursor[2]
			}
		}
	end

	function parser:parseTags(code)
		local tags = {}

		parse_tag(code, tags, {
			open = "<?lua",
			close = "?>",
			type = 1
		})

		parse_tag(code, tags, {
			open = "${",
			close = "}",
			type = 2
		})

		table.sort(tags, function(a, b)
			return a.bounds[1] < b.bounds[1]
		end)

		local cursor = 1
		for i = 1, #tags do
			local tag = tags[i]

			commit_plain(code, tags, {
				cursor, tag.bounds[1] - 1
			})
			cursor = tag.bounds[2] + 1
		end

		commit_plain(code, tags, {
			cursor, #code
		})

		table.sort(tags, function(a, b)
			return a.bounds[1] < b.bounds[1]
		end)

	--[[
		for i, data in ipairs(tags) do
			p(i, data.type, ("%s-%s (%s)"):format(data.bounds[1], data.bounds[2], data.len))
			print(data.content)
		end
	]]--

		return tags
	end
end

return parser

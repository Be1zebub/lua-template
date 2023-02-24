return function(path)
	return debug.getinfo(2).source:match("@?(.*/)") .. path
end
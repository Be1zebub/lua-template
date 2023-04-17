local pathJoin = require("pathjoin").pathJoin

return function(fs)
	fs.exists = require("fs").existsSync
	fs.appendFile = require("fs").appendFileSync

	local fs_chroot = fs.chroot

	function fs.chroot(base)
		local chroot = fs_chroot(base)

		local function resolve(path)
			assert(path, "path missing")
			return pathJoin(base, pathJoin("./".. path))
		end

		function chroot.exists(path)
			return fs.exists(resolve(path))
		end

		function chroot.appendFile(path, data)
			fs.appendFile(resolve(path), data)
		end

		return chroot
	end
end
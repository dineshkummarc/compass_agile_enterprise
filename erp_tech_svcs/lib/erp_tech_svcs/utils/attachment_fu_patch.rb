#This patch is to make the attachment_fu plugin work on Windows
#It is not necessary for 'nix operating systems, though it is not known
#to cause problems
require 'tempfile'
	class Tempfile
		def size
			if @tmpfile
				@tmpfile.fsync # added this line
				@tmpfile.flush
				@tmpfile.stat.size
			else
				0
		end
	end
end
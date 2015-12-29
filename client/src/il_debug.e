note
	description: "Summary description for {IL_DEBUG}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_DEBUG

create
	make

feature -- Initialization

	make
		do
			debug_on := true
		end


feature -- Basic operation

	dprint (a_tag: STRING; message: STRING )
			-- Print message if debugging is active
		do
			if debug_on then
				print(Debug_tag + a_tag + message)
				io.put_new_line
			end
		end

	set_debug (mode: BOOLEAN)
			-- Set the debugging mode to `mode'
		do
			debug_on := mode
		end

feature -- Constants

	Dinfo: STRING = "INFO: "

	Dwarning: STRING = "WARNING: "

	Dreceiving: STRING = "RECEIVING: "

	Dsending: STRING = "SENDING: "


feature {NONE} -- Implementation

	debug_on: BOOLEAN

	Debug_tag: STRING = "	DEBUG: "

end

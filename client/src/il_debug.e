note
	description: "A debugger to format and display messages"
	author: "Basile Maret"

class
	IL_DEBUG

create
	make

feature {NONE} -- Initialization

	make
			-- Create the debugger with the default value
		do
			debug_on := true
		end

feature -- Basic operation

	debug_print (a_tag: STRING; message: STRING)
			-- Print message if debugging is active
		do
			if debug_on then
				print (Debug_tag + a_tag + message)
				io.put_new_line
			end
		end

	set_debug (mode: BOOLEAN)
			-- Set the debugging mode to `mode'
		do
			debug_on := mode
		ensure
			debug_on_set: debug_on = mode
		end

feature -- Constants

	Debug_info: STRING = "INFO: "

	Debug_warning: STRING = "WARNING: "

	Debug_receiving: STRING = "RECEIVING: "

	Debug_sending: STRING = "SENDING: "

feature {NONE} -- Implementation

	debug_on: BOOLEAN

	Debug_tag: STRING = "%TDEBUG: "

end

note
	description: "Summary description for {IL_CONSTANTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	IL_CONSTANTS

feature -- Constants

	Default_port: INTEGER = 142

	Default_ssl_port: INTEGER = 993

	Default_address: STRING = "localhost"


	Command_ok_label: STRING = "OK"
	Command_bad_label: STRING = "BAD"
	Command_no_label: STRING = "NO"


	Tag_prefix: STRING = "il"

	Debug_tag: STRING = "	DEBUG: "

	Next_response_tag: STRING = "NEXT_RESPONSE"

end
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


	Next_response_tag: STRING = "NEXT_RESPONSE"

	debugger: IL_DEBUG
		once
			create Result.make
		end

	Message_status: STRING = "MESSAGES"
	Recent_status: STRING = "RECENT"
	Uid_next_status: STRING = "UIDNEXT"
	Uid_validity_status: STRING = "UIDVALIDIY"
	Unseen_status: STRING = "UNSEEN"


end

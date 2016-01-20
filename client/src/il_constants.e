note
	description: "The constants used in the Eiffel IMAP library"
	author: "Basile Maret"

deferred class
	IL_CONSTANTS

feature -- Constants

	Default_port: INTEGER = 143
			-- The default port for IMAP

	Default_ssl_port: INTEGER = 993
			-- The default port for IMAP when using a ssl connection

	Default_address: STRING = "localhost"
			-- The default address

	Command_ok_label: STRING = "OK"
			-- The label for an OK server response
	Command_bad_label: STRING = "BAD"
			-- The label for a BAD server response
	Command_no_label: STRING = "NO"
			-- The label for a NO server response

	Tag_prefix: STRING = "il"
			-- The prefix of the tags

	Next_response_tag: STRING = "NEXT_RESPONSE"
			-- A temporary tag used to find the next response in the responses table

	debugger: IL_DEBUG
			-- The debugger to format and print messages
		once
			create Result.make
		end

	current_mailbox: IL_MAILBOX
			-- The current mailbox
		once
			create Result.make
		end

	Message_status: STRING = "MESSAGES"
	Recent_status: STRING = "RECENT"
	Uid_next_status: STRING = "UIDNEXT"
	Uid_validity_status: STRING = "UIDVALIDIY"
	Unseen_status: STRING = "UNSEEN"

	All_macro: STRING = "ALL"
			-- Macro equivalent to: (FLAGS INTERNALDATE RFC822.SIZE ENVELOPE)
	Fast_macro: STRING = "FAST"
			-- Macro equivalent to: (FLAGS INTERNALDATE RFC822.SIZE)
	Full_macro: STRING = "FULL"
			-- Macro equivalent to: (FLAGS INTERNALDATE RFC822.SIZE ENVELOPE BODY)

	Default_max_stored_responses: INTEGER = 100
			-- The default maximum number of responses we store in the response manager before we start to remove them

end

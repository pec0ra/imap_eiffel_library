note
	description: "A message"
	author: "Basile Maret"

class
	IL_MESSAGE

inherit
	IL_CONSTANTS

create
	make_from_fetch

feature {NONE} -- Initialization

	make_from_fetch (a_fetch: IL_FETCH)
			-- Create a message from `a_fetch'
		require
			a_fetch_not_void: a_fetch /= Void
		local
			parser: IL_MESSAGE_PARSER
		do
			create parser.make_from_fetch (a_fetch)
			uid := a_fetch.get_value (uid_data_item).to_integer
			header_text := a_fetch.get_value (header_data_item)
			body_text := a_fetch.get_value (text_data_item)
			body_size := a_fetch.get_size (text_data_item)
			size := a_fetch.get_value (size_data_item).to_integer
			flags := a_fetch.get_value (flags_data_item).split (' ')

			from_address := parser.get_from
			reply_to := parser.get_addresses_from_envelope (5)
			to_address := parser.get_addresses_from_envelope (6)
			cc := parser.get_addresses_from_envelope (7)
			bcc := parser.get_addresses_from_envelope (8)

			subject := parser.subject
			date := parser.date

			mailbox_name := current_mailbox.name

		end

feature -- Access

	mailbox_name: STRING
			-- The name of the mailbox in which the message is stored

	uid: INTEGER
			-- The uid of the message

	header_text: STRING
			-- The raw text of the header

	body_text: STRING
			-- The text of the body

	body_size: INTEGER
			-- The size of the body

	size: INTEGER
			-- The total size of the message

	flags: LIST [STRING]
			-- The flags of the message

	date: DATE_TIME
			-- The date of the message

	subject: STRING
			-- The subject of the message

	from_address: IL_ADDRESS
			-- The address the message comes from

	to_address: LIST [IL_ADDRESS]
			-- The addresses the message was sent to

	cc: LIST [IL_ADDRESS]
			-- The addresses of the cc field

	bcc: LIST [IL_ADDRESS]
			-- The addresses of the bcc field

	reply_to: LIST [IL_ADDRESS]
			-- The addresses of the reply to field

;note
	copyright: "2015-2016, Maret Basile, Eiffel Software"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

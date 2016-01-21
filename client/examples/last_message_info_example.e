note
	description: "An example of how to retrieve message info"
	author: "Basile Maret"

class
	LAST_MESSAGE_INFO_EXAMPLE

inherit
	EXAMPLE

create
	make

feature -- Initialization

	make
			-- Create the example
		do
			create imap.make_ssl_with_address (Server_name)
			--imap.debugger.set_debug (imap.debugger.show_all)
			imap.connect
		end

feature -- Basic operation

	run_example
			-- Run the example
		do
			io.put_new_line
			print("** Login, select INBOX and print the last message **")
			io.put_new_line
			io.put_new_line

			imap.login (User_name, Password)
			if imap.get_current_state ~ {IL_NETWORK_STATE}.authenticated_state then
				-- We logged in successfully
				print (imap.get_last_response.information_message)
				io.put_new_line
				io.put_new_line

				if open_mailbox then
					get_last_message
				end

			else
				-- We could not log in
				print ("Error : ")
				print (imap.get_last_response.information_message)
				io.put_new_line
			end
		end

		open_mailbox: BOOLEAN
				-- Open the mailbox INBOX and return true iff the mailbox was opened successfuly
			require
				authenticated_state: imap.get_current_state = {IL_NETWORK_STATE}.authenticated_state
			do
				imap.select_mailbox ("INBOX")
				Result := imap.get_last_response.status ~ imap.Command_ok_label
			ensure
				correct_result: Result = (imap.get_current_state = {IL_NETWORK_STATE}.selected_state)
			end

		get_last_message
				-- Print the information of the last message
			require
				imap.get_current_state = {IL_NETWORK_STATE}.selected_state
			local
				messages: HASH_TABLE [IL_FETCH, NATURAL]
				data_items: LINKED_LIST [STRING]
				parser: IL_HEADER_PARSER
				tuple: detachable TUPLE
			do
				create data_items.make
				data_items.extend (From_field)
				data_items.extend (Subject_field)
				data_items.extend (Date_field)
				data_items.extend (Body_text_field)
				messages := imap.fetch (create {IL_SEQUENCE_SET}.make_last, data_items)

				across
					messages as message
				loop
					print ("Message with sequence number ")
					print (message.key)
					print (" :")
					io.put_new_line

					tuple := message.item.data.at (From_field)
					if attached {TUPLE} tuple and then attached {STRING} tuple.at (2) as field then
						create parser.make_from_text (field)
						print ("From : ")
						print (parser.from_field.at (1).out + " (" + parser.from_field.at (2).out + ")")
						io.put_new_line
					end

					tuple := message.item.data.at (Date_field)
					if attached {TUPLE} tuple and then attached {STRING} tuple.at (2) as field then
						create parser.make_from_text (field)
						print ("Date : ")
						print (parser.date_field.out)
						io.put_new_line
					end

					tuple := message.item.data.at (Subject_field)
					if attached {TUPLE} tuple and then attached {STRING} tuple.at (2) as field then
						create parser.make_from_text (field)
						print ("Subject : ")
						print (parser.subject_field)
						io.put_new_line
					end

					tuple := message.item.data.at (Body_text_field)
					if attached {TUPLE} tuple and then attached {STRING} tuple.at (2) as field then
						print ("Body text (size " + message.item.data.at (Body_text_field).at (1).out + " B):")
						io.put_new_line
						print (field)
						io.put_new_line
					end

				end
			end

feature {NONE} -- Constants

	From_field: STRING = "BODY[HEADER.FIELDS (FROM)]"
	Date_field: STRING = "BODY[HEADER.FIELDS (DATE)]"
	Subject_field: STRING = "BODY[HEADER.FIELDS (SUBJECT)]"
	Body_text_field: STRING = "BODY[TEXT]"

end

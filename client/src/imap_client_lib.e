note
	description: "imaplib application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	IMAP_CLIENT_LIB

inherit

	ARGUMENTS

	IL_CONSTANTS

	IL_IMAP_ACTION

create
	make, make_ssl, make_with_address, make_with_address_and_port, make_ssl_with_address, make_ssl_with_address_and_port

feature {NONE} -- Initialization

	make
			-- Create IMAP session with default address and ports
		do
			make_with_address_and_port (Default_address, Default_port)
		ensure
			network /= Void
			response_mgr /= Void
		end

	make_ssl
			-- Create SSL IMAP session with default address and ports
		do
			make_ssl_with_address_and_port (Default_address, Default_ssl_port)
		ensure
			network /= Void
			response_mgr /= Void
		end

	make_with_address (a_address: STRING)
			-- Create an IMAP session with address `a_address' and default port
		require
			address_not_void: a_address /= void
		do
			make_with_address_and_port (a_address, Default_port)
		ensure
			network /= Void
			response_mgr /= Void
		end

	make_with_address_and_port (a_address: STRING; a_port: INTEGER)
			-- Create an IMAP session `address' set to `a_address' and `port' to `a_port'
		require
			correct_port_number: a_port >= 1 and a_port <= 65535
			address_not_void: a_address /= void
		do
			create network.make_with_address_and_port (a_address, a_port)
			current_tag_number := 0
			current_tag := Tag_prefix + "0"
			last_response_received := -1
			create response_mgr.make_with_network (network)
		ensure
			network /= Void
			response_mgr /= Void
		end

	make_ssl_with_address (a_address: STRING)
			-- Create an SSL IMAP session with address `a_address' and default port
		require
			address_not_void: a_address /= void
		do
			make_ssl_with_address_and_port (a_address, Default_ssl_port)
		ensure
			network /= Void
			response_mgr /= Void
		end

	make_ssl_with_address_and_port (a_address: STRING; a_port: INTEGER)
			-- Create an SSL IMAP session `address' set to `a_address' and `port' to `a_port'
		require
			correct_port_number: a_port >= 1 and a_port <= 65535
			address_not_void: a_address /= void
		do
			network := create {IL_SSL_NETWORK}.make_with_address_and_port (a_address, a_port)
			current_tag_number := 0
			current_tag := Tag_prefix + "0"
			last_response_received := -1
			create response_mgr.make_with_network (network)
		ensure
			network /= Void
			response_mgr /= Void
		end

feature -- Basic Commands

	logout
			-- Attempt to logout
		do
			send_command (get_command (Logout_action), create {ARRAYED_LIST [STRING]}.make (0))
		end

	get_capability: LINKED_LIST [STRING]
		require
			network.is_connected
		local
			parser: IL_PARSER
			response: IL_SERVER_RESPONSE
			tag: STRING
		do
			tag := get_tag
			network.send_command (tag, get_command (Capability_action), create {ARRAYED_LIST [STRING]}.make (0))
			response := get_response (tag)
			check
				correct_response_received: response.untagged_response_count = 1 or response.is_error
			end
			if not response.is_error then
				create parser.make_from_text (response.get_untagged_response (0))
				Result := parser.match_capabilities
			else
				create Result.make
			end
		end

feature -- Not connected commands

	connect
			-- Attempt to create a connection to the IMAP server
		do
			network.connect
			check
				response_mgr.was_connection_ok
			end
			network.set_state ({IL_NETWORK_STATE}.not_authenticated_state)
		ensure
			network.is_connected
		end

feature -- Not authenticated commands

	starttls
			-- Start tls negociation
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			send_command (get_command (Starttls_action), args)
		end

	login (a_user_name: STRING; a_password: STRING)
			-- Attempt to login
		require
			supports_action: supports_action (Login_action)
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend (a_user_name)
			args.extend (a_password)
			send_command (get_command (Login_action), args)
			network.update_imap_state (response_mgr.read_response (current_tag), {IL_NETWORK_STATE}.authenticated_state)
		end

feature -- Authenticated commands

	select_mailbox (a_mailbox_name: STRING): IL_MAILBOX
			-- Select the mailbox `a_mailbox_name'
		require
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
		local
			args: LINKED_LIST [STRING]
			response: IL_SERVER_RESPONSE
			tag: STRING
			parser: IL_MAILBOX_PARSER
		do
			tag := get_tag
			create args.make
			args.extend (a_mailbox_name)
			network.send_command (tag, get_command (Select_action), args)
			response := get_response (tag)
			if not response.is_error and then response.status ~ Command_ok_label then
				create parser.make_from_response (response, a_mailbox_name)
				Result := parser.parse_mailbox
				network.update_imap_state (response, {IL_NETWORK_STATE}.selected_state)
			else
				create Result.make_with_name (a_mailbox_name)
			end
		end

	examine_mailbox (a_mailbox_name: STRING): IL_MAILBOX
			-- Select the mailbox `a_mailbox_name' in read only
		require
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
		local
			args: LINKED_LIST [STRING]
			response: IL_SERVER_RESPONSE
			tag: STRING
			parser: IL_MAILBOX_PARSER
		do
			tag := get_tag
			create args.make
			args.extend (a_mailbox_name)
			network.send_command (tag, get_command (Examine_action), args)
			response := get_response (tag)
			if not response.is_error and then response.status ~ Command_ok_label then
				create parser.make_from_response (response, a_mailbox_name)
				Result := parser.parse_mailbox
				network.update_imap_state (response, {IL_NETWORK_STATE}.selected_state)
			else
				create Result.make_with_name (a_mailbox_name)
			end
		end

	create_mailbox (a_mailbox_name: STRING)
			-- Delete the mailbox `a_mailbox_name'
		require
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend (a_mailbox_name)
			send_command (get_command (Create_action), args)
		end

	delete_mailbox (a_mailbox_name: STRING)
			-- Delete the mailbox `a_mailbox_name'
		require
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend (a_mailbox_name)
			send_command (get_command (Delete_action), args)
		end

	rename_mailbox (a_mailbox_name: STRING; a_new_name: STRING)
			-- Rename the mailbox `a_mailbox_name' to `a_new_name'
		require
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
			a_new_name_not_empty: a_new_name /= Void and then not a_new_name.is_empty
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend (a_mailbox_name)
			args.extend (a_new_name)
			send_command (get_command (Rename_action), args)
		end

	subscribe (a_mailbox_name: STRING)
			-- Subscribe to the mailbox `a_mailbox_name'
		require
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend (a_mailbox_name)
			send_command (get_command (Subscribe_action), args)
		end

	unsubscribe (a_mailbox_name: STRING)
			-- Unsubscribe from the mailbox `a_mailbox_name'
		require
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend (a_mailbox_name)
			send_command (get_command (Unsubscribe_action), args)
		end

	list (a_reference_name: STRING; a_name: STRING)
			-- List the names at `a_reference_name' in mailbox `a_name'
			-- `a_name' may use wildcards
		require
			args_not_void: a_reference_name /= Void and a_name /= Void
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend ("%"" + a_reference_name + "%"")
			args.extend ("%"" + a_name + "%"")
			send_command (get_command (List_action), args)
		end

	get_list (a_reference_name: STRING; a_name: STRING): LINKED_LIST [IL_NAME]
			-- Returns a list of the names at `a_reference_name' in mailbox `a_name'
			-- `a_name' may use wildcards
		require
			args_not_void: a_reference_name /= Void and a_name /= Void
		local
			args: LINKED_LIST [STRING]
			tag: STRING
			response: IL_SERVER_RESPONSE
			parser: IL_NAME_LIST_PARSER
		do
			create args.make
			args.extend ("%"" + a_reference_name + "%"")
			args.extend ("%"" + a_name + "%"")
			tag := get_tag
			network.send_command (tag, get_command (List_action), args)
			response := get_response (tag)
			create parser.make_from_response (response, false)
			if parser.get_status ~ Command_ok_label then
				Result := parser.get_list
			else
				create Result.make
			end
		end

	lsub (a_reference_name: STRING; a_name: STRING)
			-- Send command lsub for `a_reference_name' in mailbox `a_name'
			-- `a_name' may use wildcards
		require
			args_not_void: a_reference_name /= Void and a_name /= Void
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend ("%"" + a_reference_name + "%"")
			args.extend ("%"" + a_name + "%"")
			send_command (get_command (Lsub_action), args)
		end

	get_lsub (a_reference_name: STRING; a_name: STRING): LINKED_LIST [IL_NAME]
			-- Returns a list of the name for the command lsub at `a_reference_name' in mailbox `a_name'
			-- `a_name' may use wildcards
		require
			args_not_void: a_reference_name /= Void and a_name /= Void
		local
			args: LINKED_LIST [STRING]
			tag: STRING
			response: IL_SERVER_RESPONSE
			parser: IL_NAME_LIST_PARSER
		do
			create args.make
			args.extend ("%"" + a_reference_name + "%"")
			args.extend ("%"" + a_name + "%"")
			tag := get_tag
			network.send_command (tag, get_command (Lsub_action), args)
			response := get_response (tag)
			create parser.make_from_response (response, true)
			if parser.get_status ~ Command_ok_label then
				Result := parser.get_list
			else
				create Result.make
			end
		end

	get_status (a_mailbox_name: STRING; status_data: LIST [STRING]): HASH_TABLE [INTEGER, STRING]
			-- Return the status of the mailbox `a_mailbox_name' for status data in list `status_data'
		require
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
			status_data_not_empty: status_data /= Void and then not status_data.is_empty
		local
			args: LINKED_LIST [STRING]
			tag: STRING
			response: IL_SERVER_RESPONSE
			parser: IL_PARSER
		do
			create args.make
			args.extend (a_mailbox_name)
			args.extend (string_from_list (status_data))
			tag := get_tag
			network.send_command (tag, get_command (Status_action), args)
			response := get_response (tag)
			create parser.make_from_text (response.untagged_responses.at (0))
			Result := parser.get_status_data
		end

	append (a_mailbox_name: STRING; flags: LIST [STRING]; date_time: STRING; message_literal: STRING)
			-- Append `message_literal' as a new message to the end of the mailbox `a_mailbox_name'
			-- The flags in the list `flags' are set to the resulting message and if `data_time' is not empty, it is set as internal date to the message.
		require
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
			flags_not_void: flags /= Void
			date_time_not_void: date_time /= Void
			message_literal_not_empty: message_literal /= Void and then not message_literal.is_empty
		local
			args: LINKED_LIST [STRING]
			flags_string: STRING
		do
			create args.make
			args.extend (a_mailbox_name)
			flags_string := string_from_list (flags)
			if not flags_string.is_empty then
				args.extend (flags_string)
			end
			if not date_time.is_empty then
				args.extend (date_time)
			end
			args.extend ("{" + message_literal.count.out + "}")
			send_command (get_command (Append_action), args)
			if needs_continuation then
				send_command_continuation (message_literal)
			end
		end

feature -- Selected commands

	check_command
			-- Request a checkpoint
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			send_command (get_command (Check_action), args)
		end

	close
			-- Close the selected mailbox. Switch to authenticated state on success
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			send_command (get_command (Close_action), args)
			network.update_imap_state (response_mgr.read_response (current_tag), {IL_NETWORK_STATE}.authenticated_state)
		end

	expunge
			-- Send expunge command.
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			send_command (get_command (Expunge_action), args)
		end

	get_expunge: LINKED_LIST [INTEGER]
			-- Send expunge command. Returns a list of the deleted messages
		local
			args: LINKED_LIST [STRING]
			tag: STRING
			response: IL_SERVER_RESPONSE
			parser: IL_EXPUNGE_PARSER
		do
			create args.make
			tag := get_tag
			network.send_command (tag, get_command (Expunge_action), args)
			response := get_response (tag)
			create parser.make_from_response (response)
			if parser.get_status ~ Command_ok_label then
				Result := parser.parse_expunged
			else
				create Result.make
			end
		end

	search (charset: STRING; criterias: LIST [STRING]): LINKED_LIST [INTEGER]
			-- Return a list of message that match the criterias `criterias'
		require
			criterias_not_void: criterias /= Void
		local
			args: LINKED_LIST [STRING]
			tag: STRING
			response: IL_SERVER_RESPONSE
			parser: IL_PARSER
		do
			tag := get_tag
			create args.make
			if charset /= Void and then not charset.is_empty then
				args.extend ("CHARSET " + charset)
			end
			across
				criterias as criteria
			loop
				args.extend (criteria.item)
			end
			network.send_command (tag, get_command (Search_action), args)
			response := get_response (tag)
			if response.status ~ Command_ok_label and then response.untagged_response_count = 1 then
				create parser.make_from_text (response.untagged_responses.at (0))
				Result := parser.get_search_results
			else
				create Result.make
			end
		end

	fetch (a_sequence_set: IL_SEQUENCE_SET; data_items: LIST [STRING]): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set `a_sequence_set' for data items `data_items'
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			data_item_not_empty: data_items /= Void and then not data_items.is_empty
		do
			Result := fetch_string (a_sequence_set, string_from_list (data_items))
		end

	fetch_all (a_sequence_set: IL_SEQUENCE_SET): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set `a_sequence_set' for macro ALL
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
		do
			Result := fetch_string (a_sequence_set, All_macro)
		end

	fetch_fast (a_sequence_set: IL_SEQUENCE_SET): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set `a_sequence_set' for macro FAST
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
		do
			Result := fetch_string (a_sequence_set, Fast_macro)
		end

	fetch_full (a_sequence_set: IL_SEQUENCE_SET): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set `a_sequence_set' for macro FULL
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
		do
			Result := fetch_string (a_sequence_set, Full_macro)
		end

	fetch_string (a_sequence_set: IL_SEQUENCE_SET; data_items: STRING): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set `a_sequence_set' for data items `data_items'
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			data_item_not_empty: data_items /= Void and then not data_items.is_empty
		do
			Result := send_fetch (a_sequence_set, data_items, false)
		end

	fetch_uid (a_sequence_set: IL_SEQUENCE_SET; data_items: LIST [STRING]): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set of uids `a_sequence_set' for data items `data_items'
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			data_item_not_empty: data_items /= Void and then not data_items.is_empty
		do
			Result := fetch_string_uid (a_sequence_set, string_from_list (data_items))
		end

	fetch_all_uid (a_sequence_set: IL_SEQUENCE_SET): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set of uids `a_sequence_set' for macro ALL
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
		do
			Result := fetch_string_uid (a_sequence_set, All_macro)
		end

	fetch_fast_uid (a_sequence_set: IL_SEQUENCE_SET): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set of uids `a_sequence_set' for macro FAST
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
		do
			Result := fetch_string_uid (a_sequence_set, Fast_macro)
		end

	fetch_full_uid (a_sequence_set: IL_SEQUENCE_SET): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set of uids `a_sequence_set' for macro FULL
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
		do
			Result := fetch_string_uid (a_sequence_set, Full_macro)
		end

	fetch_string_uid (a_sequence_set: IL_SEQUENCE_SET; data_items: STRING): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set of uids `a_sequence_set' for data items `data_items'
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			data_item_not_empty: data_items /= Void and then not data_items.is_empty
		do
			Result := send_fetch (a_sequence_set, data_items, true)
		end

	copy_messages (a_sequence_set: IL_SEQUENCE_SET; a_mailbox_name: STRING)
			-- Copy the messages in `a_sequence_set' to mailbox `a_mailbox_name'
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend (a_sequence_set.string)
			args.extend (a_mailbox_name)
			send_command (get_command (Copy_action), args)
		end

	copy_messages_uid (a_sequence_set: IL_SEQUENCE_SET; a_mailbox_name: STRING)
			-- Copy the messages with uids in `a_sequence_set' to mailbox `a_mailbox_name'
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			a_mailbox_name_not_empty: a_mailbox_name /= Void and then not a_mailbox_name.is_empty
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend (a_sequence_set.string)
			args.extend (a_mailbox_name)
			send_command (get_command (Uid_copy_action), args)
		end

	store (a_sequence_set: IL_SEQUENCE_SET; data_item_name: STRING; data_item_values: LIST [STRING])
			-- Alter data for messages in `a_sequence_set'. Change the messages according to `data_item_name' with arguments `data_item_values'
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			data_item_name_not_empty: data_item_name /= Void and then not data_item_name.is_empty
			data_item_value_not_void: data_item_values /= Void
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend (a_sequence_set.string)
			args.extend (data_item_name)
			args.extend (string_from_list (data_item_values))
			send_command (get_command (Store_action), args)
		end

	get_store (a_sequence_set: IL_SEQUENCE_SET; data_item_name: STRING; data_item_values: LIST [STRING]): HASH_TABLE [IL_FETCH, NATURAL]
			-- Alter data for messages in `a_sequence_set'. Change the messages according to `data_item_name' with arguments `data_item_values'
			-- Returns a hash table maping the uid of the message to an il_fetch data structure for every FETCH response received
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			data_item_name_not_empty: data_item_name /= Void and then not data_item_name.is_empty
			data_item_value_not_void: data_item_values /= Void
		local
			args: LINKED_LIST [STRING]
			tag: STRING
			response: IL_SERVER_RESPONSE
			parser: IL_FETCH_PARSER
		do
			tag := get_tag
			create args.make
			args.extend (a_sequence_set.string)
			args.extend (data_item_name)
			args.extend (string_from_list (data_item_values))
			network.send_command (tag, get_command (Store_action), args)
			response := get_response (tag)
			if response.status ~ Command_ok_label and then response.untagged_response_count >= 1 then
				create parser.make_from_response (response)
				Result := parser.get_data
			else
				create Result.make (0)
			end
		end

	store_uid (a_sequence_set: IL_SEQUENCE_SET; data_item_name: STRING; data_item_values: LIST [STRING])
			-- Alter data for messages with uid in `a_sequence_set'. Change the messages according to `data_item_name' with arguments `data_item_values'
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			data_item_name_not_empty: data_item_name /= Void and then not data_item_name.is_empty
			data_item_value_not_void: data_item_values /= Void
		local
			args: LINKED_LIST [STRING]
		do
			create args.make
			args.extend (a_sequence_set.string)
			args.extend (data_item_name)
			args.extend (string_from_list (data_item_values))
			send_command (get_command (Uid_store_action), args)
		end

	get_store_uid (a_sequence_set: IL_SEQUENCE_SET; data_item_name: STRING; data_item_values: LIST [STRING]): HASH_TABLE [IL_FETCH, NATURAL]
			-- Alter data for messages with uid in `a_sequence_set'. Change the messages according to `data_item_name' with arguments `data_item_values'
			-- Returns a hash table maping the uid of the message to an il_fetch data structure for every FETCH response received
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			data_item_name_not_empty: data_item_name /= Void and then not data_item_name.is_empty
			data_item_value_not_void: data_item_values /= Void
		local
			args: LINKED_LIST [STRING]
			tag: STRING
			response: IL_SERVER_RESPONSE
			parser: IL_FETCH_PARSER
		do
			tag := get_tag
			create args.make
			args.extend (a_sequence_set.string)
			args.extend (data_item_name)
			args.extend (string_from_list (data_item_values))
			network.send_command (tag, get_command (Uid_store_action), args)
			response := get_response (tag)
			if response.status ~ Command_ok_label and then response.untagged_response_count >= 1 then
				create parser.make_from_response (response)
				Result := parser.get_data
			else
				create Result.make (0)
			end
		end

feature -- Basic Operations

	send_command (a_command: STRING; arguments: LIST [STRING])
			-- Send the command `a_command' with argument list `arguments'
		require
			a_command_not_empty: a_command /= Void and then not a_command.is_empty
			arguments_not_void: arguments /= Void
		do
			network.send_command (get_tag, a_command, arguments)
		end

	send_command_continuation (a_continuation: STRING)
			-- Send the command continuation `a_continuation'
		require
			a_continuation_not_empty: a_continuation /= Void and then not a_continuation.is_empty
			needs_continuation: needs_continuation
		do
			network.send_command_continuation (a_continuation)
		end

	is_connected: BOOLEAN
			-- Returns true iff the network is connected to the socket
		do
			if current_tag_number > 0 then
				response_mgr.update_responses (current_tag)
			end
			Result := network.is_connected
		end

		-- TODO: See if this is really needed

	supports_action (action: NATURAL): BOOLEAN
			-- Returns true if the command `action' is supported in current context
		local
			capability_list: LINKED_LIST [STRING]
		do
				--capability_list := get_capability

				--Result := false
				--across
				--	capability_list as cap
				--loop
				--	if cap.item ~ get_command(action) then
			Result := true
				--	end
				--end
		end

	get_last_response: IL_SERVER_RESPONSE
			-- Returns the response for the last command sent
		do
			Result := get_response (current_tag)
		ensure
			Result /= Void
		end

	receive
			-- Read socket for responses
		do
			response_mgr.update_responses (current_tag)
		end

	needs_continuation: BOOLEAN
			-- Return true iff the last response from the server was a command continuation request
		do
			receive
			Result := network.needs_continuation
		end

feature -- Access

	network: IL_NETWORK

feature {NONE} -- Implementation

	current_tag_number: INTEGER

	current_tag: STRING

	last_response_received: INTEGER

	get_tag: STRING
			-- increments the `current_tag_number' and returns a new tag, greater tha the last one
		do
			current_tag_number := current_tag_number + 1
			create Result.make_empty
			Result.copy (Tag_prefix)
			Result.append_integer (current_tag_number)
			current_tag := Result
		ensure
			current_tag_number_increased: current_tag_number > old current_tag_number
		end

	get_response (tag: STRING): IL_SERVER_RESPONSE
			-- Returns the server response that the server gave for command with tag `tag'
		require
			tag_not_empty: tag /= Void and then not tag.is_empty
		local
			parser: IL_PARSER
			tag_number: INTEGER
		do
			create parser.make_from_text (tag)
			tag_number := parser.get_number
			check
				correct_tag: tag_number > last_response_received and tag_number <= current_tag_number
			end
			Result := response_mgr.get_response (tag)
			last_response_received := tag_number
		ensure
			Result /= Void
		end

	send_fetch (a_sequence_set: IL_SEQUENCE_SET; data_items: STRING; is_uid: BOOLEAN): HASH_TABLE [IL_FETCH, NATURAL]
			-- Send a fetch command with sequence set `a_sequence_set' for data items `data_items'
			-- The sequence set will represent uids iff `is_uid' is set to true
			-- Returns a hash table maping the uid of the message to an il_fetch data structure
		require
			a_sequence_set_not_void: a_sequence_set /= Void
			data_item_not_empty: data_items /= Void and then not data_items.is_empty
		local
			args: LINKED_LIST [STRING]
			tag: STRING
			response: IL_SERVER_RESPONSE
			parser: IL_FETCH_PARSER
			command: STRING
		do
			create args.make
			args.extend (a_sequence_set.string)
			args.extend (data_items)
			tag := get_tag
			if is_uid then
				command := get_command (Uid_fetch_action)
			else
				command := get_command (Fetch_action)
			end
			network.send_command (tag, command, args)
			response := get_response (tag)
			if response.status ~ Command_ok_label and then response.untagged_response_count >= 1 then
				create parser.make_from_response (response)
				Result := parser.get_data
			else
				create Result.make (0)
			end
		end

	response_mgr: IL_RESPONSE_MANAGER

	string_from_list (a_list: LIST [STRING]): STRING
			-- Returns a string begining with "(" and ending with ")" and containing all the elements of `a_list' separated by " "
			-- Returns an empty string iff a_list is empty
		require
			a_list_not_void: a_list /= Void
		do
			create Result.make_empty
			across
				a_list as elem
			loop
				Result.append (elem.item + " ")
			end
			if not Result.is_empty then
				Result.remove_tail (1)
				Result := "(" + Result + ")"
			end
		ensure
			empty_list_iff_empty_result: a_list.is_empty = Result.is_empty
		end

end

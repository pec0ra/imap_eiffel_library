note
	description: "Summary description for {IL_RESPONSE_MANAGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_RESPONSE_MANAGER

inherit

	IL_CONSTANTS

create
	make_with_network

feature {NONE} -- Initialization

	make_with_network (a_network: IL_NETWORK)
			-- Create and set `network' to `a_network'
		require
			a_network_not_void: a_network /= Void
		do
			network := a_network
			create responses_table.make (0)
		ensure
			network_set: network = a_network
		end

feature -- Basic operations

	was_connection_ok: BOOLEAN
			-- Returns true if the last response sent by the server was an OK untagged response
		local
			server_response: STRING
			parser: IL_PARSER
		do
			server_response := network.get_line
			create parser.make_from_text (server_response)
			Result := parser.matches_connection_ok
		end

	update_responses (tag: STRING)
			-- Updates the response table with responses up to `tag'
		require
			tag_not_empty: tag /= Void and then not tag.is_empty
		do
			from
			until
				responses_table.has (tag) or not network.is_connected or network.needs_continuation
			loop
				get_next_response
			end
		end

	read_response (tag: STRING): IL_SERVER_RESPONSE
			-- Returns the server response that the server gave for command with tag `tag'
		require
			tag_not_empty: tag /= Void and then not tag.is_empty
		local
			server_response: detachable IL_SERVER_RESPONSE
		do
			from
			until
				responses_table.has (tag) or not network.is_connected or network.needs_continuation
			loop
				get_next_response
			end
			server_response := responses_table.at (tag)
			if attached {IL_SERVER_RESPONSE} server_response then
				Result := server_response
			else
				create Result.make_error
			end
		ensure
			Result_not_void: Result /= Void
		end

	get_response (tag: STRING): IL_SERVER_RESPONSE
			-- Returns the server response that the server gave for command with tag `tag' and deletes it from the list
		require
			tag_not_empty: tag /= Void and then not tag.is_empty
		do
			Result := read_response (tag)
			responses_table.remove (tag)
		ensure
			Result_not_void: Result /= Void
		end

feature {NONE} -- Implementation

	get_next_response
			-- gets the next response from the network, parse it and add it to the response array
		local
			response, tag, prev_response: STRING
			parser: IL_PARSER
		do
			response := network.get_line
			if not response.is_empty then
				if response.count > 1 then
					response.remove_tail (1)
					create parser.make_from_text (response)
					tag := parser.get_tag
					if parser.matches_bye then
						bye_action
					elseif tag ~ "*" then
						untagged_action (response)
					elseif tag ~ "+" then
							-- When the tag is "+", the server needs the continuation of the request
						network.set_needs_continuation (true)
					elseif tag.is_empty then
						empty_action (response)
					else
						tagged_action (response, parser, tag)
					end
				end
			else
				network.set_state ({IL_NETWORK_STATE}.Not_connected_state)
				debugger.dprint (debugger.dwarning, "Empty answer received. We are now disconnected")
			end
		end

	bye_action
			-- When the response is a bye response, we are in a disconnected state
		do
			network.set_state ({IL_NETWORK_STATE}.Not_connected_state)
			debugger.dprint (debugger.Dwarning, "BYE answer received. We are now disconnected")
		end

	untagged_action (response: STRING)
			-- When the response is an untagged response
		local
			server_response: detachable IL_SERVER_RESPONSE
		do
				-- We create a temporary entry in the `responses_table' to store the new IL_SERVER_RESPONSE
			if responses_table.has (Next_response_tag) then
				server_response := responses_table.at (Next_response_tag)
				if server_response = Void then
					create server_response.make_empty
				end
			else
				create server_response.make_empty
				responses_table.put (server_response, Next_response_tag)
			end
			server_response.add_untagged_response (response)
		end

	empty_action (response: STRING)
			-- When the response has an empty tag
		local
			server_response: detachable IL_SERVER_RESPONSE
		do
				-- When the tag is empty, it means this is the continuation of the previous message
			check
				previous_response_exists: responses_table.has (Next_response_tag)
			end
			server_response := responses_table.at (Next_response_tag)
			if server_response /= Void then
				server_response.untagged_responses.last.append (" " + response)
			end
		end

	tagged_action (response: STRING; parser: IL_PARSER; tag: STRING)
			-- When the response is a tagged response
		local
			server_response: detachable IL_SERVER_RESPONSE
		do
				-- We check for a temporary entry in the `response_table'. If it exists this will be the IL_SERVER_RESPONSE.
			if responses_table.has (Next_response_tag) then
				server_response := responses_table.at (Next_response_tag)
				responses_table.remove (Next_response_tag)
			end
			if server_response = Void then
				create server_response.make_empty
			end
			server_response.set_tagged_text (response)
			server_response.set_status (parser.get_status)
			responses_table.put (server_response, tag)
		end

	responses_table: HASH_TABLE [IL_SERVER_RESPONSE, STRING]

	network: IL_NETWORK

end

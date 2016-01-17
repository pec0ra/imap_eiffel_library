note
	description: "Summary description for {IL_NETWORK_STATE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	IL_NETWORK_STATE

inherit

	IL_CONSTANTS

feature -- Access

	Not_connected_state: NATURAL = 1
	Not_authenticated_state: NATURAL = 2
	Authenticated_state: NATURAL = 3
	Selected_state: NATURAL = 4

	Min_state: NATURAL = 1
	Max_state: NATURAL = 4

feature -- Basic operation

	check_action (a_state: NATURAL; a_action: NATURAL): BOOLEAN
			-- Returns true if `a_action' is a valid action in state `a_state'
		do
			if a_state = not_connected_state then
				Result := not_authenticated_state_actions.has (a_action)
			elseif a_state = not_authenticated_state then
				Result := not_authenticated_state_actions.has (a_action)
			elseif a_state = authenticated_state then
				Result := authenticated_state_actions.has (a_action)
			elseif a_state = selected_state then
				Result := selected_state_actions.has (a_action)
			end
		end

	set_state (a_state: NATURAL)
			-- Set `state' to `a_state'
		require
			correct_state: a_state >= Min_state and a_state <= Max_state
		do
			state := a_state
		ensure
			state = a_state
		end

	set_needs_continuation (bool: BOOLEAN)
		do
			needs_continuation := bool
		end

	update_imap_state (a_response: IL_SERVER_RESPONSE; a_state: NATURAL)
			-- Checks if the response `a_response' is OK and, if it is the case, updates the state to `a_state'
		require
			response_not_void: a_response /= Void
		do
			if a_response.status ~ Command_ok_label then
				set_state (a_state)
				debugger.dprint (debugger.Dinfo, "Switched state ")
			end
		end

feature -- Access

	state: NATURAL
			-- Current state of the connection

	needs_continuation: BOOLEAN
			-- Set to true iff server sent a command continuation request

feature -- Implementation

	not_connected_state_actions: LINKED_LIST [NATURAL]
			-- Valid actions in not connected state
		once
			create Result.make
		end

	not_authenticated_state_actions: LINKED_LIST [NATURAL]
			-- Valid actions in not authenticated state
		once
			create Result.make
			Result.extend ({IL_IMAP_ACTION}.Login_action)
			Result.extend ({IL_IMAP_ACTION}.Capability_action)
			Result.extend ({IL_IMAP_ACTION}.Noop_action)
			Result.extend ({IL_IMAP_ACTION}.Logout_action)
		end

	authenticated_state_actions: LINKED_LIST [NATURAL]
			-- Valid actions in authenticated state
		once
			create Result.make
			Result.extend ({IL_IMAP_ACTION}.Capability_action)
			Result.extend ({IL_IMAP_ACTION}.Noop_action)
			Result.extend ({IL_IMAP_ACTION}.Logout_action)
			Result.extend ({IL_IMAP_ACTION}.Select_action)
		end

	selected_state_actions: LINKED_LIST [NATURAL]
			-- Valid actions in selected state
		once
			create Result.make
			Result.extend ({IL_IMAP_ACTION}.Capability_action)
			Result.extend ({IL_IMAP_ACTION}.Noop_action)
			Result.extend ({IL_IMAP_ACTION}.Logout_action)
		end

end

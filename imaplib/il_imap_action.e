note
	description: "Summary description for {IL_IMAP_ACTION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_IMAP_ACTION

feature -- Access

	Login_action: NATURAL = 1
	Capability_action: NATURAL = 2
	Open_action: NATURAL = 3
	Noop_action: NATURAL = 4
	Logout_action: NATURAL = 5



	min_action: NATURAL = 1
	max_action: NATURAL = 5

feature -- Basic Operations

	get_command( a_action: NATURAL): STRING
			-- Returns the imap command corresponding to the action `a_action'
		require
			valid_action: a_action >= min_action and a_action <= max_action
		do
			inspect a_action
			when Login_action then
				Result := "LOGIN"
			when Capability_action then
				Result := "CAPABILITY"
			when Open_action then
				Result := "OPEN"
			when Noop_action then
				Result := "NOOP"
			when Logout_action then
				Result := "LOGOUT"
			else
				Result := ""
			end
		ensure
			result_set: not Result.is_empty
		end

feature {NONE} -- Implementation



end

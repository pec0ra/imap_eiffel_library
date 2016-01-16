note
	description: "Summary description for {IL_IMAP_ACTION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_IMAP_ACTION

feature -- Access

	Login_action: NATURAL = 1
	Starttls_action: NATURAL = 2
	Capability_action: NATURAL = 3
	Select_action: NATURAL = 4
	Examine_action: NATURAL = 5
	Create_action: NATURAL = 6
	Delete_action: NATURAL = 7
	Rename_action: NATURAL = 8
	Subscribe_action: NATURAL = 9
	Unsubscribe_action: NATURAL = 10
	List_action: NATURAL = 11
	Lsub_action: NATURAL = 12
	Status_action: NATURAL = 13
	Check_action: NATURAL = 14
	Close_action: NATURAL = 15
	Expunge_action: NATURAL = 16
	Search_action: NATURAL = 17
	Fetch_action: NATURAL = 18
	Store_action: NATURAL = 19
	Copy_action: NATURAL = 20
	Uid_copy_action: NATURAL = 21
	Uid_fetch_action: NATURAL = 22
	Uid_store_action: NATURAL = 23
	Noop_action: NATURAL = 24
	Logout_action: NATURAL = 25



	min_action: NATURAL = 1
	max_action: NATURAL = 25

feature -- Basic Operations

	get_command( a_action: NATURAL): STRING
			-- Returns the imap command corresponding to the action `a_action'
		require
			valid_action: a_action >= min_action and a_action <= max_action
		do
			inspect a_action
			when Login_action then
				Result := "LOGIN"
			when Starttls_action then
				Result := "STARTTLS"
			when Capability_action then
				Result := "CAPABILITY"
			when Noop_action then
				Result := "NOOP"
			when Logout_action then
				Result := "LOGOUT"
			when Select_action then
				Result := "SELECT"
			when Examine_action then
				Result := "EXAMINE"
			when Create_action then
				Result := "CREATE"
			when Delete_action then
				Result := "DELETE"
			when Rename_action then
				Result := "RENAME"
			when Subscribe_action then
				Result := "SUBSCRIBE"
			when Unsubscribe_action then
				Result := "UNSUBSCRIBE"
			when List_action then
				Result := "LIST"
			when Lsub_action then
				Result := "LSUB"
			when Status_action then
				Result := "STATUS"
			when Check_action then
				Result := "CHECK"
			when Close_action then
				Result := "CLOSE"
			when Expunge_action then
				Result := "EXPUNGE"
			when Search_action then
				Result := "SEARCH"
			when Fetch_action then
				Result := "FETCH"
			when Store_action then
				Result := "STORE"
			when Copy_action then
				Result := "COPY"
			when Uid_copy_action then
				Result := "UID COPY"
			when Uid_fetch_action then
				Result := "UID FETCH"
			when Uid_store_action then
				Result := "UID STORE"
			else
				Result := ""
			end
		ensure
			result_set: not Result.is_empty
		end

feature {NONE} -- Implementation



end

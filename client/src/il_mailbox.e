note
	description: "Summary description for {IL_MAILBOX}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_MAILBOX

create
	make_with_name

feature {NONE} -- Initialization

	make_with_name (a_name: STRING)
			-- Create the mailbox with name `a_name'
		require
			a_name_not_empty: a_name /= Void and then not a_name.is_empty
		do
			name := a_name
			create flags.make
			create permanent_flags.make
		end

feature -- Access

	name: STRING

	flags: LINKED_LIST [STRING]

	permanent_flags: LINKED_LIST [STRING]

	exists: INTEGER

	recent: INTEGER

	unseen: INTEGER

	uid_next: INTEGER

	uid_validity: INTEGER

	is_read_only: BOOLEAN

feature -- Basic Operations

	set_exists (n: INTEGER)
		do
			exists := n
		end

	set_recent (n: INTEGER)
		do
			recent := n
		end

	set_unseen (n: INTEGER)
		do
			unseen := n
		end

	set_uid_next (n: INTEGER)
		do
			uid_next := n
		end

	set_uid_validity (n: INTEGER)
		do
			uid_validity := n
		end

	set_flags (a_flags: LINKED_LIST [STRING])
		do
			flags := a_flags
		end

	set_permanent_flags (a_permanent_flags: LINKED_LIST [STRING])
		do
			permanent_flags := a_permanent_flags
		end

	set_read_only (b: BOOLEAN)
		do
			is_read_only := b
		end

end

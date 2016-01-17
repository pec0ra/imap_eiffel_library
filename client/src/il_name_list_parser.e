note
	description: "Summary description for {IL_NAME_LIST_PARSER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_NAME_LIST_PARSER

inherit

	IL_PARSER

create
	make_from_response

feature {NONE} -- Initialization

	make_from_response (a_response: IL_SERVER_RESPONSE; is_lsub: BOOLEAN)
			-- Create a parser which will parse `a_response'
		require
			correct_response: a_response /= Void and then not a_response.is_error
		do
			text := a_response.tagged_text
			mailbox_list := a_response.untagged_responses
			create regex.make
			if is_lsub then
				Command := Lsub
			else
				Command := List
			end
		ensure
			text_set: text = a_response.tagged_text
			mailbox_list_set: mailbox_list = a_response.untagged_responses
		end

feature -- Basic operations

	get_list: LINKED_LIST [IL_NAME]
			-- Return a list with the mailbox names
		local
			mailbox: IL_NAME
			raw_path, raw_attributes: STRING
		do
			create Result.make
			regex.compile (List_item_pattern)
			from
				mailbox_list.start
			until
				mailbox_list.after
			loop
				regex.compile (list_item_pattern)
				if regex.matches (mailbox_list.item) then
					raw_path := regex.captured_substring (3)
					create mailbox.make_with_raw_path (raw_path)
					parse_raw_path (raw_path, mailbox, regex.captured_substring (2))
					if not regex.captured_substring (2).is_empty then
						mailbox.set_hierarchy_delimiter (regex.captured_substring (2).at (1))
					end
					raw_attributes := regex.captured_substring (1)
					parse_raw_attributes (raw_attributes, mailbox)
					Result.extend (mailbox)
				end
				mailbox_list.forth
			end
		end

feature {NONE} -- Constants

	List: STRING = "LIST"

	Lsub: STRING = "LSUB"

	Command: STRING

	List_item_pattern: STRING
		once
			Result := "^\* " + Command + " \((.*)\) %"(.*)%" (.+)$"
		end

	Raw_attributes_pattern: STRING = "(\\.+)"

feature {NONE} -- Implementation

	mailbox_list: LINKED_LIST [STRING]

	parse_raw_path (a_raw_path: STRING; a_mailbox: IL_NAME; hierarchy_delimiter: STRING)
			-- Sets the path and name to `a_mailbox' from `a_raw_path'
		require
			a_raw_path_not_empty: a_raw_path /= Void and then not a_raw_path.is_empty
			a_mailbox_not_void: a_mailbox /= Void
			hierarchy_delimiter_not_void: hierarchy_delimiter /= Void
		local
			path_regex: RX_PCRE_REGULAR_EXPRESSION
			raw_path_pattern: STRING
		do
			if hierarchy_delimiter.is_empty then
				a_mailbox.set_name (a_raw_path)
			else

					-- We build the pattern depending on the hierarchy delimiter
				raw_path_pattern := "([^.]+)("
				if escaped_chars.has (hierarchy_delimiter) then
					raw_path_pattern := raw_path_pattern + "\"
				end
				raw_path_pattern := raw_path_pattern + hierarchy_delimiter + "?)"
				create path_regex.make
				path_regex.compile (raw_path_pattern)
				from
					path_regex.match (a_raw_path)
				until
					not path_regex.has_matched
				loop
					if path_regex.captured_substring (2).is_empty then -- This is the name of the mailbox
						a_mailbox.set_name (path_regex.captured_substring (1))
					else -- This is an element of the path
						a_mailbox.add_path_level (path_regex.captured_substring (1))
					end
					path_regex.next_match
				end
			end
		end

	parse_raw_attributes (a_raw_attributes: STRING; a_mailbox: IL_NAME)
			-- Sets the attributes `a_mailbox' from `a_raw_attributes'
		local
			attributes_regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create attributes_regex.make
			attributes_regex.compile (Raw_attributes_pattern)
			from
				attributes_regex.match (a_raw_attributes)
			until
				not attributes_regex.has_matched
			loop
				a_mailbox.add_attribute (attributes_regex.captured_substring (0))
				attributes_regex.next_match
			end
		end

	escaped_chars: LINKED_LIST [STRING]
			-- Charachters we need to escape in regex
		once
			create Result.make
			Result.extend ("\")
			Result.extend ("^")
			Result.extend ("$")
			Result.extend (".")
			Result.extend ("[")
			Result.extend ("|")
			Result.extend ("(")
			Result.extend (")")
			Result.extend ("?")
			Result.extend ("*")
			Result.extend ("+")
			Result.extend ("{")
		end

end

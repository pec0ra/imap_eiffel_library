note
	description: "Summary description for {IL_SERVER_RESPONSE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_SERVER_RESPONSE

inherit
	IL_CONSTANTS

create
	make_with_tagged_text,
	make_empty


feature -- Initialization

	make_with_tagged_text ( a_text: STRING)
			-- Initialize with `a_text' as `tagged_text'
		require
			a_text_not_empty: a_text /= Void and then not a_text.is_empty
		do
			tagged_text := a_text
			create untagged_responses.make
			status := Command_no_label
		ensure
			tagged_text_set: tagged_text = a_text
		end

	make_empty
		do
			tagged_text := ""
			create untagged_responses.make
			status := Command_no_label
		end

feature -- Access

	tagged_text: STRING

	status: STRING

	untagged_responses: LINKED_LIST[STRING]


feature -- Basic operations

	add_untagged_response (a_text: STRING)
			-- add an untagged response `a_text' to `untagged_response'
		require
			a_text_not_empty: a_text /= Void and then not a_text.is_empty
		do
			untagged_responses.extend(a_text)
		end

	set_tagged_text (a_text: STRING)
			-- change the tagged_text to `a_text'
		require
			a_text_not_empty: a_text /= Void and then not a_text.is_empty
		do
			tagged_text := a_text
		ensure
			tagged_text_set: tagged_text = a_text
		end

	untagged_response_count: INTEGER
			-- Returns the number of untagged responses contained in the server response
		do
			Result := untagged_responses.count
		end

	get_untagged_response (i: INTEGER): STRING
			-- Returns the text of the `i'th untagged response
		require
			correct_i: i >= 0 and i < untagged_responses.count
		do
			Result := untagged_responses.first
		end

	set_status (a_status: STRING)
			-- Sets the status to `a_status'
		require
			correct_status: a_status.is_equal(Command_ok_label) or a_status.is_equal(Command_bad_label) or a_status.is_equal(Command_no_label)
		do
			status := a_status
		ensure
			status_set: status = a_status
		end

feature -- Constants

end
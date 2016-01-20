note
	description: "A server response"
	author: "Basile Maret"
	EIS: "name=Server responses", "protocol=URI", "src=https://tools.ietf.org/html/rfc3501#section-7"

class
	IL_SERVER_RESPONSE

inherit

	IL_CONSTANTS

create
	make_with_tagged_text, make_empty, make_error

feature {NONE} -- Initialization

	make_with_tagged_text (a_text: STRING)
			-- Initialize with `a_text' as `tagged_text'
		require
			a_text_not_empty: a_text /= Void and then not a_text.is_empty
		do
			tagged_text := a_text
			create {LINKED_LIST [STRING]}untagged_responses.make
			status := Command_no_label
			is_error := false
		ensure
			tagged_text_set: tagged_text = a_text
		end

	make_empty
			-- Create an empty server response
			-- This is used to add the untagged responses before the tagged response
		do
			tagged_text := ""
			create {LINKED_LIST [STRING]}untagged_responses.make
			status := Command_no_label
			is_error := false
		end

	make_error
			-- Create an error response
			-- This is used when the message could not be parsed
		do
			tagged_text := ""
			create {LINKED_LIST [STRING]}untagged_responses.make
			status := Command_no_label
			is_error := true
		end

feature -- Access

	tagged_text: STRING
			-- The text of the tagged response closing the response

	status: STRING
			-- The status of the response

	untagged_responses: LIST [STRING]
			-- A list of the untagged responses before the closing tagged response

	is_error: BOOLEAN
			-- Set to true if the response could not be received from the server

feature -- Basic operations

	add_untagged_response (a_text: STRING)
			-- add an untagged response `a_text' to `untagged_response'
		require
			a_text_not_empty: a_text /= Void and then not a_text.is_empty
		do
			untagged_responses.extend (a_text)
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

	untagged_response (i: INTEGER): STRING
			-- Returns the text of the `i'th untagged response
		require
			correct_i: i >= 0 and i < untagged_responses.count
		do
			Result := untagged_responses.first
		end

	set_status (a_status: STRING)
			-- Sets the status to `a_status'
		require
			correct_status: a_status.is_equal (Command_ok_label) or a_status.is_equal (Command_bad_label) or a_status.is_equal (Command_no_label)
		do
			status := a_status
		ensure
			status_set: status = a_status
		end

feature -- Constants

end

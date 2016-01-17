note
	description: "Summary description for {IL_MAILBOX_PARSER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_MAILBOX_PARSER

inherit

	IL_PARSER

create
	make_from_response

feature {NONE} -- Initialization

	make_from_response (a_response: IL_SERVER_RESPONSE; a_name: STRING)
			-- Create a parser which will parse `a_response'
		require
			correct_response: a_response /= Void and then not a_response.is_error
		do
			text := a_response.tagged_text
			untagged_responses := a_response.untagged_responses
			create regex.make
			name := a_name
		ensure
			text_set: text = a_response.tagged_text
			mailbox_list_set: untagged_responses = a_response.untagged_responses
		end

feature -- Basic Operations

	parse_mailbox: IL_MAILBOX
			-- Return the mailbox parsed from the response
		local
			matched: BOOLEAN
		do
			create Result.make_with_name (name)
			regex.compile (Tagged_response_pattern)
			regex.match (text)
			if regex.captured_substring (1) ~ "READ-ONLY" then
				Result.set_read_only (true)
			end
			across
				untagged_responses as response
			loop
				matched := false
				regex.compile (Exists_pattern)
				if regex.matches (response.item) then
					Result.set_exists (regex.captured_substring (1).to_integer)
					matched := true
				end
				if not matched then
					regex.compile (Recent_pattern)
					if regex.matches (response.item) then
						Result.set_recent (regex.captured_substring (1).to_integer)
						matched := true
					end
				end
				if not matched then
					regex.compile (Unseen_pattern)
					if regex.matches (response.item) then
						Result.set_unseen (regex.captured_substring (1).to_integer)
						matched := true
					end
				end
				if not matched then
					regex.compile (Uid_next_pattern)
					if regex.matches (response.item) then
						Result.set_uid_next (regex.captured_substring (1).to_integer)
						matched := true
					end
				end
				if not matched then
					regex.compile (Uid_validity_pattern)
					if regex.matches (response.item) then
						Result.set_uid_validity (regex.captured_substring (1).to_integer)
						matched := true
					end
				end
				if not matched then
					regex.compile (Flag_response_pattern)
					if regex.matches (response.item) then
						Result.set_flags (parse_flags (regex.captured_substring (1)))
						matched := true
					end
				end
				if not matched then
					regex.compile (Permanent_flags_pattern)
					if regex.matches (response.item) then
						Result.set_permanent_flags (parse_flags (regex.captured_substring (1)))
						matched := true
					end
				end
			end
		end

feature {NONE} -- Constants

	Tagged_response_pattern: STRING = "^il\d+ OK \[(READ-ONLY|READ-WRITE)].*$"

	Flag_response_pattern: STRING = "^\* FLAGS \((.+)\)$"

	Flag_pattern: STRING = "(\\[^ \\]+)"

	Exists_pattern: STRING = "^\* ([0-9]+) EXISTS$"

	Recent_pattern: STRING = "^\* ([0-9]+) RECENT$"

	Unseen_pattern: STRING = "^\* OK \[UNSEEN ([0-9]+)].*$"

	Permanent_flags_pattern: STRING = "^\* OK \[PERMANENTFLAGS \((.+)\)].*$"

	Uid_next_pattern: STRING = "^\* OK \[UIDNEXT ([0-9]+)].*$"

	Uid_validity_pattern: STRING = "^\* OK \[UIDVALIDITY ([0-9]+)].*$"

feature {NONE} -- Implementation

	untagged_responses: LINKED_LIST [STRING]

	name: STRING

	parse_flags (raw_flags: STRING): LINKED_LIST [STRING]
			-- Return a list containing the flags in `raw_flags'
		local
			flag_regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create Result.make
			create flag_regex.make
			flag_regex.compile (Flag_pattern)
			from
				flag_regex.match (raw_flags)
			until
				not flag_regex.has_matched
			loop
				Result.extend (flag_regex.captured_substring (0))
				flag_regex.next_match
			end
		end

end

note
	description: "Summary description for {IL_EXPUNGE_PARSER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_EXPUNGE_PARSER

inherit
	IL_PARSER

create
	make_from_response

feature {NONE} -- Initialization

	make_from_response (a_response: IL_SERVER_RESPONSE)
			-- Create a parser which will parse `a_response'
		require
			correct_response : a_response /= Void and then not a_response.is_error
		do
			text := a_response.tagged_text
			untagged_responses := a_response.untagged_responses
			create regex.make
		ensure
			text_set: text = a_response.tagged_text
			mailbox_list_set: untagged_responses = a_response.untagged_responses
		end

feature -- Basic Operations

	parse_expunged: LINKED_LIST[INTEGER]
			-- Parse the response and return the list of deleted messages
		do
			create Result.make

			from
				untagged_responses.start
			until
				untagged_responses.after
			loop
				regex.compile (Expunge_pattern)
				if regex.matches (untagged_responses.item) then
					Result.extend (regex.captured_substring (1).to_integer)
				end
				untagged_responses.forth
			end
		end

feature {NONE} -- Constants

	Expunge_pattern: STRING = "^\* ([0-9]+) EXPUNGE$"

feature {NONE} -- Implementation

	untagged_responses: LINKED_LIST[STRING]
end

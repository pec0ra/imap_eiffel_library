note
	description: "A parser for the FETCH server response"
	author: "Basile Maret"
	EIS: "name=FETCH command", "protocol=URI", "src=https://tools.ietf.org/html/rfc3501#section-6.4.5"
	EIS: "name=FETCH response", "protocol=URI", "src=https://tools.ietf.org/html/rfc3501#section-7.4.2"

class
	IL_FETCH_PARSER

inherit

	IL_PARSER

create
	make_from_response

feature {NONE} -- Initialization

	make_from_response (a_response: IL_SERVER_RESPONSE)
			-- Create a parser which will parse `a_response'
		require
			correct_response: a_response /= Void and then not a_response.is_error
		do
			text := a_response.tagged_text
			untagged_responses := a_response.untagged_responses
			create regex.make
		ensure
			text_set: text = a_response.tagged_text
			mailbox_list_set: untagged_responses = a_response.untagged_responses
		end

feature -- Basic operations

	get_data: HASH_TABLE [IL_FETCH, NATURAL]
			-- Return a hash table mapping the uid of the messages to their data
		local
			fetch: IL_FETCH
			uid: NATURAL
			data: STRING
			data_regex: RX_PCRE_REGULAR_EXPRESSION
		do
			create Result.make (0)
			create data_regex.make
			across
				untagged_responses as response
			loop
				regex.compile (Fetch_pattern)
				if regex.matches (response.item) then
					uid := regex.captured_substring (1).to_natural
					create fetch.make_with_uid (uid)
					data := regex.captured_substring (2)
					data_regex.compile (Data_item_pattern)
					data_regex.match (data)
					data := data_regex.replace_all ("%R\1\")
					data_regex.compile (Data_pattern)
					from
						data_regex.match (data)
					until
						not data_regex.has_matched
					loop
						fetch.data.put (data_regex.captured_substring (6), data_regex.captured_substring (1))
						data_regex.next_match
					end
					Result.put (fetch, uid)
				end
			end
		end

feature {NONE} -- Constants

	Data_item_pattern: STRING = "(BODY|FLAGS|BODYSTRUCTURE|ENVELOPE|INTERNALDATE|RFC822|UID)"

	Fetch_pattern: STRING = "^\* ([0-9]+) FETCH \((.+)\)$"

	Data_pattern: STRING = "%R?((BODY|FLAGS|BODYSTRUCTURE|ENVELOPE|INTERNALDATE|RFC822|UID)(\[((?!%R).)*])?) ({\d+} )?(((?!%R).)*)"

feature {NONE} -- Implementation

	untagged_responses: LIST [STRING]

end

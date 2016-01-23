note
	description: "A parser for the FETCH server response"
	author: "Basile Maret"
	EIS: "name=FETCH command", "protocol=URI", "src=https://tools.ietf.org/html/rfc3501#section-6.4.5"
	EIS: "name=FETCH response", "protocol=URI", "src=https://tools.ietf.org/html/rfc3501#section-7.4.2"

class
	IL_FETCH_PARSER

inherit

	IL_PARSER
	redefine
		make_from_text
	end

create
	make_from_text

feature {NONE} -- Initialization

	make_from_text (a_text: STRING)
			-- Create a parser which will parse `a_text'
		do
			Precursor (a_text)
			create fetch.make_with_sequence_number (0)
		end

feature -- Basic operations

	sequence_number: NATURAL
			-- Returns the sequence number fetched from `text' or returns 0 if `text' did not match
		do
			regex.compile (First_line_fetch_pattern)
			if regex.matches (text) then
				Result := regex.captured_substring (1).to_natural
			else
				Result := 0
			end
		end

	parse_data (a_fetch: IL_FETCH): BOOLEAN
			-- Parse the data from fetch and add it to `a_fetch'.
			-- Returns true iff the fetch is complete
		require
			a_fetch_not_void: a_fetch /= Void
		do
			fetch := a_fetch
			regex.compile (Fetch_end_pattern)
			if regex.matches (text) then
				Result := true
			else
				regex.compile (Complete_fetch_pattern)

				if regex.matches (text) then
					text := regex.captured_substring (1)
					Result := true
				else
					fetch_bodyb
					Result := false
				end
				fetch_bodystructure
				fetch_body
				fetch_envelope
				fetch_internaldate
				fetch_flags
				fetch_size
				fetch_uid
			end

		end

feature {NONE} -- Constants

	Bodyb_pattern: STRING = ".*(BODY(\.PEEK)?(\[.*])|RFC822|RFC822\.HEADER|RFC822.TEXT) {(\d+)}%R%N"

	Body_pattern: STRING = ".*(BODY) \((((?![A-Z] \().)*)\)"

	Flags_pattern: STRING = ".*(FLAGS) \(([^)]*)\)"

	Bodystructure_pattern: STRING = ".*(BODYSTRUCTURE) \((((?![A-Z] \().)*)\)"

	Envelope_pattern: STRING = ".*(ENVELOPE) \(((%"[^%"]*%" ?|\((\((%"[^%"]*%" ?|NIL ?)+\))+\) ?|NIL ?)+)\)"

	Internaldate_pattern: STRING = ".*(INTERNALDATE) %"([^%"]*)%""

	Size_pattern: STRING = ".*(RFC822\.SIZE) (\d+)"

	Uid_pattern: STRING = ".*(UID) (\d+)"

	Fetch_end_pattern: STRING = "^ ?\)%R%N$"

	Complete_fetch_pattern: STRING = "^\* \d+ FETCH \(([^{]*)\)%R%N$"

feature {NONE} -- Implementation

	fetch: IL_FETCH

	fetch_body
			-- Parses body data if text matches it
		local
			new_data: TUPLE [INTEGER, STRING]
			body: STRING
		do
			regex.compile (Body_pattern)
			if regex.matches (text) then
				body := regex.captured_substring (2)
				create new_data.default_create
				new_data.put (body.count, 1)
				new_data.put (body, 2)
				fetch.data.extend (new_data, regex.captured_substring (1))
			end
		end

	fetch_bodyb
			-- Parses a body data if text matches it
		local
			size: INTEGER
		do
			regex.compile (Bodyb_pattern)
			if regex.matches (text) then
				fetch.set_last_key (regex.captured_substring (1))
				size := regex.captured_substring (4).to_integer
				fetch.last_item.put (size, 1)
				fetch.last_item.put (create {STRING}.make_empty, 2)
				fetch.set_literal_left (size)
			end
		end

	fetch_flags
			-- Parses flags data if text matches it
		local
			new_data: TUPLE [INTEGER, STRING]
			flags: STRING
		do
			regex.compile (Flags_pattern)
			if regex.matches (text) then
				flags := regex.captured_substring (2)
				create new_data.default_create
				new_data.put (flags.count, 1)
				new_data.put (flags, 2)
				fetch.data.extend (new_data, regex.captured_substring (1))
			end
		end

	fetch_bodystructure
			-- Parses bodystructure data if text matches it
		local
			new_data: TUPLE [INTEGER, STRING]
			bodystructure: STRING
		do
			regex.compile (Bodystructure_pattern)
			if regex.matches (text) then
				bodystructure := regex.captured_substring (2)
				create new_data.default_create
				new_data.put (bodystructure.count, 1)
				new_data.put (bodystructure, 2)
				fetch.data.extend (new_data, regex.captured_substring (1))
			end
		end

	fetch_envelope
			-- Parses envelope data if text matches it
		local
			new_data: TUPLE [INTEGER, STRING]
			envelope: STRING
		do
			regex.compile (Envelope_pattern)
			if regex.matches (text) then
				envelope := regex.captured_substring (2)
				create new_data.default_create
				new_data.put (envelope.count, 1)
				new_data.put (envelope, 2)
				fetch.data.extend (new_data, regex.captured_substring (1))
			end
		end

	fetch_internaldate
			-- Parses internaldate data if text matches it
		local
			new_data: TUPLE [INTEGER, STRING]
			internaldate: STRING
		do
			regex.compile (Internaldate_pattern)
			if regex.matches (text) then
				internaldate := regex.captured_substring (2)
				create new_data.default_create
				new_data.put (internaldate.count, 1)
				new_data.put (internaldate, 2)
				fetch.data.extend (new_data, regex.captured_substring (1))
			end
		end

	fetch_size
			-- Parses size data if text matches it
		local
			new_data: TUPLE [INTEGER, STRING]
			size: STRING
		do
			regex.compile (Size_pattern)
			if regex.matches (text) then
				size := regex.captured_substring (2)
				create new_data.default_create
				new_data.put (size.count, 1)
				new_data.put (size, 2)
				fetch.data.extend (new_data, regex.captured_substring (1))
			end
		end

	fetch_uid
			-- Parses uid data if text matches it
		local
			new_data: TUPLE [INTEGER, STRING]
			a_uid: STRING
		do
			regex.compile (Uid_pattern)
			if regex.matches (text) then
				a_uid := regex.captured_substring (2)
				create new_data.default_create
				new_data.put (a_uid.count, 1)
				new_data.put (a_uid, 2)
				fetch.data.extend (new_data, regex.captured_substring (1))
			end
		end

note
	copyright: "2015-2016, Maret Basile, Eiffel Software"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

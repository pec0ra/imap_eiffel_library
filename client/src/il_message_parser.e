note
	description: "A parser to put the data of a fetch in a message"
	author: "Basile Maret"

class
	IL_MESSAGE_PARSER

inherit
	IL_PARSER

create
	make_from_fetch

feature {NONE} -- Initialization

	make_from_fetch (a_fetch: IL_FETCH)
			-- Create the parser from the result of a fetch
		require
			a_fetch_not_void: a_fetch /= Void
		do
			create regex.make
			create text.make_empty
			fetch := a_fetch
		ensure
			fetch_set: fetch = a_fetch
		end

feature -- Basic operaion

	get_from: IL_ADDRESS
			-- Parse the from field from the envelope
		local
			envelope: STRING
			addresses: STRING
		do
			create Result.make_empty
			envelope := fetch.get_value (envelope_data_item)
			regex.compile (envelope_pattern)
			if regex.matches (envelope) then
				addresses := regex.captured_substring (6)
				regex.compile (Address_pattern)
				if regex.matches (addresses) then
					Result := address_from_matched_regex
				end
			end
		end

	get_addresses_from_envelope (a_position: INTEGER): LIST [IL_ADDRESS]
			-- Return a list of addresses parsed from the `a_position'-th field of the envelope
		require
			correct_position: a_position >= 1 and then a_position <= 6
		local
			envelope: STRING
			addresses: STRING
			address: IL_ADDRESS
		do
			create {LINKED_LIST [IL_ADDRESS]}Result.make
			envelope := fetch.get_value (envelope_data_item)
			regex.compile (envelope_pattern)
			if regex.matches (envelope) then
				addresses := regex.captured_substring (6 + 3 * (a_position - 1))
				from
					regex.compile (Address_pattern)
					regex.match (addresses)
				until
					not regex.has_matched
				loop
					address := address_from_matched_regex
					if not address.address.is_empty then
						Result.extend (address)
					end
					regex.next_match
				end
			end
		end

	subject: STRING
			-- Parse the subject from the envelope
		local
			envelope: STRING
		do
			create Result.make_empty
			envelope := fetch.get_value (envelope_data_item)
			regex.compile (envelope_pattern)
			if regex.matches (envelope) then
				Result := regex.captured_substring (4)
			end
		end

	date: DATE_TIME
			-- Parse the date from the envelope
		local
			date_s: STRING
		do
			date_s := date_string
			regex.compile (date_pattern)
			if regex.matches (date_s) then
				create Result.make (regex.captured_substring (3).to_integer, months.at (regex.captured_substring (2)), regex.captured_substring (1).to_integer, regex.captured_substring (4).to_integer, regex.captured_substring (5).to_integer, regex.captured_substring (6).to_integer)
			else
				create Result.make (1970, 1, 1, 0, 0, 0)
			end
		end

	date_string: STRING
			-- Parse the date from the envelope
		local
			envelope: STRING
		do
			envelope := fetch.get_value (envelope_data_item)
			regex.compile (envelope_pattern)
			if regex.matches (envelope) then
				Result := regex.captured_substring (2)
			else
				create Result.make_empty
			end
		end

	internaldate: DATE_TIME
			-- Parse the internaldate
		local
			date_s: STRING
		do
			date_s := fetch.get_value (internaldate_data_item)
			regex.compile (Internaldate_pattern)
			if regex.matches (date_s) then
				create Result.make (regex.captured_substring (3).to_integer, months.at (regex.captured_substring (2)), regex.captured_substring (1).to_integer, regex.captured_substring (4).to_integer, regex.captured_substring (5).to_integer, regex.captured_substring (6).to_integer)
			else
				create Result.make (1970, 1, 1, 0, 0, 0)
			end
		end

	body_field (a_substring_number: INTEGER): STRING
			-- Returns the `a_substring_number'-th part of the BODY
		require
			correct_number: a_substring_number >= 1 and a_substring_number <= 18
		local
			body: STRING
		do
			body := fetch.get_value (body_data_item)
			regex.compile (Body_pattern)
			if regex.matches (body) then
				Result := regex.captured_substring (a_substring_number)
			else
				create Result.make_empty
			end
		end

feature {NONE} -- Constants

	Envelope_pattern: STRING = "^(%"([^%"]*)%"|NIL) (%"([^%"]*)%"|NIL) (\((\((%"[^%"]*%" ?|NIL ?)+\)+)\)|NIL) (\((\((%"[^%"]*%" ?|NIL ?)+\)+)\)|NIL) (\((\((%"[^%"]*%" ?|NIL ?)+\)+)\)|NIL) (\((\((%"[^%"]*%" ?|NIL ?)+\)+)\)|NIL) (\((\((%"[^%"]*%" ?|NIL ?)+\)+)\)|NIL) (\((\((%"[^%"]*%" ?|NIL ?)+\)+)\)|NIL) (\((\((%"[^%"]*%" ?|NIL ?)+\)+)\)|NIL) (%"[^%"]*%"|NIL)$"
			-- Represents the content of an ENVELOPE data item
			-- Example : "Mon, 16 Nov 2015 11:52:34 +0100" "subject" (("Basile Maret" NIL "basile.maret" "server.ch")) (("Basile Maret" NIL "basile.maret" "server.ch")) (("Basile Maret" NIL "basile.maret" "server.ch")) ((NIL NIL "someone.else" "server.com")) NIL NIL NIL "<5649B572.1070608@server.ch>"

	Address_pattern: STRING = "\((%"([^%"]*)%"|NIL) (%"[^%"]*%"|NIL) (%"([^%"]*)%"|NIL) (%"([^%"]*)%"|NIL)\)"
			-- Represents an address in an envelope
			-- Example : ("Basile Maret" NIL "basile.maret" "server.ch")

	Body_pattern: STRING = "(%"([^%"]*)%"|NIL) (%"([^%"]*)%"|NIL) \((((%"([^%"]*)%"|NIL) (%"([^%"]*)%"|NIL) ?)+)\) (%"([^%"]*)%"|NIL) (%"([^%"]*)%"|NIL) (%"([^%"]*)%"|NIL) (\d+|NIL) ?(\d+|NIL)?"
			-- Represents the BODY data item of a single part message
			-- Example : "text" "plain" ("charset" "utf-8" "format" "flowed") NIL NIL "7bit" 6 1

	Internaldate_pattern: STRING = "(\d?\d)-([A-Z][a-z][a-z])-(\d\d\d\d) (\d?\d):(\d\d):(\d\d)"
			-- Only for INTERNALDATE. For the pattern to parse header's date, look at `Date_pattern'
			-- Represents a date of the INTERNALDATE data item
			-- Example : 16-Nov-2015 11:52:34 +0100

feature {NONE} -- Implementation

	address_from_matched_regex: IL_ADDRESS
			-- Return an address from `regex' if it has matched
		require
			regex.has_matched
		local
			name: STRING
			address: STRING
		do
			name := regex.captured_substring (2)

			if regex.captured_substring (4) /~ "NIL" and regex.captured_substring (6) /~ "NIL" then
				address := regex.captured_substring (5) + "@" + regex.captured_substring (7)
			else
				create address.make_empty
			end
			create Result.make_with_name_and_address (name, address)
		end

	fetch: IL_FETCH

;note
	copyright: "2015-2016, Maret Basile, Eiffel Software"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

note
	description: "A parser the message header"
	author: "Basile Maret"

class
	IL_HEADER_PARSER


inherit
	IL_PARSER

create
	make_from_text


feature -- Basic operation

	from_field: TUPLE [STRING, STRING]
			-- Returns a tuple of the name and the email address if `text' matches a from header field
		do
			create Result.default_create
			regex.compile (From_pattern)
			if regex.matches (text) then
				Result.item (Result.lower) := regex.captured_substring (2)
				Result.item (Result.upper) := regex.captured_substring (3)
			else
				Result.item (Result.lower) := ""
				Result.item (Result.upper) := ""
			end
		end

	to_field: TUPLE [STRING, STRING]
			-- Returns a tuple of the name and the email address if `text' matches a to header field
		do
			create Result.default_create
			regex.compile (To_pattern)
			if regex.matches (text) then
				Result.item (Result.lower) := regex.captured_substring (2)
				Result.item (Result.upper) := regex.captured_substring (3)
			else
				Result.item (Result.lower) := ""
				Result.item (Result.upper) := ""
			end
		end

	subject_field: STRING
			-- Returns the content of a subject field if `text' matches a subject header fied
		do
			regex.compile (Subject_pattern)
			if regex.matches (text) then
				Result := regex.captured_substring (2)
			else
				create Result.make_empty
			end
		end

	date_field: DATE_TIME
			-- Returns the date of the mesage
		do
			regex.compile (Date_pattern)
			if regex.matches (text) then
				create Result.make (regex.captured_substring (4).to_integer, months.at (regex.captured_substring (3)), regex.captured_substring (2).to_integer, regex.captured_substring (5).to_integer, regex.captured_substring (6).to_integer, regex.captured_substring (7).to_integer)
			else
				create Result.make (1970, 1, 1, 0, 0, 0)
			end
		end


feature {NONE} -- Constants

	From_pattern: STRING = "(from|From): (.*) <(.+@.+\..+)>"
	To_pattern: STRING = "(to|To): (.*)? ?<(.+@.+\..+)>"
	Subject_pattern: STRING = "(subject|Subject): (((?!%R).)*)"
	Date_pattern: STRING = "(date|Date): [A-Za-z]+, (\d?\d) ([A-Z][a-z][a-z]) (\d\d\d\d) (\d?\d):(\d\d):(\d\d) \+\d+"

feature {NONE} -- Implementation

	months: STRING_TABLE[INTEGER]
			-- maps the months abreviation to their number
		once
			create Result.make (12)
			Result.put (1, "Jan")
			Result.put (2, "Feb")
			Result.put (3, "Mar")
			Result.put (4, "Apr")
			Result.put (5, "May")
			Result.put (6, "Jun")
			Result.put (7, "Jul")
			Result.put (8, "Aug")
			Result.put (9, "Sep")
			Result.put (10, "Oct")
			Result.put (11, "Nov")
			Result.put (12, "Dec")
		end

end

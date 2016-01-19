note
	description: "The content of a FETCH response"
	author: "Basile Maret"
	EIS: "name=FETCH command", "protocol=URI", "src=https://tools.ietf.org/html/rfc3501#section-6.4.5"
	EIS: "name=FETCH response", "protocol=URI", "src=https://tools.ietf.org/html/rfc3501#section-7.4.2"

class
	IL_FETCH

create
	make_with_uid

feature {NONE} -- Initialization

	make_with_uid (a_uid: NATURAL)
			-- set `uid' to `a_uid'
		do
			uid := a_uid
			create data.make (0)
		ensure
			uid_set: uid = a_uid
		end

feature -- Access

	uid: NATURAL
			-- The unique id of the fetched message

	data: STRING_TABLE [STRING]
			-- Matches data item names to their value

end

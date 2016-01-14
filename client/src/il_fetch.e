note
	description: "Summary description for {IL_FETCH}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_FETCH

create
	make_with_uid

feature {NONE} -- Initialization

	make_with_uid ( a_uid: NATURAL )
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

	data: HASH_TABLE[STRING, STRING]
			-- Matches data item names to their value
end

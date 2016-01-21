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
			create last_key.make_empty
			create last_item.default_create
		ensure
			uid_set: uid = a_uid
		end

feature -- Access

	uid: NATURAL
			-- The unique id of the fetched message

	data: STRING_TABLE [TUPLE [INTEGER, STRING]]
			-- Matches data item names to their size and value

	last_key: STRING
			-- the key of the last data being added

	last_item: TUPLE [INTEGER, STRING]
			-- the last data to be added

	literal_left: INTEGER
			-- The remaining chars that the last item still needs


feature -- Basic operation

	add_data (a_data_table: STRING_TABLE [TUPLE [INTEGER, STRING]])
			-- Set `data' to `a_data_table'
		require
			a_data_table_not_void: a_data_table /= Void
		do
			across
				a_data_table as a_data
			loop
				data.extend (a_data.item, a_data.key)
			end
		end

	set_last_key (a_last_key: STRING)
		require
			a_last_key_not_empty: a_last_key /= Void and then not a_last_key.is_empty
		do
			last_key := a_last_key
		end

	set_literal_left (a_size: INTEGER)
		require
			a_size >=0
		do
			literal_left := a_size
		end

	add_literal (a_literal: STRING)
			-- Add `a_literal' to complete the last received fetch response
		require
			a_literal_not_void: a_literal /= Void
			needs_literal: last_key /= Void and then not last_key.is_empty
			needs_literal_2: last_item /= Void and then attached {STRING} last_item.at (2)
			a_literal_not_too_long: a_literal.count <= literal_left
		do
			if attached {STRING} last_item.at (2) as response then
				response.append (a_literal)
				literal_left := literal_left - a_literal.count

				if literal_left = 0 then
					data.put (last_item, last_key)
					create last_key.make_empty
					create last_item.default_create
				end
			end
		ensure
			literal_added: literal_left = old literal_left - a_literal.count
		end

invariant
	literal_left >= 0
end

note
	description: "Summary description for {MAILBOX}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IL_NAME

create
	make_with_raw_path

feature -- Initialization

	make_with_raw_path (a_raw_path: STRING)
			-- Create a new mailbox with `a_raw_path'
		require
			a_raw_path_not_empty: a_raw_path /= Void and then not a_raw_path.is_empty
		do
			create name.make_empty
			raw_path := a_raw_path
			create path.make
			create attributes.make
		end

feature -- Access

	name: STRING

	raw_path: STRING

	path: LINKED_LIST[STRING]

	hierarchy_delimiter: CHARACTER

	attributes: LINKED_LIST[STRING]

feature -- Basic Operations

	set_name (a_name: STRING)
			-- Set `name' to `a_name'
		require
			name_not_empty: a_name /= Void and then not a_name.is_empty
		do
			name := a_name
		end

	set_hierarchy_delimiter (a_hierarchy_delimiter: CHARACTER)
		do
			hierarchy_delimiter := a_hierarchy_delimiter
		end

	add_path_level (a_folder_name: STRING)
			-- Add `a_folder_name' to the list `path'
		require
			a_folder_name_not_empty: a_folder_name /= Void and then not a_folder_name.is_empty
		do
			path.extend (a_folder_name)
		end

	add_attribute (a_attribute: STRING)
			-- Add `a_attribute' to `attributes'
		require
			a_attribute_not_empty: a_attribute /= Void and then not a_attribute.is_empty
		do
			attributes.extend (a_attribute)
		end


end

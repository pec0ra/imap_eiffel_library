note
	description: "A network connection using SSL"
	author: "Basile Maret"

class
	IL_SSL_NETWORK

inherit

	IL_NETWORK
		redefine
			socket
		end

create
	make_with_address_and_port

feature -- Access

	socket: SSL_NETWORK_STREAM_SOCKET
			-- The main connection to the server

end

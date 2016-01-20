# IMAP client library

## Introduction
This repository contains an open source Eiffel library to connect to a server with the Internet Message Access Protocol.

This library provides an easy access to almost all the commands of IMAP4rev1 and the server responses and allows to send custom commands.

## Contents
* **src** : Contains the library classes
* **examples** : Contains examples of how to use the library

## Getting started

To use the Eiffel IMAP client library, add it to your project and instantiate an object of type `IMAP_CLIENT_LIB`

### Simple example
Here is a simple example to connect to a server, login, open the mailbox "INBOX" and logout :
```
	an_example
		local
			imap: IMAP_CLIENT_LIB
		do
			create imap.make_ssl_with_address ("your_server.com")
			imap.connect

			if imap.is_connected then
				imap.login ("username", "password")
				imap.select ("INBOX")
				print (imap.current_mailbox.name) -- INBOX
				imap.logout
			end
		end
```

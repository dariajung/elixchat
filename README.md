#ElixChat
-----

A command-line chat system written in the Elixir programming language.

####Usage
----

####Starting the client and examples

```elixir
Usage:
  elixir --sname bar -S mix run -e "Elixclient.main" -- -s <server> [-u <username>]

Example:
  elixir --sname bar -S mix run -e "Elixclient.main" -- -s foo@Caturday

Options:
  -s, --server: shortname for server on local network
  -u, --username: username (an optional argument, will be asked for a username)

Example:
  elixir --sname bar -S mix run -e "Elixclient.main" -- -s foo@Caturday -u daria

Options:
  -h, --help: Shows this usage information and quits.
```

####Starting the server:
```elixir
iex --sname foo -S mix
```


####Notes
-----
- `mix` does not take a shortname. 
- Currently only tested within a local network.

####Resources
-----
- [A Chat Client and Server Example](http://drew.kerrigan.io/distributed-elixir/)

defmodule Elixclient do
    use GenServer

    def main(args \\ System.argv) do 
        args |> parse_options |> process_action
    end

    def parse_options(argv) do 
        switches = [
            help: :boolean,
            username: :string,
            server: :string
        ]

        aliases = [
            h: :help,
            u: :username,
            s: :server
        ]

        opts = OptionParser.parse(argv, switches: switches, aliases: aliases)

        case opts do 
            {[help: true], _, _ }                           -> :help
            {[server: server], _, _}                        -> [server]
            {[username: username, server: server], _, _}    -> [username, server]
            {[server: server, username: username], _, _}    -> [username, server]
            _                                               -> :help
        end
    end

    def process_action(:help) do 
        IO.puts """
        Usage:
            elixir --sname bar -S mix run -e "Elixclient.main" -- -s <server> [-u <username>]

        Example:
            elixir --sname bar -S mix run -e "Elixclient.main" -- -s foo@Caturday

        Options:
            -s, --server: shortname for server on local network
            -u, --username: username (an optional argument)

        Example:
            elixir --sname bar -S mix run -e "Elixclient.main" -- -s foo@Caturday -u daria

        Options:
            -h, --help: Shows this usage information and quits.
        """
    end

    def process_action([server]) do
        IO.puts("got server, need username")
        process_action([nil, server])
    end

    def process_action([username, server]) do
        server = case server do 
            nil -> IO.gets("Please enter server to connect to: \n")
            s   -> s 
        end
        server = String.to_atom(String.rstrip(server))
        IO.puts("#{inspect self()}")

        IO.puts("Connecting to #{inspect server}\n")
        case Node.connect(server) do 
            true -> :ok
            no   ->     
                IO.puts "Could not connect to server, reason: #{inspect no}"
                System.halt()
        end

        Elixclient.MessageHandler.start_link(server)

        username = case username do 
            nil -> IO.gets("Please enter username: \n")
            u   -> u 
        end

        username = String.rstrip(username)

        case GenServer.call({:message_server, server}, {:connect, username}) do 
            {:ok, users} -> 
                IO.puts("**Joined the chatroom**")
                IO.puts("**Users in room: #{inspect users}**")
                IO.puts("use /help for commands")
            reason -> 
                IO.puts("Something went wrong, reason: #{inspect reason}")
        end

        loop_acceptor(server, username)
    end

    def loop_acceptor(server, username) do
        IO.puts("inside loop_acceptor\n") 
        action = IO.gets("#{inspect self()}> \n")
        action = String.rstrip(action)
        handle_action(action, server, username)

        loop_acceptor(server, username)
    end

    def handle_action(action, server, username) do 
        case action do 
            "/help" -> 
                IO.puts """
                /quit or /leave to leave the chat
                /join to connect to chat room
                or just type to send a message. 
                """
            "/quit" -> 
                GenServer.call({:message_server, server}, {:disconnect, username})
            "/leave" ->
                GenServer.call({:message_server, server}, {:disconnect, username})
            "/join" -> 
                GenServer.call({:message_server, server}, {:connect, username})
            "" -> 
                :ok
            nil -> 
                :ok
            msg -> 
                GenServer.cast({:message_server, server}, {:say, username, msg})
        end
    end
end

defmodule Elixclient.MessageHandler do 
    use GenServer

    def start_link(server) do 
        GenServer.start_link(__MODULE__, server, [name: :message_handler])
    end

    def init(server) do 
        {:ok, server}
    end

    def handle_call(_, _, server) do
        {:reply, :error, server}
    end

    def handle_cast({:message, user, msg}, server) do 
        msg = String.rstrip(msg)
        IO.puts("\n#{inspect server} > #{inspect user}: #{inspect msg}")
        IO.puts("\n#{inspect node()} > ")
        {:noreply, server}
    end

    def handle_cast(_, server) do 
        {:noreply, server}
    end

end
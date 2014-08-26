defmodule Elixclient do
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
            mix run -e "Elixclient.main" -- -s <server> [-u <username>]

        Example:
            mix run --sname bar -e "Elixclient.main" -- -s foo@Caturday

        Options:
            -s, --server: shortname for server on local network
            -u, --username: username (an optional argument)

        Example:
            mix run --sname bar -e "Elixclient.main" -- -s foo@Caturday -u daria

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

        #connect to server first
        username = case username do 
            nil -> IO.gets("Please enter username: \n")
            u   -> u 
        end

        username = String.rstrip(username)

        IO.puts("#{inspect username}")
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
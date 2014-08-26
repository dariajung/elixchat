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

        Options:
            -s, --server: longname for server
            -u, --username: username (an optional argument)

        Options:
            -h, --help: Shows this usage information and quits.
        """
    end

    def process_action([server]) do
        IO.puts("got server")
    end

    def process_action([username, server]) do 
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
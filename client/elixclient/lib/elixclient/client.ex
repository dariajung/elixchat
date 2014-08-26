defmodule ElixClient do
    def connect() do 
    end
end

defmodule ElixClient.MessageHandler do 
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
defmodule ElixChat.Server do
    use GenServer

    def start_link(opts \\ []) do
        # opts = [name: :message_server]
        GenServer.start_link(__MODULE__, [], opts)
    end

    def init([]) do 
        users = HashDict.new()
        {:ok, users}
    end

    def handle_call({:connect, user}, {pid, _}, users) do 
        cond do 
            user == :server or user == "server" -> 
                {:reply, :username_not_allowed, users}
            HashDict.has_key?(users, user) -> 
                {:reply, :username_in_use, users}
            true ->
                # create new node with user
                new_users = HashDict.put(users, user, node(pid))
                current_users = Enum.join(HashDict.keys(new_users), ", ")
                IO.puts("#{inspect user} has joined #{inspect current_users}.")
                request = {:say, :server, "#**{inspect user} has joined the chat**"}
                GenServer.cast(:message_server, request)
                {:reply, {:ok, current_users}, new_users}
        end
    end

    # def handle_call() do
    # end

    def handle_cast() do 
    end

    # def handle_cast() do 
    # end

end
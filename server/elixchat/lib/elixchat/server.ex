defmodule Elixchat.Server do
    use GenServer

    def start_link(opts) do
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
                IO.puts("#{inspect user} has joined, current users: #{inspect current_users}.")

                request = {:say, :server, "#**{inspect user} has joined the chat**"}
                GenServer.cast(:message_server, request)
                {:reply, {:ok, current_users}, new_users}
        end
    end

    def handle_call({:disconnect, user}, {pid, _}, users) do
        to_delete = HashDict.get(user, users)

        cond do
            to_delete == nil -> 
                {:reply, :no_such_user, users}
            to_delete == node(pid) ->
                new_users = HashDict.delete(user, users)
                current_users = Enum.join(HashDict.keys(new_users), ", ")

                IO.puts("#{inspect user} has left, current users: #{inspect current_users}.")

                request = {:say, :server, "#**{inspect user} has left the chat**"}
                GenServer.cast(:message_server, request)
                {:reply, {:ok, current_users}, new_users}
        end
    end

    defp broadcast(listeners, from_user, msg) do 
        Enum.each(listeners, fn {_name, node} -> GenServer.cast({:message_client, node}, {:message, from_user, msg }) end)
    end

    def handle_cast({:say, user, msg}, users) do
        listeners = HashDict.delete(user, users)

        IO.puts("#{inspect user}: #{inspect msg}")
        broadcast(listeners, user, "#{inspect msg}")
        {:noreply, users}
    end

    # no private messages yet
    # def handle_cast() do 
    # end

end
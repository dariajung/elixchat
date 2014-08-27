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
                IO.puts("#{inspect user} has joined\ncurrent users: #{inspect current_users}.")

                request = {:say, :server, "**#{inspect user} has joined the chat**"}
                GenServer.cast(:message_server, request)
                {:reply, {:ok, current_users}, new_users}
        end
    end

    def handle_call({:disconnect, user}, {pid, _}, users) do
        to_delete = HashDict.get(users, user)

        cond do
            to_delete == nil -> 
                {:reply, :no_such_user, users}
            to_delete == node(pid) ->
                IO.puts("#{inspect user}")
                new_users = HashDict.delete(users, user)
                current_users = Enum.join(HashDict.keys(new_users), ", ")

                IO.puts("#{inspect user} has left, current users: #{inspect current_users}.")

                request = {:say, :server, "**#{inspect user} has left the chat**"}
                GenServer.cast(:message_server, request)
                {:reply, {:ok, current_users}, new_users}
        end
    end

    def handle_cast({:say, user, msg}, users) do
        listeners = HashDict.delete(users, user)

        IO.puts("#{inspect user}: #{inspect msg}")
        broadcast(listeners, user, "#{inspect msg}")
        {:noreply, users}
    end

    defp broadcast(listeners, from_user, msg) do 
        Enum.each(listeners, fn {_name, node} -> GenServer.call({:message_handler, node}, {:message, from_user, msg }) end)
    end

    # no private messages yet
    # def handle_cast() do 
    # end

end
defmodule Elixchat.Supervisor do 
    use Supervisor

    def init(_opt) do
        children = [
            worker(Elixchat.Server, [[name: :message_server]])
        ]
        supervise(children, strategy: :one_for_one)
    end

    def start_link do
        Supervisor.start_link(__MODULE__, [])
    end

end
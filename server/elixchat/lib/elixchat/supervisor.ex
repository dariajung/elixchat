defmodule ElixChat.Supervisor do 
    use Supervisor

    def init([]) do
        children = [
            worker(ElixChat.Server, [[]])
        ]
        supervise(children, strategy: :one_for_one)
    end

    def start_link do
        Supervisor.start_link(__MODULE__, :ok)
    end

end
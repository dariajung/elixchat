defmodule Elixchat do
    use Application

    def start(_, _) do 
        Elixchat.Supervisor.start_link()
    end
end

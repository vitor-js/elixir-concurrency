defmodule Concurrency do
  alias Mix.Tasks

  def soma(a, b) do
    result = a + b
    IO.puts("#{result}")
  end

  @spec escuta :: :ok
  def escuta do
    receive do
      {:message_type, value} ->
        IO.puts(value)

      {:soma, a, b} ->
        soma(a, b)
    end

    exit(:morreu)
  end

  def send_message(pid, message) do
    send(pid, {:finish, message})
  end

  def init_spawn() do
    spawn_link(__MODULE__, :escuta, [])
  end

  def init_spawn_link() do
    Process.flag(:trap_exit, true)
    pid = spawn_link(__MODULE__, :escuta, [])
    :timer.sleep(1000)

    send(pid, {:soma, 2, 3})

    receive do
      {:EXIT, _pid, razao} ->
        IO.puts("Processo encerrado por motivo de #{razao}")
    end
  end

  def init_spaw_monitor() do
    {pid, _ref} = spawn_monitor(__MODULE__, :escuta, [])
    :timer.sleep(1000)

    send(pid, {:soma, 2, 3})

    receive do
      message ->
        IO.inspect(message)
    end
  end

  def send_message_for_soma(pid, a, b) do
    send(pid, {:soma, a, b})
  end

  def init_agent() do
    # {:ok, pid} = Agent.start_link(fn -> [1, 2, 3] end)
    Agent.start_link(fn -> [1, 2, 3] end, name: Agente)
  end

  def obter_agent() do
    #  Agent.get(pid, fn x -> x end)
    Agent.get(Agente, fn x -> x end)
  end

  @spec init_task :: any
  def init_task() do
    ## Executa em paralelo
    pid1 = Task.async(__MODULE__, :soma, [1, 2])
    pid2 = Task.async(__MODULE__, :soma, [5, 6])

    ## Executa em esteira
    IO.inspect(Task.await(pid1), label: "pid1")
    IO.inspect(Task.await(pid2), label: "pid2")
  end
end

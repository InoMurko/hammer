defmodule Interval do
  use GenServer
  use Timex
  alias Blitzy.TasksSupervisor
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(state) do
    state =
      state
      |> Map.put_new(:interval, 5_000)
      |> Map.put_new(:schedule, nil)

    # optional; to be called if the first message
    #           from outside expects the periodic
    #           function to be called at least once
    {:noreply, state} = handle_info(:work, state)
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:work, state) do
    # process periodic event

    # optional; to allow calling it from outside without
    #           setting many subsequent timers
    # if is_reference(state.schedule),
    #   do: Process.cancel_timer(state.schedule)
    req_per_node = Map.get(state, :req_per_node)
    url = Map.get(state, :url)
{timestamp, _} = Duration.measure(fn ->
    1..req_per_node
    |> Enum.map(fn _ ->
           Task.Supervisor.async(TasksSupervisor, Blitzy.Worker, :start, [url])
         end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> parse_results
end)
IO.puts """
Batch duration (with result parsing) #{Duration.to_milliseconds(timestamp)} msec
"""
    {:noreply, Map.put(state, :schedule, schedule_work(state.interval))}
  end

  @spec schedule_work(interval :: non_neg_integer()) :: :error | reference()
  defp schedule_work(interval) when is_integer(interval) and interval > 0 do
     Process.send_after(self(), :work, interval)
  end

  def parse_results(results) do
    {successes, _failures} =
      results
        |> Enum.partition(fn x ->
             case x do
               {:ok, _} -> true
               _        -> false
           end
         end)

    total_workers = Enum.count(results)
    total_success = Enum.count(successes)
    total_failure = total_workers - total_success

    data = successes |> Enum.map(fn {:ok, time} -> time end)
    average_time  = average(data)
    longest_time  = Enum.max(data)
    shortest_time = Enum.min(data)

    IO.puts """
    Total workers    : #{total_workers}
    Successful reqs  : #{total_success}
    Failed reqs      : #{total_failure}
    Average (msecs)  : #{average_time}
    Longest (msecs)  : #{longest_time}
    Shortest (msecs) : #{shortest_time}
    """
  end

  def average(list) do
    sum = Enum.sum(list)
    if sum > 0 do
      sum / Enum.count(list)
    else
      0
    end
  end

end

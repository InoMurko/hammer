defmodule Blitzy.CLI do
  alias Blitzy.TasksSupervisor
  require Logger

  def main(args) do
    Application.get_env(:blitzy, :master_node)
      |> Node.start

    Application.get_env(:blitzy, :slave_nodes)
      |> Enum.each(&Node.connect(&1))

    args
      |> parse_args
      |> process_options([node()|Node.list])
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests],
                              strict: [requests: :integer])
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n], [url], []} ->
        do_requests(n, url, nodes)

      _ ->
        Logger.info "Wrong #{options}"
        do_help()

    end
  end

  defp do_requests(n_requests, url, _) do
    Logger.info "Pummelling #{url} with #{n_requests} requests"
    Interval.start_link(%{req_per_node: n_requests, url: url})
    Process.sleep(20_000)
  end

  defp do_help() do
    IO.puts """
    Usage:
    blitzy -n [requests] [url]

    Options:
    -n, [--requests]      # Number of requests

    Example:
    ./blitzy -n 100 http://www.bieberfever.com
    """
    System.halt(0)
  end

end

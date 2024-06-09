defmodule Blitzy.CLI do
  alias Blitzy.TasksSupervisor
  require Logger

  def main(args) do
    args
      |> parse_args
      |> process_options()
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests],
                              strict: [requests: :integer])
  end

  defp process_options(options) do
    case options do
      {[requests: n], [url], []} ->
        do_requests(n, url)

      _ ->
        Logger.info "Wrong #{options}"
        do_help()

    end
  end

  defp do_requests(n_requests, url) do
    Logger.info "Pummelling #{url} with #{n_requests} requests"
    Interval.start_link(%{req_per_node: n_requests, url: url})
    #kill it with exit signal, hacky but cute
    Process.sleep(:infinity)
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

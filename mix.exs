defmodule Blitzy.Mixfile do
  use Mix.Project

  def project do
    [app: :blitzy,
     version: "0.0.1",
     elixir: "~> 1.8",
     escript: escript(),
     deps: deps()]
  end

  def escript() do
    [main_module: Blitzy.CLI]
  end

  def application do
    [mod: {Blitzy, []},
     applications: [:logger, :httpoison, :timex, :jason, :tzdata]]
  end

  defp deps() do
    [
      {:httpoison, "~> 2.2.1"},
      {:timex,     "~> 3.7.1"},
      {:jason,     "~> 1.4.1"},
      {:tzdata, git: "https://github.com/InoMurko/tzdata", ref: "b9c5f9378dbe450d34c1b0f025f83aa57b8a89a3", override: true}
    ]
  end
end

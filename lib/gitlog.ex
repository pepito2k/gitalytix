defmodule GitLog do
  require IEx

  def main do
    get_log() |> get_blocks |> parse_git_log
  end

  defp parse_git_log(blocks) do
    IEx.pry
  end

  defp get_log do
    log = System.cmd "git", ["log", "--numstat", "--pretty='%H %ai %an <%ae> %s'"]
    elem(log, 0)
  end

  defp get_blocks(log_string) do
    commits = Regex.scan(~r/([a-f0-9]{40})/, log_string)
    commits = Enum.map(commits, fn x -> List.first(x) end)
    blocks  = Regex.split(~r/[a-f0-9]{40}/, log_string)
    blocks  = Enum.map(blocks, fn x -> String.strip(x) end)
    blocks  = Enum.drop(blocks, 1) # Get rid of the first empty string
    Enum.zip(commits, blocks)
  end
end

defmodule GitLog do
  def parse_git_log do

  end

  def get_log do
    log = System.cmd "git", ["log", "--numstat", "--pretty='%H %ai %an <%ae> %s'"]
    elem(log, 0)
  end

  def get_blocks(log_string) do
    commits = Regex.scan(~r/([a-f0-9]{40})/, log_string)
    blocks  = Regex.split(~r/[a-f0-9]{40}/, log_string)
  end
end

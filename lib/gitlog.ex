defmodule GitLog do
  require IEx

  def main do
    get_log() |> get_commits |> parse_git_log
  end

  defp parse_git_log(commits) do
    authors = Enum.map(commits, fn x -> %{ name: Map.get(x, "name") } end) |> Enum.dedup
    authors = parse_authors(commits, authors, [])

    print_summary(authors)
  end

  defp get_log do
    log = System.cmd "git", ["log", "--numstat", "--pretty=\#%H %aI %an <%ae> %s .::."]
    elem(log, 0)
  end

  defp get_commits(log_string) do
    regex = ~r/^(?<hash>[a-f0-9]{40}) (?<date>.{25}) (?<name>.*?) \<(?<email>.*?)\> (?<subject>.*?) .::.(?<summary>.*)$/mus
    Regex.split(~r/(?<tag>#)[a-f0-9]{40}/, log_string, on: [:tag], trim: true)
    |> Enum.map(fn x -> String.strip(x) end)
    |> Enum.map(fn x -> Regex.named_captures(regex, x) end)
  end

  defp get_author_commits(commits, author) do
    commits |> Enum.filter(fn x -> Map.get(x, "name") == author end)
  end

  defp gregorian_day_for_datetime(datetime) do
    DateTime.to_date(datetime) |> Date.to_erl |> :calendar.date_to_gregorian_days
  end

  defp parse_authors(commits, [author | tail], result) do
    author_commits = get_author_commits(commits, Map.get(author, :name))
    commits_dates = author_commits |> Enum.map(&(Map.get(&1, "date"))) |> Enum.map(&(elem(DateTime.from_iso8601(&1), 1)))

    author = Map.put(author, :count, Enum.count(author_commits))
    author = Map.put(author, :first_commit, Enum.min(commits_dates))
    author = Map.put(author, :last_commit, Enum.max(commits_dates))

    commits_dates_diff = gregorian_day_for_datetime(author[:last_commit]) - gregorian_day_for_datetime(author[:first_commit])
    author = Map.put(author, :date_span, commits_dates_diff)
    author = Map.put(author, :working_days, Enum.count(Enum.dedup(Enum.map(commits_dates, fn x -> DateTime.to_date(x) end))))

    result = [author | result]
    parse_authors(commits, tail, result)
  end

  defp parse_authors(_commits, [], result) do
    result
  end

  defp print_summary([author | tail]) do
    IO.puts "#{Map.get(author, :name)} has made #{Map.get(author, :count)} commits on #{Map.get(author, :working_days)} separate days during a span of #{Map.get(author, :date_span)} days."
    print_summary(tail)
  end

  defp print_summary([]) do

  end
end

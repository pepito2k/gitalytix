defmodule Gitalytix do

  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    GitLog.main
  end

  def process(options) do
    # Here goes code when gitalytix is called with arguments
    options # so the compiler doesn't complain
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [name: :string]
    )
    options
  end

end

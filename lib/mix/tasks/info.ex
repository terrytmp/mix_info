defmodule Mix.Tasks.Info do
  use Mix.Task

  @shortdoc "Display project code info"

  @moduledoc """
  A mix task to display code information like number of modules, functions,
  lines of codes etc
  """
  def run([]) do
    #info is used as an accumulator
    # dirs => -2 so lib and test does not count
    scanned_dirs = ["lib", "test"]
    info =
    scanned_dirs
      |> Enum.map(&process_dir/1)
      |> merge_results

    display(info)
  end

  defp process_dir(path) do
    case File.ls(path) do
      {:ok, content} ->
        #files
        files = content
          |> Enum.map(&(Path.join(path, &1)))
          |> Enum.filter(&(not File.dir?(&1)))

        #process files
        files_info = files
          |> Enum.map(&process_file/1)
          |> merge_results


        #dirs
        dirs_info = content
          |> Enum.map(&(Path.join(path, &1)))
          |> Enum.filter(&File.dir?/1)
          |> Enum.map(&process_dir/1)
          |> merge_results

        merge_results([[{:dir, 1}], dirs_info, files_info])

      {:error, :enoent} -> Mix.Shell.IO.error("#{path} No such file or directory")
    end
  end

  defp process_file(path) do
    [{:file,1}]
  end

  defp display(info) when is_list(info) do
    IO.inspect(info)
  end

  defp merge_results(res) do
    Enum.reduce(res, Keyword.new, fn(res1, res2) ->
      cond do
        res1 == [] and res2 == [] -> []
        res1 == [] -> res2
        res2 == [] -> res1
        true -> Keyword.merge(res1, res2, fn(_, v1, v2) -> v1+v2 end)
      end
    end)
  end

end
defmodule Snaktrip.Video.Download do

  import Plug.Conn, only: [get_req_header: 2]

  @moduledoc """
    House the functionality - that handles video downloads.
      # For the Web Interface.
  """

  def fetch(%{path: path}) do
    fetch_file(path)
  end

  def fetch(path) when is_binary(path) do
    fetch_file(path)
  end

  defp fetch_file(path) when is_binary(path) do
      :httpc.request(:get, { String.to_charlist(path), []}, [], [body_format: :binary])
      |> case do
        {:ok, resp} ->
          {{_, 200, 'OK'}, _headers, body} = resp
          file_name = "#{SecureRandom.uuid}.mp4"
          {body, "priv/tmp/#{file_name}", file_name}
        error ->
          IO.inspect(error)
          raise(ArgumentError, message: "Could not fetch video.")
      end
  end

  # Returns. {:ok, data, path_to_file, file_name}
  def write_file({body, tmp_path, file_name}) do
    File.write!(tmp_path, body)
    {:ok, stats} = File.stat(tmp_path)
    {:ok, stats, tmp_path, file_name}
  end

  def calculate_range(conn, filesize) do
    if Enum.empty?( get_req_header(conn, "range") ) do
      [0, filesize - 1]
    else
      [rn] = get_req_header(conn, "range")
      res = Regex.run(~r/bytes=([0-9]+)-([0-9])?/, rn)
      default_end = Integer.to_string(filesize - 2)
      {range_start, _} = res |> Enum.at(1) |> Integer.parse
      {range_end, _} = res |> Enum.at(2, default_end) |> Integer.parse
      [range_start, range_end]
    end
  end


end

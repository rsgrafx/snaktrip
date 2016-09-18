defmodule Snaktrip.User.Server do

  use Snaktrip.RethinkDB.Helpers

  use GenServer

  def get(pid) do
    GenServer.call(pid, :current_state)
  end

  # Initiating the GenServer process => First by
  # Checking if the user exists ( in RethinkDB )
  def start_link(%{"email" => email}) do
    GenServer.start(__MODULE__, email)
  end

  def init(email) do
    send(self(), :fetch_user_account)
    {:ok, email}
  end

  def handle_call(:current_state, _, state) do
    {:reply, state, state}
  end

  def handle_info(:fetch_user_account, email) do
    user =
      Snaktrip.User.fetch_by(%{email: email})
      |> from_rethink(email)
      |> case do
        %RethinkDB.Record{data: nil, profile: nil} ->
          struct(Snaktrip.User, email: email, id: SecureRandom.uuid )
          |> save_user
        {:table, :empty} ->
          struct(Snaktrip.User, email: email, id: SecureRandom.uuid )
          |> save_user
        user ->
          user
      end
    {:noreply, user}
  end

  def save_user(user) do
    user
      |> Map.from_struct
      |> Snaktrip.User.save
    user
  end
# ** Protocol?
  def collection(%RethinkDB.Collection{data: []}) do
    {:table, :empty}
  end

  def collection(%RethinkDB.Collection{data: [%{"email" => email, "id" => id, "snaktrips" => snaktrips}]}) do
    struct(Snaktrip.User, id: id, email: email, snaktrips: snaktrips)
  end

  def record(%RethinkDB.Record{data: %{"email" => email, "id" => id, "snaktrips" => snaktrips}}, _) do
    struct(Snaktrip.User, id: id, email: email, snaktrips: snaktrips)
  end
#
end

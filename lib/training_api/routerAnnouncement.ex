defmodule TrainingManagement.RouterAnnouncement do
  use Plug.Router
  use Timex
  alias TrainingManagement.Models.Announcement

  @skip_token_verification %{jwt_skip: true}
  @skip_token_verification_view %{view: AnnouncementView, jwt_skip: true}
  @auth_url Application.get_env(:trainingManagement, :auth_url)
  @api_port Application.get_env(:trainingManagement, :port)
  @db_table Application.get_env(:trainingManagement, :redb_db)
  @db_name Application.get_env(:trainingManagement, :redb_db)

  #use TrainingManagement.Auth
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug TrainingManagement.AuthPlug
  plug(:dispatch)

  get "/" , private: %{view: AnnouncementView} do
    params = Map.get(conn.params, "filter", %{})
    content = Map.get(params, "q", "")

    {:ok, announcements} =  Announcement.match("content", content)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(announcements))
  end

 post "/" do
      {id_trainer, id_training, content, date} = {
                  Map.get(conn.params, "id_trainer", nil),
                  Map.get(conn.params, "id_training", nil),
                  Map.get(conn.params, "content", nil),
                  Map.get(conn.params, "date", nil)
                }
      cond do
        is_nil(id_trainer) ->
                conn
                |> put_status(400)
                |> assign(:jsonapi, %{"error" => "'id_trainer' field must be provided"})
        is_nil(id_training) ->
                conn
                |> put_status(400)
                |> assign(:jsonapi, %{"error" => "'id_training' field must be provided"})
        is_nil(content) ->
                 conn
                 |> put_status(400)
                 |> assign(:jsonapi, %{"error" => "'content' field must be provided"})
        is_nil(date) ->
                 conn
                 |> put_status(400)
                 |> assign(:jsonapi, %{"error" => "'date' field must be provided"})
         true ->
         case %Announcement{
            id_trainer: id_trainer,
            id_training: id_training,
            content: content,
            date: date
         } |> Announcement.save do
           {:ok, new_announcement} ->
             conn
             |> put_resp_content_type("application/json")
             |> send_resp(201, Poison.encode!(%{:data => new_announcement}))
           :error ->
             conn
             |> put_resp_content_type("application/json")
             |> send_resp(500, Poison.encode!(%{"error" => "Announcement cannot be created"}))
         end
     end
   end
end
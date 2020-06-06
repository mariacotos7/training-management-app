defmodule TrainingManagement.Router do
  use Plug.Router
  use Timex
  alias TrainingManagement.Models.Training

  @skip_token_verification %{jwt_skip: true}
  @skip_token_verification_view %{view: TrainingView, jwt_skip: true}
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


  get "/" , private: %{view: TrainingView} do
    params = Map.get(conn.params, "filter", %{})
    title = Map.get(params, "q", "")

    {:ok, trainings} =  Training.match("title", title)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(trainings))
  end

  get "/:id", private: %{view: TrainingView}  do
    case Training.get(id) do
      {:ok, training} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(training))
      :error ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(%{"error" => "training not found"}))
    end
 end

 post "/" do
       {title, date, time, duration, location, status, details, max_participants, id_trainer, approved} = {
                   Map.get(conn.params, "title", nil),
                   Map.get(conn.params, "date", nil),
                   Map.get(conn.params, "time", nil),
                   Map.get(conn.params, "duration", nil),
                   Map.get(conn.params, "location", nil),
                   Map.get(conn.params, "status", nil),
                   Map.get(conn.params, "details", nil),
                   Map.get(conn.params, "max_participants", nil),
                   Map.get(conn.params, "id_trainer", nil),
                   Map.get(conn.params, "approved", nil)
                 }
       cond do
         is_nil(title) ->
                 conn
                 |> put_status(400)
                 |> assign(:jsonapi, %{"error" => "'title' field must be provided"})
         is_nil(date) ->
                 conn
                 |> put_status(400)
                 |> assign(:jsonapi, %{"error" => "'date' field must be provided"})
         is_nil(time) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'time' field must be provided"})
         is_nil(duration) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'duration' field must be provided"})
         is_nil(location) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'location' field must be provided"})
         is_nil(status) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'status' field must be provided"})
         is_nil(details) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'details' field must be provided"})
         is_nil(max_participants) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'max_participants' field must be provided"})
         is_nil(id_trainer) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'id_trainer' field must be provided"})
         is_nil(approved) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'approved' field must be provided"})
         true ->
          case %Training{
             title: title,
             date: date,
             time: time,
             duration: duration,
             location: location,
             status: status,
             details: details,
             max_participants: max_participants,
             id_trainer: id_trainer,
             approved: approved
          } |> Training.save do
            {:ok, new_training} ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(201, Poison.encode!(%{:data => new_training}))
            :error ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(500, Poison.encode!(%{"error" => "Training could not be created. "}))
          end
      end
 end

 delete "/:id" do
     case Training.delete(id) do
          :ok ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Poison.encode!(%{:message => "training deleted"}))
          :error ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(500, Poison.encode!(%{"error" => "Training could not be deleted"}))
     end
 end
end
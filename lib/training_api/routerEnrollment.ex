defmodule TrainingManagement.RouterEnrollment do
  use Plug.Router
  use Timex
  alias TrainingManagement.Models.Enrollment

  @skip_token_verification %{jwt_skip: true}
  @skip_token_verification_view %{view: EnrollmentView, jwt_skip: true}
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

  get "/" , private: %{view: EnrollmentView} do
    params = Map.get(conn.params, "filter", %{})
    id_training = Map.get(params, "q", "")

    {:ok, enrollments} =  Enrollment.match("id_training", id_training)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(enrollments))
  end

 post "/" do
       {id_user, id_training} = {
                   Map.get(conn.params, "id_user", nil),
                   Map.get(conn.params, "id_training", nil)
                 }
       cond do
         is_nil(id_user) ->
                 conn
                 |> put_status(400)
                 |> assign(:jsonapi, %{"error" => "'id_user' field must be provided"})
         is_nil(id_training) ->
                 conn
                 |> put_status(400)
                 |> assign(:jsonapi, %{"error" => "'id_training' field must be provided"})
         true ->
          case %Enrollment{
             id_user: id_user,
             id_training: id_training
          } |> Enrollment.save do
            {:ok, new_enrollment} ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(201, Poison.encode!(%{:data => new_enrollment}))
            :error ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(500, Poison.encode!(%{"error" => "Enrollment could not be created. "}))
          end
      end
 end
end
defmodule TrainingManagement.RouterRate do
  use Plug.Router
  use Timex
  alias TrainingManagement.Models.Rate

  @skip_token_verification %{jwt_skip: true}
  @skip_token_verification_view %{view: RateView, jwt_skip: true}
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

  get "/" , private: %{view: RateView} do
    params = Map.get(conn.params, "filter", %{})
    rate = Map.get(params, "q", "")

    {:ok, rates} =  Rate.match("rate", rate)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(rates))
  end

 post "/" do
       {id_user, id_training, rate} = {
                   Map.get(conn.params, "id_user", nil),
                   Map.get(conn.params, "id_training", nil),
                   Map.get(conn.params, "rate", nil)
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
         is_nil(rate) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'rate' field must be provided"})
         true ->
          case %Rate{
             id_user: id_user,
             id_training: id_training,
             rate: rate
          } |> Rate.save do
            {:ok, new_rate} ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(201, Poison.encode!(%{:data => new_rate}))
            :error ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(500, Poison.encode!(%{"error" => "Rate could not be created. "}))
          end
      end
 end
end
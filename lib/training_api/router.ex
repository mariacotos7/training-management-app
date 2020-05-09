defmodule TrainingManagement.Router do
  use Plug.Router
  use Timex
  alias TrainingManagement.Models.User

  @skip_token_verification %{jwt_skip: true}
  @skip_token_verification_view %{view: UserView, jwt_skip: true}
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


  get "/" , private: %{view: UserView} do
    params = Map.get(conn.params, "filter", %{})
    username = Map.get(params, "q", "")

    {:ok, users} =  User.match("username", username)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(users))
  end

  get "/:id", private: %{view: UserView}  do
    case User.get(id) do
      {:ok, user} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(user))
      :error ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(%{"error" => " not found"}))
    end
 end

  post "/" do
     {username, password, role, first_name, last_name, experience} = {
                 Map.get(conn.params, "username", nil),
                 Map.get(conn.params, "password", nil),
                 Map.get(conn.params, "role", nil),
                 Map.get(conn.params, "first_name", nil),
                 Map.get(conn.params, "last_name", nil),
                 Map.get(conn.params, "experience", nil)
               }
     cond do
       is_nil(username) ->
               conn
               |> put_status(400)
               |> assign(:jsonapi, %{"error" => "'username' field must be provided"})
       is_nil(password) ->
               conn
               |> put_status(400)
               |> assign(:jsonapi, %{"error" => "'password' field must be provided"})
       is_nil(role) ->
                conn
                |> put_status(400)
                |> assign(:jsonapi, %{"error" => "'role' field must be provided"})
       is_nil(first_name) ->
                conn
                |> put_status(400)
                |> assign(:jsonapi, %{"error" => "'first_name' field must be provided"})
       is_nil(last_name) ->
                conn
                |> put_status(400)
                |> assign(:jsonapi, %{"error" => "'last_name' field must be provided"})
       is_nil(experience) ->
                conn
                |> put_status(400)
                |> assign(:jsonapi, %{"error" => "'experience' field must be provided"})
        true ->
        case %User{
           username: username,
           password: password,
           role: role,
           first_name: first_name,
           last_name: last_name,
           experience: experience
        } |> User.save do
          {:ok, new_user} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Poison.encode!(%{:data => new_user}))
          :error ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(500, Poison.encode!(%{"error" => "An unexpected error happened"}))

        end
    end
  end

  delete "/:id" do
      case User.delete(id) do
          :ok ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Poison.encode!(%{:message => "user deleted"}))
          :error ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(500, Poison.encode!(%{"error" => "An unexpected error happened"}))
      end  
  end

  post "/signin" do
    {username, password, id} = {
      Map.get(conn.params, "username", nil),
      Map.get(conn.params, "password", nil),
      Map.get(conn.params, "id", nil)
    }

    flag = case User.loginDb(username, password) do
      true ->
        {:ok, auth_service} = TrainingManagement.Auth.start_link

        case  TrainingManagement.Auth.issue_token(auth_service, %{:id => id}) do
          token ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, Poison.encode!(%{:token => token}))
          :error ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, Poison.encode!(%{:message => "token already issued"}))
        end
      false ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Poison.encode!(%{:message => "unauthorised"}))

    end
  end
end
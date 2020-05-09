defmodule TrainingManagement.Endpoint do
  require Logger
  use Plug.Router
  alias TrainingManagement.Auth
  alias TrainingManagement.Models.User

  plug(:match)

  @skip_token_verification %{jwt_skip: true}

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )
  plug TrainingManagement.AuthPlug
  plug(:dispatch)

  post "/login", private: @skip_token_verification do
    {username, password, id} = {
      Map.get(conn.params, "username", nil),
      Map.get(conn.params, "password", nil),
      Map.get(conn.params, "id", nil)
    }

    flag = case password == "a" do
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

  post "/logout" do
    id = Map.get(conn.params, "id", nil)

    case TrainingManagement.Auth.revoke_token(conn.assigns.auth_service, %{:id => id}) do
      :ok ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Poison.encode!(%{:message => "token was deleted"}))
      :error ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Poison.encode!(%{:message => "token was not deleted"}))
    end
  end

  forward("/user", to: TrainingManagement.Router)

  match _ do
    send_resp(conn, 404, "Page not found!")
  end

end
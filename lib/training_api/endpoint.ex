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
       {username, password } = {
         Map.get(conn.params, "username", nil),
         Map.get(conn.params, "password", nil)
       }
       case User.find(%{username: username, password: password})  do
           {:ok, [user|_]} ->
           {:ok, auth_service} = TrainingManagement.Auth.start_link
           case  TrainingManagement.Auth.issue_token(auth_service, user|> Map.drop([:password])) do
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

  forward("/training", to: TrainingManagement.Router)
  forward("/comment", to: TrainingManagement.RouterComment)
  forward("/enrollment", to: TrainingManagement.RouterEnrollment)
  forward("/rate", to: TrainingManagement.RouterRate)
  forward("/announcement", to: TrainingManagement.RouterAnnouncement)

  match _ do
    send_resp(conn, 404, "Page not found!")
  end

end
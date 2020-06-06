defmodule TrainingManagement.RouterComment do
  use Plug.Router
  use Timex
  alias TrainingManagement.Models.Comment

  @skip_token_verification %{jwt_skip: true}
  @skip_token_verification_view %{view: CommentView, jwt_skip: true}
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


  get "/" , private: %{view: CommentView} do
    params = Map.get(conn.params, "filter", %{})
    content = Map.get(params, "q", "")

    {:ok, comments} =  Comment.match("content", content)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(comments))
  end

  get "/:id_training", private: %{view: CommentView}  do
    case Comment.get(id_training) do
      {:ok, comment} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(comment))
      :error ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(%{"error" => "comments not found"}))
    end
 end

 post "/" do
       {id_user, id_training, content, date} = {
                   Map.get(conn.params, "id_user", nil),
                   Map.get(conn.params, "id_training", nil),
                   Map.get(conn.params, "content", nil),
                   Map.get(conn.params, "date", nil)
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
         is_nil(content) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'content' field must be provided"})
         is_nil(date) ->
                  conn
                  |> put_status(400)
                  |> assign(:jsonapi, %{"error" => "'date' field must be provided"})
         true ->
          case %Comment{
             id_user: id_user,
             id_training: id_training,
             content: content,
             date: date
          } |> Comment.save do
            {:ok, new_comment} ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(201, Poison.encode!(%{:data => new_comment}))
            :error ->
              conn
              |> put_resp_content_type("application/json")
              |> send_resp(500, Poison.encode!(%{"error" => "Comment could not be created. "}))
          end
      end
 end

 delete "/:id" do
     case Comment.delete(id) do
          :ok ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Poison.encode!(%{:message => "comment deleted"}))
          :error ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(500, Poison.encode!(%{"error" => "Comment could not be deleted"}))
     end
 end
end
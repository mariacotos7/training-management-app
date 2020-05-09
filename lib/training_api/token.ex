defmodule TrainingManagement.Models.Token do
  @db_name Application.get_env(:trainingManagement, :redb_db)
  @db_table "tokens"

  use TrainingManagement.Models.Base
  alias TrainingManagement.DB.Manager

  # Poison Enconder Type
  @derive [Poison.Encoder]

  defstruct [
    :id,
    :type, #activation, reset
    :user,
    :used,
    :expires_at,
    :created_at,
    :updated_at
  ]
end
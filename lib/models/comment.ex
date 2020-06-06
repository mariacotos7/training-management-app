defmodule TrainingManagement.Models.Comment do
  @db_name Application.get_env(:trainingManagement, :redb_db)
  @db_table "comments"

  use TrainingManagement.Models.Base

  defstruct [
    :id,
    :id_user,
    :id_training,
    :content,
    :date,
    :created_at,
    :updated_at
  ]
end
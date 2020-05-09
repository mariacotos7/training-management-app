defmodule TrainingManagement.Models.Rate do
  @db_name Application.get_env(:trainingManagement, :redb_db)
  @db_table "enrollments"

  use TrainingManagement.Models.Base

  defstruct [
    :id,
    :id_user,
    :id_training,
    :rate
  ]
end
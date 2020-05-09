defmodule TrainingManagement.Models.Announcement do
  @db_name Application.get_env(:trainingManagement, :redb_db)
  @db_table "announcements"

  use TrainingManagement.Models.Base

  defstruct [
    :id,
    :id_trainer,
    :id_training,
    :content,
    :date
  ]
end
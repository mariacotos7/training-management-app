defmodule TrainingManagement.Models.Training do
  @db_name Application.get_env(:trainingManagement, :redb_db)
  @db_table "trainings"

  use TrainingManagement.Models.Base

  defstruct [
    :id,
    :title,
    :date,
    :time,
    :duration,
    :location,
    :status,
    :details,
    :max_participants,
    :id_trainer,
    :approved
  ]
end
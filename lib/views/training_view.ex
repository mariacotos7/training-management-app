defmodule TrainingManagement.Views.TrainingView do
  use JSONAPI.View

  def fields, do: [:id,:title,:date,:time,:duration,:location,:status,:details,:max_participants,:id_trainer,:approved]
  def type, do: "training"
  def relationships, do: []
end
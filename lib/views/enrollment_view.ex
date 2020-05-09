defmodule TrainingManagement.Views.EnrollmentView do
  use JSONAPI.View

  def fields, do: [:id,:id_user,:id_training]
  def type, do: "enrollment"
  def relationships, do: []
end
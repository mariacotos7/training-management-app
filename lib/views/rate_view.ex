defmodule TrainingManagement.Views.RateView do
  use JSONAPI.View

  def fields, do: [:id,:id_user,:id_training,:rate]
  def type, do: "rate"
  def relationships, do: []
end
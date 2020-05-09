defmodule TrainingManagement.Views.AnnouncementView do
  use JSONAPI.View

  def fields, do: [:id,:id_trainer,:id_training,:content,:date]
  def type, do: "announcement"
  def relationships, do: []
end
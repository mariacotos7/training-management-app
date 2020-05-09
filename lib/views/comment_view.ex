defmodule TrainingManagement.Views.CommentView do
  use JSONAPI.View

  def fields, do: [:id,:id_user,:id_training,:content,:date]
  def type, do: "comment"
  def relationships, do: []
end
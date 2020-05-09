defmodule TrainingManagement.Views.UserView do
use JSONAPI.View

def fields, do: [:id,:username,:password,:role,:fist_name,:last_name,:experience,:created_at,:updated_at]
def type, do: "user"
def relationships, do: []
end
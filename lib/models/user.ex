defmodule TrainingManagement.Models.User do
   #defstruct username: "costel", password: "costel", id: 1, role: 1, first_name: "cost", last_name: "el", experience: "3 years"
   @db_name Application.get_env(:training, :redb_db)
   @db_table "users"

   use TrainingManagement.Models.Base

   defstruct [
     :id,
     :username,
     :password,
     :role,
     :first_name,
     :last_name,
     :experience,
     :created_at,
     :updated_at
   ]
 end
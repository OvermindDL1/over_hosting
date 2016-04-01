defmodule OverHosting.Repo.Migrations.CreateOverHostingServer do
  use Ecto.Migration

  def change do
    #create table(:servers, primary_key: false) do
    create table(:servers) do
      #add :id, :binary_id, primary_key: true
      add :name, :string
      add :group, :string
      add :cmd, :string
      add :server_type, :string

      timestamps
    end

    create index(:servers, [:group]) # Create an index on this
    create unique_index(:servers, [:name, :group]) # and on both of these together with no duplicates

  end
end

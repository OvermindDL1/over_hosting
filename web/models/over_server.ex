defmodule OverHosting.Models.Server do
  use OverHosting.Web, :model

  schema "servers" do
    field :name, :string
    field :group, :string
    field :cmd, :string
    field :server_type, :string

    timestamps
  end

  @required_fields ~w(name group cmd server_type)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

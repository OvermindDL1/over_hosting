defmodule OverHosting.OverServerTest do
  use OverHosting.ModelCase

  alias OverHosting.OverServer

  @valid_attrs %{cmd: "some content", name: "some content", path: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OverServer.changeset(%OverServer{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OverServer.changeset(%OverServer{}, @invalid_attrs)
    refute changeset.valid?
  end
end

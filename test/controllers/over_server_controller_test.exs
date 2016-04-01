defmodule OverHosting.OverServerControllerTest do
  use OverHosting.ConnCase

  alias OverHosting.OverServer
  @valid_attrs %{cmd: "some content", name: "some content", path: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, over_server_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing mcservers"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, over_server_path(conn, :new)
    assert html_response(conn, 200) =~ "New mc server"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, over_server_path(conn, :create), over_server: @valid_attrs
    assert redirected_to(conn) == over_server_path(conn, :index)
    assert Repo.get_by(OverServer, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, over_server_path(conn, :create), over_server: @invalid_attrs
    assert html_response(conn, 200) =~ "New mc server"
  end

  test "shows chosen resource", %{conn: conn} do
    over_server = Repo.insert! %OverServer{}
    conn = get conn, over_server_path(conn, :show, over_server)
    assert html_response(conn, 200) =~ "Show mc server"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, over_server_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    over_server = Repo.insert! %OverServer{}
    conn = get conn, over_server_path(conn, :edit, over_server)
    assert html_response(conn, 200) =~ "Edit mc server"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    over_server = Repo.insert! %OverServer{}
    conn = put conn, over_server_path(conn, :update, over_server), over_server: @valid_attrs
    assert redirected_to(conn) == over_server_path(conn, :show, over_server)
    assert Repo.get_by(OverServer, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    over_server = Repo.insert! %OverServer{}
    conn = put conn, over_server_path(conn, :update, over_server), over_server: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit mc server"
  end

  test "deletes chosen resource", %{conn: conn} do
    over_server = Repo.insert! %OverServer{}
    conn = delete conn, over_server_path(conn, :delete, over_server)
    assert redirected_to(conn) == over_server_path(conn, :index)
    refute Repo.get(OverServer, over_server.id)
  end
end

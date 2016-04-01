ExUnit.start

Mix.Task.run "ecto.create", ~w(-r OverHosting.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r OverHosting.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(OverHosting.Repo)


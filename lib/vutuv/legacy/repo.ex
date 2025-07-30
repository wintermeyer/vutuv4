defmodule Vutuv.Legacy.Repo do
  @moduledoc """
  Read-only repository for accessing the legacy vutuv1_dev database.

  This repo is configured to prevent any write operations to ensure
  the legacy data remains intact. All insert, update, and delete
  operations will raise an error.
  """
  use Ecto.Repo,
    otp_app: :vutuv,
    adapter: Ecto.Adapters.MyXQL

  # Make all write operations overridable
  defoverridable insert: 2,
                 insert!: 2,
                 update: 2,
                 update!: 2,
                 delete: 2,
                 delete!: 2,
                 insert_or_update: 2,
                 insert_or_update!: 2,
                 insert_all: 3,
                 update_all: 3,
                 delete_all: 2

  @doc false
  def insert(_changeset_or_struct, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end

  @doc false
  def insert!(_changeset_or_struct, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end

  @doc false
  def update(_changeset, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end

  @doc false
  def update!(_changeset, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end

  @doc false
  def delete(_struct_or_changeset, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end

  @doc false
  def delete!(_struct_or_changeset, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end

  @doc false
  def insert_or_update(_changeset, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end

  @doc false
  def insert_or_update!(_changeset, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end

  @doc false
  def insert_all(_schema_or_source, _entries, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end

  @doc false
  def update_all(_queryable, _updates, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end

  @doc false
  def delete_all(_queryable, _opts) do
    raise "Write operations are not allowed on the legacy database"
  end
end

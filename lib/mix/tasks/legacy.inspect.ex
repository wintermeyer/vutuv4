defmodule Mix.Tasks.Legacy.Inspect do
  use Mix.Task
  alias Vutuv.Legacy.Repo

  @shortdoc "Inspects the legacy database schema"
  def run(_) do
    Mix.Task.run("app.start")

    IO.puts("Inspecting vutuv1_dev database schema...\n")

    # Get all tables
    query = """
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
    ORDER BY table_name;
    """

    case Repo.query(query) do
      {:ok, %{rows: rows}} ->
        IO.puts("Tables found:")

        Enum.each(rows, fn [table_name] ->
          IO.puts("  - #{table_name}")
        end)

        IO.puts("\nTable details:")

        Enum.each(rows, fn [table_name] ->
          inspect_table(table_name)
        end)

      {:error, error} ->
        IO.puts("Error: #{inspect(error)}")
    end
  end

  defp inspect_table(table_name) do
    IO.puts("\n#{table_name}:")

    # Get columns
    columns_query = """
    SELECT column_name, data_type, is_nullable, column_default
    FROM information_schema.columns
    WHERE table_name = $1
    ORDER BY ordinal_position;
    """

    case Repo.query(columns_query, [table_name]) do
      {:ok, %{rows: columns}} ->
        IO.puts("  Columns:")

        Enum.each(columns, fn [col_name, data_type, nullable, default] ->
          IO.puts(
            "    - #{col_name}: #{data_type}#{if nullable == "NO", do: " NOT NULL", else: ""}#{if default, do: " DEFAULT #{default}", else: ""}"
          )
        end)

      {:error, error} ->
        IO.puts("  Error fetching columns: #{inspect(error)}")
    end

    # Get foreign keys
    fk_query = """
    SELECT
      tc.constraint_name,
      kcu.column_name,
      ccu.table_name AS foreign_table_name,
      ccu.column_name AS foreign_column_name
    FROM
      information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name = $1;
    """

    case Repo.query(fk_query, [table_name]) do
      {:ok, %{rows: []}} ->
        nil

      {:ok, %{rows: fks}} ->
        IO.puts("  Foreign Keys:")

        Enum.each(fks, fn [constraint_name, column_name, foreign_table, foreign_column] ->
          IO.puts(
            "    - #{column_name} -> #{foreign_table}.#{foreign_column} (#{constraint_name})"
          )
        end)

      {:error, error} ->
        IO.puts("  Error fetching foreign keys: #{inspect(error)}")
    end

    # Get indexes
    index_query = """
    SELECT
      i.relname AS index_name,
      array_to_string(array_agg(a.attname), ', ') AS column_names,
      ix.indisunique
    FROM
      pg_class t,
      pg_class i,
      pg_index ix,
      pg_attribute a
    WHERE
      t.oid = ix.indrelid
      AND i.oid = ix.indexrelid
      AND a.attrelid = t.oid
      AND a.attnum = ANY(ix.indkey)
      AND t.relkind = 'r'
      AND t.relname = $1
    GROUP BY i.relname, ix.indisunique
    ORDER BY i.relname;
    """

    case Repo.query(index_query, [table_name]) do
      {:ok, %{rows: []}} ->
        nil

      {:ok, %{rows: indexes}} ->
        IO.puts("  Indexes:")

        Enum.each(indexes, fn [index_name, columns, is_unique] ->
          IO.puts("    - #{index_name} on (#{columns})#{if is_unique, do: " UNIQUE", else: ""}")
        end)

      {:error, error} ->
        IO.puts("  Error fetching indexes: #{inspect(error)}")
    end
  end
end

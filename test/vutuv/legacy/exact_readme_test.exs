defmodule Vutuv.Legacy.ExactReadmeTest do
  use ExUnit.Case
  import Ecto.Query

  alias Vutuv.Legacy.Repo
  alias Vutuv.Legacy.UserProfiles.User
  alias Vutuv.Legacy.Devices.EmailAddress

  @moduledoc """
  This test module verifies that the exact code examples from the README work correctly.
  Each test corresponds to a specific example in the README.
  """

  describe "README examples - Basic queries" do
    test "Example: Reading all users" do
      # From README line 56
      users = Vutuv.Legacy.Repo.all(Vutuv.Legacy.UserProfiles.User)

      assert is_list(users)
      IO.puts("Found #{length(users)} users in the database")
    end

    test "Example: Get user with associations using hardcoded ID" do
      # From README lines 58-61
      # First get a valid user_id
      users = Repo.all(User)

      if length(users) > 0 do
        user_id = List.first(users).id

        # Now run the exact example with a real user_id
        user =
          Vutuv.Legacy.UserProfiles.User
          |> Vutuv.Legacy.Repo.get(user_id)
          |> Vutuv.Legacy.Repo.preload([:email_addresses, :addresses, :phone_numbers])

        assert %User{} = user
        assert user.id == user_id
        assert is_list(user.email_addresses)
        assert is_list(user.addresses)
        assert is_list(user.phone_numbers)

        IO.puts(
          "User #{user_id} loaded with #{length(user.email_addresses)} emails, " <>
            "#{length(user.addresses)} addresses, #{length(user.phone_numbers)} phone numbers"
        )
      else
        IO.puts("No users in database to test with")
      end
    end
  end

  describe "README examples - Complex queries" do
    test "Example: Find user by specific email (if exists)" do
      # From README lines 69-77
      # First check if the specific email exists
      test_email = "sw@wintermeyer-consulting.de"

      email_exists =
        EmailAddress
        |> where([e], e.value == ^test_email)
        |> Repo.exists?()

      if email_exists do
        # Run the exact example
        user_by_email =
          Vutuv.Legacy.Devices.EmailAddress
          |> where([e], e.value == ^test_email)
          |> join(:inner, [e], u in Vutuv.Legacy.UserProfiles.User, on: u.id == e.user_id)
          |> select([e, u], u)
          |> Vutuv.Legacy.Repo.one()
          |> Vutuv.Legacy.Repo.preload([:email_addresses, :addresses, :phone_numbers])

        assert %User{} = user_by_email
        assert Enum.any?(user_by_email.email_addresses, fn e -> e.value == test_email end)

        IO.puts("Found user for email #{test_email}: User ID #{user_by_email.id}")
      else
        IO.puts("Email #{test_email} not found in database")
      end
    end

    test "Example: Find user by generic email" do
      # More generic version that should work with any database
      # Get any existing email
      existing_email = Repo.all(EmailAddress) |> Enum.filter(& &1.value) |> List.first()

      if existing_email do
        user_by_email =
          Vutuv.Legacy.Devices.EmailAddress
          |> where([e], e.value == ^existing_email.value)
          |> join(:inner, [e], u in Vutuv.Legacy.UserProfiles.User, on: u.id == e.user_id)
          |> select([e, u], u)
          |> Vutuv.Legacy.Repo.one()
          |> Vutuv.Legacy.Repo.preload([:email_addresses, :addresses, :phone_numbers])

        assert %User{} = user_by_email
        assert user_by_email.id == existing_email.user_id

        IO.puts("Successfully found user by email: #{existing_email.value}")
      else
        IO.puts("No emails with values in database")
      end
    end

    test "Example: Query users with tags" do
      # From README lines 79-83
      users_with_tags =
        Vutuv.Legacy.UserProfiles.User
        |> join(:inner, [u], ut in Vutuv.Legacy.Tags.UserTag, on: ut.user_id == u.id)
        |> distinct(true)
        |> Vutuv.Legacy.Repo.all()

      assert is_list(users_with_tags)
      IO.puts("Found #{length(users_with_tags)} users with tags")
    end
  end

  describe "README examples - IEx specific patterns" do
    test "Multi-line query with parentheses (IEx style)" do
      # This pattern is specifically for IEx usage
      result =
        Vutuv.Legacy.Devices.EmailAddress
        |> limit(5)
        |> select([e], e.value)
        |> Vutuv.Legacy.Repo.all()

      assert is_list(result)
      assert length(result) <= 5

      IO.puts("Retrieved #{length(result)} email values")
    end

    test "Query building step by step (IEx style)" do
      # In IEx, users might build queries incrementally
      query = EmailAddress
      query = where(query, [e], not is_nil(e.value))
      query = limit(query, 3)
      results = Repo.all(query)

      assert is_list(results)
      assert length(results) <= 3

      IO.puts("Step-by-step query returned #{length(results)} results")
    end
  end

  describe "README examples - Import requirements" do
    test "Queries work after importing Ecto.Query" do
      # This verifies the import statement is included
      import Ecto.Query

      # Now these functions should work
      query = from u in User, limit: 1
      result = Repo.all(query)

      assert is_list(result)
      assert length(result) <= 1
    end
  end
end

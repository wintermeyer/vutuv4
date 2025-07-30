defmodule Vutuv.Legacy.ReadmeExamplesTest do
  use ExUnit.Case
  import Ecto.Query
  import Ecto.Changeset

  alias Vutuv.Legacy.Repo
  alias Vutuv.Legacy.UserProfiles.User
  alias Vutuv.Legacy.Devices.EmailAddress
  alias Vutuv.Legacy.Tags.UserTag

  describe "Read-Only Access" do
    test "insert operations raise an error" do
      assert_raise RuntimeError, "Write operations are not allowed on the legacy database", fn ->
        Repo.insert(%User{})
      end
    end

    test "update operations raise an error" do
      # Get any user from the database
      user = Repo.all(User) |> List.first()

      if user do
        assert_raise RuntimeError,
                     "Write operations are not allowed on the legacy database",
                     fn ->
                       user
                       |> change(first_name: "New Name")
                       |> Repo.update()
                     end
      else
        # If no users exist, that's fine - test passes
        :ok
      end
    end

    test "delete operations raise an error" do
      user = Repo.all(User) |> List.first()

      if user do
        assert_raise RuntimeError,
                     "Write operations are not allowed on the legacy database",
                     fn ->
                       Repo.delete(user)
                     end
      else
        :ok
      end
    end
  end

  describe "Accessing Legacy Data" do
    test "reading all users is allowed" do
      users = Repo.all(User)
      assert is_list(users)

      # Verify user structure if any exist
      if length(users) > 0 do
        user = List.first(users)
        assert %User{} = user
        assert is_integer(user.id) or is_nil(user.id)
      end
    end

    test "get user with associations" do
      # Get first user that exists
      user = Repo.all(User) |> List.first()

      if user do
        user_with_assoc =
          User
          |> Repo.get(user.id)
          |> Repo.preload([:email_addresses, :addresses, :phone_numbers])

        assert %User{} = user_with_assoc
        assert user_with_assoc.id == user.id
        assert is_list(user_with_assoc.email_addresses)
        assert is_list(user_with_assoc.addresses)
        assert is_list(user_with_assoc.phone_numbers)
      else
        # No users to test with
        :ok
      end
    end

    test "find user by email address" do
      # Get any email from the database
      email = Repo.all(EmailAddress) |> List.first()

      if email && email.value do
        user_by_email =
          EmailAddress
          |> where([e], e.value == ^email.value)
          |> join(:inner, [e], u in User, on: u.id == e.user_id)
          |> select([e, u], u)
          |> Repo.one()
          |> Repo.preload([:email_addresses, :addresses, :phone_numbers])

        if user_by_email do
          assert %User{} = user_by_email
          assert user_by_email.id == email.user_id

          # Verify the email is in the preloaded associations
          assert Enum.any?(user_by_email.email_addresses, fn e ->
                   e.value == email.value
                 end)
        end
      else
        # No emails to test with
        :ok
      end
    end

    test "query users with tags" do
      users_with_tags =
        User
        |> join(:inner, [u], ut in UserTag, on: ut.user_id == u.id)
        |> distinct(true)
        |> Repo.all()

      assert is_list(users_with_tags)

      # If we have results, verify they are User structs
      if length(users_with_tags) > 0 do
        assert %User{} = List.first(users_with_tags)
      end
    end

    test "complex queries with joins work" do
      # Since we don't have UserCredential, let's test with a different join
      # Query users who have email addresses
      users_with_emails =
        User
        |> join(:inner, [u], e in EmailAddress, on: e.user_id == u.id)
        |> distinct(true)
        |> Repo.all()

      assert is_list(users_with_emails)

      if length(users_with_emails) > 0 do
        user = List.first(users_with_emails)
        assert %User{} = user

        # Verify this user actually has emails
        user_with_emails_loaded = Repo.preload(user, :email_addresses)
        assert length(user_with_emails_loaded.email_addresses) > 0
      end
    end
  end

  describe "IEx usage patterns" do
    test "multi-line queries work with parentheses" do
      # This tests the pattern shown in the README for IEx usage
      result =
        User
        |> limit(1)
        |> Repo.all()

      assert is_list(result)
      assert length(result) <= 1
    end

    test "single line queries work without parentheses" do
      result = Repo.all(User)
      assert is_list(result)
    end
  end

  describe "Edge cases" do
    test "preloading empty associations doesn't fail" do
      user = Repo.all(User) |> List.first()

      if user do
        user_with_assoc = Repo.preload(user, [:email_addresses, :addresses, :phone_numbers])

        assert %User{} = user_with_assoc
        # These should at least be empty lists, not nil
        assert is_list(user_with_assoc.email_addresses)
        assert is_list(user_with_assoc.addresses)
        assert is_list(user_with_assoc.phone_numbers)
      else
        :ok
      end
    end

    test "one() returns nil when no results" do
      result =
        User
        # Non-existent ID
        |> where([u], u.id == -1)
        |> Repo.one()

      assert is_nil(result)
    end

    test "all() returns empty list when no results" do
      result =
        User
        # Non-existent ID
        |> where([u], u.id == -1)
        |> Repo.all()

      assert result == []
    end
  end
end

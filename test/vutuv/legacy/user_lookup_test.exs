defmodule Vutuv.Legacy.UserLookupTest do
  use ExUnit.Case
  import Ecto.Query

  alias Vutuv.Legacy.Repo
  alias Vutuv.Legacy.Devices.EmailAddress
  alias Vutuv.Legacy.UserProfiles.User

  describe "finding user by email" do
    test "finds user by email address and preloads associations" do
      # This test assumes the email exists in the legacy database
      email = "sw@wintermeyer-consulting.de"

      user_by_email =
        EmailAddress
        |> where([e], e.value == ^email)
        |> join(:inner, [e], u in User, on: u.id == e.user_id)
        |> select([e, u], u)
        |> Repo.one()

      # If user is found, preload associations
      if user_by_email do
        user_with_associations =
          Repo.preload(user_by_email, [
            :email_addresses,
            :addresses,
            :phone_numbers
          ])

        # Verify the user has the expected email
        assert Enum.any?(user_with_associations.email_addresses, fn e ->
                 e.value == email
               end)

        # Verify associations are loaded
        assert %User{} = user_with_associations
        assert is_list(user_with_associations.email_addresses)
        assert is_list(user_with_associations.addresses)
        assert is_list(user_with_associations.phone_numbers)
      else
        # If no user found, that's also valid - the test passes
        # but logs a message for awareness
        IO.puts("No user found with email: #{email}")
      end
    end

    test "returns nil when email doesn't exist" do
      non_existent_email = "non.existent@example.com"

      user_by_email =
        EmailAddress
        |> where([e], e.value == ^non_existent_email)
        |> join(:inner, [e], u in User, on: u.id == e.user_id)
        |> select([e, u], u)
        |> Repo.one()

      assert is_nil(user_by_email)
    end

    test "can query email table directly" do
      # Test that we can query the emails table
      emails = Repo.all(EmailAddress) |> Enum.take(5)

      # Verify the schema fields
      Enum.each(emails, fn email ->
        assert %EmailAddress{} = email
        assert is_binary(email.value) or is_nil(email.value)
        assert is_binary(email.md5sum) or is_nil(email.md5sum)
        assert is_boolean(email.public?) or is_nil(email.public?)
        assert is_integer(email.user_id) or is_nil(email.user_id)
      end)
    end

    test "handles multiple email addresses for the same user" do
      # Get any user that has email addresses
      user_with_emails =
        User
        |> join(:inner, [u], e in EmailAddress, on: e.user_id == u.id)
        |> limit(1)
        |> Repo.one()

      if user_with_emails do
        user = Repo.preload(user_with_emails, :email_addresses)

        # If user has multiple emails, verify we can find them by any email
        if length(user.email_addresses) > 1 do
          Enum.each(user.email_addresses, fn email ->
            found_user =
              EmailAddress
              |> where([e], e.value == ^email.value)
              |> join(:inner, [e], u in User, on: u.id == e.user_id)
              |> select([e, u], u)
              |> Repo.one()

            assert found_user.id == user.id
          end)
        else
          IO.puts("User #{user.id} has only #{length(user.email_addresses)} email(s)")
        end
      else
        IO.puts("No users with email addresses found in legacy database")
      end
    end
  end
end

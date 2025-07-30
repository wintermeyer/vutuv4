defmodule Vutuv.Legacy.Migrator do
  @moduledoc """
  Helper module for migrating data from the legacy vutuv1_dev database
  to the new database structure.
  """

  alias Vutuv.Legacy.Repo, as: LegacyRepo

  @doc """
  Lists all users from the legacy database
  """
  def list_legacy_users do
    LegacyRepo.all(Vutuv.Legacy.UserProfiles.User)
  end

  @doc """
  Gets a legacy user with all associations preloaded
  """
  def get_legacy_user_with_associations(user_id) do
    Vutuv.Legacy.UserProfiles.User
    |> LegacyRepo.get(user_id)
    |> LegacyRepo.preload([
      :addresses,
      :email_addresses,
      :email_notifications,
      :phone_numbers,
      :posts,
      :sessions,
      :social_media_accounts,
      :user_tags,
      :work_experiences,
      :user_credential,
      :followees,
      :followers
    ])
  end

  @doc """
  Example migration function for users.
  This is a template - actual implementation will depend on new schema structure.
  """
  def migrate_user(legacy_user_id) do
    legacy_user = get_legacy_user_with_associations(legacy_user_id)

    # TODO: Transform legacy_user data to new schema format
    # Example:
    # new_user_attrs = %{
    #   name: legacy_user.full_name,
    #   email: get_primary_email(legacy_user),
    #   # ... other transformations
    # }
    # 
    # Repo.transaction(fn ->
    #   # Create new user
    #   # Create related records
    #   # Handle associations
    # end)

    {:ok, legacy_user}
  end

  @doc """
  Batch migrate users with progress tracking
  """
  def migrate_all_users(opts \\ []) do
    batch_size = Keyword.get(opts, :batch_size, 100)
    offset = Keyword.get(opts, :offset, 0)

    users =
      Vutuv.Legacy.UserProfiles.User
      |> LegacyRepo.all(limit: batch_size, offset: offset)

    results =
      Enum.map(users, fn user ->
        # Since migrate_user/1 is a stub that always returns {:ok, _},
        # we'll just return success for now
        {:ok, _} = migrate_user(user.id)
        {:ok, user.id}
      end)

    successful = Enum.count(results, fn {status, _} -> status == :ok end)
    failed = Enum.count(results, fn {status, _} -> status == :error end)

    %{
      batch_size: batch_size,
      offset: offset,
      successful: successful,
      failed: failed,
      has_more: length(users) == batch_size,
      errors: Enum.filter(results, fn {status, _} -> status == :error end)
    }
  end

  # Helper functions

  # defp get_primary_email(user) do
  #   case Enum.find(user.email_addresses, & &1.is_primary) do
  #     nil -> List.first(user.email_addresses)
  #     primary -> primary
  #   end
  # end
end

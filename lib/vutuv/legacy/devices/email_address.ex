defmodule Vutuv.Legacy.Devices.EmailAddress do
  @moduledoc """
  Legacy EmailAddress schema for managing user email addresses.

  Users can have multiple email addresses with different purposes
  and privacy settings. One email is designated as primary.

  ## Fields
  - `value` - The email address (required)
  - `md5sum` - MD5 hash of the email
  - `public?` - Whether email is visible on public profile

  ## Features
  - Multiple emails per user
  - Privacy control per email

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "emails" do
    field :value, :string
    field :md5sum, :string
    field :public?, :boolean, source: :public?

    belongs_to :user, Vutuv.Legacy.UserProfiles.User

    timestamps(type: :utc_datetime)
  end

  def changeset(email_address, attrs) do
    email_address
    |> cast(attrs, [:value, :md5sum, :public?, :user_id])
    |> validate_required([:value, :user_id])
  end
end

defmodule Vutuv.Legacy.Accounts.UserCredential do
  @moduledoc """
  Legacy UserCredential schema for user authentication and security.

  Stores authentication credentials and security settings for users.
  Uses Argon2 for password hashing in the original system.

  ## Fields
  - `password` - Virtual field for plain text password (never stored)
  - `password_hash` - Hashed password using Argon2
  - `password_reset_sent_at` - Timestamp of last password reset email
  - `password_resettable` - Whether password can be reset
  - `otp_secret` - Secret for two-factor authentication
  - `confirmed` - Email confirmation status
  - `is_admin` - Admin privilege flag

  ## Security Notes
  - Passwords are hashed using Argon2
  - Supports two-factor authentication via OTP
  - Email confirmation required for account activation

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_credentials" do
    field :password, :string, virtual: true
    field :password_hash, :string
    field :password_reset_sent_at, :utc_datetime
    field :password_resettable, :boolean, default: false
    field :otp_secret, :string
    field :confirmed, :boolean, default: false
    field :is_admin, :boolean, default: false

    belongs_to :user, Vutuv.Legacy.UserProfiles.User

    timestamps()
  end

  def changeset(user_credential, attrs) do
    user_credential
    |> cast(attrs, [
      :password,
      :password_hash,
      :password_reset_sent_at,
      :password_resettable,
      :otp_secret,
      :confirmed,
      :is_admin,
      :user_id
    ])
    |> validate_required([:user_id])
  end
end

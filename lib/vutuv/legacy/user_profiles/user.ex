defmodule Vutuv.Legacy.UserProfiles.User do
  @moduledoc """
  Legacy User schema representing the core user entity in the Vutuv3 system.

  This is the central model that most other entities relate to. It stores
  basic user information including personal details, preferences, and settings.

  ## Fields
  - `first_name` - User's first name
  - `last_name` - User's last name
  - `middlename` - User's middle name
  - `nickname` - User's nickname/preferred name
  - `gender` - User's gender
  - `birthdate` - User's date of birth
  - `avatar` - Profile picture/avatar
  - `headline` - Professional headline/tagline
  - `honorific_prefix` - Title prefix (Dr., Mr., Ms., etc.)
  - `honorific_suffix` - Title suffix (PhD, MD, etc.)
  - `locale` - User's preferred language/locale
  - `active_slug` - URL-friendly identifier for the user profile
  - `noindex?` - SEO flag to prevent search engine indexing
  - `validated?` - Whether user is validated
  - `verified` - Whether user is verified
  - `administrator` - Whether user is an admin
  - `send_birthday_reminder` - Email birthday reminder preference

  ## Associations
  - Has many addresses, email addresses, phone numbers
  - Has many posts, work experiences, social media accounts
  - Has user credentials for authentication
  - Has follower/followee relationships through user connections
  - Has tags for skills/interests

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :middlename, :string
    field :nickname, :string
    field :gender, :string
    field :birthdate, :date
    field :avatar, :string
    field :headline, :string
    field :honorific_prefix, :string
    field :honorific_suffix, :string
    field :locale, :string
    field :active_slug, :string
    field :noindex?, :boolean, source: :noindex?
    field :validated?, :boolean, source: :validated?
    field :verified, :boolean
    field :administrator, :boolean
    field :send_birthday_reminder, :boolean

    has_many :addresses, Vutuv.Legacy.UserProfiles.Address
    has_many :email_addresses, Vutuv.Legacy.Devices.EmailAddress

    has_many :email_notifications, Vutuv.Legacy.Notifications.EmailNotification,
      foreign_key: :owner_id

    has_many :phone_numbers, Vutuv.Legacy.Devices.PhoneNumber
    has_many :posts, Vutuv.Legacy.Publications.Post
    has_many :sessions, Vutuv.Legacy.Sessions.Session
    has_many :social_media_accounts, Vutuv.Legacy.SocialNetworks.SocialMediaAccount
    has_many :user_tags, Vutuv.Legacy.Tags.UserTag
    has_many :work_experiences, Vutuv.Legacy.Biographies.WorkExperience
    has_one :user_credential, Vutuv.Legacy.Accounts.UserCredential
    has_many :followees, Vutuv.Legacy.UserConnections.UserConnection, foreign_key: :follower_id
    has_many :followers, Vutuv.Legacy.UserConnections.UserConnection, foreign_key: :followee_id

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :last_name,
      :middlename,
      :nickname,
      :gender,
      :birthdate,
      :avatar,
      :headline,
      :honorific_prefix,
      :honorific_suffix,
      :locale,
      :active_slug,
      :noindex?,
      :validated?,
      :verified,
      :administrator,
      :send_birthday_reminder
    ])
    |> validate_required([])
  end
end

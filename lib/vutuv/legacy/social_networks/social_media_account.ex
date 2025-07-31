defmodule Vutuv.Legacy.SocialNetworks.SocialMediaAccount do
  @moduledoc """
  Legacy SocialMediaAccount schema for external social media links.

  Stores links to user profiles on various social media platforms.

  ## Fields
  - `provider` - Social platform name (from predefined list)
  - `value` - Username, profile URL, or handle

  ## Supported Providers
  - Facebook
  - Twitter
  - Instagram
  - Youtube
  - Snapchat
  - LinkedIn
  - XING (European professional network)
  - GitHub

  ## Notes
  - Users can have multiple accounts per platform
  - Value format varies by platform (username vs URL)

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "social_media_accounts" do
    field :provider, :string
    field :value, :string

    belongs_to :user, Vutuv.Legacy.UserProfiles.User

    timestamps()
  end

  @providers [
    "Facebook",
    "Twitter",
    "Instagram",
    "Youtube",
    "Snapchat",
    "LinkedIn",
    "XING",
    "GitHub"
  ]

  def changeset(social_media_account, attrs) do
    social_media_account
    |> cast(attrs, [:provider, :value, :user_id])
    |> validate_required([:provider, :value, :user_id])
    |> validate_inclusion(:provider, @providers)
  end
end

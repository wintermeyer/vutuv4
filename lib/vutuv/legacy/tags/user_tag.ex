defmodule Vutuv.Legacy.Tags.UserTag do
  @moduledoc """
  Legacy UserTag join table schema linking users to tags.

  Associates tags with users to represent skills, interests,
  or areas of expertise. These tags can be endorsed by other users.

  ## Purpose
  - Links users to their skill/interest tags
  - Enables skill-based searching and matching
  - Supports endorsement system through UserTagEndorsement

  ## Associations
  - Belongs to both User and Tag
  - Has many endorsements from other users

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_tags" do
    belongs_to :tag, Vutuv.Legacy.Tags.Tag
    belongs_to :user, Vutuv.Legacy.UserProfiles.User
    has_many :user_tag_endorsements, Vutuv.Legacy.Tags.UserTagEndorsement

    timestamps(type: :utc_datetime)
  end

  def changeset(user_tag, attrs) do
    user_tag
    |> cast(attrs, [:tag_id, :user_id])
    |> validate_required([:tag_id, :user_id])
  end
end

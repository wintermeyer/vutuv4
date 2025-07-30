defmodule Vutuv.Legacy.Tags.UserTagEndorsement do
  @moduledoc """
  Legacy UserTagEndorsement schema for skill endorsements.

  Allows users to endorse other users' skills/tags, similar to
  LinkedIn's skill endorsement feature.

  ## Purpose
  - Social proof for user skills
  - Community-driven skill validation
  - Reputation building mechanism

  ## Structure
  - Links endorsing user to a UserTag
  - One user can endorse multiple skills
  - Skills can have multiple endorsements

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_tag_endorsements" do
    belongs_to :user, Vutuv.Legacy.UserProfiles.User
    belongs_to :user_tag, Vutuv.Legacy.Tags.UserTag
  end

  def changeset(user_tag_endorsement, attrs) do
    user_tag_endorsement
    |> cast(attrs, [:user_id, :user_tag_id])
    |> validate_required([:user_id, :user_tag_id])
  end
end

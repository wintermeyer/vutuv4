defmodule Vutuv.Legacy.Tags.Tag do
  @moduledoc """
  Legacy Tag schema for categorization and skill tagging.

  Central tag entity used for both user skills and post categorization.
  Tags can be applied to users (skills/interests) and posts (topics).

  ## Fields
  - `name` - Display name of the tag (required)
  - `downcase_name` - Lowercase version for searching
  - `description` - Detailed description of the tag
  - `slug` - URL-friendly identifier
  - `url` - External reference URL (e.g., Wikipedia)

  ## Usage
  - User skills and expertise areas
  - Post categorization and topics
  - Searchable taxonomy system
  - Can be endorsed by other users

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "tags" do
    field :name, :string
    field :downcase_name, :string
    field :description, :string
    field :slug, :string
    field :url, :string

    has_many :post_tags, Vutuv.Legacy.Tags.PostTag
    has_many :user_tags, Vutuv.Legacy.Tags.UserTag

    timestamps()
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :downcase_name, :description, :slug, :url])
    |> validate_required([:name])
  end
end

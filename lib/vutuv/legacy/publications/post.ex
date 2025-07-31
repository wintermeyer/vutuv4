defmodule Vutuv.Legacy.Publications.Post do
  @moduledoc """
  Legacy Post schema for user-generated content and publications.

  Represents blog posts, articles, or updates created by users
  with privacy controls and tagging support.

  ## Fields
  - `title` - Post title (required)
  - `body` - Post content (required)
  - `page_info_cache` - Cached metadata (e.g., Open Graph data)
  - `published_at` - Publication timestamp
  - `visibility_level` - Privacy setting: "private", "public", or "followers"

  ## Features
  - Three-tier privacy system
  - Tag support for categorization
  - Rich content with metadata caching
  - Draft/published states via published_at

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "posts" do
    field :body, :string
    field :page_info_cache, :string
    field :published_at, :utc_datetime
    field :title, :string
    field :visibility_level, :string, default: "private"

    belongs_to :user, Vutuv.Legacy.UserProfiles.User
    has_many :post_tags, Vutuv.Legacy.Tags.PostTag

    timestamps(type: :utc_datetime)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :page_info_cache, :published_at, :title, :visibility_level, :user_id])
    |> validate_required([:body, :title, :user_id])
    |> validate_inclusion(:visibility_level, ["private", "public", "followers"])
  end
end

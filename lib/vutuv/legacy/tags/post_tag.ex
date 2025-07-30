defmodule Vutuv.Legacy.Tags.PostTag do
  @moduledoc """
  Legacy PostTag join table schema linking posts to tags.

  Associates tags with posts for categorization and topic classification.

  ## Purpose
  - Categorizes posts by topic/subject
  - Enables tag-based post discovery
  - Supports multiple tags per post

  ## Usage
  - Blog post categorization
  - Content discovery through tags
  - Topic-based filtering

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "post_tags" do
    belongs_to :post, Vutuv.Legacy.Publications.Post
    belongs_to :tag, Vutuv.Legacy.Tags.Tag

    timestamps()
  end

  def changeset(post_tag, attrs) do
    post_tag
    |> cast(attrs, [:post_id, :tag_id])
    |> validate_required([:post_id, :tag_id])
  end
end

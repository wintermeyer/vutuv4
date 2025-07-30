defmodule Vutuv.Legacy.UserConnections.UserConnection do
  @moduledoc """
  Legacy UserConnection schema for follower/followee relationships.

  Implements a social following system where users can follow
  other users, creating a directed social graph.

  ## Structure
  - `follower_id` - User who is following
  - `followee_id` - User being followed

  ## Features
  - Asymmetric relationships (one-way following)
  - Enables social feeds and notifications
  - Privacy-aware content visibility

  ## Example
  If User A follows User B:
  - follower_id = A's ID
  - followee_id = B's ID

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_connections" do
    belongs_to :followee, Vutuv.Legacy.UserProfiles.User
    belongs_to :follower, Vutuv.Legacy.UserProfiles.User

    timestamps()
  end

  def changeset(user_connection, attrs) do
    user_connection
    |> cast(attrs, [:followee_id, :follower_id])
    |> validate_required([:followee_id, :follower_id])
  end
end

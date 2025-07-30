defmodule Vutuv.Legacy.Sessions.Session do
  @moduledoc """
  Legacy Session schema for user session management.

  Tracks active user sessions with expiration times.
  Used for authentication and session-based features.

  ## Fields
  - `expires_at` - UTC timestamp when the session expires

  ## Purpose
  - Maintains user login state
  - Enables session timeout functionality
  - Supports "remember me" features with longer expiration

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "sessions" do
    field :expires_at, :utc_datetime

    belongs_to :user, Vutuv.Legacy.UserProfiles.User

    timestamps()
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:expires_at, :user_id])
    |> validate_required([:user_id])
  end
end

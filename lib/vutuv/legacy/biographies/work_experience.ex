defmodule Vutuv.Legacy.Biographies.WorkExperience do
  @moduledoc """
  Legacy WorkExperience schema for professional history.

  Stores employment history and professional experiences,
  similar to LinkedIn work experience entries.

  ## Fields
  - `title` - Job title/position (required)
  - `organization` - Company/organization name (required)
  - `description` - Role description and responsibilities
  - `start_date` - Employment start date
  - `end_date` - Employment end date (nil for current positions)
  - `slug` - URL-friendly identifier

  ## Features
  - Chronological work history
  - Current position indicated by nil end_date
  - Rich text descriptions of roles

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "work_experiences" do
    field :description, :string
    field :end_date, :date
    field :organization, :string
    field :slug, :string
    field :start_date, :date
    field :title, :string

    belongs_to :user, Vutuv.Legacy.UserProfiles.User

    timestamps(type: :naive_datetime)
  end

  def changeset(work_experience, attrs) do
    work_experience
    |> cast(attrs, [:description, :end_date, :organization, :slug, :start_date, :title, :user_id])
    |> validate_required([:organization, :title, :user_id])
  end
end

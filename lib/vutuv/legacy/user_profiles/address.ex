defmodule Vutuv.Legacy.UserProfiles.Address do
  @moduledoc """
  Legacy Address schema for storing user physical addresses.

  Supports multiple addresses per user with flexible formatting
  to accommodate international address variations.

  ## Fields
  - `description` - Label/description for the address (e.g., "Home", "Work")
  - `line_1` through `line_4` - Flexible address lines
  - `city` - City name
  - `state` - State/province/region
  - `country` - Country name
  - `zip_code` - Postal/ZIP code

  ## Usage
  Users can have multiple addresses for different purposes.
  The flexible line structure accommodates various international formats.

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "addresses" do
    field :city, :string
    field :country, :string
    field :description, :string
    field :line_1, :string
    field :line_2, :string
    field :line_3, :string
    field :line_4, :string
    field :state, :string
    field :zip_code, :string

    belongs_to :user, Vutuv.Legacy.UserProfiles.User

    timestamps()
  end

  def changeset(address, attrs) do
    address
    |> cast(attrs, [
      :city,
      :country,
      :description,
      :line_1,
      :line_2,
      :line_3,
      :line_4,
      :state,
      :zip_code,
      :user_id
    ])
    |> validate_required([:user_id])
  end
end

defmodule Vutuv.Legacy.Devices.PhoneNumber do
  @moduledoc """
  Legacy PhoneNumber schema for storing user phone contact information.

  Supports multiple phone numbers per user with type classification.

  ## Fields
  - `number_type` - Phone type (e.g., "mobile", "home", "work", "fax")
  - `value` - The phone number

  ## Notes
  - Both number_type and value are required
  - Users can have multiple phone numbers
  - No specific format validation in the schema

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "phone_numbers" do
    field :number_type, :string
    field :value, :string

    belongs_to :user, Vutuv.Legacy.UserProfiles.User

    timestamps()
  end

  def changeset(phone_number, attrs) do
    phone_number
    |> cast(attrs, [:number_type, :value, :user_id])
    |> validate_required([:number_type, :value, :user_id])
  end
end

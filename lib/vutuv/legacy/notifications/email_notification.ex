defmodule Vutuv.Legacy.Notifications.EmailNotification do
  @moduledoc """
  Legacy EmailNotification schema for email notification tracking.

  Records email notifications sent to users, including delivery status.
  Used for notification history and email delivery tracking.

  ## Fields
  - `subject` - Email subject line (required)
  - `body` - Email body content (required)
  - `delivered` - Delivery status flag
  - `owner_id` - Recipient user ID

  ## Purpose
  - Track notification history
  - Monitor email delivery success
  - Audit trail for communications
  - Retry failed deliveries

  ⚠️ READ-ONLY: This schema is for legacy data access only.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "email_notifications" do
    field :body, :string
    field :delivered, :boolean, default: false
    field :subject, :string

    belongs_to :owner, Vutuv.Legacy.UserProfiles.User

    timestamps()
  end

  def changeset(email_notification, attrs) do
    email_notification
    |> cast(attrs, [:body, :delivered, :subject, :owner_id])
    |> validate_required([:body, :subject, :owner_id])
  end
end

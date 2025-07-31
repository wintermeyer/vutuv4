# Legacy Data Migration

This directory contains **READ-ONLY** Ecto schemas that map to the old `vutuv1_dev` database structure. These modules are designed to be temporary and can be easily removed once data migration is complete.

⚠️ **IMPORTANT**: The Legacy Repo is configured as read-only. Any attempt to insert, update, or delete data will raise an error. This ensures the integrity of the legacy data.

## Setup

The legacy database connection is configured in `config/dev.exs`:

```elixir
config :vutuv, Vutuv.Legacy.Repo,
  database: "vutuv1_dev"
```

## Structure

The legacy schemas mirror the original Vutuv3 structure:

- `user_profiles/` - Core user data (User, Address)
- `devices/` - Contact information (EmailAddress, PhoneNumber)
- `sessions/` - User sessions
- `biographies/` - Work experiences
- `publications/` - Posts
- `social_networks/` - Social media accounts
- `tags/` - Tagging system (Tag, UserTag, PostTag, UserTagEndorsement)
- `user_connections/` - Follower/followee relationships
- `notifications/` - Email notifications

## Usage

### Read-Only Access

All write operations (insert, update, delete) are disabled on the Legacy Repo:

```elixir
# ❌ This will raise an error:
Vutuv.Legacy.Repo.insert(%Vutuv.Legacy.UserProfiles.User{})
# => ** (RuntimeError) Write operations are not allowed on the legacy database

# ❌ This will also raise an error:
user |> Ecto.Changeset.change(name: "New Name") |> Vutuv.Legacy.Repo.update()
# => ** (RuntimeError) Write operations are not allowed on the legacy database
```

### Accessing Legacy Data

**Note**: When using these examples in IEx, you must first import Ecto.Query:

```elixir
# First, import Ecto.Query to use query functions
import Ecto.Query

# ✅ Reading data is allowed:
users = Vutuv.Legacy.Repo.all(Vutuv.Legacy.UserProfiles.User)

# ✅ Get user with associations:
user = Vutuv.Legacy.UserProfiles.User
|> Vutuv.Legacy.Repo.get(user_id)
|> Vutuv.Legacy.Repo.preload([:email_addresses, :addresses, :phone_numbers])

# ✅ Complex queries are supported:
active_users = Vutuv.Legacy.UserProfiles.User
|> join(:inner, [u], e in Vutuv.Legacy.Devices.EmailAddress, on: e.user_id == u.id)
|> where([u, e], e.verified == true)
|> distinct(true)
|> Vutuv.Legacy.Repo.all()

# ✅ Find user by email address (use parentheses in IEx for multi-line):
user_by_email = (
  Vutuv.Legacy.Devices.EmailAddress
  |> where([e], e.value == "sw@wintermeyer-consulting.de")
  |> join(:inner, [e], u in Vutuv.Legacy.UserProfiles.User, on: u.id == e.user_id)
  |> select([e, u], u)
  |> Vutuv.Legacy.Repo.one()
  |> Vutuv.Legacy.Repo.preload([:email_addresses, :addresses, :phone_numbers])
)

# ✅ Query users with tags:
users_with_tags = Vutuv.Legacy.UserProfiles.User
|> join(:inner, [u], ut in Vutuv.Legacy.Tags.UserTag, on: ut.user_id == u.id)
|> distinct(true)
|> Vutuv.Legacy.Repo.all()
```

### Migration Helper

Use `Vutuv.Legacy.Migrator` for data migration:

```elixir
# Migrate a single user
{:ok, user} = Vutuv.Legacy.Migrator.migrate_user(legacy_user_id)

# Batch migrate users
result = Vutuv.Legacy.Migrator.migrate_all_users(batch_size: 50)
```

## Removal

To completely remove the legacy integration:

1. Remove the `Vutuv.Legacy.Repo` from `lib/vutuv/application.ex`
2. Remove the legacy repo configuration from `config/dev.exs`
3. Delete the entire `lib/vutuv/legacy/` directory
4. Remove any references to `Vutuv.Legacy` modules from your codebase
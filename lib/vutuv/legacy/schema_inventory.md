# Legacy Schema Inventory

This document confirms that all Ecto schemas from Vutuv3 have been mapped to the legacy module.

## Complete Schema List (15 schemas)

### ✅ User and Profile Related (2 schemas)
- [x] `Vutuv.Legacy.UserProfiles.User` - maps to `users` table
- [x] `Vutuv.Legacy.UserProfiles.Address` - maps to `addresses` table

### ✅ Authentication and Sessions (2 schemas)
- [x] `Vutuv.Legacy.Accounts.UserCredential` - maps to `user_credentials` table
- [x] `Vutuv.Legacy.Sessions.Session` - maps to `sessions` table

### ✅ Contact Information (2 schemas)
- [x] `Vutuv.Legacy.Devices.EmailAddress` - maps to `email_addresses` table
- [x] `Vutuv.Legacy.Devices.PhoneNumber` - maps to `phone_numbers` table

### ✅ Content and Publications (1 schema)
- [x] `Vutuv.Legacy.Publications.Post` - maps to `posts` table

### ✅ Social Features (2 schemas)
- [x] `Vutuv.Legacy.SocialNetworks.SocialMediaAccount` - maps to `social_media_accounts` table
- [x] `Vutuv.Legacy.UserConnections.UserConnection` - maps to `user_connections` table

### ✅ Tagging System (4 schemas)
- [x] `Vutuv.Legacy.Tags.Tag` - maps to `tags` table
- [x] `Vutuv.Legacy.Tags.UserTag` - maps to `user_tags` table
- [x] `Vutuv.Legacy.Tags.PostTag` - maps to `post_tags` table
- [x] `Vutuv.Legacy.Tags.UserTagEndorsement` - maps to `user_tag_endorsements` table

### ✅ Professional Information (1 schema)
- [x] `Vutuv.Legacy.Biographies.WorkExperience` - maps to `work_experiences` table

### ✅ Notifications (1 schema)
- [x] `Vutuv.Legacy.Notifications.EmailNotification` - maps to `email_notifications` table

## Non-Schema Modules from Vutuv3

These modules from Vutuv3 are NOT Ecto schemas and were not included:
- `Vutuv.UserProfiles.Locale` - A utility struct for locale handling, not a database schema

## Summary

**Total Ecto Schemas**: 15 (all migrated)
**Database Tables**: 15
**Status**: ✅ Complete - All Ecto schemas from Vutuv3 have been successfully mapped to the legacy module.
# I18n Quick Reference Guide

## UI Text Translation

```elixir
# Simple translation
<%= gettext("Welcome") %>

# With interpolation
<%= gettext("Hello %{name}!", name: @user.name) %>

# Pluralization
<%= ngettext("1 item", "%{count} items", @count) %>

# Domain-specific
<%= dgettext("errors", "Invalid input") %>
```

## Database Content Translation (Tags/Skills/Categories)

```elixir
# Import helpers
import VutuvWeb.TranslationHelpers

# Translate tags
<%= translate_tag(tag.name) %>

# Translate skills
<%= translate_skill(skill.name) %>

# Translate categories
<%= translate_category(category.name) %>

# Generic domain translation
<%= translate_content("custom_domain", content) %>
```

## Domain Structure

```
priv/gettext/
├── default.pot       # UI translations
├── errors.pot        # Error messages
├── tags.pot         # Tag names
├── skills.pot       # Skill names
├── categories.pot   # Category names
└── [locale]/
    └── LC_MESSAGES/
        ├── default.po
        ├── errors.po
        ├── tags.po
        ├── skills.po
        └── categories.po
```

## Adding New Content

1. **Add to database in English**: `Tags.create_tag(%{name: "Machine Learning"})`
2. **Extract for translation**: `mix gettext.extract.tags`
3. **Merge translations**: `mix gettext.merge priv/gettext`
4. **Translate in .po files**: Edit `priv/gettext/de/LC_MESSAGES/tags.po`

## Adding New Languages

1. Create locale directory: `mkdir -p priv/gettext/[locale]/LC_MESSAGES`
2. Copy English .po files as templates
3. Translate content in .po files
4. Add locale to config: `config :vutuv_web, VutuvWeb.Gettext, locales: ~w(en de fr)`

## Common Patterns

```elixir
# Set locale in controller/LiveView
Gettext.put_locale(VutuvWeb.Gettext, locale)

# Get current locale
locale = Gettext.get_locale(VutuvWeb.Gettext)

# In templates with helpers
<%= for tag <- @tags do %>
  <span><%= translate_tag(tag.name) %></span>
<% end %>

# In LiveView
def render(assigns) do
  ~H"""
  <div>
    <%= for skill <- @skills do %>
      <div><%= translate_skill(skill.name) %></div>
    <% end %>
  </div>
  """
end
```

## Translation File Example

```po
# priv/gettext/de/LC_MESSAGES/tags.po
msgid "Software Development"
msgstr "Softwareentwicklung"

msgid "Data Science"
msgstr "Datenwissenschaft"
```

## Key Commands

- Extract all: `mix gettext.extract --merge`
- Extract tags: `mix gettext.extract.tags`
- Extract skills: `mix gettext.extract.skills`
- Merge all: `mix gettext.merge priv/gettext`
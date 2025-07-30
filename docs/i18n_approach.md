# Internationalization (I18n) Approach for Vutuv4

## Overview

This document outlines the internationalization strategy for Vutuv4. Our approach uses Elixir's Gettext library exclusively, storing all content in English and translating through Gettext domains. This provides a simple, maintainable solution that leverages Gettext's compile-time benefits.

## Key Principles

1. **English-Only Database**: All content (tags, skills, categories) stored in English
2. **Gettext for Everything**: Use Gettext domains to translate all content
3. **Simple and Maintainable**: No complex database schemas or dynamic translation systems
4. **Compile-Time Benefits**: Leverage Gettext's extraction and validation tools
5. **Domain Organization**: Use separate domains for different content types

## Architecture

### 1. Database Storage

All content is stored in English:

```elixir
# Simple schema - no translation tables needed
defmodule Vutuv.Tags.Tag do
  use Ecto.Schema
  
  schema "tags" do
    field :name, :string  # Stored in English, e.g., "Software Development"
    field :slug, :string
    field :description, :string  # Also in English
    timestamps()
  end
end

defmodule Vutuv.Skills.Skill do
  use Ecto.Schema
  
  schema "skills" do
    field :name, :string  # English, e.g., "Project Management"
    field :category, :string  # English, e.g., "Management"
    timestamps()
  end
end
```

### 2. Gettext Domain Structure

Organize translations by domain for better maintainability:

```
priv/gettext/
├── default.pot          # UI translations
├── errors.pot           # Error messages
├── tags.pot            # Tag translations
├── skills.pot          # Skill translations
├── categories.pot      # Category translations
└── en/
    └── LC_MESSAGES/
        ├── default.po
        ├── errors.po
        ├── tags.po
        ├── skills.po
        └── categories.po
```

### 3. Translation Helpers

Create simple helpers that use Gettext with appropriate domains:

```elixir
defmodule VutuvWeb.TranslationHelpers do
  @moduledoc """
  Helpers for translating database content through Gettext
  """
  
  import VutuvWeb.Gettext
  
  @doc """
  Translates a tag name using the tags domain
  """
  def translate_tag(tag_name) when is_binary(tag_name) do
    dgettext("tags", tag_name)
  end
  
  @doc """
  Translates a skill name using the skills domain
  """
  def translate_skill(skill_name) when is_binary(skill_name) do
    dgettext("skills", skill_name)
  end
  
  @doc """
  Translates a category using the categories domain
  """
  def translate_category(category_name) when is_binary(category_name) do
    dgettext("categories", category_name)
  end
  
  @doc """
  Generic translation for any domain
  """
  def translate_content(domain, content) when is_binary(content) do
    dgettext(domain, content)
  end
end
```

### 4. Usage in Templates

```elixir
# Import the helpers in your view modules
defmodule VutuvWeb.UserView do
  use VutuvWeb, :view
  import VutuvWeb.TranslationHelpers
end

# In templates
<div class="user-tags">
  <h3><%= gettext("Skills & Expertise") %></h3>
  <%= for tag <- @user.tags do %>
    <span class="tag">
      <%= translate_tag(tag.name) %>
    </span>
  <% end %>
</div>

# For skills with categories
<div class="skills">
  <%= for skill <- @user.skills do %>
    <div class="skill-item">
      <span class="skill-name"><%= translate_skill(skill.name) %></span>
      <span class="skill-category">
        <%= translate_category(skill.category) %>
      </span>
    </div>
  <% end %>
</div>
```

### 5. LiveView Integration

```elixir
defmodule VutuvWeb.UserLive.Profile do
  use VutuvWeb, :live_view
  import VutuvWeb.TranslationHelpers
  
  def render(assigns) do
    ~H"""
    <div class="profile">
      <h2><%= gettext("User Profile") %></h2>
      
      <div class="tags-section">
        <h3><%= gettext("Tags") %></h3>
        <%= for tag <- @tags do %>
          <.tag_badge name={translate_tag(tag.name)} />
        <% end %>
      </div>
    </div>
    """
  end
  
  def mount(_params, session, socket) do
    locale = get_locale_from_session(session)
    Gettext.put_locale(VutuvWeb.Gettext, locale)
    
    {:ok, assign(socket, :tags, load_user_tags())}
  end
end
```

## Implementation Guidelines

### 1. Locale Detection and Storage

```elixir
defmodule VutuvWeb.Plugs.Locale do
  import Plug.Conn
  
  def init(opts), do: opts
  
  def call(conn, _opts) do
    locale = get_locale_from_params(conn) || 
             get_locale_from_session(conn) || 
             get_locale_from_headers(conn) || 
             "en"
    
    Gettext.put_locale(VutuvWeb.Gettext, locale)
    
    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end
  
  defp get_locale_from_params(conn) do
    conn.params["locale"]
  end
  
  defp get_locale_from_session(conn) do
    get_session(conn, :locale)
  end
  
  defp get_locale_from_headers(conn) do
    conn
    |> get_req_header("accept-language")
    |> Enum.at(0, "")
    |> String.split(",")
    |> Enum.map(&parse_language_option/1)
    |> Enum.sort(&(&1.quality > &2.quality))
    |> Enum.find(&is_supported_locale?/1)
    |> case do
      nil -> nil
      lang -> lang.locale
    end
  end
end
```

### 2. Managing Translation Files

When new tags, skills, or categories are added:

1. **Add to seed data** with English names
2. **Extract translations** using Mix tasks
3. **Update .pot files** with new entries
4. **Translate in .po files** for each supported locale

#### Creating Custom Mix Tasks for Content Extraction

```elixir
defmodule Mix.Tasks.Gettext.ExtractTags do
  use Mix.Task
  alias Vutuv.{Repo, Tags}
  
  @shortdoc "Extracts tag names for translation"
  
  def run(_args) do
    Mix.Task.run("app.start")
    
    tags = Repo.all(Tags.Tag)
    pot_file = "priv/gettext/tags.pot"
    
    # Generate entries for each tag
    entries = Enum.map(tags, fn tag ->
      """
      #: database:tags
      msgid "#{tag.name}"
      msgstr ""
      """
    end)
    
    # Write to POT file (simplified example)
    File.write!(pot_file, generate_pot_header() <> Enum.join(entries, "\n"))
    
    Mix.shell().info("Extracted #{length(tags)} tags to #{pot_file}")
  end
end
```

### 3. Handling User-Generated Content

For completely new user-generated content:

```elixir
defmodule Vutuv.Tags do
  @doc """
  Creates a new tag. For user-generated tags, we store them in English
  and add them to our translation workflow if they become popular.
  """
  def create_tag(attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> validate_english_content()
    |> Repo.insert()
  end
  
  defp validate_english_content(changeset) do
    # Optionally validate or normalize to English
    changeset
  end
  
  @doc """
  Track tag usage to identify candidates for translation
  """
  def track_popular_tags do
    Repo.all(
      from t in Tag,
      join: ut in assoc(t, :user_tags),
      group_by: t.id,
      having: count(ut.id) > 100,
      select: {t, count(ut.id)}
    )
  end
end
```

## Migration Strategy from Vutuv3

1. **Import all tags as English** - Store tag names directly from vutuv3
2. **Normalize naming** - Ensure consistent capitalization and formatting
3. **Generate translation files** - Create initial .pot files with all content
4. **Prioritize translations** - Start with most-used tags and skills

```elixir
defmodule Vutuv.Migrations.ImportFromV3 do
  def import_tags do
    # Import from vutuv3
    v3_tags
    |> Enum.map(&normalize_tag_name/1)
    |> Enum.each(&create_or_update_tag/1)
  end
  
  defp normalize_tag_name(tag_name) do
    tag_name
    |> String.trim()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
```

## Testing Strategy

```elixir
defmodule VutuvWeb.TranslationTest do
  use VutuvWeb.ConnCase
  import VutuvWeb.TranslationHelpers
  
  describe "content translation" do
    test "translates tags through gettext domain" do
      # Assuming German translations exist in tags.po
      Gettext.put_locale(VutuvWeb.Gettext, "de")
      
      assert translate_tag("Software Development") == "Softwareentwicklung"
      assert translate_tag("Project Management") == "Projektmanagement"
    end
    
    test "falls back to English for missing translations" do
      Gettext.put_locale(VutuvWeb.Gettext, "fr")
      
      # If French translation doesn't exist, returns original
      assert translate_tag("Machine Learning") == "Machine Learning"
    end
    
    test "handles different domains correctly" do
      Gettext.put_locale(VutuvWeb.Gettext, "de")
      
      assert translate_skill("Leadership") == "Führung"
      assert translate_category("Technical") == "Technisch"
    end
  end
end
```

## Workflow for Adding New Content

1. **Developer adds new tag/skill/category** in English to seed file
2. **Run extraction task** `mix gettext.extract.tags`
3. **Merge into existing translations** `mix gettext.merge priv/gettext --locale=de`
4. **Translator updates** .po files with translations
5. **Deploy** - Translations immediately available

## Performance Considerations

Since all translations are handled by Gettext:

1. **Compile-time optimization** - Gettext compiles translations for fast lookup
2. **No database queries** for translations
3. **Built-in caching** through Gettext's implementation
4. **Minimal runtime overhead**

## Example Translation Files

### priv/gettext/tags.pot
```
msgid ""
msgstr ""
"Language: en\n"

#: database:tags
msgid "Software Development"
msgstr ""

#: database:tags
msgid "Project Management"
msgstr ""

#: database:tags
msgid "Data Science"
msgstr ""
```

### priv/gettext/de/LC_MESSAGES/tags.po
```
msgid ""
msgstr ""
"Language: de\n"

#: database:tags
msgid "Software Development"
msgstr "Softwareentwicklung"

#: database:tags
msgid "Project Management"
msgstr "Projektmanagement"

#: database:tags
msgid "Data Science"
msgstr "Datenwissenschaft"
```

## Common Patterns and Best Practices

1. **Always store in English** - Consistency is key
2. **Use descriptive domain names** - tags, skills, categories, etc.
3. **Automate extraction** - Regular Mix tasks to catch new content
4. **Version control .pot files** - Track what needs translation
5. **Monitor untranslated content** - Identify high-priority items

## Advantages of This Approach

1. **Simplicity** - No complex database schemas or runtime lookups
2. **Performance** - Gettext's compile-time optimizations
3. **Tool Support** - Standard .po file editors and translation services
4. **Maintainability** - Clear separation between code and translations
5. **Flexibility** - Easy to add new languages or domains

## Conclusion

This simplified approach treats all content as translatable strings through Gettext, eliminating the need for complex database translation schemes. By storing everything in English and using Gettext domains, we achieve:

- Maximum simplicity in implementation
- Excellent performance through compile-time optimization
- Standard tooling for translators
- Easy maintenance and updates
- Clear workflow for adding new content

The key insight is that tags, skills, and categories are essentially a finite set of strings that can be managed like any other UI text through Gettext's proven translation system.
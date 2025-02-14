# Rails I18n Manager
> A complete translation editor and workflow

<a href="https://badge.fury.io/rb/rails_i18n_manager" target="_blank"><img height="21" style='border:0px;height:21px;' border='0' src="https://badge.fury.io/rb/rails_i18n_manager.svg" alt="Gem Version"></a>
<a href='https://github.com/westonganger/rails_i18n_manager/actions' target='_blank'><img src="https://github.com/westonganger/rails_i18n_manager/actions/workflows/test.yml/badge.svg" style="max-width:100%;" height='21' style='border:0px;height:21px;' border='0' alt="CI Status"></a>

Web interface to manage i18n translations helping to facilitate the editors of your translations. Provides a low-tech and complete workflow for importing, translating, and exporting your I18n translation files. Designed to allow you to keep the translation files inside your projects git repository where they should be.

Features:

- Import & export translations using standard i18n YAML/JSON files
- Allows managing translations for any number of apps
- Built in support for Google Translation for missing translations
- Provides an API end point to perform automated downloads of your translations

## Screenshots
![Screenshot](/screenshot_list.png)
<br><br>
![Screenshot](/screenshot_import.png)
<br><br>
![Screenshot](/screenshot_edit.png)

## Setup

Developed as a Rails engine. So you can add to any existing app or create a brand new app with the functionality.

First add the gem to your Gemfile

```ruby
### Gemfile
gem "rails_i18n_manager"
```

Then install and run the database migrations

```sh
bundle install
bundle exec rake rails_i18n_manager:install:migrations
bundle exec rake db:migrate
```

### Routes

#### Option A: Mount to a path

```ruby
### config/routes.rb

### As sub-path
mount RailsI18nManager::Engine, at: "/rails_i18n_manager", as: "rails_i18n_manager"

### OR as root-path
mount RailsI18nManager::Engine, at: "/", as: "rails_i18n_manager"
```

#### Option B: Mount to a subdomain

```ruby
### config/routes.rb

translations_engine_subdomain = "translations"

mount RailsI18nManager::Engine,
  at: "/", as: "translations_engine",
  constraints: Proc.new{|request| request.subdomain == translations_engine_subdomain }

not_engine = Proc.new{|request| request.subdomain != translations_engine_subdomain }

constraints not_engine do
  # your app routes here...
end
```

### Configuration

```ruby
### config/initializers/rails_i18n_manager.rb

RailsI18nManager.config do |config|
  config.google_translate_api_key = ENV.fetch("GOOGLE_TRANSLATE_API_KEY", nil)

  ### You can use our built-in list of all locales Google Translate supports
  ### OR make your own list. These need to be supported by Google Translate
  # config.valid_locales = ["en", "es", "fr"]
end
```

### Customizing Authentication

```ruby
### config/routes.rb

### Using Devise
authenticated :user do
  mount RailsI18nManager::Engine, at: "/rails_i18n_manager", as: "rails_i18n_manager"
end

### Custom devise-like
constraints ->(req){ req.session[:user_id].present? && User.find_by(id: req.session[:user_id]) } do
  mount RailsI18nManager::Engine, at: "/rails_i18n_manager", as: "rails_i18n_manager"
end

### HTTP Basic Auth
with_http_basic_auth = ->(engine){
  Rack::Builder.new do
    use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV.fetch("RAILS_I18N_MANAGER_USERNAME"))) &&
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV.fetch("RAILS_I18N_MANAGER_PASSWORD")))
    end
    run(engine)
  end
}
mount with_http_basic_auth.call(RailsI18nManager::Engine), at: "/rails_i18n_manager", as: "rails_i18n_manager"
```

### API Endpoint

We provide an endpoint to retrieve your translation files at `/translations`.

You will likely want to add your own custom authentication strategy and can do so using a routing constraint on the `mount RailsI18nManager` call.

From that point you can implement an automated mechanism to update your apps translations using the provided API end point. Some examples

An example in Ruby:

```ruby
require 'open-uri'

zip_stream = URI.open('https://translations-manager.example.com/translations.zip?export_format=yaml')
IO.copy_stream(zip_stream, '/tmp/my-app-locales.zip')
`unzip /tmp/my-app-locales.zip /tmp/my-app-locales/`
`rsync --delete-after /tmp/my-app-locales/my-app/ /path/to/my-app/config/locales/`
puts "Locales are now updated, app restart not-required"
```

A command line example using curl:

```
curl https://translations-manager.example.com/translations.zip?export_format=json -o /tmp/my-app-locales.zip \
  && unzip /tmp/my-app-locales.zip /tmp/my-app-locales/ \
  && rsync --delete-after /tmp/my-app-locales/my-app/ \
  && echo "Locales are now updated, app restart not-required"
```

## Recommended Workflow for Teams

It is desirable to reduce how often import/export is performed. It is also desirable that we do not violate the regular PR lifecycle/process. The following workflow should allow for this.

When creating a PR you can just create a new YAML file named after your feature name or ticket number and then use the following format:

```yaml
# config/locales/some_new_feature.yml

en:
  some_new_key: "foo"
fr:
  some_new_key: "bar"
es:
  some_new_key: "baz"
```

Whenever releasing a new version of your application, pre-deploy or some other cadence, then you can have a step where all translation files are uploaded to the `rails_i18n_manager`, have your translator folks double check everything, then export your new files and cleanup all the feature files.

## Recommended I18n Configuration

The default I18n backend has some glaring issues

- It will silently show "translation_missing" text which is very undesirable
- It will not fallback to your default or any other locale

You can avoid these issues using either of the techniques below

```ruby
# config/initializers/i18n.rb

Rails.configuration do |config|
  config.i18n.raise_on_missing_translations = true # WARNING: this will raise exceptions in Production too, preventing your users from using your application even when some silly little translation  is missing

  config.i18n.fallbacks = [I18n.default_locale, :en].uniq # fallback to default locale, or if that is missing then fallback to english translation
end
```

You will likely find that `raise_on_missing_translations` is too aggressive. Causing major outages just because a translation is missing. In that scenario its better to use something like the following:

```ruby
# config/initializers/i18n.rb

Rails.configuration do |config|
  config.i18n.raise_on_missing_translations = false # Instead we use the custom backend below

  config.i18n.fallbacks = [I18n.default_locale, :en].uniq # fallback to default locale, or if that is missing then fallback to english translation
end

module I18n
  class CustomI18nBackend
    include I18n::Backend::Base

    def translate(locale, key, options = EMPTY_HASH)
      if !key.nil? && key.to_s != "i18n.plural.rule"
        translation_value = lookup(locale, key, options[:scope], options)

        if translation_value.blank?
          if Rails.env.production?
            # send an email or some other warning mechanism
          else
            # Raise exception in non-production environments
            raise "Translation not found (locale: #{locale}, key: #{key})"
          end
        end
      end

      return nil # allow the Backend::Chain to continue to the next backend
    end
  end
end

if I18n.backend.is_a?(I18n::Backend::Chain)
  I18n.backend.backends.unshift(I18n::CustomI18nBackend)
else
  I18n.backend = I18n::Backend::Chain.new(
    I18n::CustomI18nBackend,
    I18n.backend, # retain original backend
  )
end
```

## Development

Run migrations using: `rails db:migrate`

Run server using: `bin/dev` or `cd test/dummy/; rails s`

## Testing

```
bundle exec rspec
```

We can locally test different versions of Rails using `ENV['RAILS_VERSION']`

```
export RAILS_VERSION=7.0
bundle install
bundle exec rspec
```

## Other Translation Managers & Web Interfaces

For comparison, some other projects for managing Rails translations.

- https://github.com/tolk/tolk - This is the project that inspired rails_i18n_manager. UI and file-based approach. I [attempted to revive tolk](https://github.com/tolk/tolk/pull/161) but gave up as I found the codebase and workflow was really just a legacy ball of spagetti.
- https://github.com/prograils/lit
- https://github.com/alphagov/rails_translation_manager
- https://github.com/glebm/i18n-tasks


# Credits

Created & Maintained by [Weston Ganger](https://westonganger.com) - [@westonganger](https://github.com/westonganger)

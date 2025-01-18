source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in coders_log.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

def get_env(name)
  (ENV[name] && !ENV[name].empty?) ? ENV[name] : nil
end

rails_version = get_env("RAILS_VERSION")

gem "rails", rails_version

db_gem = get_env("DB_GEM") || "sqlite3"
gem db_gem, get_env("DB_GEM_VERSION")

group :development do
  gem "puma"
end

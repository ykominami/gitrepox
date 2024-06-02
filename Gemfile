# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in gitrepox.gemspec
gemspec

gem "git"
gem "google_drive"
gem "rake", "~> 13.2"
# gem "secretmgr", path: "../secretmgr"
gem "loggerx"
gem "secretmgr", ">= 0.2.0"

group :test, :development, optional: true do
  gem "debug"
  gem "rspec", "~> 3.13"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
end

# group :development, optional: true do
# end

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'
gem 'jwt'
gem 'rails-i18n'
gem 'net-smtp'
gem 'net-imap'
gem 'net-pop'
gem 'dotenv-rails'
gem 'rubocop', require:false
gem 'rubocop-rails', require:false
gem 'sprockets', '~> 3.7.2'
gem 'rails', '~> 6.1.5', '>= 6.1.5.1'
gem 'mysql2', '~> 0.5'
gem 'puma', '~> 5.0'
gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'rack-cors'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :production, :staging do
  gem 'unicorn'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

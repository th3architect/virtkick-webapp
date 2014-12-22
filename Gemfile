source 'https://rubygems.org'

ruby '2.1.5'

gem 'rake', '10.1.0'
gem 'active_hash'
gem 'activemodel'
gem 'bootstrap-sass', '~> 3.1'
gem 'bugsnag'
gem 'coffee-rails', '~> 4.1.0'
gem 'daemons'
gem 'debug_inspector'
gem 'devise', git: 'https://github.com/plataformatec/devise.git', branch: 'lm-rails-4-2'
gem 'font-awesome-rails'
gem 'ipaddress', '~> 0.8.0'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'httparty'
gem 'rails', '4.2.0'
gem 'twitter-bootstrap-rails-confirm', git: 'https://github.com/bluerail/twitter-bootstrap-rails-confirm.git'
gem 'rails-html-sanitizer', '~> 1.0'
gem 'rails_bootstrap_navbar'
gem 'recursive-open-struct'
gem 'responders', '~> 2.0'
gem 'sass-rails', '~> 5.0.0.beta1'
gem 'slim'
gem 'uglifier', '>= 1.3.0'
gem 'requirejs-rails', git: 'https://github.com/Rush/requirejs-rails.git', branch: 'sourceMaps'

# These require native extensions. Ensure Traveling Ruby provides an appropriate version before bumping.
gem 'bcrypt', '3.1.9'
gem 'nokogiri', '1.6.5'
gem 'sqlite3', '1.3.9'


group :development, :test do
  gem 'rspec-rails'
  gem 'spring'
  gem 'web-console', '2.0.0'
end unless ENV['PACKAGING']

group :development do
  gem 'rb-fsevent', require: false
end unless ENV['PACKAGING']

group :test do
  gem 'codeclimate-test-reporter'
  gem 'timecop'
end unless ENV['PACKAGING']

# Gems that need to be required as last
gem 'delayed_job', git: 'https://github.com/Nowaker/delayed_job.git', branch: 'feature/exception-in-failure-hook'
gem 'delayed_job_active_record', '~> 4.0', git: 'https://github.com/Nowaker/delayed_job_active_record.git'


if File.exists?('Gemfile.local')
  eval File.read('Gemfile.local'), nil, 'Gemfile.local'
end

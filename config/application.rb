require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ProjectCato
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.middleware.insert_before ActionDispatch::Static, "Rack::Cors" do

      allow do
        origins 'localhost', 'localhost:3000', 'www.morgenbladet.no', 'morgenbladet.no'

        resource '/nominations', headers: :any, methods: %i(post), max_age: 0, credentials: true
        resource '*', headers: :any, methods: %i(get options head), max_age: 0
      end

    end
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { :api_token => "ffa0113f-75fb-40d2-9afe-6483adbf2ea4" }
    config.action_mailer.default_url_options = { host: 'cato.herokuapp.com', protocol: 'https' }
  end
end

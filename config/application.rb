require_relative "boot"

require "rails/all"
require "dotenv"
Dotenv.load(".env.production")


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SampleApp
  class Application < Rails::Application
    config.load_defaults 8.0
    config.beginning_of_week = :sunday

    config.time_zone = "Asia/Tokyo"
    config.active_record.default_timezone = :local
    config.api_only = true
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: "_sample_app_session"
  end

  module AiDiary
    class Application < Rails::Application
      config.load_defaults 8.0

      config.autoload_lib(ignore: %w[assets tasks])

      config.time_zone = "Tokyo"
      config.i18n.default_locale = :ja
      config.i18n.available_locales = [ :en, :ja ]
    end
  end
end

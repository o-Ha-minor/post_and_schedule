require_relative "boot"

require "rails/all"
require "dotenv"
Dotenv.load(".env.production")


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SampleApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    # config.autoload_lib(ignore: %w[assets tasks])

    config.beginning_of_week = :sunday

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Asia/Tokyo"
    config.active_record.default_timezone = :local
    config.api_only = true
    # config.eager_load_paths << Rails.root.join("extras")
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

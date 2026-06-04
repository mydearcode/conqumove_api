require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Conqurun
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.generators do |generate|
      generate.orm :active_record, primary_key_type: :uuid
    end

    config.x.public_base_url = ENV["CONQUMOVE_PUBLIC_BASE_URL"]
    config.x.public_cable_url = ENV["CONQUMOVE_PUBLIC_CABLE_URL"]
    config.x.public_api_rate_limits = {
      auth: {
        register: { limit: 10, period: 5.minutes },
        login: { limit: 10, period: 5.minutes },
        refresh: { limit: 30, period: 5.minutes }
      },
      sessions: {
        start: { limit: 30, period: 5.minutes },
        finish: { limit: 30, period: 5.minutes }
      },
      movement_batches: {
        create: { limit: 240, period: 1.minute }
      },
      realtime_subscriptions: {
        nearby: { limit: 60, period: 5.minutes }
      },
      territories: {
        nearby: { limit: 60, period: 5.minutes }
      },
      leaderboards: {
        show: { limit: 30, period: 5.minutes }
      }
    }

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end

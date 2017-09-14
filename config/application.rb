require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module ElmDirectory
  class Application < Rails::Application
    config.active_job.queue_adapter = :sidekiq
    config.autoload_paths += Dir.glob("#{config.root}/app/interactions/*")
  end
end

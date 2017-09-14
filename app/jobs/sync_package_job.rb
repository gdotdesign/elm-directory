class SyncPackageJob < ApplicationJob
  rescue_from(StandardError) do |exception|
    Rails.logger.error "[#{self.class.name}] #{exception}"
  end

  queue_as :default

  def perform(repository)
    SyncPackage.run repository: repository
  end
end

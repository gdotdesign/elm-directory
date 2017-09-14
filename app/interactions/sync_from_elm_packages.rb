require 'net/http'

class SyncFromElmPackages < ActiveInteraction::Base
  def execute
    JSON.parse(
      Net::HTTP.get(
        URI.parse('http://package.elm-lang.org/all-packages')))
        .map { |package| SyncPackageJob.perform_later package['name'] }
  end
end

class SyncPackages < ActiveInteraction::Base
  def execute
    @date = Date.today
    process
  end

  def process
    @date.downto(Date.new(2016, 05, 01)) do |date|
      puts "\n#{date}"
      puts '=============================================='

      @date = date
      page(date).items.each do |repo|
        SyncPackageJob.perform_later repo.full_name
      end
    end
  rescue Octokit::TooManyRequests
    puts "\nSleeping because of the search rate limit..."
    puts '=============================================='
    sleep 60
    process
  end

  def page(date)
    Octokit.search_repositories("language:elm pushed:#{date}", per_page: 1000)
  end
end

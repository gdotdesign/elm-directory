class SyncPackage < ActiveInteraction::Base
  string :repository

  def execute
    # Don't bother with versionless repos.
    return if raw_versions.empty?
    update_package_infos
    import_versions
  end

  def update_package_infos
    package.update_attributes(stars: stars, pushed_at: pushed_at)
  end

  def import_versions
    versions.each do |semver|
      ImportVersion.run(package: package, semver: semver)
    end
  end

  def raw_versions
    Octokit
      .tags(repository)
      .map(&:name)
  rescue StandardError => error
    puts error
    []
  end

  def versions
    raw_versions
      .reject { |version| package.versions.exists?(version: version) }
      .select do |version|
        begin
          semver = Semantic::Version.new version
          # Only valid semvers are ok
          !(semver.pre || semver.build)
        # Skip because invalid semver
        rescue StandardError
          false
        end
      end
  end

  def pushed_at
    package_info.pushed_at
  end

  def stars
    package_info.stargazers_count
  end

  def package_info
    @package_info ||= Octokit.repository(repository)
  end

  def package
    @package ||= Package.find_or_create_by(repository: repository)
  end
end

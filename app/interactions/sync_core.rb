class SyncCore < ActiveInteraction::Base
  def execute
    update_package_infos

    packages
      .find { |item| item['name'] == 'elm-lang/core' }['versions']
      .map { |version| import version }
  end

  def import(version)
    return if package.versions.exists?(version: version)

    package
      .versions
      .create(
        documentation: documentation(version),
        package_json: package_json(version),
        readme: readme(version),
        effect_manager: true,
        version: version
      )
  end

  def documentation(version)
    JSON.parse(
      Net::HTTP
        .get(URI.parse("#{host}/packages/elm-lang/core/#{version}/documentation.json"))
        .to_s
        .force_encoding('UTF-8'))
  end

  def package_json(version)
    JSON.parse(
      Net::HTTP
        .get(URI.parse("https://raw.githubusercontent.com/elm-lang/core/#{version}/elm-package.json"))
        .to_s
        .force_encoding('UTF-8'))
  end

  def readme(version)
    Net::HTTP
      .get(URI.parse("#{host}/packages/elm-lang/core/#{version}/README.md"))
      .to_s
      .force_encoding('UTF-8')
  end

  def packages
    JSON.parse(Net::HTTP.get(URI.parse("#{host}/all-packages")))
  end

  def package
    @package ||= Package.find_or_initialize_by(repository: 'elm-lang/core')
  end

  def update_package_infos
    package.update_attributes(stars: stars, pushed_at: pushed_at)
  end

  def pushed_at
    package_info.pushed_at
  end

  def stars
    package_info.stargazers_count
  end

  def package_info
    @package_info ||= Octokit.repository('elm-lang/core')
  end

  def host
    'http://package.elm-lang.org'
  end
end

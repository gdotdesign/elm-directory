require 'open-uri'
require 'pathname'
require 'zip'

class ImportVersion < ActiveInteraction::Base
  object :package, class: Package
  string :semver

  def execute
    extract do |dir|
      next if elm_package_json(dir)['exposed-modules'].to_a.empty?

      version
        .update_attributes(
          # This needs to be first because it would search in elm-stuff in
          # edge cases.
          effect_manager: effect_manager(dir),
          documentation: compile_documentation(dir),
          package_json: elm_package_json(dir),
          readme: readme(dir),
          version: semver
        )
    end
  end

  def version
    @version ||=
      Version.find_or_initialize_by(package: package, version: semver)
  end

  # Returns the readme
  def readme(dir)
    filename = Dir.glob("#{dir}/readme.*", File::FNM_CASEFOLD).first
    filename ? File.read(filename) : ''
  end

  # Returns whether or not the version contains effect managers
  def effect_manager(dir)
    @effect_manager ||=
      !`grep -rnw #{source_directories(dir)} -e '^effect module' -s`.empty?
  end

  # Returns the source directories
  def source_directories(dir)
    elm_package_json(dir)['source-directories']
      .to_a
      .map { |directory| Pathname.new("#{dir}/#{directory}").cleanpath }
      .select { |directory| Dir.exist?(directory) }
      .map { |directory| "'#{directory}'" }
      .join(' ')
  end

  # Compiles documentation
  def compile_documentation(dir)
    elm_executable =
      Rails.root.join 'vendor', 'executables', "elm-make-#{elm_version(dir)}"

    relative_elm_executable =
      Pathname.new(elm_executable).relative_path_from(Pathname.new(dir))

    if ENV['DATABASE_URL']
      relative_elm_executable =
        "/app/.heroku/vendor/bin/sysconfcpus -n 2 #{relative_elm_executable}"
    end

    puts 'Installing dependencies via elm-install...'

    cache_directory = File.join(Dir.pwd, '.cache')

    Dir.chdir dir do
      ElmInstall.install cache_directory: cache_directory, verbose: false

      raise unless Dir.exist?('elm-stuff')
      puts 'Compiling documentation...'
      `#{relative_elm_executable} --docs=test.json --yes`
    end

    JSON.parse(File.read(File.join(dir, 'test.json')))
  # If anything goes wrong return empty string
  rescue StandardError, SystemExit => error
    puts error
    []
  end

  def extract
    Dir.mktmpdir do |dir|
      Zip::File.open_buffer(archive) do |zip_file|
        puts "Extracting archive to: #{dir}..."

        zip_file.each do |entry|
          # Remove the package-name-version root directory
          path = entry.name.split('/')[1..-1].join('/')
          entry.extract(File.join(dir, path))
        end
      end

      yield dir
    end
  end

  def elm_version(dir)
    range = elm_package_json(dir)['elm-version'].to_s.strip

    if range.starts_with?('0.17')
      17
    elsif range.starts_with?('0.18')
      18
    else
      -1
    end
  end

  def elm_package_json(dir)
    package_path = File.join(dir, 'elm-package.json')
    JSON.parse(File.read(package_path))
  rescue StandardError => error
    puts error
    {}
  end

  def archive
    puts "Downloading archive from: #{archive_path}..."
    @archive ||= Net::HTTP.get(URI.parse(archive_path))
  end

  def archive_path
    "https://codeload.github.com/#{package.repository}/zip/#{semver}"
  end
end

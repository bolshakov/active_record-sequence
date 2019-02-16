require 'yaml'

matrix = [
  {
    rails_version: '4.2.11',
    ruby_versions: %w[2.4.5 2.5.3 2.6.1],
    pg_version: '< 1.0.0',
  },
  {
    rails_version: '5.2.2',
    ruby_versions: %w[2.4.5 2.5.3 2.6.1],
    pg_version: '>= 1.0.0',
  },
]

matrix.each do |gemfile|
  rails_version = gemfile.fetch(:rails_version)
  pg_version = gemfile.fetch(:pg_version)

  appraise "rails_#{rails_version}" do
    gem 'activerecord', "~> #{rails_version}"
    gem 'pg', pg_version
  end
end

travis = ::YAML.dump(
  'language' => 'ruby',
  'services' => [
    'postgresql',
  ],
  'before_script' => [
    'bundle install',
    'psql -c "create database travis_ci_test;" -U postgres',
  ],
  'matrix' => {
    'include' =>
      matrix.flat_map do |rails_version:, ruby_versions:, **|
        ruby_versions.map do |ruby_version|
          {
            rvm: ruby_version,
            gemfile: "gemfiles/rails_#{rails_version}.gemfile",
          }
        end
      end,
  },
  'script' => [
    'bundle exec rake spec',
    'bundle exec rubocop --fail-level C',
  ],
)

::File.open('.travis.yml', 'w+') do |file|
  file.write(travis)
end

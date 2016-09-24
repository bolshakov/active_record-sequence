require 'yaml'

ruby_versions = %w(2.2.5 2.3.1)
rails_versions = %w(4.2.7 5.0.0)

rails_versions.each do |rails_version|
  appraise "rails_#{rails_version}" do
    gem 'activerecord', rails_version
  end
end

travis = ::YAML.dump(
  'language' => 'ruby',
  'rvm' => ruby_versions,
  'services' => ['postgresql'],
  'before_script' => [
    './bin/setup',
   ],
  'script'  => [
    'bundle exec rake spec',
    'bundle exec rubocop --fail-level C'
  ],
  'gemfile' => Dir.glob('gemfiles/*.gemfile'),
)

::File.open('.travis.yml', 'w+') do |file|
  file.write(travis)
end

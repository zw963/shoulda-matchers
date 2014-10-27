require 'fileutils'

class TestRailsApplication
  ROOT_DIR = File.expand_path('../../../tmp/aruba/testapp', __FILE__)

  def initialize
    @fs = TestFilesystem.new
    @shell = TestShell.new
  end

  def create
    fs.clean
    generate
    fs.within_project { install_gems }
  end

  def load
    load_environment
    run_migrations
  end

  def gemfile_path
    fs.find('Gemfile')
  end

  def environment_file_path
    fs.find_in_project('config/environment')
  end

  def temp_views_directory
    fs.find_in_project('tmp/views')
  end

  def create_temp_view(path, contents)
    full_path = temp_view_path_for(path)
    full_path.mkpath
    full_path.write(contents)
  end

  def delete_temp_views
    temp_views_directory.rmtree
  end

  def draw_routes(&block)
    Rails.application.routes.draw(&block)
    Rails.application.routes
  end

  protected

  attr_reader :fs

  private

  def migrations_directory
    project.find_in_project('db/migrate')
  end

  def temp_view_path_for(path)
    temp_views_directory.join(path)
  end

  def generate
    rails_new
    fix_available_locales_warning
  end

  def rails_new
    shell.run_command! "rails new #{fs.project_directory} --skip-bundle'"
  end

  def fix_available_locales_warning
    # See here for more on this:
    # http://stackoverflow.com/questions/20361428/rails-i18n-validation-deprecation-warning

    file = find_in_project('config/application.rb')

    lines = File.read(filename).split("\n")
    lines.insert(-3, <<EOT)
if I18n.respond_to?(:enforce_available_locales=)
I18n.enforce_available_locales = false
end
EOT

    file.write(lines.join("\n"))
  end

  def load_environment
    require environment_file_path
  end

  def run_migrations
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migrator.migrate(migrations_directory)
  end

  # TODO
  def install_gems
    shell.retrying_command('bundle install --local') do |runner|
      runner.around { |run_command| Bundler.with_clean_env(&run_command) }
    end
  end
end

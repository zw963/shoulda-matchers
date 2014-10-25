module Acceptance
  module Helpers
    extend ActiveSupport::Concern

    TEST_PROJECT_NAME = 'test-project'
    TEST_TEMP_DIRECTORY = File.expand_path('../../../../tmp/acceptance', __FILE__)
    TEST_PROJECT_DIRECTORY = File.join(TEST_TEMP_DIRECTORY, TEST_PROJECT_NAME)

    CommandResult = Struct.new(:command, :success, :exit_status, :output)

    included do
      before do
        clean_room
        # save_environment_variables
        # unset_bundler_environment_variables
      end

      after do
        # restore_environment_variables
      end
    end

    def clean
      FileUtils.rm_rf(TEST_PROJECT_DIRECTORY)
    end

    # def save_environment_variables
      # @original_environment_variables = {}

      # (BUNDLER_ENVIRONMENT_VARIABLES + %w(PATH)).each do |key|
        # @original_environment_variables[key] = ENV[key]
      # end
    # end

    # def unset_bundler_environment_variables
      # BUNDLER_ENVIRONMENT_VARIABLES.each do |key|
        # ENV[key] = nil
      # end
    # end

    # def restore_environment_variables
      # @original_environment_variables.each_pair do |key, value|
        # ENV[key] = value
      # end
    # end

    def create_active_model_project
      create_generic_bundler_project
      add_gem 'activemodel', active_model_version
    end

    def create_generic_bundler_project
      FileUtils.mkdir_p(TEST_PROJECT_DIRECTORY)
      run_command! 'bundle init'
    end

    def within_temp_directory(&block)
      Dir.chdir(TEST_TEMP_DIRECTORY, &block)
    end

    def within_project_directory(&block)
      Dir.chdir(TEST_PROJECT_DIRECTORY, &block)
    end

    def run_command(command)
      output = StringIO.new
      success = system(command, stderr: :stdout, stdout: output)
      exit_status = $?

      CommandResult.new(command, success, exit_status, output)
    end

    def run_command!(command)
      result = run_command(command, stderr: :stdout)

      unless result.success?
        raise <<-MESSAGE.strip_heredoc
          Command #{command.inspect} exited with status #{result.exit_status}.
          Output:
          #{output.gsub(/^/, '  ')}
        MESSAGE
      end

      result.output
    end

    def add_gem(gem, *args)
      options = args.extract_options!
      version = args.shift

      line = %(gem '#{gem}')
      line << %(, '#{version}') if version
      line << %(, #{options.inspect}) if options.any?
      line << "\n"

      append_to_file 'Gemfile', line
      install_gems
    end

    def write_file(partial_path, content)
      full_path = File.join(TEST_PROJECT_DIRECTORY, partial_path)
      File.write(full_path, content)
    end

    def install_gems
      run_command! 'bundle install'
    end

    def active_model_version
      Bundler.definition.specs['activemodel'][0].version
    end
  end
end

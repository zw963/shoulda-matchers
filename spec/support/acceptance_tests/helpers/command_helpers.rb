require_relative 'base_helpers'

module AcceptanceTests
  module CommandHelpers
    include BaseHelpers
    extend RSpec::Matchers::DSL

    def run_command(*args)
      CommandRunner.run_quickly!(*args) do |runner|
        runner.directory = fs.project_directory
        yield runner if block_given?
      end
    end

    def run_command!(*args)
      run_command(*args) do |runner|
        runner.run_successfully = true
        yield runner if block_given?
      end
    end

    def run_command_within_bundle(*args)
      run_command(*args) do |runner|
        runner.command_prefix = 'bundle exec'
        runner.env['BUNDLE_GEMFILE'] = fs.find_in_project('Gemfile').to_s

        runner.around_command do |run_command|
          Bundler.with_clean_env(&run_command)
        end

        yield runner if block_given?
      end
    end

    def run_command_within_bundle!(*args)
      run_command_within_bundle(*args) do |runner|
        runner.run_successfully = true
        yield runner if block_given?
      end
    end

    def run_rake_tasks(*tasks)
      run_command_within_bundle('rake', *tasks)
    end

    def run_rake_tasks!(*tasks)
      run_command_within_bundle!('rake', *tasks)
    end

    # TODO
    def retrying_command(command, &runner)
      CommandRunner.call(command) do |runner|
        runner.retries = 3
        yield runner if block_given?
      end
    end

    matcher :have_output do |output|
      match do |runner|
        @runner = runner
        runner.has_output?(output)
      end

      failure_message do
        "Expected command to have output, but did not.\n\n" +
          "Command: #{@runner.formatted_command}\n\n" +
          "Expected output:\n" +
          output + "\n\n" +
          "Actual output:\n" +
          @runner.elided_output
      end
    end
  end
end

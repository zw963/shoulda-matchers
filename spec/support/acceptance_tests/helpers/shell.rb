module AcceptanceTests
  # REMOVE ME
  class Shell
    def quickly_run_command!(*args)
      CommandRunner.run(*args) do |runner|
        runner.run_quickly = true
        yield runner if block_given?
      end
    end

    def quickly_and_successfully_run_command!(*args)
      quickly_run_command!(*args).tap do |runner|
        unless runner.success?
          runner.fail!
        end
      end
    end

    private

    def run_command(*args)
      CommandRunner.call(*args)
    end
  end
end

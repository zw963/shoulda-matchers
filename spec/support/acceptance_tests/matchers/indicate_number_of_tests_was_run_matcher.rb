module AcceptanceTests
  module Matchers
    def indicate_number_of_tests_was_run(expected_output)
      IndicateNumberOfTestsWasRunMatcher.new(expected_output)
    end

    class IndicateNumberOfTestsWasRunMatcher
      include RailsVersionHelpers

      def initialize(number)
        @number = number
      end

      def matches?(runner)
        @runner = runner
        expected_output === actual_output
      end

      def failure_message
        message = "Expected output to indicate that #{some_tests_were_run}.\n"

        if actual_output.empty?
          message << 'Output: (empty)'
        else
          message << "Output:\n#{actual_output}"
        end

        message
      end

      def expected_output
        # Rails 4 has slightly different output than Rails 3 due to
        # changing from Test::Unit::TestCase to Minitest

        if rails_version >= 4
          /#{number} (tests|runs), #{number} assertions, 0 failures, 0 errors, 0 skips/
        else
          "#{number} tests, #{number} assertions, 0 failures, 0 errors"
        end
      end

      def actual_output
        runner.output
      end

      def some_tests_were_run
        if number == 1
          "#{number} test was run"
        else
          "#{number} tests were run"
        end
      end

      protected

      attr_reader :number, :runner
    end
  end
end

module AcceptanceTests
  module Matchers
    def indicate_that_tests_were_run(series)
      IndicateThatTestsWereRunMatcher.new(series)
    end

    class IndicateThatTestsWereRunMatcher
      include RailsVersionHelpers

      def initialize(args)
        @series = args.values
      end

      def matches?(runner)
        @runner = runner
        runner.output =~ expected_output
      end

      protected

      attr_reader :series, :runner

      def expected_output
        # Rails 3 runs separate test suites in separate processes, but Rails 4
        # does not, so that's why we have to check for different things here

        if rails_version >= 4
          total = series.inject(:+)
          /#{total} (tests|runs), #{total} assertions, 0 failures, 0 errors/
        else
          series.map do |number|
            "#{number} tests, #{number} assertions, 0 failures, 0 errors"
          end.join('.+')

          Regexp.new(full_report)
        end
      end
    end
  end
end

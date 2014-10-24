require 'set'

module Shoulda
  module Matchers
    module Integrations
      # @private
      class Configuration
        def self.apply(configuration, &block)
          new(configuration, &block).apply
        end

        def initialize(configuration, &block)
          @test_frameworks = Set.new

          test_framework :missing_test_framework
          library :missing_library

          block.call(self)
        end

        def test_framework(name)
          clear_default_test_framework
          @test_frameworks << Integrations.find_test_framework!(name)
        end

        def library(name)
          @library = Integrations.find_library!(name)
        end

        def apply
          # if add_active_support_test_case?
            # test_framework :active_support_test_case
          # end

          puts "Test frameworks: #{@test_frameworks.map(&:class)}"
          puts "Library: #{@library.class}"

          if no_test_frameworks_added? && library_not_set?
            raise ConfigurationError, <<EOT
shoulda-matchers is not configured correctly. You need to specify a test
framework and/or library. For example:

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
EOT
          end

          @test_frameworks.each do |test_framework|
            # test_framework.validate!
            test_framework.include(Shoulda::Matchers::Independent)
            @library.integrate_with(test_framework)
          end
        end

        private

        def clear_default_test_framework
          @test_frameworks.select!(&:present?)
        end

        # def add_active_support_test_case?
          # @library.rails?
        # end

        def no_test_frameworks_added?
          @test_frameworks.empty? || !@test_frameworks.any?(&:present?)
        end

        def library_not_set?
          @library.nil?
        end
      end
    end
  end
end

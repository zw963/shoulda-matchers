require 'yaml'
require_relative 'rspec_helpers'

puts 'slkj'

module Features
  class ConfiguresProjectWithShouldaMatchers < Struct.new(:world, :yaml, :options)
    include Features::RspecHelpers

    def call
      config = YAML.load(yaml)
      config['test_frameworks'] ||= ['test_unit']

      append_to_gemfile(build_gemfile_line)

      install_gems

      split_config(config).each do |test_helper_file, test_framework, library|
        add_shoulda_matchers_config_to(
          test_helper_file,
          test_framework,
          library,
          options
        )
      end
    end

    private

    def build_gemfile_line
      gemfile_line = "gem 'shoulda-matchers', path: '#{PROJECT_ROOT}'"

      unless options[:auto_require]
        gemfile_line << ", require: false"
      end

      gemfile_line
    end

    def add_shoulda_matchers_config_to(test_helper_file, test_framework, library, options)
      test_framework_config = "with.test_framework :#{test_framework}\n"

      if library
        library_config = "with.library :#{library}\n"
      else
        library_config = ''
      end

      content = <<-EOT
        Shoulda::Matchers.configure do |config|
          config.integrate do |with|
            #{test_framework_config}
            #{library_config}
          end
        end
      EOT

      unless options[:auto_require]
        content = "require 'shoulda-matchers'\n#{content}"
      end

      append_to_file test_helper_file, content
    end

    def split_config(config)
      config['test_frameworks'].flat_map do |test_framework|
        library = config['library']
        test_helper_files_for(test_framework, library).map do |test_helper_file|
          [test_helper_file, test_framework, library]
        end
      end
    end

    def test_helper_file_for(test_framework, library)
      files = []

      if integrates_with_nunit?(test_framework) or integrates_with_rails?(library)
        files << 'test/test_helper.rb'
      end

      if integrates_with_rspec?(test_framework)
        if world.rspec_gte_3? or world.rspec_rails_gte_3?
          files << 'spec/rails_helper.rb'
        else
          files << 'spec/spec_helper.rb'
        end
      end

      files
    end

    def integrates_with_nunit?(test_framework)
      nunit_frameworks = ['test_unit', 'minitest', 'minitest_4', 'minitest_5']
      nunit_frameworks.include?(test_framework)
    end

    def integrates_with_rspec?(test_framework)
      test_framework == 'rspec'
    end

    def integrates_with_rails?(library)
      library == 'rails'
    end
  end
end

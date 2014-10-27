module AcceptanceTests
  module RubyVersionHelpers
    def ruby_version
      Version.new(RUBY_VERSION)
    end
  end
end

module AcceptanceTests
  module GemHelpers
    include CommandHelpers
    include FileHelpers

    def add_gem(gem, *args)
      bundle.add_gem(gem, *args)
    end

    def install_gems
      bundle.install_gems
    end

    def updating_bundle(&block)
      bundle.updating(&block)
    end

    def bundle_version_of(gem)
      Version.new(Bundler.definition.specs[gem][0].version)
    end

    def bundle_includes?(gem)
      Bundler.definition.dependencies.any? do |dependency|
        dependency.name == gem
      end
    end

    def bundle
      @_bundle ||= Bundle.new
    end
  end
end

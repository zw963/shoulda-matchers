module Features
  module RspecHelpers
    def rspec_version
      Bundler.definition.specs['rspec-core'][0].version
    end

    def rspec_gte_3?
      if rspec_version
        Gem::Requirement.new('>= 3').satisfied_by?(rspec_version)
      end
    end
  end
end

World(Features::RspecHelpers)

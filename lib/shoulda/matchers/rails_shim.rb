module Shoulda
  module Matchers
    # @private
    class RailsShim
      def self.verb_for_update
        if action_pack_gte_4_1?
          :patch
        else
          :put
        end
      end

      def self.active_record_major_version
        ::ActiveRecord::VERSION::MAJOR
      end

      def self.action_pack_gte_4_1?
        Gem::Requirement.new('>= 4.1').satisfied_by?(action_pack_version)
      end

      def self.action_pack_version
        Gem::Version.new(::ActionPack::VERSION::STRING)
      end
    end
  end
end

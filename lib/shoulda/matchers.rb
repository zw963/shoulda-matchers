require 'shoulda/matchers/assertion_error'
require 'shoulda/matchers/doublespeak'
require 'shoulda/matchers/error'
require 'shoulda/matchers/independent'
require 'shoulda/matchers/matcher_context'
require 'shoulda/matchers/rails_shim'
require 'shoulda/matchers/util'
require 'shoulda/matchers/version'
require 'shoulda/matchers/warn'

module Shoulda
  module Matchers
    class << self
      attr_accessor :assertion_error_class
    end
  end
end

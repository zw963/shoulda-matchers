require 'shoulda/matchers'

if defined?(Minitest)
  top_level_module = Minitest
  test_case_class = Minitest::Test
else
  top_level_module = MiniTest
  test_case_class = MiniTest::Unit::TestCase
end

Shoulda::Matchers.assertion_error_class = top_level_module::Assertion

test_case_class.class_eval do
  include Shoulda::Matchers::Independent
end

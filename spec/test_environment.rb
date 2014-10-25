class TestEnvironment
  TEST_PROJECT_NAME = 'test-project'
  TEST_TEMP_DIRECTORY = File.expand_path('../../../../tmp/acceptance', __FILE__)
  TEST_PROJECT_DIRECTORY = File.join(TEST_TEMP_DIRECTORY, TEST_PROJECT_NAME)

  def self.test_temp_directory
    TEST_TEMP_DIRECTORY
  end

  def self.test_project_directory
    TEST_PROJECT_DIRECTORY
  end
end

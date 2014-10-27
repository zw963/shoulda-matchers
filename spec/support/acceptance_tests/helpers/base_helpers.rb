module AcceptanceTests
  module BaseHelpers
    def fs
      @fs ||= Filesystem.new
    end

    def shell
      @shell ||= Shell.new
    end
  end
end

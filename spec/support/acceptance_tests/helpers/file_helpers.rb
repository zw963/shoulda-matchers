module AcceptanceTests
  module FileHelpers
    include BaseHelpers

    def append_to_file(path, content, options = {})
      if options[:following]
        append_to_file_following(path, content, options[:following])
      else
        fs.open(path, 'a') do |file|
          file.puts(content + "\n")
        end
      end
    end

    def append_to_file_following(path, content_to_add, insertion_point)
      content_to_add = content_to_add + "\n"

      file_content = fs.read(path)
      file_lines = file_content.split("\n")
      insertion_index = file_lines.find_index(insertion_point)

      if insertion_index.nil?
        raise "Cannot find #{insertion_point.inspect} in #{path}"
      end

      file_lines.insert(insertion_index + 1, content_to_add)
      new_file_content = file_lines.join("\n")
      fs.write(path, new_file_content)
    end

    def remove_from_file(path, pattern)
      content = fs.read(path)
      content.sub!(/#{pattern}\n/, '')
      fs.write(path, content)
    end

    def write_file(path, content)
      fs.write(path, content)
    end
  end
end

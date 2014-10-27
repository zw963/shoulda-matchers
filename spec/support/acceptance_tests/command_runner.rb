module AcceptanceTests
  class CommandRunner
    def self.call(*args)
      new(*args).tap do |runner|
        yield runner
        runner.call
      end
    end

    def self.run_quickly!(*args)
      call(*args) do |runner|
        runner.run_quickly = true
        yield runner if block_given?
      end
    end

    def self.run_quickly_and_successfully!(*args)
      run_quickly!(*args) do |runner|
        runner.run_successfully = true
        yield runner if block_given?
      end
    end

    attr_reader :status, :options, :env
    attr_accessor :command_prefix, :directory, :run_quickly,
      :run_successfully, :retries, :timeout

    def initialize(*args)
      @reader, @writer = IO.pipe
      options = (args.last.is_a?(Hash) ? args.pop : {})
      @args = args
      @options = options.merge(
        err: [:child, :out],
        out: writer,
        close_others: true
      )
      @env = extract_env_from(@options)

      @wrapper = ->(block) { block.call }
      @command_prefix = ''
      @directory = Dir.pwd
      @run_quickly = false
      @run_successfully = false
      @retries = 1
      @num_times_run = 0
      @timeout = 20
    end

    def around_command(&block)
      @wrapper = block
    end

    def directory=(directory)
      @directory = directory || Dir.pwd
    end

    def formatted_command
      [formatted_env, Shellwords.join(command)].
        select { |value| !value.empty? }.
        join(' ')
    end

    def call
      possibly_retrying do
        possibly_running_quickly do
          debug { "\n\e[32mRunning command:\e[0m #{formatted_command}" }
          wrapper.call(-> { run })
          debug { "\n" + divider('START') + output + divider('END') }

          if run_successfully && !success?
            fail!
          end
        end
      end

      self
    end

    def stop
      unless writer.closed?
        writer.close
      end
    end

    def output
      @_output ||= begin
        stop
        without_colors(reader.read)
      end
    end

    def elided_output
      lines = output.split(/\n/)
      new_lines = lines[0..4]

      if lines.size > 10
        new_lines << "(...#{lines.size - 10} more lines...)"
      end

      new_lines << lines[-5..-1]
      new_lines.join("\n")
    end

    def success?
      status.success?
    end

    def exit_status
      status.exitstatus
    end

    def fail!
      raise <<-MESSAGE
Command #{command.inspect} exited with status #{exit_status}.
Output:
#{output.gsub(/^/, '  ')}
      MESSAGE
    end

    def has_output?(expected_output)
      output.include?(expected_output)
    end

    protected

    attr_reader :args, :reader, :writer, :wrapper

    private

    def extract_env_from(options)
      options.delete(:env) { {} }.inject({}) do |hash, (key, value)|
        hash[key.to_s] = value
        hash
      end
    end

    def command
      ([command_prefix] + args).flat_map do |word|
        Shellwords.split(word)
      end
    end

    def formatted_env
      env.map { |key, value| "#{key}=#{value.inspect}" }.join(' ')
    end

    def run
      Dir.chdir(directory) do
        system(env, *command, options)
      end

      @status = $?
    end

    def possibly_running_quickly(&block)
      if run_quickly
        begin
          Timeout.timeout(timeout, &block)
        rescue Timeout::Error
          stop

          message =
            "Command timed out after #{timeout} seconds: #{formatted_command}\n" +
            "Output:\n" +
            elided_output

          raise message
        end
      else
        yield
      end
    end

    def possibly_retrying
      begin
        @num_times_run += 1
        yield
      rescue
        if @num_times_run < @retries
          retry
        end
      end
    end

    def divider(title = '')
      total_length = 72
      start_length = 3

      string = ''
      string << ('-' * start_length)
      string << title
      string << '-' * (total_length - start_length - title.length)
      string << "\n"
      string
    end

    def without_colors(string)
      string.gsub(/\e\[\d+(?:;\d+)?m(.+?)\e\[0m/, '\1')
    end

    def debugging_enabled?
      ENV['DEBUG_COMMANDS'] == '1'
    end

    def debug(&block)
      if debugging_enabled?
        puts block.call
      end
    end
  end
end

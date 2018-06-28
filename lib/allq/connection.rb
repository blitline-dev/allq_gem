require 'yaml'
require 'socket'

class AllQ
  # Represents a connection to a allq instance.
  class Connection

    # Default number of retries to send a command to a connection
    MAX_RETRIES = 3

    # Default retry interval
    DEFAULT_RETRY_INTERVAL = 1

    # Default port value for beanstalk connection
    DEFAULT_PORT = 11300

    attr_reader :address, :host, :port, :connection

    # Initializes new connection.
    #
    # @param [String] address allq instance address.
    # @example
    #   AllQ::Connection.new('127.0.0.1')
    #   AllQ::Connection.new('127.0.0.1:11300')
    #
    #   ENV['ALLQ_CLIENT_URL'] = '127.0.0.1:11300'
    #   @b = AllQ.new
    #   @b.connection.host # => '127.0.0.1'
    #   @b.connection.port # => '11300'
    #
    def initialize(address = '')
      @address = address || _host_from_env
      @mutex = Mutex.new
      establish_connection
    rescue
      _raise_not_connected!
    end

    # Send commands to allq server via connection.
    #
    # @param [String] command AllQ command
    # @return [Array<Hash{String => String, Number}>] AllQ command response
    # @example
    #   @conn = AllQ::Connection.new
    #   @conn.transmit('bury 123')
    #   @conn.transmit('stats')
    #
    def transmit(command, options={}, &block)
      _with_retry(options[:retry_interval], options[:init]) do
        @mutex.synchronize do
          _raise_not_connected! unless @connection
          @connection.puts(command.to_s)
          res = @connection.readline
          yield block.call(res)
        end
      end
    end

    # Close connection with allq server.
    #
    # @example
    #  @conn.close
    #
    def close
      if @connection
        @connection.close
        @connection = nil
      end
    end

    # Returns string representation of job.
    #
    # @example
    #  @conn.inspect
    #
    def to_s
      "#<AllQ::Connection host=#{host.inspect} port=#{port.inspect}>"
    end
    alias :inspect :to_s

    protected

    # Establish a connection based on beanstalk address.
    #
    # @return [Net::TCPSocket] connection for specified address.
    # @raise [AllQ::NotConnected] Could not connect to specified allq instance.
    # @example
    #  establish_connection('localhost:3005')
    #
    def establish_connection
      @address = address.first if address.is_a?(Array)
      match = address.split(':')
      @host, @port = match[0], Integer(match[1] || DEFAULT_PORT)

      @connection = TCPSocket.new @host, @port
    end

    private

    # Wrapper method for capturing certain failures and retry the payload block
    #
    # @param [Proc] block The command to execute.
    # @param [Integer] retry_interval The time to wait before the next retry
    # @param [Integer] tries The maximum number of tries in draining mode
    # @return [Object] Result of the block passed
    #
    def _with_retry(retry_interval, init=true, tries=MAX_RETRIES, &block)
      yield
    rescue => ex
      _reconnect(ex, retry_interval)
      retry
    end

    # Tries to re-establish connection to the allq
    #
    # @param [Exception] original_exception The exception caused the retry
    # @param [Integer] retry_interval The time to wait before the next reconnect
    # @param [Integer] tries The maximum number of attempts to reconnect
    def _reconnect(original_exception, retry_interval, tries=MAX_RETRIES)
      close
      establish_connection
    rescue Errno::ECONNREFUSED
      tries -= 1
      if tries.zero?
        _raise_not_connected!
      end
      sleep(retry_interval || DEFAULT_RETRY_INTERVAL)
      retry
    end

    # The host provided by ALLQ_CLIENT_URL environment variable, if available.
    #
    # @return [String] A allq host address
    # @example
    #  ENV['ALLQ_CLIENT_URL'] = "localhost:1212"
    #   # => 'localhost:1212'
    #
    def _host_from_env
      ENV['ALLQ_CLIENT_URL'].respond_to?(:length) && ENV['ALLQ_CLIENT_URL'].length > 0 && ENV['ALLQ_CLIENT_URL'].strip
    end

    # Raises an error to be triggered when the connection has failed
    # @raise [AllQ::NotConnected] AllQ is no longer connected
    def _raise_not_connected!
      raise "Connection to allq '#{@host}:#{@port}' is closed!"
    end

  end # Connection
end # AllQ
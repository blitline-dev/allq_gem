require 'json'

class AllQ
  # Base class for handling allq actions
  class Base

    def initialize(connection)
      @connection = connection
      setup
    end

    def snd(data)
      send_data = base_send(data)
      response = send_hash_as_json(send_data)
      rcv(response)
    end

    def rcv(data)
      return nil if data.to_s == '' || data.to_s.strip == '{}'
      data
    end

    def send_hash_as_json(data_hash)
      if @requires_q_server
        params = data_hash["params"]
      end
      transmit_data = data_hash.to_json
      result = nil
      @connection.transmit(transmit_data) do |response|
        result = response
      end
      result
    end

    def build_job(result)
      result_hash = JSON.parse(result)
      job_info = result_hash["job"]
      job_id = job_info["job_id"]

      job = Job.new(job_id)
      # -- Optional fields
      job.body = job_info["body"] if job_info["body"]
      job.expired_count = job_info["expired_count"] if job_info["expired_count"]
      return job
    end

    def setup
    end

    # -- Abstract
    def base_send(_data)
      raise NotImplementedError
    end

  end
end

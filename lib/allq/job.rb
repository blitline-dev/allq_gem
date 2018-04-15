class AllQ

  class Job
    attr_accessor :id, :q_server, :body, :expired_count
    def initialize(id, tube = nil, body = nil, expired_count = nil)
      @body = body
      @id = id
      @tube = tube
      @expired_count = expired_count
    end

    def to_hash
      {
        'job_id' => @id,
        'body' => @body,
        'tube' => @tube,
        'expired_count' => @expired_count
      }
    end

    def done
      AllQ::Client.instance.done(self)
    end

    def delete
      AllQ::Client.instance.delete(self)
    end

    def touch
      AllQ::Client.instance.touch(self)
    end

    def release
      AllQ::Client.instance.release(self)
    end

    def bury
      AllQ::Client.instance.bury(self)
    end

    def to_json
      {
        id: @id,
        q_server: @q_server,
        body: @body
      }
    end

    def to_s
      to_json.to_json
    end

    def self.new_from_hash(hash)
      puts hash.inspect
      begin
        id = hash.fetch('job_id')
        body = hash.fetch('body')
        tube = hash.fetch('tube')
        expired_count = hash.fetch('expired_count')
        job = Job.new(id, tube, body, expired_count)
        return job
      rescue => ex
        puts "Server value: #{hash}"
        puts "Can't create job, version mismatch?"
        puts "Invalid job data #{ex.message}"
      end


    end

  end
end

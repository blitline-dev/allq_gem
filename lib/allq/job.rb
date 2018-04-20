class AllQ

  class Job
    attr_accessor :id, :body, :expireds, :releases
    def initialize(id, tube = nil, body = nil, expireds = nil, releases = nil)
      @body = body
      @id = id
      @tube = tube
      @expireds = expireds
      @releases = releases
    end

    def to_hash
      {
        'job_id' => @id,
        'body' => @body,
        'tube' => @tube,
        'expireds' => @expireds,
        'releases' => @releases
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

    def release(delay = 0)
      AllQ::Client.instance.release(self, delay)
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

    def stats
      {
        "releases" => @releases,
        "expireds" => @expireds
      }
    end

    def self.new_from_hash(hash)
      begin
        id = hash.fetch('job_id')
        body = hash.fetch('body')
        tube = hash.fetch('tube')
        expireds = hash.fetch('expireds')
        releases = hash.fetch('releases')
        job = Job.new(id, tube, body, expireds, releases)
        return job
      rescue => ex
        puts "Server value: #{hash}"
        puts "Can't create job, version mismatch?"
        puts "Invalid job data #{ex.message}"
      end


    end

  end
end

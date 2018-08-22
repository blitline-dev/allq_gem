class AllQ

  class Job
    attr_accessor :id, :body, :expireds, :releases, :client, :tube
    def initialize(id, client, tube = nil, body = nil, expireds = nil, releases = nil)
      @body = body
      @id = id
      @tube = tube
      @expireds = expireds
      @releases = releases
      @client = client
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
      @client.done(self)
    end

    def delete
      @client.delete(self)
    end

    def touch
      @client.touch(self)
    end

    def kick
      @client.kick(self)
    end

    def release(delay = 0)
      @client.release(self, delay)
    end

    def bury
      @client.bury(self)
    end

    def to_json
      {
        id: @id,
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

    def self.new_from_hash(hash, client)
      begin
        id = hash.fetch('job_id')
        body = hash.fetch('body')
        tube = hash.fetch('tube')
        expireds = hash.fetch('expireds')
        releases = hash.fetch('releases')
        job = Job.new(id, client, tube, body, expireds, releases)
        return job
      rescue => ex
        puts caller
        puts "Server value: #{hash}"
        puts "Can't create job, version mismatch?"
        puts "Invalid job data #{ex.message}"
      end


    end

  end
end

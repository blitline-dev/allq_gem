require 'singleton'

class AllQ
  # Represents the client singleton
  class Client
    include Singleton

    URL = ENV['ALLQ_CLIENT_URL'] || '127.0.0.1:7766'
    def initialize
      @connection = AllQ::Connection.new(URL)
      @get_action = AllQ::Get.new(@connection)
      @put_action = AllQ::Put.new(@connection)
      @done_action = AllQ::Done.new(@connection)
      @stats_action = AllQ::Stats.new(@connection)
      @release_action = AllQ::Release.new(@connection)
      @touch_action = AllQ::Touch.new(@connection)
    end

    def get(tube_name)
      @get_action.snd(tube_name)
    end

    def put(body, tube, delay = 0, ttl = 3600, priority = 5)
      data = {
        'body' => body,
        'tube' => tube,
        'delay' => delay,
        'ttl' => ttl,
        'priority' => priority
      }
      @put_action.snd(data)
    end

    def done(job)
      raise "Can't set 'done' on a Job that is nil. Please check for Nil job before setting done." unless job
      @done_action.snd(job_id: job.id, q_server: job.q_server)
    end

    def touch(job)
      @touch_action.snd(job_id: job.id, q_server: job.q_server)
    end

    def stats
      @stats_action.snd(nil)
    end

    def release(job)
      @release_action.snd(job_id: job.id, q_server: job.q_server)
    end

    def delete(job)
    end

    def kick(job)
    end

  end
end

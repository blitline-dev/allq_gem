require 'singleton'

class AllQ
  # Represents the client singleton
  class Client

    URL = ENV['ALLQ_CLIENT_URL'] || '127.0.0.1:7766'
    def initialize(url = nil)
      url = URL if url.nil?

      @connection = AllQ::Connection.new(url)
      @get_action = AllQ::Get.new(@connection)
      @put_action = AllQ::Put.new(@connection)
      @done_action = AllQ::Done.new(@connection)
      @stats_action = AllQ::Stats.new(@connection)
      @release_action = AllQ::Release.new(@connection)
      @touch_action = AllQ::Touch.new(@connection)
      @kick_action = AllQ::Kick.new(@connection)
      @bury_action = AllQ::Bury.new(@connection)
      @clear_action = AllQ::Clear.new(@connection)
      @peek_action = AllQ::Peek.new(@connection)
      @delete_action = AllQ::Delete.new(@connection)
      @parent_job_action = AllQ::ParentJob.new(@connection)
    end

    def parent_job(tube, body, ttl: 3600, delay: 0, parent_id: nil, priority: 5, limit: nil, noop: false)
      data = {
        'body' => body,
        'tube' => tube,
        'delay' => delay,
        'ttl' => ttl,
        'priority' => priority,
        'parent_id' => parent_id,
        'limit' => limit,
        'noop' => noop
      }
      @parent_job_action.snd(data)
    end

    def kick(tube_name)
      @kick_action.snd(tube: tube_name)
    end

    def clear(cache_type = "cache_type", value = "all")
      @clear_action.snd(cache_type: :all)
    end

    def peek(tube_name)
      @peek_action.snd(tube: tube_name, buried: false)
    end

    def peek_buried(tube_name)
      @peek_action.snd(tube: tube_name, buried: true)
    end

    def bury(job)
      raise "Can't 'bury' a Job that is nil. Please check for Nil job before burying." unless job
      @bury_action.snd(job_id: job.id)
    end

    def get(tube_name)
      @get_action.snd(tube_name)
    end

    def put(tube, body, ttl: 3600, delay: 0, parent_id: nil, priority: 5)
      data = {
        'body' => body,
        'tube' => tube,
        'delay' => delay,
        'ttl' => ttl,
        'priority' => priority,
        'parent_id' => parent_id
      }
      @put_action.snd(data)
    end

    def done(job)
      raise "Can't set 'done' on a Job that is nil. Please check for Nil job before setting done." unless job
      @done_action.snd(job_id: job.id)
    end

    def touch(job)
      raise "Can't 'touch' a Job that is nil. Please check for Nil job before 'touch'." unless job
      @touch_action.snd(job_id: job.id)
    end

    def stats(breakout = false)
      v = @stats_action.snd(breakout: breakout)
    end

    def release(job, delay)
      raise "Can't 'release' a Job that is nil." unless job
      @release_action.snd(job_id: job.id, delay: delay)
    end


  end
end

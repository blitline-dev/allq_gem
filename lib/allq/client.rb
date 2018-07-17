require 'singleton'

class AllQ
  # Represents the client singleton
  class Client

    URL = ENV['ALLQ_CLIENT_URL'] || '127.0.0.1:7766'
    def initialize(url = nil)
      @url = url.nil? ? URL : url
      @connection = nil
      reload!
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

    def delete(job)
      raise "Can't delete a Nil job" unless job
      @delete_action.snd(job_id: job.id)
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

    def close
       @connection.close
    end

    def reload!
      @connection.close if @connection
      puts "New --#{@url}"
      @connection = AllQ::Connection.new(@url)
      @get_action = AllQ::Get.new(@connection, self)
      @put_action = AllQ::Put.new(@connection, self)
      @done_action = AllQ::Done.new(@connection, self)
      @stats_action = AllQ::Stats.new(@connection, self)
      @release_action = AllQ::Release.new(@connection, self)
      @touch_action = AllQ::Touch.new(@connection, self)
      @kick_action = AllQ::Kick.new(@connection, self)
      @bury_action = AllQ::Bury.new(@connection, self)
      @clear_action = AllQ::Clear.new(@connection, self)
      @peek_action = AllQ::Peek.new(@connection, self)
      @delete_action = AllQ::Delete.new(@connection, self)
      @parent_job_action = AllQ::ParentJob.new(@connection, self)
    end


  end
end

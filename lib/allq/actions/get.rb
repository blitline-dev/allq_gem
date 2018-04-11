class AllQ
  class Get < AllQ::Base

    def setup
      @requires_q_server = false
    end

    def rcv(data)
      return nil if data.to_s == '' || data.to_s.strip == '{}'

      result = JSON.parse(data)
      if result['job']
        return nil if result['job'].to_s == "{}"
        job = Job.new_from_hash(result['job'])
        return job
      end
      nil
    end

    def base_send(tube)
      {
        'action' => 'get',
        'params' => {
          'tube' => tube
        }
      }
    end
  end
end
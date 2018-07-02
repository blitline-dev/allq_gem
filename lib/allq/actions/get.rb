class AllQ
  class Get < AllQ::Base

    def rcv(data)
      return nil if data.to_s == '' || data.to_s.strip == '{}'

      result = JSON.parse(data)
      if result['job']
        return nil if result['job'].empty?
        job = Job.new_from_hash(result['job'], @client)
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
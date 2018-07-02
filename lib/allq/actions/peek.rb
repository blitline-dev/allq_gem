class AllQ
  class Peek < AllQ::Base

    def snd(data)
      result = nil
      tube = data.delete(:tube)
      buried = data.delete(:buried)

      send_data = base_send(tube, buried)
      response = send_hash_as_json(send_data)
      rcv(response)
    end

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

    def base_send(tube, buried)
      out = {
        'action' => 'peek',
        'params' => {
          'tube' => tube
        }
      }

      out['params']['buried'] = 'true' if buried
      out
    end
  end
end
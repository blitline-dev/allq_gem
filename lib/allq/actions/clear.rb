class AllQ
  class Clear < AllQ::Base

    def snd(data)
      cache_type = data[:cache_type] || "all"

      send_data = base_send(cache_type)
      response = send_hash_as_json(send_data)
      result = rcv(response)
      rcv(response)
    end

    def rcv(data)
      return nil if data.to_s == '' || data.to_s.strip == '{}'
      JSON.parse(data)
    end

    def base_send(cache_type)
      {
        'action' => 'clear',
        'params' => {
          'cache_type' => cache_type
        }
      }
    end

  end
end
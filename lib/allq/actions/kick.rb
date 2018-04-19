class AllQ
  class Kick < AllQ::Base

    def snd(data)
      result = nil
      tube = data[:tube]

      send_data = base_send(tube)
      response = send_hash_as_json(send_data)
      rcv(response)
    end

    def base_send(tube)
      {
        'action' => 'kick',
        'params' => {
          'tube' => tube
        }
      }
    end
  end
end
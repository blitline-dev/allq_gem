class AllQ
    class Throttle < AllQ::Base
  
      def snd(data)
        name = data[:name]
        tps = data[:tps].to_i || 10

        send_data = base_send(name, tps)
        response = send_hash_as_json(send_data, true)
        rcv(response)
      end
  
      def base_send(name, tps)
        {
            'action' => 'throttle',
            'params' => {
              'tube' => name,
              'tps' => tps
            }
          }
    
      end
    end
  end
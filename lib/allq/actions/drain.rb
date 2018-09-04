class AllQ
    class Drain < AllQ::Base
  
    def snd(data)
        server_id = data[:server_id]
        send_data = base_send(server_id)
        response = send_hash_as_json(send_data, true)
        rcv(response)
    end
        
      def base_send(server_id)
        {
          'action' => 'drain',
          'params' => {
            'server_id' => server_id
          }
        }
      end
    end
  end
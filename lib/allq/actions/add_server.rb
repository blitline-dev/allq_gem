class AllQ
    class AddServer < AllQ::Base
  
    def snd(data)
        server_url = data[:server_url]
        send_data = base_send(server_url)
        response = send_hash_as_json(send_data, true)
        rcv(response)
    end
        
      def base_send(server_url)
        {
          'action' => 'add_server',
          'params' => {
            'server_url' => server_url
          }
        }
      end
    end
  end
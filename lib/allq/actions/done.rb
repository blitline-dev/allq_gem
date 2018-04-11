class AllQ
  class Done < AllQ::Base

    def snd(data)
      job_id = data[:job_id]
      q_server = data[:q_server]

      send_data = base_send(job_id, q_server)
      response = send_hash_as_json(send_data)
      rcv(response)
    end

    def base_send(job_id, q_server)
      {
        'action' => 'done',
        'params' => {
          'job_id' => job_id,
          'q_server' => q_server
        }
      }
    end
  end
end
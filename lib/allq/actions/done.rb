class AllQ
  class Done < AllQ::Base

    def snd(data)
      job_id = data[:job_id]

      send_data = base_send(job_id)
      response = send_hash_as_json(send_data, true)
      rcv(response)
    end

    def base_send(job_id)
      {
        'action' => 'done',
        'params' => {
          'job_id' => job_id
        }
      }
    end
  end
end
class AllQ
  class Delete < AllQ::Base

   def snd(data)
      job_id = data[:job_id]
      q_server = data[:q_server]

      send_data = base_send(job_id, q_server)
      response = send_hash_as_json(send_data)
      result = rcv(response)
      return JSON.parse(result)
    end

    def base_send(job_id, q_server)
      {
        'action' => 'delete',
        'params' => {
          'job_id' => job_id,
          'q_server' => q_server
        }
      }
    end
  end
end
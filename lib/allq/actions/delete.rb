class AllQ
  class Delete < AllQ::Base

   def snd(data)
      job_id = data[:job_id]

      send_data = base_send(job_id)
      response = send_hash_as_json(send_data)
      result = rcv(response)
      return JSON.parse(result)
    end

    def base_send(job_id, q_server)
      {
        'action' => 'delete',
        'params' => {
          'job_id' => job_id
        }
      }
    end
  end
end
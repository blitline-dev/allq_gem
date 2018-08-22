class AllQ
  class Kick < AllQ::Base

    def snd(data)
      result = nil
      job = data[:job]

      send_data = base_send(job)
      response = send_hash_as_json(send_data, true)
      rcv(response)
    end

    def base_send(job)
      {
        'action' => 'kick',
        'params' => {
          'job_id' => job.id,
          'tube' => job.tube
        }
      }
    end
  end
end
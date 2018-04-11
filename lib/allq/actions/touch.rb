class AllQ
  class Touch < AllQ::Base

    def snd(data)
      job_id = data[:job_id]
      q_server = data[:q_server]

      send_data = base_send(job_id, q_server)
      response = send_hash_as_json(send_data)
      result = rcv(response)
      return result["touch"] && result["touch"]["job_id"]
    end

    def rcv(data)
      return nil if data.to_s == '' || data.to_s.strip == '{}'
      JSON.parse(data)
    end

    def base_send(job_id, q_server)
      {
        'action' => 'touch',
        'params' => {
          'q_server' => q_server,
          'job_id' => job_id
        }
      }
    end

  end
end
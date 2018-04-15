class AllQ
  class Release < AllQ::Base

    def snd(data)
      job_id = data[:job_id]
      send_data = base_send(job_id)
      response = send_hash_as_json(send_data)
      result = rcv(response)
      return result["release"] && result["release"]["job_id"]
    end

    def rcv(data)
      return nil if data.to_s == '' || data.to_s.strip == '{}'
      JSON.parse(data)
    end

    def base_send(job_id)
      {
        'action' => 'release',
        'params' => {
          'job_id' => job_id
        }
      }
    end
  end
end
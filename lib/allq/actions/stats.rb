class AllQ
  class Stats < AllQ::Base

    def setup
    end

    def snd(data)
      send_data = base_send(data)
      @breakout = data ? data[:breakout].to_s == "true" : false
      response = send_hash_as_json(send_data)
      rcv(response)
    end


    def rcv(data)
      return nil if data.to_s == '' || data.to_s.strip == '{}'
      results = JSON.parse(data)
      stats = {}
      return breakout(results) if @breakout

      results.each do |server, s_data|
        s_data.each do |tube, tube_data|
          stats[tube] = merge_tube_data(stats[tube], tube_data)
        end
      end
      stats
    end

    def merge_tube_data(original_hash, new_hash)
      if original_hash.nil?
        original_hash = {}
      end
      interize(new_hash)
      new_hash.each do |k, v|
        original_hash[k] = original_hash[k].to_i + v
      end
      original_hash
    end

    def breakout(results)
      results.each do |server, s_data|
        s_data.delete('global')
        s_data.each do |tube, tube_data|
          interize(tube_data)
        end
      end
      results
    end

    def interize(hash)
      return {} if hash.nil? || hash.empty?
      hash.update(hash){ |_, v| v.to_i }
    end

    def base_send(_data)
      {
        'action' => 'stats',
        'params' => {}
      }
    end
  end
end
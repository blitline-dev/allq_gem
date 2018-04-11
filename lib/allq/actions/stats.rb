class AllQ
  class Stats < AllQ::Base

    def setup
      @requires_q_server = false
    end

    def rcv(data)
      return nil if data.to_s == '' || data.to_s.strip == '{}'
      results = JSON.parse(data)
      stats = {}
      results.each do |server, data|
        data.each do |tube, tube_data|
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
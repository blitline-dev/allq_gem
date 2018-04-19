class AllQ
  class ParentJob < AllQ::Base

    def snd(data)
      result = nil
      tube = data.delete('tube')
      body = data.delete('body')

      send_data = base_send(tube, body, data)
      response = send_hash_as_json(send_data)
      result = rcv(response)
      build_job(result)
    end

    def base_send(tube, body, options = {})
      raise 'Must have tube name and body' unless tube && body
      base = {
        'action' => 'set_parent_job',
        'params' => {
          'tube' => tube,
          'body' => body
        }
      }
      base['params']['limit'] = options['limit'] if options['limit']
      base['params']['noop'] = options['noop'] if options['noop']
      base['params']['ttl'] = options['ttl'] if options['ttl']
      base['params']['delay'] = options['delay'] if options['delay']
      base['params']['parent_id'] = options['parent_id'] if options['parent_id']
      return base
    end
  end
end

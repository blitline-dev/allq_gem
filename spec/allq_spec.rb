require 'allq'

RSpec.describe Allq do

  def client
    return @client if @client
    @client = AllQ::Client.new("127.0.0.1:7766")
    return @client
  end

  def stats_count(f, r = 0, rs = 0, b = 0, d = 0, p = 0)
    out_all = f.stats
    expect(out_all[gen_tube]['ready']).to eq(r)
    expect(out_all[gen_tube]['reserved']).to eq(rs)
    expect(out_all[gen_tube]['buried']).to eq(b)
    expect(out_all[gen_tube]['delayed']).to eq(d)
    expect(out_all[gen_tube]['parents']).to eq(p)
  end

  def gen_body
    (0...8).map { (65 + rand(26)).chr }.join
  end

  def gen_tube
    'rspec-test-tube'
  end

  it 'ping works' do
    json = { action: "ping", params: {}}
    output = "echo '#{json.to_json}' | socat -t 1.0 - tcp4-connect:127.0.0.1:7766"
    results = `#{output}`
    expect(results.size).to be > 0
  end

  it 'release delay works' do
    f = client
    f.clear
    f.put(gen_tube, gen_body)
    sleep(1)
    j2 = f.get(gen_tube)
    j2.release(3)
    sleep(1)
    stats_count(f, 0, 0, 0, 1)
    sleep(5)
    stats_count(f, 1, 0, 0, 0)
    f.clear
  end

  it 'delay works' do
    f = client
    f.clear
    f.put(gen_tube, gen_body, delay: 3)
    sleep(1)
    stats_count(f, 0, 0, 0, 1)
    sleep(5)
    stats_count(f, 1, 0, 0, 0)
    j2 = f.get(gen_tube)
    j2.done
    stats_count(f)
  end

  it 'ttl works' do
    f = client
    f.clear
    f.put(gen_tube, gen_body, ttl: 2)
    sleep(2)
    stats_count(f, 1, 0, 0, 0)
    j2 = f.get(gen_tube)
    stats_count(f, 0, 1, 0, 0)
    sleep(8)
    stats_count(f, 1, 0, 0, 0)
    j2 = f.get(gen_tube)
    j2.done
  end

 it 'clear works' do
    f = client
    f.clear
    f.put(gen_tube, gen_body)
    sleep(1.0)
    stats_count(f, 1, 0, 0, 0 , 0)
    f.clear
  end

  it 'put-get-bury-peek works' do
    f = client
    f.clear
    f.put(gen_tube, gen_body)
    sleep(1.0)
    job = f.get(gen_tube)
    job.bury
    stats_count(f, 0, 0, 1, 0, 0)
    f.peek_buried(gen_tube)
    stats_count(f, 0, 0, 1, 0, 0)
    f.kick(gen_tube)
    stats_count(f, 1, 0, 0, 0, 0)
    job = f.get(gen_tube)
    stats_count(f, 0, 1, 0, 0, 0)
    job.done
    stats_count(f, 0, 0, 0, 0, 0)
  end

  it 'put-get-bury-kick works' do
    f = client
    f.clear
    f.put(gen_tube, gen_body)
    sleep(1.0)
    job = f.get(gen_tube)
    job.bury
    stats_count(f, 0, 0, 1, 0, 0)
    f.kick(gen_tube)
    stats_count(f, 1, 0, 0, 0, 0)
    job = f.get(gen_tube)
    stats_count(f, 0, 1, 0, 0, 0)
    job.done
    stats_count(f, 0, 0, 0, 0, 0)
    f.clear
  end

  it 'put-get-bury works' do
    f = client
    f.clear
    f.put(gen_tube, gen_body)
    sleep(1.0)
    job = f.get(gen_tube)
    job.bury
    stats_count(f, 0, 0, 1, 0, 0)
    f.clear
  end

  it 'put-get-done works' do
    f = client
    f.clear
    f.put(gen_tube, gen_body)
    sleep(1.0)
    job = f.get(gen_tube)
    job.done
    stats_count(f, 0, 0, 0, 0, 0)
    f.clear
  end

  it 'put-get-count works' do
    f = client
    f.put(gen_tube, gen_body)
    f.put(gen_tube, gen_body)
    sleep(1)
    stats_count(f, 2, 0, 0)
    j1 = f.get(gen_tube)
    stats_count(f, 1, 1, 0)
    j2 = f.get(gen_tube)
    stats_count(f, 0, 2, 0)
    j1.done
    j2.done
    stats_count(f)
  end


  it 'put-get-stats-breakout works' do
    f = client
    f.put(gen_tube, gen_body)
    f.put(gen_tube, gen_body)
    sleep(1)
    stats_count(f, 2, 0, 0)
    j1 = f.get(gen_tube)
    stats_count(f, 1, 1, 0)
    j2 = f.get(gen_tube)
    stats_count(f, 0, 2, 0)
    j1.done
    j2.done
    out = f.stats(true)
    expect(out.values.first.values.first["ready"].to_i).to eq(0)
    stats_count(f)
  end

  it 'handles parent jobs properly' do
    f = client
    f.clear
    limit = 3
    parent_job = f.parent_job(gen_tube, gen_body, limit: limit)
    sleep(1)
    stats_count(f, 0, 0, 0, 0, 1)
    1.upto(limit) do
      f.put(gen_tube, gen_body, ttl: 100, delay: 0, parent_id: parent_job.id)
    end
    sleep(1)
    stats_count(f, limit, 0, 0, 0, 1)
    1.upto(limit) do
      f.get(gen_tube).done
    end
    sleep(6)
    stats_count(f, 1, 0, 0, 0, 0)
    new_job = f.get(gen_tube)
    expect(parent_job.id).to eq(new_job.id)
    new_job.done
  end

  it 'handles multiple waits' do
    f = client
    f.clear
    1.upto(2) do
      limit = 3
      master_job = f.parent_job(gen_tube, gen_body, limit: 2)
      merge_data = {
        parent_id: master_job.id,
        noop: true,
        limit: limit
      }
      waiter_1 = f.parent_job(gen_tube, gen_body, merge_data)
      waiter_2 = f.parent_job(gen_tube, gen_body, merge_data)

      1.upto(limit) do
        f.put(gen_tube, gen_body, parent_id: waiter_1.id)
      end

      1.upto(limit) do
        f.put(gen_tube, gen_body, parent_id: waiter_2.id)
      end
      sleep(1)
      stats_count(f, 6, 0, 0, 0, 3)
      sleep(1)
      f.get(gen_tube).done
      f.get(gen_tube).done
      f.get(gen_tube).done
      sleep(1)
      stats_count(f, 3, 0, 0, 0, 2)
      f.get(gen_tube).done
      f.get(gen_tube).done
      f.get(gen_tube).done
      sleep(6)
      stats_count(f, 1, 0, 0, 0, 0)
      last_job_id = f.get(gen_tube).id
      expect(master_job.id).to eq(last_job_id)
      master_job.done
      # -- Cleanup
      stats_count(f, 0, 0, 0, 0)
    end
  end

end

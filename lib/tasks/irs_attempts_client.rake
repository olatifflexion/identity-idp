namespace :attempts do

  desc 'Retrieve events'
  task :fetch_events do
    auth_token = 'abc123'
    private_key_path = "keys/attempts_api_private_key.key"
    conn = Faraday.new(url: "http://localhost:3000")

    resp = conn.post('/api/irs_attempts_api/security_events') do |req|
      req.headers["Authorization"] = "Bearer #{auth_token}"
    end.body

    events = JSON.parse(resp)

    # if keys/irs-private-key.key exists, use it
    if File.exist?(private_key_path)
      key = OpenSSL::PKey::RSA.new(File.read(private_key_path))
      # We can decrypt!
      events['sets'].each do |event|
        pp JSON.parse(JWE.decrypt(event[1], key)) rescue "error"
        puts "\n" # Let the events breathe a little
      end
    else
      pp events
    end
  end

  desc 'Clear all events'
  task :purge_events do
    # This sooooo needs to be DRYed up
    auth_token = 'abc123'
    conn = Faraday.new(url: "http://localhost:3000")

    resp = conn.post('/api/irs_attempts_api/security_events') do |req|
      req.headers["Authorization"] = "Bearer #{auth_token}"
    end.body

    events = JSON.parse(resp)
    event_ids = events['sets'].collect { |e| e[0] }

    puts "Would purge #{event_ids}"

    # This doesn't work yet...
    resp = conn.post('/api/irs_attempts_api/security_events') do |req|
      req.headers["Authorization"] = "Bearer #{auth_token}"
      req.body = "ack = #{event_ids.join(", ")}"
    end
  end
end

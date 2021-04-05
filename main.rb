require 'dalli'
require 'securerandom'

INTERVAL  = 0.1
COUNT     = 10
MASTER    = "172.16.0.2:11211"
REPLICA   = "172.16.0.3:11211"
OPTIONS   = { expires_in: 60 }

$dc = Dalli::Client.new(["#{MASTER}:100", "#{REPLICA}:0"], OPTIONS)
$m  = Dalli::Client.new(MASTER,  OPTIONS)
$r  = Dalli::Client.new(REPLICA, OPTIONS)

def put_status
  $dc.reset_stats
  stats = $dc.stats
  puts "[#{MASTER}] -------------"
  puts "items : #{stats[MASTER]["curr_items"]}"
  puts "bytes : #{stats[MASTER]["bytes"]}"
  puts "[#{REPLICA}] -------------"
  puts "items : #{stats[REPLICA]["curr_items"]}"
  puts "bytes : #{stats[REPLICA]["bytes"]}"
end

# show status
put_status

# set keys
puts "[set] ----------------------------"
COUNT.times do |i|
  v = SecureRandom.alphanumeric(130)
  res = $m.set("key#{i}", v)
  puts "set : key#{i} => #{v}"
  sleep INTERVAL
end

# get keys
puts "[get] ----------------------------"
COUNT.times do |i|
  res = $r.get("key#{i}")
  puts "get : key#{i} => #{res}"
end

# show status
put_status


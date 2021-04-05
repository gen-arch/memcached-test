require 'dalli'
require 'securerandom'

#COUNT=10
COUNT=10
MASTER="172.16.0.2:11211"
REPLICA="172.16.0.3:11211"
options = { expires_in: 60 }
$dc = Dalli::Client.new(["#{MASTER}:100", "#{REPLICA}:0"], options)

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

put_status
COUNT.times do |i|
  v = SecureRandom.alphanumeric(130)
  res = $dc.set("key#{i}", v)
  puts "set : key#{i} => #{v}"
end

puts "values ----------------------------"
#COUNT.times do |i|
#  res = $dc.get("key#{i}")
#  #puts "get : key#{i} => #{res}"
#end
put_status


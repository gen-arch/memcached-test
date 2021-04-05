require 'dalli'
require 'securerandom'

VERBOSE   = false
TTL       = 60

class Memcache
  def initialize(master, slave, **options)
    # add hosts
    @host[:master] = master
    @host[:slave ] = slave

    # create options
    @verbose  = options.delete(:verbose)  || VERBOSE
    @options  = options

    # setting optison is default
    @options[:expires_in]  ||= TTL

    # get client
    @client   = con(master, slave)
  end

  def stats
    client.each do |k, c|
      c.reset_stats
      stats = c.stats
      puts "[#{k.to_s}] -------------"
      puts "items : #{stats["curr_items"]}"
      puts "bytes : #{stats["bytes"]}"
    end
  end

  def check(count = 10, interval = 0)
    key = "key#{i}"
    count.times do |i|
      set(key)
      sleep interval
    end

    count.times do |i|
      get(key)
    end
  end

  def set(key)
    v = SecureRandom.alphanumeric(130)
    res = @client[:master].set(key, v)
    puts "set : #{key} => #{v}" if @verbose
    sleep @interval
  end

  def get(key)
    v = SecureRandom.alphanumeric(130)
    res = @client[:slave].get(key)
    puts "get : #{key} => #{res}" if @verbose
  end

  def recon
    client.each do |k, c|
      c.alive!
      c.close
      @client[k] = Dalli::Client.new(@host[k], @options)
    end
  end

  private
  def con
    client = Hash.new
    @host.each{|k, h| client[k] = Dalli::Client.new(h, @options) }

    return client
  end
end


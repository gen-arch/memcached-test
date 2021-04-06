require 'dalli'
require 'securerandom'

VERBOSE   = false
TTL       = 60

class Memcache
  def initialize(master, slave, **options)
    # add hosts
    @host = Hash.new
    @host[:master] = master
    @host[:slave ] = slave

    # create options
    @verbose  = options.delete(:verbose)  || VERBOSE
    @options  = options

    # setting optison is default
    @options[:expires_in]  ||= TTL

    # get client
    @client   = con
  end

  def stats
    @client.each do |k, c|
      c.reset_stats
      _, stat = c.stats.first
      puts "[#{k.to_s}] -------------"
      puts "items : #{stat["curr_items"]}"
      puts "bytes : #{stat["bytes"]}"
    end
  end

  def check(count = 10, interval = 0)
    count.times do |i|
      key = "key#{i}"
      set(key)
      get(key)
      sleep interval
    end
  end

  def set(key)
    v = SecureRandom.alphanumeric(130)
    res = @client[:master].set(key, v)
    puts "[master] set : #{key} => #{v}" if @verbose
  end

  def get(key)
    v = SecureRandom.alphanumeric(130)
    res = @client[:slave].get(key)
    puts "[slave ] get : #{key} => #{res}" if @verbose
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


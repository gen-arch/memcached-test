require_relative 'lib/memcache'


MASTER  = "172.16.0.2:11211"
SLAVE   = "172.16.0.3:11211"

m = Memcache.new(MASTER, SLAVE)

m.stats
m.check(20000, 0.1)
m.stats


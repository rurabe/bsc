class Deal < ActiveRecord::Base
  attr_accessible :description, :link

  after_save { Deal.update_cache }

  def self.update_cache
    REDIS.del( :deals_all )
    REDIS.set( :deals_all, Marshal.dump( all ) )
  end

  def self.cached_deals
    d = REDIS.get(:deals_all)
    Marshal.load( d ) if d.present?
  end

  def self.all
    cached_deals || super
  end
end

require 'active_record'

class IpTable < ActiveRecord::Base
  attr_accessible :from_ip, :to_ip, :registry, :assigned, :country, :country3, :country_name
end

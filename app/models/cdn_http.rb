require 'date'
require 'active_record'

class CdnHttp < ActiveRecord::Base
  attr_accessible :full_path, :happened_at, :http_version, :ip_address, :referrer, :size, :status, :user_agent, :verb, :path, :md5_id
end

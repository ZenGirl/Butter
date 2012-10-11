require 'active_record'

class Catalogue < ActiveRecord::Base
  self.primary_key = "pkId"
  attr_accessible :sku, :mediaId, :distributionTerritoryId, :mediaType, :binaryLocation, :contentProvider, :cost, :active, :fileSize
end

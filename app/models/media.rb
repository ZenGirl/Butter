require 'active_record'

class Media < ActiveRecord::Base
  self.primary_key = "pkId"
  attr_accessible :id, :contextSignature, :name, :description, :descripionLong, :descriptionPerformers, :descriptionComposers
  attr_accessible :descriptionAlbum, :locationSample, :locationThumbnail, :addedDate, :publishedDate, :timesDownloaded
  attr_accessible :duration, :active, :isrc, :digital_upc, :physical_upc, :c_notice, :trackId, :startDate, :stopDate
  attr_accessible :explicit, :genre, :volume_num, :modifiedDate
end

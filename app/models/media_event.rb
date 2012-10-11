require 'date'
require 'active_record'

class MediaEvent < ActiveRecord::Base
  # event:    Stream, Download
  # source:   Mobile, Web
  # country:  AU/US
  # label:    char3
  # label_id: specific to label
  attr_accessible :event, :source, :media_id, :label, :label_id, :user_id, :country, :upc, :isrc, :happened_at, :album, :artist, :title, :duration, :is_sme, :is_royalty_bearing
end
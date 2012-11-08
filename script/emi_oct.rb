#!/usr/bin/env ruby

require 'date'
require 'active_record'

# ---------------------------------------------------------------------------
# Load the db config
# ---------------------------------------------------------------------------
puts "Loading database configuration"
$dbconfig = YAML::load(File.read('config/database.yml'))

# ---------------------------------------------------------------------------
# This table shouldn't be part of butter
# ---------------------------------------------------------------------------
require './app/models/media.rb'
Media.establish_connection($dbconfig['db_butter'])

# ---------------------------------------------------------------------------
# These are legacy and should be in app/models/legacy/
# ---------------------------------------------------------------------------
class Tracks < ActiveRecord::Base
	establish_connection($dbconfig['db_logging'])
	attr_accessible :user_id, :subscription_id, :sponsorship_id, :session_id, :uri, :territory, 
		:track_id, :platform, :media_type, :sales_type, :price, :currency, :label, :created_at, :updated_at
end
class GbhTracks < ActiveRecord::Base
	establish_connection($dbconfig['db_gbh'])
	self.table_name = 'tracks'
	attr_accessible :track_key, :label, :batch_name, :batch_date, :batch_type, :upc, :isrc, 
		:label_id, :disc, :track, :duration, :explicit, :artist, :main_artists, :title, 
		:contributors, :composers, :copyright, :p_notice, :released_at, :genre, :style, 
		:available, :territory, :platform, :sales_type, :media_type, :sales_start_at, :sales_end_at, 
		:price_code, :price, :uri, :path, :filename, :filesize, :album_key, :created_at, :updated_at
end
class GbhTracksEmi < ActiveRecord::Base
	self.table_name = 'tracks_emi'
	establish_connection($dbconfig['db_gbh'])
	# establish_connection db_gbh
	attr_accessible :label, :batch_name, :batch_date, :upc, :batch_type, :isrc, :label_id, :territory, 
		:disc, :track, :media_type, :platform, :sales_type, :digital_icpn, :digital_upc, :physical_icpn, :physical_upc, 
		:physical_isrc, :track_id, :usage_types, :category, :price_code, :start_at, :end_at, :album_key, :track_key, 
		:created_at, :updated_at
end
class Demographics < ActiveRecord::Base
	self.table_name = 'demographics'
	establish_connection($dbconfig['db_guvera'])
	attr_accessible :user_id, :secondary_email, :fullname, :address, :postcode, :born_at, 
		:gender, :mobile, :occupation, :marital_status, :salary, :education, :ethnicity, 
		:orientation, :residence, :created_at, :updated_at
end

# ---------------------------------------------------------------------------
# These indexes make the tracks_emi call quicker
# ---------------------------------------------------------------------------
# alter table gbh.tracks_emi add index `by_uitms` (`upc`,`isrc`,`territory`,`media_type`,`sales_type`);
# alter table gbh.tracks_emi add index `by_bdate` (`batch_date`);
# explain select * from gbh.tracks_emi where upc = '5099967957354' and isrc='GBUM71021646' and territory='AU' and media_type='DLD' and sales_type='ADD' and batch_date <= '2012-10-31';

# ---------------------------------------------------------------------------
# And here we go
# ---------------------------------------------------------------------------
label, country, platform, month					= 'EMI', 'AU', 'WEB', 10
start_date, end_date, report_date, report_time	= '2012-10-01', '2012-10-31', '20121001', '180000'

# ---------------------------------------------------------------------------
# Let's do downloads first
# ---------------------------------------------------------------------------
if false
puts "EMI AU Downloads"
etailer, wholesale_price, media_type 			= '1010013663', '1.29', 'DLD'
total_revenue 	= 0.0
row_number		= 1
csv_file		= File.new("AUGUD#{report_date}.csv", 'w')
Tracks.where("territory='#{country}' and month(created_at)=#{month} and label='#{label}' and platform='#{platform}' and media_type='#{media_type}'").each do |row|
	for_date	= row.created_at.strftime('%Y-%m-%d')
	csv_date	= row.created_at.strftime('%Y%m%d')
	csv_time	= row.created_at.strftime('%H%I%S')
	media		= Media.where("id='#{label}-#{row.track_id}'").first
	upc			= media.digital_upc
	isrc		= media.isrc
	album		= media.descriptionAlbum.gsub(',',' ').slice(0,99)
	artist		= media.descriptionPerformers.gsub(',',' ').slice(0,99)
	title   	= media.name.gsub(',',' ').slice(0,99)
	gbh_track 	= GbhTracksEmi.where("upc='#{upc}' and isrc='#{isrc}' and territory='#{country}' and media_type='#{media_type}' and sales_type='ADD' and batch_date <= '#{for_date}'").order("batch_date desc").first
	label_id	= ''
	label_id	= gbh_track['track_id'] unless gbh_track.nil?
	paid_price	= row.price
	paid_price	= 1.99 if paid_price <= 0.0
	p "#{sprintf('%07d',row_number)} Record for: #{for_date} #{upc} #{isrc} #{label_id} #{artist} - #{album} - #{title}"
	total_revenue += paid_price
	line = "#{report_date},#{report_time},#{etailer},GUVERA,www.guvera.com,#{csv_date},#{csv_time},#{csv_date},#{csv_time},#{label_id},#{artist},#{title},1,#{sprintf('%1.2f',paid_price)},AUD,#{wholesale_price},AUD,DRF,#{sprintf('%08d',row_number)},AU\n";
	csv_file.write(line)
	row_number	+= 1
end
csv_file.close
end

# ---------------------------------------------------------------------------
# Now streams
# ---------------------------------------------------------------------------
if false
puts "EMI AU Streams"
etailer, wholesale_price, media_type 			= '1010013552', '0.01', 'STR'
customer_id 	= etailer
filename		= "AUGUV#{report_date}.txt"
txt_file		= File.new(filename, 'w')
row_number		= 1
select_clause	= "date_format(date(created_at),'%Y-%m-%d') as for_date, track_id, count(track_id) as num_rows"
where_clause	= "where territory='#{country}' and month(created_at)=#{month} and label='#{label}' and platform='#{platform}' and media_type='#{media_type}'"
group_clause	= "group by track_id,for_date"
order_clause	= "order by for_date"
rows = Tracks.connection.execute("select #{select_clause} from tracks #{where_clause} #{group_clause} #{order_clause}")
item_count		= 0
rows.each { |row| item_count += row[2] }
total_revenue	= item_count * 0.01
sequence_number	= 50
header_row = "H\t#{report_date}\t#{customer_id}\t#{etailer}\tS\t#{item_count}\tAU\t#{total_revenue}\t#{report_date}\t#{filename}\t#{sequence_number}\tNet Advertising Revenue:$0\n"
txt_file.write(header_row)
puts "Total rows: #{rows.count}"
rows.each do |row|
	for_date	= row[0]
	num_rows	= row[2]
	media		= Media.where("id='#{label}-#{row[1]}'").first
	upc			= media.digital_upc
	isrc		= media.isrc
	album		= media.descriptionAlbum.gsub(',',' ').slice(0,99)
	artist		= media.descriptionPerformers.gsub(',',' ').slice(0,99)
	title   	= media.name.gsub(',',' ').slice(0,99)
	gbh_track 	= GbhTracksEmi.where("upc='#{upc}' and isrc='#{isrc}' and territory='#{country}' and media_type='#{media_type}' and sales_type='ADD' and batch_date <= '#{for_date}'").order("batch_date desc").first
	label_id	= ''
	label_id	= gbh_track['track_id'] unless gbh_track.nil?
	p "#{sprintf('%07d',row_number)} Record for: #{for_date} #{upc} #{isrc} #{label_id} #{artist} - #{album} - #{title}"
	detail_row	= "D\t#{etailer}\tAU\tS\t#{num_rows}\t#{for_date.gsub('-','')}\t#{label_id}\t#{sprintf('%-100s', artist)}\t#{sprintf('%-100s', title)}\n"
	txt_file.write(detail_row)
	row_number	+= 1
end
txt_file.close
end

# ---------------------------------------------------------------------------
# EMI US Downloads
# ---------------------------------------------------------------------------
puts "EMI US Downloads"
etailer, provider, country_code, wholesale_price = "00717295", "00717280", "840"
period_from     = "2012-10-01 00:00:00"
period_to       = "2012-10-31 23:59:59"
period_date     = "201210"
report_from     = "100112"
file_id         = "201210"
report_date     = "20121001"
end_report_date = "20121031"
sound_scan		= sprintf('%20s',' ')
blank_15_zero	= sprintf('%15d', 0)
blank_header	= sprintf('%177s', '')
txt_filename	= "EMIUSDDL#{report_from}.txt"
txt_file		= File.new(txt_filename, 'w')
prc_filename	= "EMI_PRICE_TIER_#{report_from}.csv"
prc_file		= File.new(prc_filename, 'w')
prices			= {
	'TKT1' => { :wholesale_price => 0.49,	:total_price => 0, :total_count => 0 },
	'TK1'  => { :wholesale_price => 0.70,	:total_price => 0, :total_count => 0 },
	'TKT3' => { :wholesale_price => 0.91,	:total_price => 0, :total_count => 0 },
	'TK3'  => { :wholesale_price => 1.40,	:total_price => 0, :total_count => 0 },
	'TK5'  => { :wholesale_price => 2.10,	:total_price => 0, :total_count => 0 },
	'TK6'  => { :wholesale_price => 2.80,	:total_price => 0, :total_count => 0 },
	'TK7'  => { :wholesale_price => 3.50,	:total_price => 0, :total_count => 0 },
	'TK8'  => { :wholesale_price => 4.20,	:total_price => 0, :total_count => 0 },
	'TK9'  => { :wholesale_price => 4.90,	:total_price => 0, :total_count => 0 },
	'TK11' => { :wholesale_price => 5.60,	:total_price => 0, :total_count => 0 },
	'TK12' => { :wholesale_price => 6.30,	:total_price => 0, :total_count => 0 },
	'TK13' => { :wholesale_price => 7.00,	:total_price => 0, :total_count => 0 },
	'TK14' => { :wholesale_price => 7.70,	:total_price => 0, :total_count => 0 },
	'TK15' => { :wholesale_price => 8.40,	:total_price => 0, :total_count => 0 },
	'TK16' => { :wholesale_price => 9.10,	:total_price => 0, :total_count => 0 },
	'TK17' => { :wholesale_price => 9.80,	:total_price => 0, :total_count => 0 },
	'TK18' => { :wholesale_price => 10.50,	:total_price => 0, :total_count => 0 },
	'TK19' => { :wholesale_price => 11.20,	:total_price => 0, :total_count => 0 }
}
country, platform, media_type = 'US', 'WEB', 'DLD'

detail_header 	=  "#{period_date}DDDL#{etailer}#{sprintf('%25s',' ')}"

where_clause	= "where territory='#{country}' and month(created_at)=#{month} and label='#{label}' and platform='#{platform}' and media_type='#{media_type}'"
rows			= Tracks.connection.execute("select count(distinct(user_id)) from tracks #{where_clause}").first
tot_emi_users	= rows[0]

select_clause	= "id, date_format(date(created_at),'%Y-%m-%d') as for_date, user_id, track_id, count(track_id) as num_rows"
group_clause	= "group by id, for_date"
order_clause	= "order by for_date"
rows = Tracks.connection.execute("select #{select_clause} from tracks #{where_clause} #{group_clause} #{order_clause}")

puts "Calculating header data..."
total_units		= 0
total_revenue	= 0.0
row_number		= 1
rows.each do |row|
	id, for_date, user_id, track_id, num_items = row[0], row[1], row[2], row[3], row[4]
	media			= Media.where("id='#{label}-#{track_id}'").first
	if media.nil?
		puts "  Missing: media id='#{label}-#{track_id}'"
		next
	end
	upc				= media.digital_upc
	isrc			= media.isrc
	gbh_track 		= GbhTracksEmi.where("upc='#{upc}' and isrc='#{isrc}' and territory='#{country}' and media_type='#{media_type}' and sales_type='ADD' and batch_date <= '#{for_date}'").order("batch_date desc").first
	if gbh_track.nil?
		puts "  Missing: tracks_emi upc='#{upc}' and isrc='#{isrc}' and territory='#{country}' and media_type='#{media_type}' and sales_type='ADD' and batch_date <= '#{for_date}'"
		next
	end
	price_code		= gbh_track['price_code']
	price_code		= 'TK1' if ! prices.has_key?(price_code)
	total_revenue	+= (num_items * prices[price_code][:wholesale_price])
	total_units		+= num_items
	puts "#{sprintf('%07d',row_number)} #{for_date} #{upc} #{isrc}"
	row_number	+= 1
end

puts "Starting main run..."
tot_units		= sprintf("%015s", total_units)
tot_all_cnt		= sprintf("%015s", rows.count)
tot_rev			= sprintf("%016s", total_revenue).gsub(/[^0-9]/, '')
header_row		= "#{period_date}HDDL#{etailer}#{country_code}#{report_date}#{sound_scan}#{tot_units}#{tot_all_cnt}#{blank_15_zero}#{blank_15_zero}#{tot_emi_users}#{blank_15_zero}#{blank_15_zero}#{tot_rev}#{blank_15_zero}#{blank_15_zero}#{blank_header}\n"
txt_file.write(header_row)

row_number		= 1
rows.each do |row|
	id, for_date, user_id, track_id, num_items = row[0], row[1], row[2], row[3], row[4]
	media				= Media.where("id='#{label}-#{track_id}'").first
	if media.nil?
		puts "  Missing: media id='#{label}-#{track_id}'"
		next
	end
	upc					= media.digital_upc
	fmt_upc				= sprintf('%-25s',upc)
	isrc				= media.isrc
	album				= media.descriptionAlbum.gsub(',',' ').slice(0,30)
	artist				= media.descriptionPerformers.gsub(',',' ')
	fmt_artist			= sprintf('%-30s',artist.slice(0,30))
	title   			= media.name.gsub(',',' ')
	fmt_title			= sprintf('%-30s',title.slice(0,30))
	gbh_track 			= GbhTracksEmi.where("upc='#{upc}' and isrc='#{isrc}' and territory='#{country}' and media_type='#{media_type}' and sales_type='ADD' and batch_date <= '#{for_date}'").order("batch_date desc").first
	if gbh_track.nil?
		puts "  Missing: tracks_emi upc='#{upc}' and isrc='#{isrc}' and territory='#{country}' and media_type='#{media_type}' and sales_type='ADD' and batch_date <= '#{for_date}'"
		next
	end
	label_id			= ''
	label_id			= gbh_track['track_id'] unless gbh_track.nil?
	label_id			= sprintf('%-25s', label_id)
	#p "#{sprintf('%07d',row_number)} Record for: #{for_date} #{upc} #{isrc} #{label_id} #{artist} - #{album} - #{title}"
	comp_num			= sprintf('%03d', media.volume_num)
	item_num			= sprintf('%03d', media.trackId)
	quantity			= sprintf('%015d', num_items)
	po_number			= "PO" + sprintf('%023d', row_number)
	net_price			= 0.0
	fmt_net_price 		= sprintf('%016.4f', net_price).gsub(/[^0-9]/,'')
	price_code			= gbh_track['price_code']
	price_code			= 'TK1' if ! prices.has_key?(price_code)
	fmt_wholesale_price = sprintf('%016.4f', prices[price_code][:wholesale_price]).gsub(/[^0-9]/,'')
	prices[price_code][:total_count] += num_items
	prices[price_code][:total_price] += prices[price_code][:wholesale_price]
	promo_code			= "      "
	user				= Demographics.where("user_id=#{user_id}").first
	zip					= user.postcode
	zip					= '' if zip == 'undefined'
	fmt_zip				= sprintf('%-12s', zip)
	detail = "#{detail_header}#{label_id}#{fmt_upc}#{comp_num}#{item_num}#{fmt_artist}#{fmt_title}#{quantity}#{end_report_date}MP3#{po_number}#{fmt_net_price}#{fmt_wholesale_price}#{fmt_wholesale_price}#{promo_code}#{country_code}#{fmt_zip}\n"
	txt_file.write("#{detail}#{sprintf('%100s',' ')}")
	puts "#{sprintf('%07d',row_number)} #{for_date} #{detail}"
	row_number	+= 1
end

puts "Price Tier Breakdown for file : #{prc_filename}"
prices.each do |code,price|
	puts "#{code} %10.2f %10.2f" % [ price[:total_price], price[:total_count] ]
	prc_file.write("#{code},%10.2f,%d" % [ price[:total_price], price[:total_count] ])
end

txt_file.close
prc_file.close

# ---------------------------------------------------------------------------
# EMI US Streams
# ---------------------------------------------------------------------------
puts "EMI US Streams"
etailer, provider, country_code, wholesale_price = "00717280", "00717280", "840"
period_from     = "2012-10-01 00:00:00"
period_to       = "2012-10-31 23:59:59"
period_date     = "201210"
report_from     = "100112"
file_id         = "201210"
report_date     = "20121001"
end_report_date = "20121031"
sound_scan		= sprintf('%20s',' ')
blank_15_zero	= sprintf('%15d', 0)
blank_header	= sprintf('%177s', '')
txt_filename	= "EMIUSSTR#{report_from}.txt"
txt_file		= File.new(txt_filename, 'w')
country, platform, media_type = 'US', 'WEB', 'STR'

detail_header 	=  "#{period_date}DSTR#{etailer}#{sprintf('%25s',' ')}"

where_clause	= "where territory='#{country}' and month(created_at)=#{month} and label='#{label}' and platform='#{platform}' and media_type='#{media_type}'"
rows			= Tracks.connection.execute("select count(distinct(user_id)) from tracks #{where_clause}").first
tot_emi_users	= rows[0]

puts "Calculating header data..."
total_units		= 0
total_revenue	= 0.0
row_number		= 1
rows.each do |row|
	id, for_date, user_id, track_id, num_items = row[0], row[1], row[2], row[3], row[4]
	media			= Media.where("id='#{label}-#{track_id}'").first
	if media.nil?
		puts "  Missing: media id='#{label}-#{track_id}'"
		next
	end
	upc				= media.digital_upc
	isrc			= media.isrc
	gbh_track 		= GbhTracksEmi.where("upc='#{upc}' and isrc='#{isrc}' and territory='#{country}' and media_type='#{media_type}' and sales_type='ADD' and batch_date <= '#{for_date}'").order("batch_date desc").first
	if gbh_track.nil?
		puts "  Missing: tracks_emi upc='#{upc}' and isrc='#{isrc}' and territory='#{country}' and media_type='#{media_type}' and sales_type='ADD' and batch_date <= '#{for_date}'"
		next
	end
	total_revenue	+= (num_items * prices[price_code][:wholesale_price])
	total_units		+= num_items
	puts "#{sprintf('%07d',row_number)} #{for_date} #{upc} #{isrc}"
	row_number	+= 1
end

puts "Starting main run..."
tot_units		= sprintf("%015s", total_units)
tot_all_cnt		= sprintf("%015s", rows.count)
tot_rev			= sprintf("%016s", total_revenue).gsub(/[^0-9]/, '')
header_row		= "#{period_date}HSTR#{provider}#{country_code}#{report_date}#{sound_scan}#{tot_units}#{tot_all_cnt}#{blank_15_zero}#{blank_15_zero}#{tot_emi_users}000000000000001#{tot_rev}#{tot_rev}#{blank_15_zero}#{blank_15_zero}#{blank_header}\n"
txt_file.write(header_row)

row_number		= 1
rows.each do |row|
	id, for_date, user_id, track_id, num_items = row[0], row[1], row[2], row[3], row[4]
	media				= Media.where("id='#{label}-#{track_id}'").first
	if media.nil?
		puts "  Missing: media id='#{label}-#{track_id}'"
		next
	end
	upc					= media.digital_upc
	fmt_upc				= sprintf('%-25s',upc)
	isrc				= media.isrc
	album				= media.descriptionAlbum.gsub(',',' ').slice(0,30)
	artist				= media.descriptionPerformers.gsub(',',' ')
	fmt_artist			= sprintf('%-30s',artist.slice(0,30))
	title   			= media.name.gsub(',',' ')
	fmt_title			= sprintf('%-30s',title.slice(0,30))
	gbh_track 			= GbhTracksEmi.where("upc='#{upc}' and isrc='#{isrc}' and territory='#{country}' and media_type='#{media_type}' and sales_type='ADD' and batch_date <= '#{for_date}'").order("batch_date desc").first
	if gbh_track.nil?
		puts "  Missing: tracks_emi upc='#{upc}' and isrc='#{isrc}' and territory='#{country}' and media_type='#{media_type}' and sales_type='ADD' and batch_date <= '#{for_date}'"
		next
	end
	label_id			= ''
	label_id			= gbh_track['track_id'] unless gbh_track.nil?
	label_id			= sprintf('%-25s', label_id)
	#p "#{sprintf('%07d',row_number)} Record for: #{for_date} #{upc} #{isrc} #{label_id} #{artist} - #{album} - #{title}"
	comp_num			= sprintf('%03d', media.volume_num)
	item_num			= sprintf('%03d', media.trackId)
	quantity			= sprintf('%015d', num_items)
	po_number			= "PO" + sprintf('%023d', row_number)
	net_price			= 0.0
	fmt_net_price 		= sprintf('%016.4f', net_price).gsub(/[^0-9]/,'')
	price_code			= gbh_track['price_code']
	price_code			= 'TK1' if ! prices.has_key?(price_code)
	fmt_wholesale_price = sprintf('%016.4f', prices[price_code][:wholesale_price]).gsub(/[^0-9]/,'')
	prices[price_code][:total_count] += num_items
	prices[price_code][:total_price] += prices[price_code][:wholesale_price]
	promo_code			= "      "
	user				= Demographics.where("user_id=#{user_id}").first
	zip					= user.postcode
	zip					= '' if zip == 'undefined'
	fmt_zip				= sprintf('%-12s', zip)
	detail = "#{detail_header}#{label_id}#{fmt_upc}#{comp_num}#{item_num}#{fmt_artist}#{fmt_title}#{quantity}#{end_report_date}MP3#{po_number}#{fmt_net_price}#{fmt_wholesale_price}#{fmt_wholesale_price}#{promo_code}#{country_code}#{fmt_zip}\n"

	txt_file.write("#{detail}#{sprintf('%100s',' ')}")
	puts "#{sprintf('%07d',row_number)} #{for_date} #{detail}"
	row_number	+= 1
end

txt_file.close



















require 'date'
require 'active_record'

class CdnFcs < ActiveRecord::Base
  attr_accessible :mode, :happened_at, :path, :http_status, :ip_address, :md5_id
  # 1 pause/play/seek/stop/unpause
  #	2 stream
  #	3 2012-10-04
  #	4 13:09:45
  #	5 UTC
  #	6 s/content/VLA/Audio/931/9332412005931/01_020_SOLO(Reg_Livermore)_128
  #	7 ::ffff:203.77.189.201 cdn_ip_address
  #	8 18046 size?
  #	9 0..137 unknown??
  #	10 0..85 unknown??
  #	11 _defaultRoot_
  #	12 _defaultVHost_
  #	13 a4183
  #	14 d1
  #	15 0
  #	16 -/200/401/404/408 http_status
  #	17 208.111.140.74 src_ip_address
  #	18 rtmpe/rtmpte(HTTP-1.0)/rtmpte(HTTP-1.0-KeepAlive)/rtmpte(HTTP-1.1)
  #	19 rtmpe://fcds95.hkg.llnw.net:1935/a4183/d1
  #	20 rtmpe://fcds95.hkg.llnw.net:1935/a4183/d1
  #	21 - unknown?
  #	22 - flowplayer. e.g. https://www.guvera.com/flowplayer/flowplayer-3.2.7.swf
  #	23 LNX 10,0,22,87 browser_id
  #	24 4699357121207157105 epoch?
  #	25 3174 some_size?
  #	26 19885 timestamp? e.g. 224801167..426329067
  #	27 normal always
  #	28 s/content/VLA/Audio/626/9399421083626/01_007_Waiting_For_That_Train(Southern_Sons)_128
  #	29 -/e=1349134474&h=762cddbbef95e1240e1fe4a3903a5d42
  #	30 -/e=1349134474&h=762cddbbef95e1240e1fe4a3903a5d42
  #	31 rtmpe://fcds95.hkg.llnw.net:1935/a4183/d1/test_unsec/guvera_test.mp3
  #	32 rtmpe://fcds95.hkg.llnw.net:1935/a4183/d1/test_unsec/guvera_test.mp3
  #	33 /llnw/applications/a4183/streams/d1/test_unsec/guvera_test.mp3
  #	34 mp3/id3
  #	35 149128 size?
  #	36 9.064000 - 4727.745117 unknown. bandwidth?
  #	37 0..4551966 size?
  #	38 0 always
  #	39 0..72877932 size?
  #	40 - always
  #	41 -/0..4919487 size?
  #	42 - always
  #	43 - always

end
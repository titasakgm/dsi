#!/usr/bin/ruby

require 'cgi'
require 'postgres'

def log(msg)
  log = open("/tmp/dsi3.log","a")
  log.write(msg)
  log.write("\n")
  log.close
end

def check_npark(lon,lat)
  con = PGconn.connect("localhost",5432,nil,nil,"dsi","postgres")
  sql = "select name_th from national_park where contains(the_geom,"
  sql += "geometryfromtext('POINT(#{lon} #{lat})',4326))"
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  name = "NA"
  if (found == 1)
    name = res[0][0]
  end
  name
end

def check_rforest(lon,lat)
  con = PGconn.connect("localhost",5432,nil,nil,"dsi","postgres")
  sql = "select name_th,mapsheet,area_decla,dec_date,ratchakija,ton "
  sql += "from reserve_forest "
  sql += "where contains(the_geom,"
  sql += "geometryfromtext('POINT(#{lon} #{lat})',4326))"
  log("check_rforest-sql: #{sql}")
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  msg = "NA"
  if (found == 1)
    name = res[0][0]
    mapsheet = res[0][1]
    area_decla = res[0][2]
    dec_date = res[0][3]
    ratchakija = res[0][4]
    ton = res[0][5]
    msg = "<font face=\"time, serif\" size=\"4\">#{name}<br />ระวาง:#{mapsheet}<br/>"
    msg += "พื้นที่:#{area_decla} ตร.กม.<br />ประกาศเมื่อ: #{dec_date}<br />"
    msg += "ราชกิจจานุเบกษา: #{ratchakija} ตอนที่: #{ton}</font>"
  end
  log("check_rforest-msg: #{msg}")
  msg 
end

c = CGI::new
layer = c['layer']
lon = c['lon'].to_f
lat = c['lat'].to_f

msg = nil

if layer == 'national_park'
  msg = check_npark(lon,lat)
elsif layer == 'reserve_forest'
  msg = check_rforest(lon,lat)
end

data = "{'msg':'#{msg}','lon':'#{lon}','lat':'#{lat}'}"

print <<EOF
Content-type: text/html

#{data}
EOF

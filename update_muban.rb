#!/usr/bin/ruby

require 'postgres'

def get_fullname(gid)
  con = PGconn.connect("localhost",5432,nil,nil,"dsi")
  sql = "SELECT muban || ' ต.' || tambol || ' อ.' || amphoe "
  sql += "|| ' จ.' || changwat "
  sql += "FROM no_06_muban "
  sql += "WHERE gid=#{gid} "
  res = con.exec(sql)
  con.close
  fullname = res[0][0]
end

def update_location(id, text)
  con = PGconn.connect("localhost",5432,nil,nil,"dsi")
  sql = "UPDATE locations "
  sql += "SET loc_text='#{text}' "
  sql += "WHERE id=#{id} "
  res = con.exec(sql)
  con.close
end

t1 = Time.now

con = PGconn.connect("localhost",5432,nil,nil,"dsi")
sql = "SELECT id,loc_gid FROM locations "
sql += "WHERE loc_text LIKE 'บ้าน%' "
res = con.exec(sql)
con.close

n = 0
res.each do |rec|
  n += 1
  id = rec[0]
  gid = rec[1]
  fullname = get_fullname(gid)
  puts "#{n}: #{fullname}"
  update_location(id,fullname)
end

t2 = Time.now
puts "Time: #{t2-t1} seconds"

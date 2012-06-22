#!/usr/bin/ruby

require 'postgres'

def get_fullname(gid)
  con = PGconn.connect("localhost",5432,nil,nil,"dsi")
  sql = "SELECT amphoe_t || ' ' || prov_nam_t "
  sql += "FROM no_03_amphoe "
  sql += "WHERE gid=#{gid}"
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
sql += "WHERE loc_text LIKE 'อ.%' "
res = con.exec(sql)
con.close

res.each do |rec|
  id = rec[0]
  gid = rec[1]
  fullname = get_fullname(gid)
  puts "fullname: #{fullname}"
  update_location(id,fullname)
end

t2 = Time.now
puts "Time: #{t2-t1} seconds"

#!/usr/bin/ruby

require 'cgi'
require 'postgres'
require 'net/http'
require 'rubygems'
require 'json'

def log(msg)
  File.open("/tmp/search-googlex","a").write(msg)
  File.open("/tmp/search-googlex","a").write("\n")
end

def create_hili_map(table,gid)

  ##### Start create hilimap according to query with exact = 1
  geom = "POLYGON"
  filter = "gid = #{gid}"
  if table =~ /muban/
    geom = "POINT"
  end

  log("filter: #{filter}")

  map = open("/ms521/map/search.tpl").readlines.to_s.gsub('#GEOM#',"#{geom}").gsub('#TABLE#',"#{table}").gsub('#FILTER#',"#{filter}")

  File.open("/ms521/map/hili.map","w").write(map)
  ##### End of create hilight

end

def get_center(table,gid)
  con = PGconn.connect("localhost",5432,nil,nil,"dsi")
  sql = "SELECT center(the_geom) "
  sql += "FROM #{table} "
  sql += "WHERE gid=#{gid}"
  res = con.exec(sql)
  con.close
  found = res.num_tuples
  lonlat = []
  if (found == 1)
    res.each do |rec|
      lonlat = rec[0].to_s.tr('()','').split(',')
      lon = sprintf("%0.2f", lonlat[0].to_f)
      lat = sprintf("%0.2f", lonlat[1].to_f)
      lonlat = [lon,lat]
    end
  end
  lonlat
end

def search_location(query, start, limit, exact)
  con = PGconn.connect("localhost",5432,nil,nil,"dsi")
  cond = nil

  if exact == 1
    cond = "loc_text = '#{query}' "
  elsif query.include?('.')
    cond = "loc_text LIKE '#{query}%' "
  elsif query.strip =~ /\ /
    kws = query.strip.split(' ')
    (0..kws.length-1).each do |n|
      if n == 0
        if kws[0][1..1] == '.' # ต. อ. จ.
          cond = "loc_text LIKE '#{kws[n]}%' "
        else
          cond = "loc_text LIKE '%#{kws[n]}%' "
        end
      else
        cond += "AND loc_text LIKE '%#{kws[n]}%' "
      end
    end
  else
    cond = "loc_text LIKE '%#{query}%' "
  end

  sql = "SELECT count(*) FROM locations WHERE #{cond}" 

  log("sql: #{sql}")

  res = con.exec(sql)
  found = res[0][0].to_i

  return_data = nil

  if (found > 1)
    sql = "SELECT loc_gid,loc_text,loc_table "
    sql += "FROM locations "
    sql += "WHERE #{cond} "
    sql += "ORDER BY id DESC "
    sql += "LIMIT #{limit} OFFSET #{start}"

    log("sql>1: #{sql}")

    res = con.exec(sql)

    return_data = Hash.new
    return_data[:success] = true
    return_data[:totalcount] = found
    return_data[:records] = res.collect{ |u| {
      :loc_gid => u[0],
      :loc_text => u[1],
      :loc_table => u[2]
    } }
  elsif found == 1
    sql = "SELECT loc_gid,loc_text,loc_table "
    sql += "FROM locations "
    sql += "WHERE loc_text LIKE '%#{query}%' "

    log("sql=1: #{sql}")

    res = con.exec(sql)

    gid = res[0][0]
    text = res[0][1]
    table = res[0][2]
    lonlat = get_center(table,gid)
    lon = lonlat[0]
    lat = lonlat[1]  

    create_hili_map(table,gid)
 
    return_data = Hash.new
    return_data[:success] = true
    return_data[:totalcount] = 1
    return_data[:records] = [{
      :loc_gid => gid,
      :loc_text => text,
      :loc_table => table,
      :lon => lon, 
      :lat => lat
    }]
  else # found == 0
    return_data = Hash.new
    return_data[:success] = true
    return_data[:totalcount] = 0
    return_data[:records] = [{}]
  end
  con.close
  return_data
end

c = CGI::new
query = c['query']
start = c['start'].to_i
limit = c['limit'].to_i
exact = c['exact'].to_s.to_i

if start == 0
  limit = 5
end

data = search_location(query, start, limit, exact)

#if lonlat.nil?
#  lonlat = google(kw)
#end

print <<EOF
Content-type: text/html

#{data.to_json}
EOF

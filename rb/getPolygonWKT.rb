#!/usr/bin/ruby

require 'cgi'
require 'postgres'

c = CGI::new
gid = c['gid']

con = PGconn.connect("localhost",5432,nil,nil,"dsi","postgres")
sql = "SELECT astext(the_geom) "
sql += "FROM province "
sql += "WHERE gid='#{gid}' "
res = con.exec(sql)
con.close

geometry = res[0][0]
geometry = "MULTIPOLYGON((104.97 16.27,105 16,104.5 16,104.97 16.27))"

print <<EOF
Content-type: text/html

#{geometry}
EOF


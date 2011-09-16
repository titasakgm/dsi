MAP
	NAME Thai
        STATUS ON
        EXTENT 97.0 5.5 105.7 20.5
        UNITS dd
        SIZE 600 400
        IMAGECOLOR 180 180 180
        TRANSPARENT ON
        IMAGETYPE png
	FONTSET "/ms521/fonts/fonts.txt"
	#SYMBOLSET "/ms521/symbols/symbols.txt"
	OUTPUTFORMAT
		NAME png
		DRIVER "GD/PNG"
		MIMETYPE "image/png"
		IMAGEMODE RGB
		EXTENSION "png"
		FORMATOPTION "INTERLACE=OFF"
	END
        WEB
                IMAGEPATH '/wms/tmp/'
                IMAGEURL "/wms/tmp/"
		METADATA
			"wms_title" "DSI WMS"
			"wms_onlineresource" "http://203.157.240.9/cgi-bin/mapserv?map=/ms521/map/hili.map&"
			"wms_srs" "EPSG:4326 EPSG:900913"
		END
        END
        PROJECTION
                "proj=latlong"
		"datum=WGS84"
	END

	LAYER
		NAME "hili"
                METADATA
                        "wms_title" "Highlight"
			"wms_srs" "EPSG:4326 EPSG:900913"
                END
        	PROJECTION
                	"proj=latlong"
			"datum=WGS84"
		END
		STATUS ON
		OPACITY 50
                TYPE #GEOM#
                CONNECTIONTYPE postgis
                CONNECTION "host=localhost dbname=dsi user=postgres"
                DATA "the_geom FROM #TABLE# using unique gid using srid=4326"
                FILTER "#FILTER#"
		CLASS
			STYLE
				ANGLE 360
				COLOR  255 99 71
				OUTLINECOLOR 255 0 0
                                WIDTH 5
			END
		END
	END
END

 

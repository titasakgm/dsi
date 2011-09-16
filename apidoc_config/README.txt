This directory contains the config files for generating MapFish api documentation.
It is nighty built and available on http://mapfish.org/apidoc/trunk/

To have the apidoc manually generated (mapfish api only), follow these steps:
* Install NaturalDocs in /path/to/naturaldocs from http://naturaldocs.org/
* Copy Menu.txt in some tmp dir
  * $ cp /path/to/mf/apidoc_config/* /tmp/naturaldocs_workdir/.
* Generate the apidoc
  * $ cd /path/to/naturaldocs
  * $ ./NaturalDocs -i /path/to/mfbase/mapfish -p /tmp/naturaldocs_workdir -o HTML /path/to/generated/apidoc -r -ro

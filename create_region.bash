mkdir -p rd
mkdir -p wgs84

# REGIONNAME="gemeente"
# YEAR=2016
MDFILE="index.md"
echo -e "# Contents\n" > $MDFILE


for REGIONNAME in "provincie" "coropgebied" "gemeente" "wijk" "buurt"
do
  echo -e "## $REGIONNAME \n" >> $MDFILE

  for YEAR in {2003..2016}
  do 
    echo -e "${YEAR}:" >> $MDFILE
    REGION="${REGIONNAME}_${YEAR}"
    #echo $REGION

    # get WGS84 (EPSG:4326)
    curl "http://geodata.nationaalgeoregister.nl/cbsgebiedsindelingen/wfs?request=GetFeature&service=WFS&version=2.0.0&typeName=cbs_${REGION}_gegeneraliseerd&outputFormat=json&SRSName=urn:x-ogc:def:crs:EPSG:4326" > "wgs84/${REGION}.json"
    mapshaper "wgs84/$REGION.json" -proj wgs84 -o "wgs84/$REGION.json" 
    mapshaper "wgs84/$REGION.json" -simplify 10% -o "wgs84/$REGION.geojson" id-field=statcode
    mapshaper "wgs84/$REGION.json" -simplify 10% -o "wgs84/$REGION.topojson" id-field=statcode

    echo "[wgs84,geojson](wgs84/$REGION.geojson)" >> $MDFILE
    echo "[wgs84,topojson](wgs84/$REGION.topojson)" >> $MDFILE

    # get rijkdriehoeksstelsel (EPSG:28894)
    curl "http://geodata.nationaalgeoregister.nl/cbsgebiedsindelingen/wfs?request=GetFeature&service=WFS&version=2.0.0&typeName=cbs_${REGION}_gegeneraliseerd&outputFormat=json" > "rd/${REGION}.json"
    mapshaper "rd/$REGION.json" -simplify 10% -o "rd/$REGION.geojson" id-field=statcode
    mapshaper "rd/$REGION.json" -simplify 10% -o "rd/$REGION.topojson" id-field=statcode
    echo "[rd,geojson](rd/$REGION.geojson)" >> $MDFILE
    echo "[rd,topojson](rd/$REGION.topojson)" >> $MDFILE
    echo "" >> $MDFILE
  done
done

# remove all original files
rm */*.json

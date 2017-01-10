# obistools

Tools for data enhancement and quality control.

## Taxon matching

```R
names <- c("Abra alva", "Buccinum fusiforme", "Buccinum fusiforme", "Buccinum fusiforme", "hlqsdkf")
match_taxa(names)
```

```
3 names, 1 without matches, 1 with multiple matches
Proceed to resolve names (y/n/p)? y

  AphiaID     scientificname      authority     status match_type
1  531014 Buccinum fusiforme   Kiener, 1834 unaccepted      exact
2  510389 Buccinum fusiforme Broderip, 1830 unaccepted      exact

Multiple matches, pick a number or leave empty to skip: 2

        scientificName                          scientificNameID match_type
1            Abra alba urn:lsid:marinespecies.org:taxname:141433     near_1
2   Buccinum fusiforme urn:lsid:marinespecies.org:taxname:510389      exact
2.1 Buccinum fusiforme urn:lsid:marinespecies.org:taxname:510389      exact
2.2 Buccinum fusiforme urn:lsid:marinespecies.org:taxname:510389      exact
3                 <NA>                                      <NA>       <NA>
```

## Check required fields

```R
data <- data.frame(
  occurrenceID = c("1", "2", "3"),
  scientificName = c("Abra alba", NA, ""),
  locality = c("North Sea", "English Channel", "Flemish Banks"),
  minimumDepthInMeters = c("10", "", "5")
)

check_fields(data)
```

```
             field level                                       message row
1        eventDate error           Required field eventDate is missing  NA
2 decimalLongitude error    Required field decimalLongitude is missing  NA
3  decimalLatitude error     Required field decimalLatitude is missing  NA
4 scientificNameID error    Required field scientificNameID is missing  NA
5 occurrenceStatus error    Required field occurrenceStatus is missing  NA
6    basisOfRecord error       Required field basisOfRecord is missing  NA
7   scientificName error Empty value for required field scientificName   2
8   scientificName error Empty value for required field scientificName   3
```

## Plot points on a map

```R
plot_map(abra)
```

![https://raw.githubusercontent.com/iobis/obistools/master/images/abra.png](https://raw.githubusercontent.com/iobis/obistools/master/images/abra.png)

```R
plot_map_leaflet(abra)
```

![https://raw.githubusercontent.com/iobis/obistools/master/images/abra_2.png](https://raw.githubusercontent.com/iobis/obistools/master/images/abra_2.png)

## Identify points on a map

```R
plot_map(abra, zoom = TRUE)
identify_map(abra)
```

```
            id decimalLongitude decimalLatitude    basisOfRecord           eventDate institutionCode
2078 384334009            29.51           43.97 HumanObservation 2010-05-20 10:00:00       GeoEcoMar
                                           collectionCode                            catalogNumber         locality
2078 GeoEcoMar BlackSea R/V Mare Nigrum Cruises 2010-2011 GeoEcoMar_BlackSeaCruises_2003_2011_3723 Constanta_10CT05
                                                                         datasetName   phylum    order    family
2078 Macrobenthos data from the Romanian part of the Black Sea between 2003 and 2011 Mollusca Cardiida Semelidae
     genus scientificName originalScientificName scientificNameAuthorship obisID resourceID yearcollected   species
2078  Abra      Abra alba              Abra alba          (W. Wood, 1802) 395450       4273          2010 Abra alba
            qc aphiaID speciesID continent coordinateUncertaintyInMeters       datasetID            modified
2078 859307135  141433    395450 Black Sea                          <NA> IMIS:dasid:5256 2015-12-27 00:00:00
                                 occurrenceID recordedBy                          scientificNameID    class
2078 GeoEcoMar_BlackSeaCruises_2003_2011_3723       <NA> urn:lsid:marinespecies.org:taxname:141433 Bivalvia
     lifestage  sex individualCount eventID depth minimumDepthInMeters maximumDepthInMeters fieldNumber
2078      <NA> <NA>              NA    <NA> 60.94                60.94                60.94           I
     occurrenceRemarks eventTime footprintWKT identifiedBy
2078              <NA>      <NA>         <NA>     Teaca A.```
```

## Check points on land

```R
check_onland(abra)
```

```
          id decimalLongitude decimalLatitude basisOfRecord           eventDate
31 365512845       -0.9092748        54.57467    Occurrence 2011-09-03 10:00:00
                                      institutionCode collectionCode catalogNumber                      locality
31 Yorkshire Naturalists' Union Marine and Coastal Se          60051     261729389 Skinningrove. Cattersty Sands
                                                      datasetName   phylum    order    family genus scientificName
31 Yorkshire Naturalists Union Marine and Coastal Section Records Mollusca Cardiida Semelidae  Abra      Abra alba
   originalScientificName scientificNameAuthorship obisID resourceID yearcollected   species         qc aphiaID
31              Abra alba          (W. Wood, 1802) 395450       3083          2011 Abra alba 1073216639  141433
   speciesID continent coordinateUncertaintyInMeters       datasetID            modified
31    395450    Europe                         707.0 IMIS:dasid:3182 2014-04-16 16:16:43
                                                                     occurrenceID    recordedBy
31 urn:catalog:Yorkshire Naturalists' Union Marine and Coastal Se:60051:261729389 Adrian Norris
                            scientificNameID    class lifestage  sex individualCount eventID depth
31 urn:lsid:marinespecies.org:taxname:141433 Bivalvia      <NA> <NA>              NA    <NA>    NA
   minimumDepthInMeters maximumDepthInMeters fieldNumber occurrenceRemarks eventTime footprintWKT identifiedBy
31                   NA                   NA        <NA>              <NA>      <NA>         <NA>         <NA>
```

```R
check_onland(abra, report = TRUE)
```

```
  field   level row                         message
1    NA warning  31 Coordinates are located on land
```

## Check eventID and parentEventID

```R
data <- data.frame(
  eventID = c("a", "b", "c", "d", "e", "f"),
  parentEventID = c("", "", "a", "a", "bb", "b"),
  stringsAsFactors = FALSE
)
check_eventids(data)
```

```
          field level row                                       message
1 parentEventID error   5 parentEventID bb has no corresponding eventID
```

## Flatten event records

```R
event <- data.frame(
  eventID = c("cruise_1", "station_1", "station_2", "sample_1", "sample_2", "sample_3", "sample_4", "subsample_1", "subsample_2"),
  parentEventID = c(NA, "cruise_1", "cruise_1", "station_1", "station_1", "station_2", "station_2", "sample_3", "sample_3"),
  eventDate = c(NA, NA, NA, "2017-01-01", "2017-01-02", "2017-01-03", "2017-01-04", NA, NA),
  decimalLongitude = c(NA, 2.9, 4.7, NA, NA, NA, NA, NA, NA),
  stringsAsFactors = FALSE
)

flatten_event(event)
```

```
      eventID parentEventID  eventDate decimalLongitude
1    cruise_1          <NA>       <NA>               NA
2   station_1      cruise_1       <NA>              2.9
3   station_2      cruise_1       <NA>              4.7
4    sample_1     station_1 2017-01-01              2.9
5    sample_2     station_1 2017-01-02              2.9
6    sample_3     station_2 2017-01-03              4.7
7    sample_4     station_2 2017-01-04              4.7
8 subsample_1      sample_3 2017-01-03              4.7
9 subsample_2      sample_3 2017-01-03              4.7
```


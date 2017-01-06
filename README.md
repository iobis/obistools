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

## Identify points on a map

```R
plot_map(abra, zoom = TRUE)
identify_map(abra)
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

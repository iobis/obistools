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

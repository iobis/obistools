# suppress warning for "no visible binding for global variable" in R CMD check
utils::globalVariables(c('decimalLongitude','decimalLatitude', 'x', 'y',
                         'AphiaID', 'scientificname', 'authority', 'status',
                         'match_type', 'occurrenceID', 'eventID',
                         'measurementType', 'parentEventID', 'leaf'))

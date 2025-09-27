# filename
```foobar2000
%album artist%\$if($meta_test((ORIGINALDATE),),'['$meta(ORIGINALDATE)'] ',$if($meta_test(date),'['$meta(date)'] '))%album%\[$ifequal(%totaldiscs%,1,,$num(%discnumber%,2).)[%tracknumber%] - ]%title%[$if($not($stricmp(%artist%,%album artist%)), '['%artist%']')]
```

# Grouping
```foobar2000
$if2(%album artist%,<no artist>)[ - %album%]$if($meta_test(ORIGINALDATE), '['%ORIGINALDATE%']',[ '['%date%']']))
```

# Title
```foobar2000
[%title%][$if($not($stricmp(%artist%,%album artist%)), '['%artist%']')]]
```

# Date
```foobar2000
$if($meta_test(ORIGINALDATE),%ORIGINALDATE%,%date%))
```

# Sort Column
## Sorting script
```foobar2000
%album artist% - 
%album% - 
$num(discnumber, 10).$num(tracknumber, 10) - 
%title%
```

## Display Scription
```foobar2000
$if(%isplaying%,>)
```
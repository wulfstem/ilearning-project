let
  Source = Json.Document(Web.Contents("https://api.worldbank.org/v2/country/USA/indicator/NY.GDP.MKTP.CD?format=json&date=2000:2024")),
  Navigation = Source{1},
  #"Converted to table" = Table.FromList(Navigation, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
  #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to table", "Column1", {"indicator", "country", "date", "value"}, {"indicator", "country", "date", "value"}),
  #"Expanded indicator" = Table.ExpandRecordColumn(#"Expanded Column1", "indicator", {"value"}, {"value.1"}),
  #"Expanded country" = Table.ExpandRecordColumn(#"Expanded indicator", "country", {"value"}, {"value.2"}),
  #"Renamed columns" = Table.RenameColumns(#"Expanded country", {{"value", "gdp_value"}, {"value.1", "indicator"}, {"value.2", "country"}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed columns", {{"indicator", type text}, {"country", type text}, {"date", type text}, {"gdp_value", type text}})
in
  #"Changed column type"
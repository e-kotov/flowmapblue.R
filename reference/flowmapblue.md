# Create an interactive flow map

Creates an interactive flow map visualizing flows between various
locations and outputs it as an HTML widget. This function utilizes the
[`FlowmapBlue`](https://www.flowmap.blue/) library to create maps with
customizable options such as clustering, animation, and dark mode. The
widget can be rendered in R Markdown, Shiny, or viewed in a browser. It
can also be saved to `html` file with
[`htmlwidgets:saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html).
See examples for more details.

## Usage

``` r
flowmapblue(
  locations,
  flows,
  mapboxAccessToken = NULL,
  clustering = TRUE,
  animation = FALSE,
  darkMode = FALSE
)
```

## Arguments

- locations:

  A `data.frame` containing the location data. The `data.frame` should
  have the following columns:

  id

  :   A character vector representing the unique identifier for each
      location (e.g., "JU", "LU").

  name

  :   (Optional) A character vector representing the name of each
      location (e.g., "Jura", "Luzern").

  lat

  :   A numeric vector representing the latitude of each location in
      WGS84 (EPSG: 4326) coordinate reference system.

  lon

  :   A numeric vector representing the longitude of each location in
      WGS84 (EPSG: 4326) coordinate reference system.

- flows:

  A `data.frame` containing the flow data between locations. The
  `data.frame` should have the following columns:

  origin

  :   A `character` vector representing the origin location identifier
      (must match the `id` in `locations`).

  dest

  :   A `character` vector representing the destination location
      identifier (must match the `id` in `locations`).

  count

  :   An `integer` vector representing the flow count between the origin
      and destination locations.

  time

  :   (Optional) A vector of `POSIXct` or `Date` objects representing
      the date or date and time of the flow.

- mapboxAccessToken:

  A `character` string representing the Mapbox access token. This is
  required to render the map using Mapbox tiles. You can obtain a free
  token at <https://account.mapbox.com/>.

- clustering:

  A `logical` value indicating whether to enable clustering of locations
  on the map. Defaults to `TRUE`.

- animation:

  A `logical` value indicating whether to enable animation of flows on
  the map. Defaults to `FALSE`.

- darkMode:

  A `logical` value indicating whether to enable dark mode for the map.
  Defaults to `FALSE`.

## Value

An HTML widget of class `flowmapblue` and `htmlwidget` that can be
rendered in R Markdown, Shiny, or viewed in a browser. It can also be
saved to `html` file with
[`htmlwidgets:saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html).
See examples for more details.

## Examples

``` r
if (FALSE) { # \dontrun{
# example 1, normal flows
# set your Mapbox access token
Sys.setenv(MAPBOX_API_TOKEN = "YOUR_MAPBOX_ACCESS_TOKEN")

# load locations and flows for Switzerland
locations <- data(ch_locations)
flows <- data(ch_flows)

flowmap <- flowmapblue(
 locations,
 flows,
 mapboxAccessToken = Sys.getenv('MAPBOX_API_TOKEN'),
 clustering = TRUE,
 darkMode = TRUE,
 animation = FALSE
)

# view the map
flowmap

# or save it as an HTML file
htmlwidgets::saveWidget(flowmap, file = "flowmap.html")

# example 2, flows with date in time column
# set your Mapbox access token
Sys.setenv(MAPBOX_API_TOKEN = "YOUR_MAPBOX_ACCESS_TOKEN")

# load locations and flows for Switzerland
data(ch_locations)
data(ch_flows)

# generate fake datetime
flows$time <- seq(from =as.POSIXct("2020-01-01"),
  to = as.POSIXct("2020-01-05"), length.out = nrow(flows))

flowmap <- flowmapblue(
 ch_locations,
 ch_flows,
 mapboxAccessToken = Sys.getenv('MAPBOX_API_TOKEN'),
 clustering = TRUE,
 darkMode = TRUE,
 animation = FALSE
)

# view the map
flowmap

# example 3, flows with date in time column
# set your Mapbox access token
Sys.setenv(MAPBOX_API_TOKEN = "YOUR_MAPBOX_ACCESS_TOKEN")

# load locations and flows for Switzerland
data(ch_locations)
data(ch_flows)
# generate fake dates
flows$time <- seq(from = as.Date("2020-01-01"),
  to = as.Date("2020-06-01"), length.out = nrow(flows))

flowmap <- flowmapblue(
 ch_locations,
 ch_flows,
 mapboxAccessToken = Sys.getenv('MAPBOX_API_TOKEN'),
 clustering = TRUE,
 darkMode = TRUE,
 animation = FALSE
)

# view the map
flowmap
} # }
```

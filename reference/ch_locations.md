# Swiss Locations Dataset

A dataset containing geographic information about 26 locations in
Switzerland. This data includes unique identifiers, names, and
geographic coordinates (latitude and longitude) for each location.

## Usage

``` r
ch_locations
```

## Format

### `ch_locations`

A data frame with 26 rows and 4 columns:

- id:

  A `character` vector representing the unique identifier for each Swiss
  location (e.g., "JU", "LU").

- name:

  A `character` vector representing the name of each location (e.g.,
  "Jura", "Luzern").

- lat:

  A `numeric` vector representing the latitude of each location in WGS84
  (EPSG: 4326) coordinate reference system.

- lon:

  A `numeric` vector representing the longitude of each location in
  WGS84 (EPSG: 4326) coordinate reference system.

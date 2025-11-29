# Swiss Flows Dataset

A dataset containing flow data between various locations in Switzerland.
This data represents the flow counts between origin and destination
locations, identified by their unique codes.

## Usage

``` r
ch_flows
```

## Format

### `ch_flows`

A data frame with 676 rows and 3 columns:

- origin:

  A `character` vector representing the origin location identifier (must
  match the `id` in the `ch_locations` dataset).

- dest:

  A `character` vector representing the destination location identifier
  (must match the `id` in the `ch_locations` dataset).

- count:

  An `integer` vector representing the flow count between the origin and
  destination locations.

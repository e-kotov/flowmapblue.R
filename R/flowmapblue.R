#' Create an interactive flow map
#'
#' @description
#' Creates an interactive flow map visualizing flows between various locations and outputs it as an HTML widget. This function utilizes the \href{https://www.flowmap.blue/}{`FlowmapBlue`} library to create maps with customizable options such as clustering, animation, and dark mode. The widget can be rendered in R Markdown, Shiny, or viewed in a browser. It can also be saved to `html` file with \code{\link[htmlwidgets:saveWidget]{htmlwidgets:saveWidget()}}. See examples for more details.
#'
#' @param locations A `data.frame` containing the location data. The `data.frame` should have the following columns:
#' \describe{
#'   \item{id}{A character vector representing the unique identifier for each location (e.g., "JU", "LU").}
#'   \item{name}{(Optional) A character vector representing the name of each location (e.g., "Jura", "Luzern").}
#'   \item{lat}{A numeric vector representing the latitude of each location in WGS84 (EPSG: 4326) coordinate reference system.}
#'   \item{lon}{A numeric vector representing the longitude of each location in WGS84 (EPSG: 4326) coordinate reference system.}
#' }
#'
#' @param flows A `data.frame` containing the flow data between locations. The `data.frame` should have the following columns:
#' \describe{
#'   \item{origin}{A `character` vector representing the origin location identifier (must match the `id` in `locations`).}
#'   \item{dest}{A `character` vector representing the destination location identifier (must match the `id` in `locations`).}
#'   \item{count}{An `integer` vector representing the flow count between the origin and destination locations.}
#'   \item{time}{(Optional) A vector of `POSIXct` or `Date` objects representing the date or date and time of the flow.}
#'   \item{color}{(Optional) A `character` vector representing the color of the flow (e.g., "#ffccaa").}
#' }
#'
#' @param mapboxAccessToken A `character` string representing the Mapbox access token. This is required to render the map using Mapbox tiles. You can obtain a free token at \href{https://account.mapbox.com/}{https://account.mapbox.com/}.
#' @param clustering A `logical` value indicating whether to enable clustering of locations on the map. Defaults to `TRUE`.
#' @param animation A `logical` value indicating whether to enable animation of flows on the map. Defaults to `FALSE`.
#' @param darkMode A `logical` value indicating whether to enable dark mode for the map. Defaults to `FALSE`.
#'
#' @param palette A `character` string specifying the color palette to use for automatic color scaling based on flow magnitude. Can be a palette name from `grDevices::hcl.pals()` (e.g., "Viridis", "Plasma", "Blues") or a vector of hex color codes. If provided, the `color` column in `flows` will be overwritten.
#' @param reverse_palette A `logical` value indicating whether to reverse the color palette. Defaults to `FALSE`.
#' @param style A `character` string specifying the method to calculate breaks for the color scale. Supported methods are "fixed", "sd", "equal", "pretty", "quantile", "kmeans", "hclust", "bclust", "fisher", "jenks". Defaults to "quantile". See \code{\link[classInt:classIntervals]{classInt::classIntervals()}} for details.
#' @param n An `integer` specifying the number of color intervals. Defaults to 5.
#' @param breaks A numeric vector of break points for the color scale when `style = "fixed"`.
#' @param location_color A `character` string specifying the color of the location circles. Can be a color name (e.g., "red", "blue") or a hex code (e.g., "#FF0000"). If `NULL` and `palette` is specified, defaults to the highest value of the flow palette. If `NULL` and `palette` is not specified, the color is determined by the `darkMode` setting (white for light mode, black for dark mode).
#'
#' @return An HTML widget of class `flowmapblue` and `htmlwidget` that can be rendered in R Markdown, Shiny, or viewed in a browser. It can also be saved to `html` file with \code{\link[htmlwidgets:saveWidget]{htmlwidgets:saveWidget()}}. See examples for more details.
#'
#' @examples
#' \dontrun{
#' # example 1, normal flows
#' # set your Mapbox access token
#' Sys.setenv(MAPBOX_API_TOKEN = "YOUR_MAPBOX_ACCESS_TOKEN")
#'
#' # load locations and flows for Switzerland
#' locations <- data(ch_locations)
#' flows <- data(ch_flows)
#'
#' flowmap <- flowmapblue(
#'  locations,
#'  flows,
#'  mapboxAccessToken = Sys.getenv('MAPBOX_API_TOKEN'),
#'  clustering = TRUE,
#'  darkMode = TRUE,
#'  animation = FALSE
#' )
#'
#' # view the map
#' flowmap
#'
#' # or save it as an HTML file
#' htmlwidgets::saveWidget(flowmap, file = "flowmap.html")
#'
#' # example 2, flows with date in time column
#' # set your Mapbox access token
#' Sys.setenv(MAPBOX_API_TOKEN = "YOUR_MAPBOX_ACCESS_TOKEN")
#'
#' # load locations and flows for Switzerland
#' data(ch_locations)
#' data(ch_flows)
#'
#' # generate fake datetime
#' flows$time <- seq(from =as.POSIXct("2020-01-01"),
#'   to = as.POSIXct("2020-01-05"), length.out = nrow(flows))
#'
#' flowmap <- flowmapblue(
#'  ch_locations,
#'  ch_flows,
#'  mapboxAccessToken = Sys.getenv('MAPBOX_API_TOKEN'),
#'  clustering = TRUE,
#'  darkMode = TRUE,
#'  animation = FALSE
#' )
#'
#' # view the map
#' flowmap
#'
#' # example 3, flows with date in time column
#' # set your Mapbox access token
#' Sys.setenv(MAPBOX_API_TOKEN = "YOUR_MAPBOX_ACCESS_TOKEN")
#'
#' # load locations and flows for Switzerland
#' data(ch_locations)
#' data(ch_flows)
#' # generate fake dates
#' flows$time <- seq(from = as.Date("2020-01-01"),
#'   to = as.Date("2020-06-01"), length.out = nrow(flows))
#'
#' flowmap <- flowmapblue(
#'  ch_locations,
#'  ch_flows,
#'  mapboxAccessToken = Sys.getenv('MAPBOX_API_TOKEN'),
#'  clustering = TRUE,
#'  darkMode = TRUE,
#'  animation = FALSE
#' )
#'
#' # view the map
#' flowmap
#'
#' # example 4, automatic color scaling
#' flowmap <- flowmapblue(
#'  ch_locations,
#'  ch_flows,
#'  mapboxAccessToken = Sys.getenv('MAPBOX_API_TOKEN'),
#'  clustering = FALSE,
#'  darkMode = TRUE,
#'  palette = "Plasma",
#'  reverse_palette = TRUE,
#'  style = "jenks",
#'  n = 5
#' )
#' flowmap
#' }
#'
#' @import htmlwidgets
#' @import classInt
#' @export
flowmapblue <- function(
  locations,
  flows,
  mapboxAccessToken = NULL,
  clustering = TRUE,
  animation = FALSE,
  darkMode = FALSE,
  palette = NULL,
  reverse_palette = FALSE,
  style = "quantile",
  n = 5,
  breaks = NULL,
  location_color = NULL
) {
  # Apply color scaling if palette is provided
  if (!is.null(palette)) {
    if (clustering) {
      warning(
        "Clustering is enabled. Individual flow colors may not be visible as they are aggregated. Consider setting clustering = FALSE."
      )
    }

    # Calculate breaks
    # We pass style directly to classIntervals
    # If style is 'fixed', breaks must be provided
    if (style == "fixed" && is.null(breaks)) {
      stop("When style = 'fixed', the 'breaks' argument must be provided.")
    }

    # classIntervals arguments
    ci_args <- list(var = flows$count, n = n, style = style)
    if (!is.null(breaks)) {
      ci_args$fixedBreaks <- breaks
    }

    breaks_obj <- do.call(classInt::classIntervals, ci_args)

    # Generate palette
    if (length(palette) == 1) {
      # Normalize common palette names
      if (palette == "Greys") {
        palette <- "Grays"
      }

      if (palette %in% grDevices::hcl.pals()) {
        colors <- grDevices::hcl.colors(
          n,
          palette = palette,
          rev = reverse_palette
        )
      } else {
        # Try to use it as a color for interpolation (e.g. "red" or c("red", "blue"))
        # We wrap in tryCatch to give a better error message if it fails
        tryCatch(
          {
            cols <- grDevices::colorRampPalette(palette)(n)
            if (reverse_palette) {
              cols <- rev(cols)
            }
            colors <- cols
          },
          error = function(e) {
            stop(paste0(
              "Palette '",
              palette,
              "' not found in hcl.pals() and is not a valid color for interpolation."
            ))
          }
        )
      }
    } else if (length(palette) >= n) {
      # User provided a vector of colors
      colors <- palette[1:n]
      if (reverse_palette) colors <- rev(colors)
    } else {
      # User provided a vector of colors but fewer than n, interpolate
      cols <- grDevices::colorRampPalette(palette)(n)
      if (reverse_palette) {
        cols <- rev(cols)
      }
      colors <- cols
    }

    # Assign colors
    # classIntervals returns $brks
    # We use cut to map values to intervals
    flows$color <- as.character(cut(
      flows$count,
      breaks = breaks_obj$brks,
      labels = colors,
      include.lowest = TRUE
    ))

    # Default location_color to the highest value of the palette if not specified
    if (is.null(location_color)) {
      location_color <- colors[length(colors)]
    }
  }

  # Convert color names to hex codes
  if (!is.null(location_color)) {
    # Check if it's not already a hex code
    if (!grepl("^#", location_color)) {
      # Convert color name to hex
      location_color <- grDevices::rgb(
        t(grDevices::col2rgb(location_color)) / 255,
        maxColorValue = 1
      )
    }
  }

  # convert time columng to UNIX time in milliseconds
  if ("time" %in% colnames(flows)) {
    if (inherits(flows$time, "POSIXct")) {
      flows$time <- as.numeric(flows$time) * 1000
    }
    if (inherits(flows$time, "Date")) {
      flows$time <- as.numeric(as.POSIXct(flows$time)) * 1000
    }
  }

  # pass the data and settings using 'x'
  x <- list(
    locations = locations,
    flows = flows,
    mapboxAccessToken = mapboxAccessToken,
    clustering = clustering,
    animation = animation,
    darkMode = darkMode,
    locationColor = location_color
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'flowmapblue',
    x,
    width = NULL,
    height = NULL,
    package = 'flowmapblue',
    sizingPolicy = sizingPolicy(
      padding = 0,
      browser.padding = 0
    )
  )
}

#' Shiny bindings for flowmapblue
#'
#' Output and render functions for using flowmapblue within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from.
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a `flowmapblue` widget.
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @return
#' \describe{
#'   \item{\code{flowmapblueOutput}}{Returns a `shiny.tag.list` object that can be included in a Shiny UI to display the `flowmapblue` widget.}
#'   \item{\code{renderFlowmapblue}}{Returns a `shiny.render.function` that is used to generate the `flowmapblue` widget on the server side in a Shiny application.}
#' }
#'
#' @seealso \code{\link[htmlwidgets:shinyWidgetOutput]{shinyWidgetOutput}}, \code{\link[htmlwidgets:shinyRenderWidget]{shinyRenderWidget}}
#'
#' @name flowmapblue-shiny
#'
#' @export
flowmapblueOutput <- function(outputId, width = '100%', height = '400px') {
  htmlwidgets::shinyWidgetOutput(
    outputId,
    'flowmapblue',
    width,
    height,
    package = 'flowmapblue'
  )
}

#' @rdname flowmapblue-shiny
#' @export
renderFlowmapblue <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, flowmapblueOutput, env, quoted = TRUE)
}

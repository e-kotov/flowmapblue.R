# Shiny bindings for flowmapblue

Output and render functions for using flowmapblue within Shiny
applications and interactive Rmd documents.

## Usage

``` r
flowmapblueOutput(outputId, width = "100%", height = "400px")

renderFlowmapblue(expr, env = parent.frame(), quoted = FALSE)
```

## Arguments

- outputId:

  output variable to read from.

- width, height:

  Must be a valid CSS unit (like `'100%'`, `'400px'`, `'auto'`) or a
  number, which will be coerced to a string and have `'px'` appended.

- expr:

  An expression that generates a `flowmapblue` widget.

- env:

  The environment in which to evaluate `expr`.

- quoted:

  Is `expr` a quoted expression (with
  [`quote()`](https://rdrr.io/r/base/substitute.html))? This is useful
  if you want to save an expression in a variable.

## Value

- `flowmapblueOutput`:

  Returns a `shiny.tag.list` object that can be included in a Shiny UI
  to display the `flowmapblue` widget.

- `renderFlowmapblue`:

  Returns a `shiny.render.function` that is used to generate the
  `flowmapblue` widget on the server side in a Shiny application.

## See also

[`shinyWidgetOutput`](https://rdrr.io/pkg/htmlwidgets/man/htmlwidgets-shiny.html),
[`shinyRenderWidget`](https://rdrr.io/pkg/htmlwidgets/man/htmlwidgets-shiny.html)

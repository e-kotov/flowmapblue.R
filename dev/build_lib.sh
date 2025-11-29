#!/bin/bash

# Exit on error
set -e

# Default pinned commit
PINNED_COMMIT="f874a208c0121f98974c779aca6b1bbec6786f76"
USE_LATEST=false

# Parse arguments
for arg in "$@"; do
  case $arg in
    --latest)
      USE_LATEST=true
      shift
      ;;
  esac
done

# Directory paths
PROJECT_ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEV_DIR="$PROJECT_ROOT/dev"
FLOWMAP_DIR="$DEV_DIR/FlowmapBlue"
OUTPUT_DIR="$PROJECT_ROOT/inst/htmlwidgets/lib"
ENTRY_POINT="$DEV_DIR/lib-entry.tsx"

echo "Building FlowmapBlue library..."
echo "Project Root: $PROJECT_ROOT"

# 1. Clone the repository if it doesn't exist
if [ ! -d "$FLOWMAP_DIR" ]; then
    echo "Cloning FlowmapBlue repository..."
    git clone https://github.com/FlowmapBlue/FlowmapBlue.git "$FLOWMAP_DIR"
else
    echo "FlowmapBlue repository already exists at $FLOWMAP_DIR"
fi

cd "$FLOWMAP_DIR"

# Clean up any previous patches/changes to ensure clean checkout
echo "Cleaning up previous changes..."
git checkout .
git clean -fd

# Fetch latest updates
echo "Fetching updates..."
git fetch origin

if [ "$USE_LATEST" = true ]; then
    echo "Checking out latest version (HEAD)..."
    # Get the default branch name (usually master or main)
    DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
    git checkout "$DEFAULT_BRANCH"
    git pull origin "$DEFAULT_BRANCH"
else
    echo "Checking out pinned commit: $PINNED_COMMIT"
    git checkout "$PINNED_COMMIT"
fi

# 2. Copy our custom entry point into the source tree
echo "Copying lib-entry.tsx..."
cp "$ENTRY_POINT" lib-entry.tsx

# 3. Patch dependencies and files
echo "Applying patches..."

# Patch package.json: Downgrade react-map-gl from 7.0.23 to 6.1.19
if grep -q '"react-map-gl": "7.0.23"' package.json; then
    echo "Downgrading react-map-gl to v6 for compatibility..."
    sed -i '' 's/"react-map-gl": "7.0.23"/"react-map-gl": "6.1.19"/' package.json
fi

# Patch FlowMap.tsx: Use StaticMap instead of Map
FLOWMAP_TSX="core/FlowMap.tsx"
if grep -q 'import {Map as ReactMapGl} from' "$FLOWMAP_TSX"; then
    echo "Patching FlowMap.tsx to use StaticMap..."
    sed -i '' 's/import {Map as ReactMapGl} from/import {StaticMap as ReactMapGl} from/' "$FLOWMAP_TSX"
    # Also fix the prop name change from v7 to v6
    sed -i '' 's/mapboxAccessToken={mapboxAccessToken}/mapboxApiAccessToken={mapboxAccessToken}/' "$FLOWMAP_TSX"
fi

# Patch core/colors.ts: Support custom location color
COLORS_TS="core/colors.ts"
# We need to match the IIFE version that was previously applied
if grep -q "outgoing: (function()" "$COLORS_TS"; then
    echo "Removing old patch and re-applying..."
    git checkout "$COLORS_TS"
fi

if grep -q "locationCircles: {" "$COLORS_TS"; then
    echo "Patching colors.ts to support custom location color..."
    # Replace the entire locationCircles block
    # When location_color is provided, set all properties to that color
    # When not provided, only set outgoing (let SDK use defaults for others)
    
    perl -i -pe '
      BEGIN { $in_location_circles = 0; }
      if (/locationCircles: \{/) {
        $in_location_circles = 1;
        $_ = "    locationCircles: config[\"colors.location\"] ? {\n" .
             "      outgoing: config[\"colors.location\"],\n" .
             "      incoming: config[\"colors.location\"],\n" .
             "      inner: config[\"colors.location\"],\n" .
             "      highlighted: config[\"colors.location\"],\n" .
             "    } : {\n" .
             "      outgoing: darkMode ? \"#000\" : \"#fff\",\n";
        next;
      }
      if ($in_location_circles && /^\s*\},\s*$/) {
        $in_location_circles = 0;
        $_ = "    },\n";
      }
      if ($in_location_circles) {
        $_ = "";
      }
    ' "$COLORS_TS"
fi

# TODO: Patch core/FlowMap.selectors.ts to preserve colors during clustering
# This is currently causing issues and needs more investigation
# SELECTORS_TS="core/FlowMap.selectors.ts"
# if grep -q "export const getSortedAggregatedFilteredFlows" "$SELECTORS_TS"; then
#     echo "Patching FlowMap.selectors.ts to preserve colors during clustering..."
#     ...
# fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install --legacy-peer-deps
fi

# 4. Build the library using esbuild
echo "Running esbuild..."
npx esbuild lib-entry.tsx \
    --bundle \
    --outfile="$OUTPUT_DIR/flowmap-blue.min.js" \
    --minify \
    --format=iife \
    --global-name=flowmapBlue \
    --loader:.js=jsx \
    --loader:.ts=tsx \
    --loader:.tsx=tsx \
    --loader:.css=css \
    --loader:.woff=dataurl \
    --loader:.woff2=dataurl \
    --loader:.ttf=dataurl \
    --loader:.eot=dataurl \
    --define:process.env.NODE_ENV='"production"' \
    --define:process.browser=true \
    --define:global=window \
    --banner:js="var process={env:{NODE_ENV:'production'},browser:true,cwd:function(){return'/'},hrtime:function(){return[0,0]},type:'browser',version:'',versions:{}};"

echo "Build complete!"
echo "Files generated:"
ls -lh "$OUTPUT_DIR/flowmap-blue.min.js"
ls -lh "$OUTPUT_DIR/flowmap-blue.min.css"

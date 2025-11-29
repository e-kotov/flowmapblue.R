// Polyfill process for browser
if (typeof window !== 'undefined' && !window.process) {
  (window as any).process = {
    env: { NODE_ENV: 'production' },
    browser: true,
    cwd: () => '/',
    hrtime: () => [0, 0],
    type: 'browser',
    version: '',
    versions: {},
  };
}

import * as React from 'react';
import * as ReactDOM from 'react-dom';
import FlowMap from './core/FlowMap';
import { ConfigPropName, Location, Flow } from './core/types';
import './css/blueprint.css';
import '@blueprintjs/select/lib/css/blueprint-select.css';
import '@blueprintjs/icons/lib/css/blueprint-icons.css';
import 'mapbox-gl/dist/mapbox-gl.css';
import './css/globals.css';

// Mock Next.js router
import { RouterContext } from 'next/dist/shared/lib/router-context';

const mockRouter: any = {
  route: '/',
  pathname: '/',
  query: {},
  asPath: '/',
  push: async () => true,
  replace: async () => true,
  reload: () => null,
  back: () => null,
  prefetch: async () => undefined,
  beforePopState: () => null,
  events: {
    on: () => null,
    off: () => null,
    emit: () => null,
  },
  isFallback: false,
};

function FlowMapWrapper(props: any) {
  return (
    <RouterContext.Provider value={mockRouter}>
      <FlowMap {...props} />
    </RouterContext.Provider>
  );
}

export function init({
  locations,
  flows,
  container,
  mapboxAccessToken,
  clustering = true,
  animation = false,
  darkMode = false,
  locationColor = null,
}: {
  locations: Location[];
  flows: Flow[];
  container: HTMLElement;
  mapboxAccessToken: string;
  clustering?: boolean;
  animation?: boolean;
  darkMode?: boolean;
  locationColor?: string | null;
}) {
  const config: any = {
    [ConfigPropName.MAPBOX_ACCESS_TOKEN]: mapboxAccessToken,
    [ConfigPropName.CLUSTER_ON_ZOOM]: clustering ? 'yes' : 'no',
    [ConfigPropName.ANIMATE_FLOWS]: animation ? 'yes' : 'no',
    [ConfigPropName.COLORS_DARK_MODE]: darkMode ? 'yes' : 'no',
  };

  // Only add location color if provided
  if (locationColor) {
    config['colors.location'] = locationColor;
  }

  console.log('Config object:', config);
  console.log('Location color:', locationColor);

  ReactDOM.render(
    <FlowMapWrapper
      inBrowser={true}
      embed={true}
      config={config}
      locationsFetch={{ value: locations }}
      flowsFetch={{ value: flows }}
      spreadSheetKey={undefined}
      flowsSheet={undefined}
    />,
    container
  );
}

// Explicitly assign to window to ensure global availability
if (typeof window !== 'undefined') {
  (window as any).flowmapBlue = { init };
}

// Export as default for esbuild IIFE to create global object
export default { init };

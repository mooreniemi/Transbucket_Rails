import { paraglideVitePlugin } from '@inlang/paraglide-js'
/// <reference types="vitest/config" />
import { defineConfig } from 'vite';
import { devtools } from '@tanstack/devtools-vite';
import { tanstackRouter } from '@tanstack/router-plugin/vite';
import viteReact from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import RubyPlugin from 'vite-plugin-ruby';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { storybookTest } from '@storybook/addon-vitest/vitest-plugin';
import { playwright } from '@vitest/browser-playwright';
const dirname = path.dirname(fileURLToPath(import.meta.url));

// Storybook and Vitest load this file too, but they don't run behind Rails --
// the Ruby plugin would remap their root, base, and build inputs.
const runsBehindRails = !process.env.STORYBOOK && !process.env.VITEST;

// More info at: https://storybook.js.org/docs/next/writing-tests/integrations/vitest-addon
const config = defineConfig({
  // Copied as-is into the build output (e.g. the og:image). Absolute because
  // the Ruby plugin's root is src/, where Vite would otherwise look.
  publicDir: path.resolve(dirname, 'public'),
  resolve: {
    tsconfigPaths: true
  },
  // Only when served through Rails (see runsBehindRails above).
  server: runsBehindRails ? {
    // Rails' dev proxy (inside Docker) forwards requests with this Host
    // header; Vite rejects unknown hosts by default.
    allowedHosts: ['host.docker.internal'],
    // The proxy only relays HTTP, not WebSockets, so HMR connects straight
    // to the dev server instead of going through the page's origin (:3000).
    hmr: { host: 'localhost', clientPort: 5173 },
  } : undefined,
  plugins: [
    paraglideVitePlugin({
      // Absolute: the Ruby plugin sets Vite's root to src/, so relative
      // paths in plugin options would resolve against that instead.
      project: path.resolve(dirname, 'project.inlang'),
      outdir: path.resolve(dirname, 'src/generated/paraglide'),
      strategy: ['url'],
      outputStructure: process.env.production ? 'message-modules' : 'locale-modules'
    }),
    // base, manifest, output dir, port, and the entrypoint list all come
    // from config/vite.json (shared with the vite_rails gem).
    ...(runsBehindRails ? [RubyPlugin()] : []),
    devtools({
      // Console piping calls /__tsd/... at the page's origin, which the
      // Rails dev proxy doesn't forward (it only forwards /vite-dev/*).
      consolePiping: {
        enabled: false
      },
    }),
    tailwindcss(),
    tanstackRouter({
      routesDirectory: path.resolve(dirname, 'src/routes'),
      generatedRouteTree: path.resolve(dirname, 'src/routeTree.gen.ts'),
      target: 'react',
      autoCodeSplitting: true
    }),
    viteReact()
  ],
  test: {
    projects: [{
      extends: true,
      test: {
        name: 'unit',
        environment: 'jsdom',
        include: ['src/**/*.test.{ts,tsx}'],
        setupFiles: ['vitest.setup.ts'],
      }
    }, {
      extends: true,
      plugins: [
      // The plugin will run tests for the stories defined in your Storybook config
      // See options at: https://storybook.js.org/docs/next/writing-tests/integrations/vitest-addon#storybooktest
      storybookTest({
        configDir: path.join(dirname, '.storybook')
      })],
      test: {
        name: 'storybook',
        browser: {
          enabled: true,
          headless: true,
          provider: playwright({}),
          instances: [{
            browser: 'chromium'
          }]
        }
      }
    }]
  }
});
export default config;
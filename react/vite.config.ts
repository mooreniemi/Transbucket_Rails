import { paraglideVitePlugin } from '@inlang/paraglide-js'
/// <reference types="vitest/config" />
import { defineConfig } from 'vite';
import { devtools } from '@tanstack/devtools-vite';
import { tanstackRouter } from '@tanstack/router-plugin/vite';
import viteReact from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { storybookTest } from '@storybook/addon-vitest/vitest-plugin';
import { playwright } from '@vitest/browser-playwright';
const dirname = path.dirname(fileURLToPath(import.meta.url));

// More info at: https://storybook.js.org/docs/next/writing-tests/integrations/vitest-addon
const config = defineConfig(({ command }) => ({
  // The build is served by Rails out of public/vite (see lib/tasks/vite.rake),
  // so every URL Vite bakes into the bundle -- imported images, lazy route
  // chunks, CSS url()s -- has to start with /vite/. With the default "/",
  // they'd point at /assets/..., which is Sprockets' territory, and 404.
  // Dev keeps "/" because the dev server itself serves everything.
  base: command === 'build' ? '/vite/' : '/',
  resolve: {
    tsconfigPaths: true
  },
  plugins: [
    paraglideVitePlugin({
      project: './project.inlang',
      outdir: './src/generated/paraglide',
      strategy: ['url'],
      outputStructure: process.env.production ? 'message-modules' : 'locale-modules'
    }),
    devtools({
      // can enable this if ruby is updated and we can migrate to vite_rails gem instead of custom setup
      consolePiping: {
        enabled: false
      },
    }),
    tailwindcss(),
    tanstackRouter({
      target: 'react',
      autoCodeSplitting: true
    }),
    viteReact()
  ],
  // manifest: true so the Rails catch-all view can look up the current
  // build's hashed asset filenames instead of hardcoding them.
  build: {
    manifest: true,
  },
  // strictPort so Rails' dev-mode asset helper can rely on this port
  // always being the dev server, matching the "dev" npm script's
  // --port 5173; cors so the Rails-origin page can load module scripts
  // from here directly in development.
  server: {
    port: 5173,
    strictPort: true,
    cors: {
      origin: 'http://localhost:3000'
    },
    // Without this, Vite resolves asset imports (e.g. the header logo) to
    // root-relative dev URLs like /src/assets/foo.png -- fine when Vite
    // serves the page itself, but wrong when Rails does: the browser
    // resolves that path against Rails' origin (:3000), not Vite's
    // (:5173), and 404s. origin makes Vite emit the absolute dev-server
    // URL instead.
    origin: 'http://localhost:5173',
  },
  test: {
    projects: [{
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
}));
export default config;
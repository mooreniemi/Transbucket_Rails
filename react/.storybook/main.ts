import type { StorybookConfig } from '@storybook/tanstack-react';
import tailwindcss from '@tailwindcss/vite';
import tailwindIntegration from '@unpunnyfuns/swatchbook-integrations/tailwind';

const config: StorybookConfig = {
  "stories": [
    "../src/**/*.mdx",
    "../src/**/*.stories.@(js|jsx|mjs|ts|tsx)"
  ],
  "addons": [
    "@chromatic-com/storybook",
    "@storybook/addon-vitest",
    "@storybook/addon-a11y",
    "@storybook/addon-docs",
    "@storybook/addon-mcp",
    {
      name: '@unpunnyfuns/swatchbook-addon',
      options: {
        configPath: '../swatchbook.config.ts',
        integrations: [tailwindIntegration()],
      },
    },
  ],
  "framework": "@storybook/tanstack-react",
  // Default docgen (react-docgen) can't resolve generic prop types like
  // `RenderProps<T, ElementType>`, which every react-aria-components wrapper
  // in this library extends -- switch to the TS-compiler-based docgen, and
  // stop it from filtering out props whose type lives in node_modules
  // (react-aria-components' own prop interfaces), which is its own default.
  typescript: {
    reactDocgen: 'react-docgen-typescript',
    reactDocgenTypescriptOptions: {
      // Keep the default exclusion of node_modules noise (native HTML/DOM
      // attributes, third-party library internals), but let react-aria-
      // components' own prop interfaces through -- every wrapper component
      // in this library extends those directly, so excluding them wholesale
      // hides most of the real prop list.
      propFilter: (prop) => {
        const fileName = prop.parent?.fileName;
        if (!fileName || !/node_modules/.test(fileName)) return true;
        return /node_modules\/react-aria-components\//.test(fileName);
      },
    },
  },
  // Tailwind v4 Vite plugin -- processes the `@theme` block the swatchbook
  // addon's virtual module serves. The addon knows nothing about Tailwind
  // directly; the integration package does. Matches the pattern from
  // unpunnyfuns/swatchbook's own apps/storybook config.
  viteFinal(viteConfig) {
    const plugins = Array.isArray(viteConfig.plugins) ? [...viteConfig.plugins] : [];
    plugins.push(tailwindcss());
    return { ...viteConfig, plugins };
  },
};
export default config;
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
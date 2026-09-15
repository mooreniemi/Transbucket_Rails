import { definePreview } from '@storybook/tanstack-react';
import addonDocs from '@storybook/addon-docs';
import swatchbookAddon from '@unpunnyfuns/swatchbook-addon';
import '../src/styles.css';
// Preview-only: live-updates Tailwind utility classes as the toolbar flips
// token axes. Not a replacement for the production build's generated
// tailwind-theme.css (still produced by terrazzo.config.ts).
import 'virtual:swatchbook/tailwind.css';

// definePreview() needs each addon's own preview-composition function called
// here explicitly -- registering an addon only in main.ts's addons array
// (as a string) is not enough for definePreview() to pick up its preview
// annotations (e.g. addon-docs's docs.renderer). This was the actual cause
// of definePreview() breaking all Docs pages earlier, not a framework bug.
export default definePreview({
  addons: [addonDocs(), swatchbookAddon()],
  parameters: {
    controls: {
      matchers: {
       color: /(background|color)$/i,
       date: /Date$/i,
      },
    },

    a11y: {
      // 'todo' - show a11y violations in the test UI only
      // 'error' - fail CI on a11y violations
      // 'off' - skip a11y checks entirely
      test: 'todo'
    }
  },
});

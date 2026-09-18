import { definePreview } from '@storybook/tanstack-react';
import addonDocs from '@storybook/addon-docs';
import addonA11y from '@storybook/addon-a11y';
import addonVitest from '@storybook/addon-vitest';
import addonChromatic from '@chromatic-com/storybook';
import swatchbookAddon from '@unpunnyfuns/swatchbook-addon';
import '../src/styles.css';

// definePreview() needs each addon's own preview-composition function called
// here explicitly -- registering an addon only in main.ts's addons array
// (as a string) is not enough for definePreview() to pick up its preview
// annotations. This is what broke Docs pages earlier (missing addonDocs())
// and what left the Accessibility/Interactions/Visual tests panels stuck
// "scan in progress" forever (missing addonA11y()/addonVitest()) -- both
// are the same root cause, not separate bugs.
export default definePreview({
  addons: [addonDocs(), addonA11y(), addonVitest(), addonChromatic(), swatchbookAddon()],
  tags: ['autodocs'],
  parameters: {
    controls: {
      matchers: {
       color: /(background|color)$/i,
       date: /Date$/i,
      },
    },

    docs: {
      codePanel: true,
    },

    a11y: {
      // 'todo' - show a11y violations in the test UI only
      // 'error' - fail CI on a11y violations
      // 'off' - skip a11y checks entirely
      test: 'todo'
    }
  },
});

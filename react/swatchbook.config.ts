import { defineSwatchbookConfig } from '@unpunnyfuns/swatchbook-core';

export default defineSwatchbookConfig({
  resolver: 'tokens/resolver.json',
  default: { theme: 'light' },
  cssVarPrefix: 'ds',
});

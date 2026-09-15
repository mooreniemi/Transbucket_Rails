import { defineConfig } from '@terrazzo/cli';
import css from '@terrazzo/plugin-css';
import tailwind from '@terrazzo/plugin-tailwind';

export default defineConfig({
  tokens: ['./tokens/resolver.json'],
  plugins: [
    css({
      filename: 'tokens.css',
      permutations: [{ input: { theme: 'light' }, prepare: (css) => `:root {\n${css}\n}` }],
    }),
    tailwind({
      template: '../../tailwind.template.css',
      filename: 'tailwind-theme.css',
      theme: {
        /** Tailwind v4 `@theme` namespaces -- @see https://tailwindcss.com/docs/theme#theme-variable-namespaces */
        color: {
          // Glob so new shades (or a new color group under color.*) show up
          // automatically -- add a group here only when a genuinely new
          // color group is introduced, not per-shade.
          black: ['color.black.*'],
          // Replace Tailwind's built-in red/blue/yellow scales with the
          // brand's versions -- see tailwind.template.css for the
          // `--color-*: initial` resets that remove Tailwind's defaults.
          red: ['color.red.*'],
          blue: ['color.blue.*'],
          yellow: ['color.yellow.*'],
        },
        font: {
          sans: 'typography.family.sans',
        },
        spacing: {
          1: 'space.100',
        },
        radius: {
          m: 'radius.100',
        },
      },
    }),
  ],
  // Generated output only -- never hand-edit files in here, they're
  // regenerated from tokens/core/*.json on every dev/build/storybook run
  // (see the `pre*` npm scripts) and are gitignored. Lives under src/ since
  // it's CSS the app consumes directly, not a token spec document.
  outDir: './src/generated/',
  lint: {
    build: { enabled: true },
    rules: {
      'core/valid-color': 'error',
      'core/valid-dimension': 'error',
      'core/valid-font-family': 'error',
      'core/valid-font-weight': 'error',
      'core/valid-duration': 'error',
      'core/valid-cubic-bezier': 'error',
      'core/valid-number': 'error',
      'core/valid-link': 'error',
      'core/valid-boolean': 'error',
      'core/valid-string': 'error',
      'core/valid-stroke-style': 'error',
      'core/valid-border': 'error',
      'core/valid-transition': 'error',
      'core/valid-shadow': 'error',
      'core/valid-gradient': 'error',
      'core/valid-typography': 'error',
      'core/consistent-naming': 'warn'
    }
  }
});

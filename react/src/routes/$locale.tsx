import { useEffect } from 'react';
import { createFileRoute, Outlet } from '@tanstack/react-router';
import { I18nProvider } from 'react-aria-components';
import { PublicHeader } from '#/components/publicHeader';
import { Footer } from '#/components/footer';
import { locales } from '#/generated/paraglide/runtime';

export const Route = createFileRoute('/$locale')({
  component: RouteComponent,
  head: ({ params, matches }) => {
    const locale = params.locale || 'en';
    // Path below /$locale, taken from the deepest match: this layout's own
    // match only knows its own segment (/en), not the page it wraps.
    const leaf = matches[matches.length - 1];
    const rest = leaf.pathname.split('/').filter(Boolean).slice(1).join('/');
    const urlFor = (l: string) => `${SITE_ORIGIN}/${l}${rest ? `/${rest}` : ''}`;

    return {
      title: 'Transbucket',
      meta: [
        {
          property: 'description',
          content: 'Community photo-sharing for transition and gender-affirming procedures, surgeon profiles, and real-world submissions.'
        },
        {
          property: 'og:title',
          content: 'Transbucket'
        },
        {
          property: 'og:description',
          content: 'Community photo-sharing for transition and gender-affirming procedures, surgeon profiles, and real-world submissions.'
        },
        {
          property: 'og:url',
          content: urlFor(locale)
        },
        {
          property: 'og:image',
          // From react/public, so the URL stays the same across builds
          // (unlike imported assets, which get content-hashed names).
          content: `${SITE_ORIGIN}${import.meta.env.BASE_URL}dysphoria3.png`
        },
        { property: 'og:image:width', content: '400' },
        { property: 'og:image:height', content: '400' },
        { name: 'twitter:card', content: 'summary' },
        {
          property: 'og:locale',
          content: locale
        }
      ],
      links: [
        // Each locale's page is canonical to itself; pointing them all at
        // one URL would tell search engines the translations are duplicates.
        { rel: 'canonical', href: urlFor(locale) },
        ...locales.map((l) => ({ rel: 'alternate', hrefLang: l, href: urlFor(l) })),
        { rel: 'alternate', hrefLang: 'x-default', href: urlFor('en') },
      ]
    };
  }
});

const SITE_ORIGIN = 'https://transbucket.com';

const RTL_LOCALES = ['ar'];

function RouteComponent() {
  const { locale } = Route.useParams();
  const currLocale = locale || 'en';
  const dir = RTL_LOCALES.includes(currLocale.split('-')[0]) ? 'rtl' : 'ltr';

  // On <html>, not the wrapper div: popovers and toasts render in portals
  // outside this tree and would otherwise miss the direction.
  useEffect(() => {
    document.documentElement.lang = currLocale;
    document.documentElement.dir = dir;
  }, [currLocale, dir]);

  return (
    <I18nProvider locale={currLocale}>
      <div className="grid grid-cols-1 grid-rows-[auto_1fr_auto] h-svh">
          <PublicHeader locale={currLocale} />
          <main className="overflow-auto bg-slate-50">
              <Outlet />
          </main>
          <Footer locale={currLocale} />
      </div>
    </I18nProvider>
  );
}

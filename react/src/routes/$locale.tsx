import { createFileRoute, Outlet } from '@tanstack/react-router'
import {
  Header,
  HeaderLink,
  HeaderMenu,
  HeaderMenuItem,
  NavVariantContext,
} from '#/components/header';
import { Earth } from 'lucide-react';
import { createLink } from '@tanstack/react-router';
import { Button } from '#/components/button';
import { useContext } from 'react';

export const Route = createFileRoute('/$locale')({
  component: RouteComponent,
})

const iconClasses = "w-4 h-4 fill-yellow-500 inline align-middle";

const TanstackMenuItem = createLink(HeaderMenuItem);
const TanstackMenuLink = createLink(HeaderLink);

interface LocaleSwitcher {
  currentLocale: string;
}

function LocaleSwitcher({ currentLocale }: LocaleSwitcher) {
  return (
    <HeaderMenu label={
        <>
          <Earth className="inline mr-1 align-middle" size="14" />
          <span className="align-middle">{currentLocale}</span>
        </>
      }>
        <TanstackMenuItem to="." params={(prev) => ({ ...prev, locale: 'en' })}>English</TanstackMenuItem>
        <TanstackMenuItem to="." params={(prev) => ({ ...prev, locale: 'de' })}>Deutsch</TanstackMenuItem>
        <TanstackMenuItem to="." params={(prev) => ({ ...prev, locale: 'es' })}>Español</TanstackMenuItem>
        <TanstackMenuItem to="." params={(prev) => ({ ...prev, locale: 'fr' })}>Français</TanstackMenuItem>
        <TanstackMenuItem to="." params={(prev) => ({ ...prev, locale: 'it' })}>Italiano</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'ja'})}>日本語</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'zh-CN'})}>简体中文</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'zh-TW'})}>繁體中文</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'pt-BR'})}>Português (Brasil)</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'nl'})}>Nederlands</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'pl'})}>Polski</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'ru'})}>Русский</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'tr'})}>Türkçe</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'vi'})}>Tiếng Việt</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'ar'})}>العربية</TanstackMenuItem>
        <TanstackMenuItem to='.' params={(prev) => ({ ...prev, locale: 'sv'})}>Svenska</TanstackMenuItem>
    </HeaderMenu>
  )
}

interface HeaderSectionRight {
  locale: string;
}

function HeaderSectionRight({ locale }: HeaderSectionRight) {
  const variant = useContext(NavVariantContext);
  const currentLocale = locale.toUpperCase();

  if (variant === "mobile") {
    return (
      <>
        <TanstackMenuLink to="/$locale/login" params={{ locale }}>Login</TanstackMenuLink>
        <HeaderMenuItem href={`/${locale}/register`}>Register</HeaderMenuItem>
        <LocaleSwitcher currentLocale={currentLocale} />
      </>
    );
  }

  return (
    <>
      <LocaleSwitcher currentLocale={currentLocale} />
      <TanstackMenuLink to="/$locale/login" params={{ locale }}>Login</TanstackMenuLink>
      <Button variant="outline" href="/register">Register</Button>
    </>
  );
}

function FacebookIcon() {
  return (
    <svg
      aria-hidden="true"
      role="img"
      viewBox="0 0 24 24"
      xmlns="http://www.w3.org/2000/svg"
      className={iconClasses}
    >
      <title>Facebook</title>
      <path d="M9.101 23.691v-7.98H6.627v-3.667h2.474v-1.58c0-4.085 1.848-5.978 5.858-5.978.401 0 .955.042 1.468.103a8.68 8.68 0 0 1 1.141.195v3.325a8.623 8.623 0 0 0-.653-.036 26.805 26.805 0 0 0-.733-.009c-.707 0-1.259.096-1.675.309a1.686 1.686 0 0 0-.679.622c-.258.42-.374.995-.374 1.752v1.297h3.919l-.386 2.103-.287 1.564h-3.246v8.245C19.396 23.238 24 18.179 24 12.044c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.628 3.874 10.35 9.101 11.647Z"/>
    </svg>
  );
}

function DiscordIcon() {
  return (
    <svg
      aria-hidden="true"
      role="img"
      viewBox="0 0 24 24"
      xmlns="http://www.w3.org/2000/svg"
      className={iconClasses}
    >
      <title>Discord</title>
      <path d="M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7363 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286zM8.02 15.3312c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9555-2.4189 2.157-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.9555 2.4189-2.1569 2.4189zm7.9748 0c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9554-2.4189 2.1569-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189Z"/>
    </svg>
  );
}

function TwitterIcon() {
  return (
    <svg
      aria-hidden="true"
      role="img"
      viewBox="0 0 24 24"
      xmlns="http://www.w3.org/2000/svg"
      className={iconClasses}
    >
      <title>Twitter</title>
      <path d="M14.234 10.162 22.977 0h-2.072l-7.591 8.824L7.251 0H.258l9.168 13.343L.258 24H2.33l8.016-9.318L16.749 24h6.993zm-2.837 3.299-.929-1.329L3.076 1.56h3.182l5.965 8.532.929 1.329 7.754 11.09h-3.182z"/>
    </svg>
  );
}

function RouteComponent() {
  const { locale } = Route.useParams();
  const currLocale = locale || 'en';

  return (
    <div className="grid grid-cols-1 grid-rows-[auto_1fr_auto] h-svh">
        <Header
            sectionRight={<HeaderSectionRight locale={currLocale} />}
        >
            <HeaderLink href={`/${locale}/newsfeed`}>News</HeaderLink>
            <HeaderLink href={`/${locale}/procedures`}>Procedures</HeaderLink>
            <HeaderLink href={`/${locale}/surgeons`}>Surgeons</HeaderLink>
        </Header>
        <main className="overflow-auto bg-slate-50">
            <Outlet />
        </main>
        <footer className="px-5 py-5 sm:px-10 border-t border-black-200 shadow-[0_-8px_10px_-13px_var(--color-black-300)]">
          <div className="text-sm align-middle flex flex-wrap justify-start gap-4">
            <a href="https://www.facebook.com/transbucket" className="block" target="_blank" rel="noreferrer noopener"><FacebookIcon/><span className="align-middle ml-1">Facebook</span></a>
            <a href="https://twitter.com/TransBucket" className="block" target="_blank" rel="noreferrer noopener"><TwitterIcon/><span className="align-middle ml-1">@Transbucket</span></a>
            <a href="https://discord.gg/fRW4RnPqgv" className="block" target="_blank" rel="noreferrer noopener"><DiscordIcon/><span className="align-middle ml-1">Join us on Discord</span></a>
          </div>
          <div className="grid auto-cols-auto grid-flow-col justify-start gap-2 text-xs mt-2" style={{columnRule: "1px solid var(--color-black-200)"}}>
            <a href={`/${locale}/about`}>About</a>
            <a href={`/${locale}/terms`}>Terms of service</a>
            <a href={`/${locale}/privacy`}>Privacy policy</a>
          </div>
        </footer>
    </div>
  );
}

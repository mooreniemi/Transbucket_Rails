import {
  Header,
  HeaderLink,
  HeaderMenu,
  HeaderMenuItem,
  NavVariantContext,
} from '#/design-system/header';
import { Earth } from 'lucide-react';
import { createLink } from '@tanstack/react-router';
import { Button } from '#/design-system/button';
import { useContext } from 'react';
import { m } from '#/generated/paraglide/messages';

const TanstackMenuItem = createLink(HeaderMenuItem);
const TanstackMenuLink = createLink(HeaderLink);

interface LocaleSwitcher {
  currentLocale: string;
}

function LocaleSwitcher({ currentLocale }: LocaleSwitcher) {
  return (
    <HeaderMenu label={
        <>
          <Earth className="inline me-1 align-middle" size="14" />
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
        <TanstackMenuLink to="/$locale/login" params={{ locale }}>{m['global.buttons.login']()}</TanstackMenuLink>
        <HeaderMenuItem href={`/${locale}/register`}>{m['global.buttons.register']()}</HeaderMenuItem>
        <LocaleSwitcher currentLocale={currentLocale} />
      </>
    );
  }

  return (
    <>
      <LocaleSwitcher currentLocale={currentLocale} />
      <TanstackMenuLink to="/$locale/login" params={{ locale }}>{m['global.buttons.login']()}</TanstackMenuLink>
      <Button variant="outline" href="/register">{m['global.buttons.register']()}</Button>
    </>
  );
}

interface PublicHeader {
  locale: string;
}

export function PublicHeader({ locale }: PublicHeader) {
    return (
        <Header
            sectionRight={<HeaderSectionRight locale={locale} />}
        >
            <HeaderLink href={`/${locale}/newsfeed`}>{m['global.pages.news']()}</HeaderLink>
            <HeaderLink href={`/${locale}/procedures`}>{m['global.pages.procedures']()}</HeaderLink>
            <HeaderLink href={`/${locale}/surgeons`}>{m['global.pages.surgeons']()}</HeaderLink>
        </Header>
    );
}
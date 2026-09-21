import { createFileRoute, Outlet } from '@tanstack/react-router';
import { PublicHeader } from '#/components/publicHeader';
import { Footer } from '#/components/footer';

export const Route = createFileRoute('/$locale')({
  component: RouteComponent,
});

function RouteComponent() {
  const { locale } = Route.useParams();
  const currLocale = locale || 'en';

  return (
    <div className="grid grid-cols-1 grid-rows-[auto_1fr_auto] h-svh">
        <PublicHeader locale={currLocale} />
        <main className="overflow-auto bg-slate-50">
            <Outlet />
        </main>
        <Footer locale={currLocale} />
    </div>
  );
}

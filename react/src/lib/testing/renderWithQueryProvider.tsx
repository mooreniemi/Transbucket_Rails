import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { renderHook, render, type RenderOptions, type RenderHookOptions } from '@testing-library/react';
import { type ReactNode } from 'react';

const createNewQueryClient = () => {
    return new QueryClient({
        defaultOptions: {
            queries: {
                retry: false,
                gcTime: 0
            },
        },
    });
}

export function renderWithQueryProvider(ui: ReactNode, options: RenderOptions & { queryClient?: QueryClient }) {
    const queryClient = options?.queryClient || createNewQueryClient();
    return render(
        <QueryClientProvider client={queryClient}>
            {ui}
        </QueryClientProvider>,
        options
    );
}

export function renderHookWithQueryProvider<Result, Props>(
    callback: (initialProps: Props) => Result,
    options?: RenderHookOptions<Props> & { queryClient?: QueryClient }
){
    const queryClient = options?.queryClient || createNewQueryClient();
    return renderHook(callback, {
        ...options,
        wrapper: ({ children }) => (
            <QueryClientProvider client={queryClient}>
                {options?.wrapper ? <options.wrapper>{children}</options.wrapper> : children}
            </QueryClientProvider>
        ),
    });
}
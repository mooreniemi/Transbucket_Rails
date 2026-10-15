import { beforeAll, afterEach, afterAll } from 'vitest'
import { server } from './src/lib/mocks/mockServer';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

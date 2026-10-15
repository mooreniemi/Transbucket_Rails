import { setupServer } from 'msw/node';
import { userHandlers } from './user';

const handlers = [
  ...userHandlers,
];

export const server = setupServer(...handlers);

import { Hono } from 'hono';
import { auth } from '../auth';

export const authRoute = new Hono()
  .on(['POST', 'GET'], '/*', (c) => {
    return auth.handler(c.req.raw);
  });

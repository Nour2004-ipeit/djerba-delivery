import { Hono } from 'hono';
import { handle } from 'hono/vercel';
import { cors } from 'hono/cors';
import { ordersRoute } from '@/server/routes/orders';
import { driversRoute } from '@/server/routes/drivers';
import { authRoute } from '@/server/routes/auth';
import { restaurantsRoute } from '@/server/routes/restaurants';
import { usersRoute } from '@/server/routes/users';
import { adminRoute } from '@/server/routes/admin';
import { aiRoute } from '@/server/routes/ai';
import { uploadRoute } from '@/server/routes/upload';

const app = new Hono().basePath('/api');

// Middlewares globaux
app.use('*', cors({
  origin: (origin) => origin,
  credentials: true,
  allowHeaders: ['Content-Type', 'Authorization', 'Accept'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
}));

import { passwordResetRoutes } from '@/server/routes/password_reset';

// Enregistrement des sous-routeurs
const routes = app
  .route('/auth', authRoute)
  .route('/password-reset', passwordResetRoutes)
  .route('/orders', ordersRoute)
  .route('/drivers', driversRoute)
  .route('/restaurants', restaurantsRoute)
  .route('/users', usersRoute)
  .route('/admin', adminRoute)
  .route('/ai', aiRoute)
  .route('/upload', uploadRoute);

export const GET = handle(app);
export const POST = handle(app);
export const PUT = handle(app);
export const PATCH = handle(app);
export const DELETE = handle(app);
export const OPTIONS = handle(app);

// Export du type Hono pour le RPC côté client web
export type AppType = typeof routes;

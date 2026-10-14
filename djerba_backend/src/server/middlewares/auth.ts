import { createMiddleware } from 'hono/factory';
import { auth } from '../auth';
import * as fs from 'fs';

export const requireAuth = (allowedRoles?: string[]) => {
  return createMiddleware(async (c, next) => {
    let logStr = `\n=== AUTH MIDDLEWARE ===\n`;
    logStr += `Method: ${c.req.method} | URL: ${c.req.url}\n`;
    logStr += `All Headers: ${JSON.stringify(Object.fromEntries(c.req.raw.headers.entries()))}\n`;
    
    const session = await auth.api.getSession({ headers: c.req.raw.headers });
    logStr += `Session result: ${session ? 'Valid Session' : 'NULL'}\n`;
    
    if (session && session.user) {
        logStr += `User: ${session.user.email} | Role: ${session.user.role}\n`;
    }

    logStr += `=======================\n`;
    
    try {
        fs.appendFileSync('auth-debug.log', logStr);
    } catch (e) {
        console.error('Could not write to auth-debug.log');
    }

    if (!session || !session.user) {
      return c.json({ error: 'Non autorisé. Veuillez vous connecter.' }, 401);
    }

    if (allowedRoles && !allowedRoles.includes(session.user.role as string)) {
      return c.json({ error: 'Accès interdit. Privilèges insuffisants.' }, 403);
    }

    // On injecte l'utilisateur dans le contexte Hono pour les prochaines fonctions
    c.set('user', session.user);
    await next();
  });
};

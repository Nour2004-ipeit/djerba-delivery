import type { Config } from 'drizzle-kit';

export default {
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'sqlite',
  dbCredentials: {
    url: process.env.TURSO_URL ?? 'file:sqlite.db',
    token: process.env.TURSO_AUTH_TOKEN,
  },
} satisfies Config;

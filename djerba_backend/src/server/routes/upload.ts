import { Hono } from 'hono';
import * as fs from 'fs';
import * as path from 'path';

export const uploadRoute = new Hono()
  .post('/', async (c) => {
    try {
      const body = await c.req.parseBody();
      const file = body['image'];

      if (!file || !(file instanceof File)) {
        return c.json({ error: 'No image file uploaded' }, 400);
      }

      // Create public/uploads directory if it doesn't exist
      const uploadsDir = path.join(process.cwd(), 'public', 'uploads');
      if (!fs.existsSync(uploadsDir)) {
        fs.mkdirSync(uploadsDir, { recursive: true });
      }

      // Generate unique filename
      const extension = file.name.split('.').pop() || 'png';
      const filename = `${Date.now()}-${Math.round(Math.random() * 1e9)}.${extension}`;
      const filepath = path.join(uploadsDir, filename);

      // Save file to disk
      const arrayBuffer = await file.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);
      fs.writeFileSync(filepath, buffer);

      // Return public URL
      const reqUrl = new URL(c.req.url);
      const imageUrl = `${reqUrl.origin}/uploads/${filename}`;

      return c.json({ imageUrl }, 200);
    } catch (error) {
      console.error('Upload error:', error);
      return c.json({ error: 'Failed to upload image' }, 500);
    }
  });

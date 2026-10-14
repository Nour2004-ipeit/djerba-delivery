import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';

export const aiRoute = new Hono()
  .get('/image', async (c) => {
    const prompt = c.req.query('prompt');
    const seed = c.req.query('seed');
    if (!prompt) return c.text('Missing prompt', 400);
    
    try {
      const encodedPrompt = encodeURIComponent(prompt + ' high quality food photography professional lighting appetizing');
      const seedParam = seed ? `&seed=${seed}` : '';
      const url = `https://image.pollinations.ai/prompt/${encodedPrompt}?width=800&height=600&nologo=true${seedParam}`;
      
      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        }
      });
      
      if (!response.ok) throw new Error('Pollinations AI failed');
      
      const arrayBuffer = await response.arrayBuffer();
      return c.body(arrayBuffer, 200, {
        'Content-Type': 'image/jpeg',
        'Cache-Control': 'public, max-age=31536000',
        'Access-Control-Allow-Origin': '*'
      });
    } catch (e) {
      return c.text('Error proxying image', 500);
    }
  })
  .post('/generate-image', zValidator('json', z.object({
    prompt: z.string().min(1),
  })), async (c) => {
    const { prompt } = c.req.valid('json');
    const seed = Math.floor(Math.random() * 1000000000);
    // Return our proxy URL to bypass frontend CORS / 403 blocks
    const encodedParam = encodeURIComponent(prompt);
    const reqUrl = new URL(c.req.url);
    const imageUrl = `${reqUrl.origin}/api/ai/image?prompt=${encodedParam}&seed=${seed}`;
    return c.json({ imageUrl }, 200);
  });

const http = require('http');
const fs = require('fs');
const path = require('path');

const APPS = [
  { name: 'Customer App', port: 8080, dir: path.join(__dirname, 'djerba_client_app', 'build', 'web') },
  { name: 'Restaurant Kitchen', port: 8081, dir: path.join(__dirname, 'djerba_restaurant_dashboard', 'build', 'web') },
  { name: 'Courier Driver', port: 8082, dir: path.join(__dirname, 'djerba_driver_app', 'build', 'web') },
  { name: 'Super Admin', port: 8083, dir: path.join(__dirname, 'djerba_admin_dashboard', 'build', 'web') },
];

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2'
};

function createStaticServer(app) {
  const server = http.createServer((req, res) => {
    // If build folder does not exist yet
    if (!fs.existsSync(app.dir)) {
      res.writeHead(503, { 'Content-Type': 'text/html; charset=utf-8', 'Retry-After': '10' });
      res.end(`<!DOCTYPE html><html><head><meta http-equiv="refresh" content="5"><title>${app.name} Building</title><style>body{font-family:sans-serif;background:#0f172a;color:#f8fafc;display:flex;flex-direction:column;align-items:center;justify-content:center;height:100vh;margin:0;}h2{color:#38bdf8;}.loader{margin-top:20px;font-size:14px;color:#94a3b8;}</style></head><body><h2>🔨 ${app.name} is building...</h2><p class="loader">This page will refresh automatically once ready.</p></body></html>`);
      return;
    }

    let file = req.url.split('?')[0];
    if (file === '/' || file === '') file = '/index.html';
    let filePath = path.join(app.dir, file);

    if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
      filePath = path.join(app.dir, 'index.html');
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME[ext] || 'application/octet-stream';

    fs.readFile(filePath, (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end('Not found');
        return;
      }

      if (file.includes('flutter_service_worker.js')) {
        res.writeHead(200, {
          'Content-Type': 'application/javascript; charset=utf-8',
          'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0'
        });
        res.end('self.addEventListener("install", () => self.skipWaiting()); self.addEventListener("activate", () => self.registration.unregister());');
        return;
      }

      res.writeHead(200, {
        'Content-Type': contentType,
        'Access-Control-Allow-Origin': '*',
        'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0',
        'Pragma': 'no-cache',
        'Expires': '0'
      });
      res.end(data);
    });
  });

  server.listen(app.port, '0.0.0.0', () => {
    console.log(`[${app.name}] Live at http://localhost:${app.port}`);
  });

  server.on('error', (err) => {
    console.error(`[${app.name}] Error on port ${app.port}:`, err.message);
  });
}

APPS.forEach(createStaticServer);

// Server for quad_view.html on port 8085
const quadServer = http.createServer((req, res) => {
  fs.readFile(path.join(__dirname, 'quad_view.html'), (err, data) => {
    if (err) {
      res.writeHead(500);
      res.end('Error loading quad_view.html');
      return;
    }
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(data);
  });
});
quadServer.listen(8085, '0.0.0.0', () => {
  console.log(`[Quad View] Live at http://localhost:8085`);
});

console.log('All frontend servers and Quad View initiated.');

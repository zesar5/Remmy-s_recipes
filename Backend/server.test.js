// server.test.js
const request = require('supertest');
const app = require('./server');  // Importa la app exportada

describe('Pruebas del servidor (server.js)', () => {
  // Prueba de una ruta: GET /usuarios (ajusta según tu lógica real)
  test('GET /usuarios debería devolver una lista de usuarios', async () => {
    const response = await request(app).get('/usuarios');
    expect(response.status).toBe(200);
    expect(Array.isArray(response.body)).toBe(true);  // Asumiendo que devuelve un array
    // Si tu ruta devuelve algo diferente, cambia esto (e.g., expect(response.body).toHaveProperty('usuarios'))
  });

  // Prueba de otra ruta: GET /recetas (si existe)
  test('GET /recetas debería devolver una lista de recetas', async () => {
    const response = await request(app).get('/recetas');
    expect(response.status).toBe(200);
    expect(Array.isArray(response.body)).toBe(true);
  });

  // Prueba de middlewares: Verificar que CORS esté funcionando
  test('Middleware CORS debería permitir requests con Origin', async () => {
    const response = await request(app)
      .get('/usuarios')
      .set('Origin', 'http://localhost:3000');  // Simula un request con Origin
    expect(response.headers['access-control-allow-origin']).toBeDefined();
  });

  // Prueba de ruta raíz: GET /
  test('GET / debería devolver algo (ajusta según indexRoutes)', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    // Agrega más assertions según lo que devuelva tu ruta raíz
  });
});
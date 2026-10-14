import { Redis } from '@upstash/redis';

// We will mock this locally if process.env.UPSTASH_REDIS_REST_URL is missing
const redis = process.env.UPSTASH_REDIS_REST_URL 
  ? Redis.fromEnv() 
  : new Redis({ url: 'http://localhost:8079', token: 'mock' });

export class DispatchService {
  // 1. Le livreur met à jour sa position
  static async updateDriverLocation(driverId: string, lat: number, lng: number) {
    try {
      const key = 'active_drivers';
      // Ajoute ou met à jour les coordonnées dans l'index spatial
      await redis.geoadd(key, { longitude: lng, latitude: lat, member: driverId });
      // Met un TTL (Time To Live) de 5 minutes. Si le livreur perd sa 4G, il disparait de la carte.
      await redis.setex(`driver_last_seen:${driverId}`, 300, Date.now().toString());
    } catch (e) {
      console.warn("Redis mock: updateDriverLocation called", driverId);
    }
  }

  // 2. Trouver les livreurs proches pour une commande
  static async findNearbyDrivers(lat: number, lng: number, radiusKm: number = 5) {
    try {
      // GEOSEARCH retourne les IDs triés par distance
      const nearby = await redis.geosearch(
        'active_drivers',
        'FROMLONLAT', lng, lat,
        'BYRADIUS', radiusKm, 'km',
        'WITHDIST', 'ASC'
      );
      return nearby as [string, number][]; // [ ["driver_1", 2.4], ["driver_2", 3.1] ]
    } catch (e) {
      console.warn("Redis mock: findNearbyDrivers called");
      return [];
    }
  }

  // 3. Verrou distribué (Empêcher la concurrence)
  static async lockOrder(orderId: string, driverId: string): Promise<boolean> {
    try {
      // SET NX : Set if Not eXists. Si la clé existe déjà, un autre livreur a pris la course.
      const acquired = await redis.set(`lock:order:${orderId}`, driverId, { nx: true, ex: 10 });
      return acquired !== null;
    } catch (e) {
      console.warn("Redis mock: lockOrder called");
      return true;
    }
  }
}

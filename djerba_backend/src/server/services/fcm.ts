// import admin from 'firebase-admin';
import { db } from '../../db';
import { user } from '../../db/schema';
import { eq } from 'drizzle-orm';

export class FCMService {
  static async sendNotificationToUser(userId: string, title: string, body: string) {
    console.log(`[FCM Mock] Would send to user ${userId}: ${title} - ${body}`);
    return false;
  }
}

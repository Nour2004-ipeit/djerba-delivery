import { Hono } from 'hono';
import { db } from '../../db';
import { user, passwordResetOtps, account } from '../../db/schema';
import { eq, or } from 'drizzle-orm';
import nodemailer from 'nodemailer';
import fs from 'fs';
import path from 'path';
import { auth } from '../auth'; // to use better-auth's password update
import crypto from 'crypto';
import { hashPassword } from 'better-auth/crypto';

export const passwordResetRoutes = new Hono()

  // 1. Demande de réinitialisation
  .post('/request-reset', async (c) => {
    try {
      const body = await c.req.json();
      const identifier = body.identifier; // email ou phone

      if (!identifier) {
        return c.json({ error: "L'identifiant est requis (email ou numéro de téléphone)." }, 400);
      }

      // Trouver l'utilisateur
      const [dbUser] = await db.select().from(user).where(
        or(
          eq(user.email, identifier),
          eq(user.phoneNumber, identifier)
        )
      );

      if (!dbUser) {
        // Pour des raisons de sécurité, on ne dit pas si l'utilisateur existe ou non
        return c.json({ success: true, message: "Si un compte existe, un code a été envoyé." });
      }

      // Générer OTP à 4 chiffres
      const otp = Math.floor(1000 + Math.random() * 9000).toString();
      const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

      // Supprimer les anciens OTPs de cet utilisateur
      await db.delete(passwordResetOtps).where(eq(passwordResetOtps.userId, dbUser.id));

      // Enregistrer le nouvel OTP
      await db.insert(passwordResetOtps).values({
        id: crypto.randomUUID(),
        userId: dbUser.id,
        identifier: dbUser.email, // On envoie toujours à l'email
        otp,
        expiresAt,
      });

      const email = dbUser.email;

      // Envoyer l'e-mail
      if (process.env.SMTP_USER && process.env.SMTP_PASS) {
        const transporter = nodemailer.createTransport({
          service: 'gmail',
          auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
          },
        });

        await transporter.sendMail({
          from: `"Djerba Delivery" <${process.env.SMTP_USER}>`,
          to: email,
          subject: "Réinitialisation de votre mot de passe",
          html: `
              <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
                  <h2 style="color: #008B8B; text-align: center;">Djerba Delivery</h2>
                  <p>Bonjour,</p>
                  <p>Vous avez demandé à réinitialiser votre mot de passe.</p>
                  <p>Voici votre code de vérification :</p>
                  <h1 style="text-align: center; font-size: 40px; color: #333; letter-spacing: 5px;">${otp}</h1>
                  <p style="color: #888; font-size: 12px; text-align: center;">Ce code expirera dans 10 minutes. Ne le partagez avec personne.</p>
              </div>
          `,
        });
        console.log(`✅ Real password reset email sent to ${email}`);
      } else {
        const message = `\n=========================================\n📧 EMAIL TO ${email}:\n"Votre code de réinitialisation de mot de passe est: ${otp}"\n=========================================\n`;
        console.log(message);
        fs.writeFileSync(path.join(process.cwd(), 'LATEST_EMAIL.txt'), message);
      }

      // Renvoyer une réponse masquée pour montrer à quelle adresse ça a été envoyé
      const maskedEmail = email.replace(/(.{2})(.*)(?=@)/,
        (gp1, gp2, gp3) => { 
          for(let i = 0; i < gp3.length; i++) { gp2+= "*"; } return gp2; 
        });

      return c.json({ success: true, email: maskedEmail, message: "Un code a été envoyé." });
    } catch (e) {
      console.error("Erreur request-reset:", e);
      return c.json({ error: "Erreur serveur." }, 500);
    }
  })

  // 2. Vérification et mise à jour du mot de passe
  .post('/verify-reset-otp', async (c) => {
    try {
      const body = await c.req.json();
      const { identifier, otp, newPassword } = body;

      if (!identifier || !otp || !newPassword) {
        return c.json({ error: "L'identifiant, l'OTP et le nouveau mot de passe sont requis." }, 400);
      }

      // Trouver l'utilisateur
      const [dbUser] = await db.select().from(user).where(
        or(
          eq(user.email, identifier),
          eq(user.phoneNumber, identifier)
        )
      );

      if (!dbUser) {
        return c.json({ error: "OTP invalide ou expiré." }, 400); // Éviter de dire "utilisateur non trouvé"
      }

      // Trouver l'OTP
      const [dbOtp] = await db.select().from(passwordResetOtps).where(eq(passwordResetOtps.userId, dbUser.id));

      if (!dbOtp) {
        return c.json({ error: "Aucune demande de réinitialisation trouvée pour ce compte." }, 400);
      }

      if (dbOtp.otp !== otp) {
        return c.json({ error: "Le code est incorrect." }, 400);
      }

      if (new Date() > dbOtp.expiresAt) {
        // Code expiré
        await db.delete(passwordResetOtps).where(eq(passwordResetOtps.id, dbOtp.id));
        return c.json({ error: "Le code a expiré. Veuillez refaire une demande." }, 400);
      }

      // OTP Valide ! Changer le mot de passe manuellement via la BDD
      const hashedPassword = await hashPassword(newPassword);
      await db.update(account)
        .set({ password: hashedPassword })
        .where(eq(account.userId, dbUser.id));

      // Supprimer l'OTP
      await db.delete(passwordResetOtps).where(eq(passwordResetOtps.id, dbOtp.id));

      return c.json({ success: true, message: "Mot de passe réinitialisé avec succès." });
    } catch (e) {
      console.error("Erreur verify-reset-otp:", e);
      return c.json({ error: "Erreur lors de la réinitialisation." }, 500);
    }
  });

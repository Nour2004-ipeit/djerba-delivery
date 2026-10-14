import { betterAuth } from "better-auth";
import fs from "fs";
import path from "path";
import nodemailer from "nodemailer";
import dns from "dns";
import { drizzleAdapter } from "better-auth/adapters/drizzle";

// Force Node.js to use IPv4 for DNS resolution to bypass the ENETUNREACH IPv6 error
dns.setDefaultResultOrder('ipv4first');
import { phoneNumber, bearer, emailOTP } from "better-auth/plugins";
import { db } from "../db";
import * as schema from "../db/schema";

export const auth = betterAuth({
    logger: { level: 'debug' },
    onAPIError: { throw: true },
    advanced: { defaultAccessControl: { session: false } },
    trustedOrigins: ["http://localhost:8080", "http://localhost:8081", "http://localhost:8082", "http://localhost:8083", "http://localhost:8084", "http://localhost:8085", "http://localhost:8086", "http://127.0.0.1:8080", "http://127.0.0.1:8081", "http://127.0.0.1:8082", "http://127.0.0.1:8083", "http://127.0.0.1:8084", "http://127.0.0.1:8085", "http://127.0.0.1:8086"],
    database: drizzleAdapter(db, {
        provider: "sqlite",
        schema: schema,
    }),
    emailAndPassword: {
        enabled: true,
        autoSignIn: true,
    },
    user: {
        additionalFields: {
            role: { type: "string", defaultValue: "client" },
            phoneNumber: { type: "string" },
            phoneNumberVerified: { type: "boolean", defaultValue: false }
        }
    },
    plugins: [
        bearer(),
        phoneNumber({
            otpLength: 4,
            sendOTP: async ({ phoneNumber, code }, request) => {
                // MOCK SMS SENDER FOR LOCAL TESTING
                const message = `\n=========================================\n📲 SMS TO ${phoneNumber}:\n"Votre code de vérification Djerba Delivery est: ${code}"\n=========================================\n`;
                console.log(message);
                
                // Write it to a file so the user can easily see it without terminal access
                fs.writeFileSync(path.join(process.cwd(), 'LATEST_SMS.txt'), message);
            }
        }),
        emailOTP({
            otpLength: 4,
            async sendVerificationOTP({ email, otp, type }, request) {
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
                        subject: "Votre code de vérification",
                        html: `
                            <div style="font-family: Arial, sans-serif; max-width: 500px; margin: auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
                                <h2 style="color: #008B8B; text-align: center;">Djerba Delivery</h2>
                                <p>Bonjour,</p>
                                <p>Voici votre code de vérification pour Djerba Delivery :</p>
                                <h1 style="text-align: center; font-size: 40px; color: #333; letter-spacing: 5px;">${otp}</h1>
                                <p style="color: #888; font-size: 12px; text-align: center;">Ce code expirera bientôt. Ne le partagez avec personne.</p>
                            </div>
                        `,
                    });
                    console.log(`✅ Real email sent to ${email}`);
                } else {
                    // Fallback to local file if credentials aren't set
                    const message = `\n=========================================\n📧 EMAIL TO ${email}:\n"Votre code de vérification Djerba Delivery est: ${otp}"\n=========================================\n`;
                    console.log(message);
                    fs.writeFileSync(path.join(process.cwd(), 'LATEST_EMAIL.txt'), message);
                }
            }
        })
    ]
});

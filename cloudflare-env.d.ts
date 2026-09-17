declare namespace Cloudflare {
  interface Env {
    DB?: D1Database;
    ADMIN_EMAILS?: string;
    STRIPE_SECRET_KEY?: string;
    STRIPE_WEBHOOK_SECRET?: string;
    RESEND_API_KEY?: string;
    EMAIL_FROM?: string;
    AUTOMATION_SECRET?: string;
    BUCKET?: R2Bucket;
  }
}

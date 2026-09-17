# Deployment and operations

Use the existing Site identity in .openai/hosting.json. Do not create a replacement Site. The repository is a managed Sites checkout with DB and BUCKET bindings.

## Required hosted secrets

ADMIN_EMAILS: comma-separated authorised family administrator emails. Already configured for the Site owner.
STRIPE_SECRET_KEY and STRIPE_WEBHOOK_SECRET: use test credentials first; never expose them in browser code.
RESEND_API_KEY and EMAIL_FROM: verified transactional sender.
AUTOMATION_SECRET: a strong shared secret for the scheduler endpoint.

Keep .env local and ignored. The .env.example lists keys only. Use the Sites environment-variable connector for hosted values, then publish the saved version to apply the revision.

## Payments

Webhook URL: /api/stripe/webhook. Subscribe to checkout.session.completed, checkout.session.async_payment_succeeded, checkout.session.expired, checkout.session.async_payment_failed and charge.refunded. Verify signed events and amounts in test mode. Wallet methods depend on the connected Stripe account and supported device. Live refunds are completed in Stripe and reflected by the verified webhook.

Demo mode intentionally bypasses all real payment and email delivery. It does not collect card numbers. Do not disable demo mode until policies, venue details, child eligibility, live products and events, provider credentials and commercial readiness are approved.

## Email scheduling

Call POST /api/automation/run with Authorization: Bearer AUTOMATION_SECRET from a trusted scheduler. This releases safely expired reservations and dispatches due email outbox records. No scheduler is provisioned in this build. Do not expose the secret in frontend requests. Demo emails have status demo and are never sent. Provider retry uses an idempotency key.

## Media

Admin uploads support JPEG, PNG, WebP and PDF up to 10 MB. Public files may be used for approved content. Leave public disabled for private photographs/photobooks, and assign the correct customer. Back up database and object storage through the hosting provider's supported procedures; source control is not a customer-data backup.

## Schema and publication

Generate and inspect Drizzle migrations. Applied migration files are immutable. Build through the Sites build helper, commit and push the exact source, package the output, save the version, then deploy privately unless sharing is explicitly authorised. A successful compilation alone is not evidence of a successful deployment.

## Before public launch

Complete the founder checklist; replace demo inventory; approve all legal pages; connect and test payments, authentication expectations and email; configure retention/deletion processes; review physical access and food safety; verify search metadata, geographic contact information and indexing. No real residential address should be placed in public content.

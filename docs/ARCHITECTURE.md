# Nimontron implementation

## Information architecture

Public discovery: Home; Our Story; Meet Sanzida; Meet the Family; Supper Club; Food and Menu; Upcoming Events with list/calendar filters; event detail and booking; Cooking with Sanzida; Photography; Clothing; Membership; Visit Bangladesh with interactive map and consent-aware enquiries; Gallery; Journal and stories; FAQs; Private Events; Contact; Gift Cards.

Commerce: Shop, category and product pages; authenticated wishlist; persistent anonymous/account basket; checkout; confirmation; account overview, bookings, orders, photography, membership, gift cards and preferences.

Family operations: Role-gated admin, events, booking records, guest sheets/check-in, orders, products, inventory, memberships, photography/photobook tracking, editorial content, legal copy, enquiries, waitlists, gift balances, promo codes, email outbox, media upload, audit log and founder checklist.

## Visual system

Forest #123c30, ivory #f7f4eb, gold #d7b875 and terracotta #a34432. Cormorant Garamond display and DM Sans body, locally served with licences. Large serif headlines, cinematic imagery, restrained motion, responsive shared components, keyboard support, Radix/Shadcn primitives and reduced-motion rules.

## Runtime and data

TypeScript, React 19 and Next.js App Router APIs on the hosting platform's Vinext/Cloudflare Workers starter. The platform currently uses a compatibility layer, not a standalone Next.js Node deployment. Existing pinned dependencies were preserved. Cloudflare D1 (SQLite) is used instead of PostgreSQL because this host supplies managed D1 and does not support raw TCP databases. Drizzle owns schema migrations; runtime queries use prepared D1 statements. R2 stores uploaded public media and private customer files.

26 relational tables cover profiles, memberships, locations, events, products, variants, carts, wishlists, orders, line items, bookings, guests, photography, reservations, gifts, promos, content, enquiries, waitlist, email outbox, audit, webhooks, rate limits and media. Menus and detailed editorial options use validated JSON in related records.

## Authentication and security

Platform ChatGPT sign-in identifies customers. Server-side role checks authorise every private operation. Owner admin emails are provided only as a hosted secret. Public customer email/password or social identity login is not supplied by this hosting path and would require a separately supported identity integration before a public commercial rollout.

Public settings omit the residential address. Customer records and media require ownership or an authorised operational role. Mutations check origin and use rate limits. Card data never enters this site. Webhook signatures are verified using HMAC SHA-256, a timestamp tolerance and event deduplication. All financial calculations are server-side integer pence.

## Reservations and pricing

Only the best applicable ticket percentage is applied. Membership comes from the authenticated account. Children's tickets remain fixed. Clothing and photographs are separate additions. A full bundle can use a configured saving if it is better than the ticket discount, without stacking.

Checkout recomputes prices and atomically reserves seats and stock with conditional updates and transaction guards. Concurrent insufficient availability rolls the batch back. Gift-card debit occurs in the same transaction. Unique order IDs provide checkout idempotency. Paid confirmation occurs only after verified provider completion; demo confirmation records no real payment.

## External services

Stripe Checkout REST adapter and verified webhook endpoint are implemented. Credentials, live end-to-end testing and approved business details are required before live payments. Resend-compatible email dispatch and durable scheduled outbox are implemented. A verified sender, provider credentials and a secured scheduler calling POST /api/automation/run are required for automatic delivery. The preview does not send mail or share travel leads.

## Content limitations before commercial launch

Events, products and stock are demonstrations. Food images are illustrative; cultural references have documented licences. No genuine customer testimonials are fabricated. Founder portraits, personal history, final product data, legal approval, addresses and partner verification remain founder inputs. The admin manages operational records and structured editorial entries; some bespoke marketing layout prose remains source-managed. Business analytics are a foundational operational overview rather than a full accounting or CRM system.

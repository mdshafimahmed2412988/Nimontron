CREATE TABLE `audit_logs` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`action` text NOT NULL,
	`entity_id` text NOT NULL,
	`details` text NOT NULL,
	`created_at` text NOT NULL
);
--> statement-breakpoint
CREATE TABLE `bookings` (
	`id` text PRIMARY KEY NOT NULL,
	`reference` text NOT NULL,
	`user_id` text NOT NULL,
	`event_id` text NOT NULL,
	`order_id` text NOT NULL,
	`adults` integer NOT NULL,
	`children` integer NOT NULL,
	`status` text NOT NULL,
	`total` integer NOT NULL,
	`details` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `profiles`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `bookings_reference_unique` ON `bookings` (`reference`);--> statement-breakpoint
CREATE INDEX `idx_bookings_event` ON `bookings` (`event_id`);--> statement-breakpoint
CREATE INDEX `idx_bookings_user` ON `bookings` (`user_id`);--> statement-breakpoint
CREATE INDEX `idx_bookings_order` ON `bookings` (`order_id`);--> statement-breakpoint
CREATE TABLE `cart_items` (
	`id` text PRIMARY KEY NOT NULL,
	`owner` text NOT NULL,
	`kind` text NOT NULL,
	`reference_id` text NOT NULL,
	`quantity` integer NOT NULL,
	`data` text DEFAULT '{}' NOT NULL,
	`created_at` text NOT NULL
);
--> statement-breakpoint
CREATE INDEX `idx_cart_owner` ON `cart_items` (`owner`);--> statement-breakpoint
CREATE TABLE `content` (
	`id` text PRIMARY KEY NOT NULL,
	`type` text NOT NULL,
	`title` text NOT NULL,
	`body` text NOT NULL,
	`image` text DEFAULT '' NOT NULL,
	`published` integer DEFAULT 1 NOT NULL,
	`data` text DEFAULT '{}' NOT NULL
);
--> statement-breakpoint
CREATE INDEX `idx_content_type` ON `content` (`type`);--> statement-breakpoint
CREATE TABLE `enquiries` (
	`id` text PRIMARY KEY NOT NULL,
	`type` text NOT NULL,
	`user_id` text,
	`name` text NOT NULL,
	`email` text NOT NULL,
	`data` text NOT NULL,
	`status` text DEFAULT 'new' NOT NULL,
	`consent` integer DEFAULT 0 NOT NULL,
	`created_at` text NOT NULL
);
--> statement-breakpoint
CREATE INDEX `idx_enquiries_type_created` ON `enquiries` (`type`,`created_at`);--> statement-breakpoint
CREATE TABLE `events` (
	`id` text PRIMARY KEY NOT NULL,
	`slug` text NOT NULL,
	`title` text NOT NULL,
	`type` text NOT NULL,
	`date` text NOT NULL,
	`start` text NOT NULL,
	`end` text NOT NULL,
	`capacity` integer NOT NULL,
	`reserved` integer DEFAULT 0 NOT NULL,
	`price` integer NOT NULL,
	`image` text NOT NULL,
	`description` text NOT NULL,
	`region` text NOT NULL,
	`theme` text NOT NULL,
	`status` text DEFAULT 'open' NOT NULL,
	`menu` text DEFAULT '[]' NOT NULL,
	`details` text DEFAULT '{}' NOT NULL,
	`demo` integer DEFAULT 1 NOT NULL,
	`location_id` text NOT NULL,
	FOREIGN KEY (`location_id`) REFERENCES `locations`(`id`) ON UPDATE no action ON DELETE no action,
	CONSTRAINT "event_capacity_valid" CHECK("events"."reserved" >= 0 and "events"."reserved" <= "events"."capacity"),
	CONSTRAINT "event_price_valid" CHECK("events"."price" >= 0)
);
--> statement-breakpoint
CREATE UNIQUE INDEX `events_slug_unique` ON `events` (`slug`);--> statement-breakpoint
CREATE INDEX `idx_events_date_type` ON `events` (`date`,`type`);--> statement-breakpoint
CREATE TABLE `gift_cards` (
	`code` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`order_id` text NOT NULL,
	`value` integer NOT NULL,
	`balance` integer NOT NULL,
	`status` text NOT NULL,
	`recipient` text NOT NULL,
	`created_at` text NOT NULL,
	`demo` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `profiles`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON UPDATE no action ON DELETE no action,
	CONSTRAINT "gift_balance_valid" CHECK("gift_cards"."balance" >= 0)
);
--> statement-breakpoint
CREATE INDEX `idx_gift_user` ON `gift_cards` (`user_id`);--> statement-breakpoint
CREATE TABLE `operation_guards` (
	`id` text PRIMARY KEY NOT NULL,
	`ok` integer NOT NULL,
	CONSTRAINT "operation_valid" CHECK("operation_guards"."ok"=1)
);
--> statement-breakpoint
CREATE TABLE `booking_guests` (
	`id` text PRIMARY KEY NOT NULL,
	`booking_id` text NOT NULL,
	`name` text NOT NULL,
	`ticket_type` text NOT NULL,
	`discount` text NOT NULL,
	`price` integer NOT NULL,
	`details` text NOT NULL,
	`checked_in` integer DEFAULT 0 NOT NULL,
	FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `idx_guests_booking` ON `booking_guests` (`booking_id`);--> statement-breakpoint
CREATE TABLE `locations` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`public_area` text NOT NULL,
	`private_address` text DEFAULT '' NOT NULL,
	`details` text DEFAULT '{}' NOT NULL
);
--> statement-breakpoint
CREATE TABLE `media` (
	`id` text PRIMARY KEY NOT NULL,
	`owner` text NOT NULL,
	`key` text NOT NULL,
	`content_type` text NOT NULL,
	`size` integer NOT NULL,
	`public` integer DEFAULT 0 NOT NULL,
	`caption` text NOT NULL,
	`created_at` text NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `media_key_unique` ON `media` (`key`);--> statement-breakpoint
CREATE TABLE `memberships` (
	`user_id` text PRIMARY KEY NOT NULL,
	`status` text NOT NULL,
	`expires_at` text,
	`details` text DEFAULT '{}' NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `profiles`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `order_items` (
	`id` text PRIMARY KEY NOT NULL,
	`order_id` text NOT NULL,
	`kind` text NOT NULL,
	`reference_id` text NOT NULL,
	`name` text NOT NULL,
	`quantity` integer NOT NULL,
	`price` integer NOT NULL,
	`data` text NOT NULL,
	FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `idx_order_items_order` ON `order_items` (`order_id`);--> statement-breakpoint
CREATE TABLE `orders` (
	`id` text PRIMARY KEY NOT NULL,
	`reference` text NOT NULL,
	`user_id` text NOT NULL,
	`status` text NOT NULL,
	`total` integer NOT NULL,
	`currency` text DEFAULT 'GBP' NOT NULL,
	`contact` text NOT NULL,
	`delivery` text NOT NULL,
	`payment_id` text,
	`created_at` text NOT NULL,
	`demo` integer NOT NULL,
	`expires_at` integer NOT NULL,
	`gift_code` text,
	`gift_applied` integer DEFAULT 0 NOT NULL,
	`promo_code` text,
	FOREIGN KEY (`user_id`) REFERENCES `profiles`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `orders_reference_unique` ON `orders` (`reference`);--> statement-breakpoint
CREATE INDEX `idx_orders_user_created` ON `orders` (`user_id`,`created_at`);--> statement-breakpoint
CREATE INDEX `idx_orders_status_expires` ON `orders` (`status`,`expires_at`);--> statement-breakpoint
CREATE TABLE `email_outbox` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text,
	`order_id` text,
	`template` text NOT NULL,
	`recipient` text NOT NULL,
	`subject` text NOT NULL,
	`body` text NOT NULL,
	`status` text DEFAULT 'queued' NOT NULL,
	`scheduled_at` text NOT NULL,
	`attempts` integer DEFAULT 0 NOT NULL,
	`created_at` text NOT NULL
);
--> statement-breakpoint
CREATE INDEX `idx_outbox_status_schedule` ON `email_outbox` (`status`,`scheduled_at`);--> statement-breakpoint
CREATE TABLE `photography_orders` (
	`id` text PRIMARY KEY NOT NULL,
	`booking_id` text NOT NULL,
	`user_id` text NOT NULL,
	`status` text DEFAULT 'Awaiting event' NOT NULL,
	`photobook_status` text DEFAULT 'Not started' NOT NULL,
	`marketing_consent` integer DEFAULT 0 NOT NULL,
	`private_consent` integer NOT NULL,
	`gallery_key` text,
	`notes` text DEFAULT '' NOT NULL,
	FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`user_id`) REFERENCES `profiles`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `idx_photography_user` ON `photography_orders` (`user_id`);--> statement-breakpoint
CREATE TABLE `products` (
	`id` text PRIMARY KEY NOT NULL,
	`slug` text NOT NULL,
	`name` text NOT NULL,
	`category` text NOT NULL,
	`price` integer NOT NULL,
	`sale_price` integer,
	`image` text NOT NULL,
	`description` text NOT NULL,
	`story` text NOT NULL,
	`details` text DEFAULT '{}' NOT NULL,
	`featured` integer DEFAULT 0 NOT NULL,
	`active` integer DEFAULT 1 NOT NULL,
	`demo` integer DEFAULT 1 NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `products_slug_unique` ON `products` (`slug`);--> statement-breakpoint
CREATE INDEX `idx_products_category_active` ON `products` (`category`,`active`);--> statement-breakpoint
CREATE TABLE `profiles` (
	`id` text PRIMARY KEY NOT NULL,
	`email` text NOT NULL,
	`name` text NOT NULL,
	`role` text DEFAULT 'customer' NOT NULL,
	`preferences` text DEFAULT '{}' NOT NULL,
	`created_at` text NOT NULL
);
--> statement-breakpoint
CREATE INDEX `idx_profiles_email` ON `profiles` (`email`);--> statement-breakpoint
CREATE TABLE `promo_codes` (
	`code` text PRIMARY KEY NOT NULL,
	`percent` integer NOT NULL,
	`active` integer DEFAULT 1 NOT NULL,
	`expires_at` text NOT NULL,
	`scope` text DEFAULT 'tickets' NOT NULL
);
--> statement-breakpoint
CREATE TABLE `rate_limits` (
	`key` text PRIMARY KEY NOT NULL,
	`count` integer NOT NULL,
	`window` integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE `reservations` (
	`id` text PRIMARY KEY NOT NULL,
	`order_id` text NOT NULL,
	`kind` text NOT NULL,
	`resource_id` text NOT NULL,
	`quantity` integer NOT NULL,
	`released` integer DEFAULT 0 NOT NULL,
	FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `idx_reservations_order` ON `reservations` (`order_id`);--> statement-breakpoint
CREATE TABLE `settings` (
	`key` text PRIMARY KEY NOT NULL,
	`value` text NOT NULL
);
--> statement-breakpoint
CREATE TABLE `variants` (
	`id` text PRIMARY KEY NOT NULL,
	`product_id` text NOT NULL,
	`label` text NOT NULL,
	`size` text NOT NULL,
	`colour` text NOT NULL,
	`stock` integer NOT NULL,
	`reserved` integer DEFAULT 0 NOT NULL,
	`price` integer,
	FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON UPDATE no action ON DELETE no action,
	CONSTRAINT "variant_stock_valid" CHECK("variants"."reserved" >= 0 and "variants"."reserved" <= "variants"."stock")
);
--> statement-breakpoint
CREATE INDEX `idx_variants_product_id` ON `variants` (`product_id`);--> statement-breakpoint
CREATE TABLE `waitlist` (
	`id` text PRIMARY KEY NOT NULL,
	`event_id` text NOT NULL,
	`name` text NOT NULL,
	`email` text NOT NULL,
	`seats` integer NOT NULL,
	`preferences` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `idx_waitlist_event_email` ON `waitlist` (`event_id`,`email`);--> statement-breakpoint
CREATE TABLE `webhook_events` (
	`id` text PRIMARY KEY NOT NULL,
	`type` text NOT NULL,
	`created_at` text NOT NULL
);
--> statement-breakpoint
CREATE TABLE `wishlists` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`product_id` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `profiles`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `idx_wishlist_unique` ON `wishlists` (`user_id`,`product_id`);
# Student Nest Web Admin Documentation

This document describes the Student Nest web management site end to end: purpose, architecture, routes, screens, permissions, data flows, calculations, deployment, operations, and known limitations.

## 1. Purpose

The web admin dashboard is the browser-based management interface for Student Nest. It is used by trusted admins to manage:

- landlord accounts
- property approvals
- listing status and expiry
- manual listing payments
- admin accounts
- admin activity logs
- platform overview metrics

The mobile app is for students and landlords. The web dashboard is for internal operations because admin workflows need tables, review tools, account controls, logs, and larger detail views.

## 2. Live And Local URLs

Production Render backend:

```text
https://student-nest-api.onrender.com
```

Production admin website:

```text
https://student-nest-api.onrender.com/admin/
```

Production API base:

```text
https://student-nest-api.onrender.com/api
```

Local admin website:

```text
http://localhost:5000/admin
```

Local API base:

```text
http://localhost:5000/api
```

## 3. Project Location

The web admin is inside the Node backend project:

```text
StudentNest/
  src/
  public/admin/
  database/
  scripts/
  package.json
```

The admin frontend is served as static files from:

```text
StudentNest/public/admin
```

The backend serves it through Express:

```js
app.use(express.static(path.join(__dirname, '../public')));

app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/admin/index.html'));
});
```

## 4. Runtime Architecture

The system has four main parts:

- Express server: `StudentNest/src/app.js`
- PostgreSQL database: managed by Render in production
- Static admin frontend: `StudentNest/public/admin`
- Cloudinary integration: used for property photo storage

The admin frontend talks to the backend using same-origin API calls such as:

```text
/api/admin/stats
/api/admin/landlords
/api/admin/properties
```

Because the admin website and API are served from the same Render service, the frontend does not need a separate public API host setting.

## 5. Backend Startup

Main file:

```text
StudentNest/src/app.js
```

Startup sequence:

1. Loads environment variables with `dotenv`.
2. Creates an Express app.
3. Applies security middleware with `helmet`.
4. Enables CORS.
5. Enables JSON and form-body parsing:

```js
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
```

6. Serves static files from `StudentNest/public`.
7. Mounts API routes.
8. Connects to PostgreSQL.
9. Ensures admin logs table exists.
10. Ensures admin access levels exist.
11. Starts the listing expiry background job.

## 6. Environment Variables

Required production variables:

```env
DATABASE_URL=
JWT_SECRET=
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
```

Optional/local database variables:

```env
DB_HOST=
DB_PORT=
DB_NAME=
DB_USER=
DB_PASSWORD=
DB_SSL=false
```

Admin creation variables for script-based setup:

```env
ADMIN_FULL_NAME=
ADMIN_PHONE=
ADMIN_EMAIL=
ADMIN_PASSWORD=
```

Database connection behavior:

- If `DATABASE_URL` exists, it is used.
- If `DATABASE_URL` does not exist, the backend uses `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD`.
- SSL is enabled for `DATABASE_URL` unless `DB_SSL=false`.

## 7. Database Schema

Schema file:

```text
StudentNest/database/schema.sql
```

Apply schema:

```bash
npm run db:schema
```

Main tables:

- `users`
- `schools`
- `properties`
- `rooms`
- `photos`
- `payments`
- `admin_logs`

### 7.1 users

Stores landlords and admins.

Important fields:

- `id`: UUID primary key
- `full_name`
- `phone`: unique
- `email`
- `password_hash`
- `role`: `landlord` or `admin`
- `is_approved`
- `access_level`: `owner`, `manager`, or null
- `created_at`

Admin meaning:

- `role = 'admin'`
- `access_level = 'owner'` means full admin-account control
- `access_level = 'manager'` means operational admin access

Landlord meaning:

- `role = 'landlord'`
- `is_approved = false` means pending/suspended
- `is_approved = true` means approved

### 7.2 schools

Stores schools/campuses used for property proximity.

Seeded schools:

- UNZA
- Copperbelt University
- Mulungushi University
- Levy Mwanawasa Medical University

### 7.3 properties

Stores property listings.

Important fields:

- `landlord_id`
- `title`
- `description`
- `address`
- `latitude`
- `longitude`
- `nearest_school_id`
- `distance_from_school`
- `amenities`
- `is_approved`
- `is_active`
- `listing_expires_at`
- `view_count`
- `contact_click_count`

Visibility logic for student-facing APIs:

```text
visible = is_approved = true
       AND is_active = true
       AND (listing_expires_at IS NULL OR listing_expires_at > NOW())
```

### 7.4 rooms

Stores room types for a property.

Important fields:

- `property_id`
- `room_type`
- `price_per_month`
- `students_per_room`
- `total_rooms`
- `available_rooms`

### 7.5 photos

Stores Cloudinary photo URLs.

Important fields:

- `property_id`
- `url`
- `is_cover`

### 7.6 payments

Stores manual listing payment records.

Important fields:

- `landlord_id`
- `property_id`
- `amount`
- `payment_method`
- `mobile_money_provider`
- `bank_name`
- `payment_reference`
- `duration_months`
- `status`: `pending`, `confirmed`, or `failed`
- `paid_at`
- `expires_at`

### 7.7 admin_logs

Stores audit records for admin actions.

Important fields:

- `admin_id`
- `admin_access_level`
- `action`
- `entity_type`
- `entity_id`
- `status`
- `message`
- `metadata`
- `ip_address`
- `user_agent`
- `created_at`

## 8. Authentication And Session Behavior

Login endpoint:

```text
POST /api/auth/login
```

Login accepts:

```json
{
  "phone": "0978006839",
  "password": "password"
}
```

Successful login returns:

```json
{
  "message": "Login successful",
  "token": "jwt-token",
  "user": {
    "id": "...",
    "full_name": "...",
    "phone": "...",
    "email": "...",
    "role": "admin",
    "access_level": "owner"
  }
}
```

JWT payload:

```json
{
  "id": "user-id",
  "role": "admin",
  "access_level": "owner"
}
```

JWT backend expiry:

```text
7 days
```

Admin frontend idle timeout:

```text
30 minutes
```

Frontend session storage keys:

```text
studentNestAdminToken
studentNestAdminUser
studentNestAdminLastActive
```

Idle timeout calculation:

```text
idle_time_ms = Date.now() - studentNestAdminLastActive
expired = idle_time_ms > 30 * 60 * 1000
```

Admin activity resets the timer on:

- click
- keydown
- pointermove
- scroll
- touchstart
- API request

On refresh:

- if token exists
- user role is `admin`
- and idle timeout has not expired

the dashboard opens directly without returning to the login page.

## 9. Access Control

All `/api/admin/*` routes use:

```js
router.use(verifyToken, isAdmin);
```

`verifyToken` checks:

```text
Authorization: Bearer <token>
```

`isAdmin` checks:

```text
req.user.role === 'admin'
```

### Owner Admin

Owner admins can:

- create admin accounts
- delete manager admins
- change admin access levels
- view all admin stats
- approve/suspend landlords
- approve/reject/delete properties
- record payments
- view logs

Owner admins cannot be deleted through the admin UI.

### Manager Admin

Manager admins can:

- perform operational review work
- approve/suspend landlords
- approve/reject/delete properties
- record payments
- view logs
- view their own admin stats

Manager admins cannot:

- create admins
- delete admins
- change admin access levels
- view other admins' stats

## 10. Admin Frontend File Organization

```text
StudentNest/public/admin/
  index.html
  styles.css
  app.js
  assets/
  css/
    01-base.css
    02-layout.css
    03-accounts.css
    04-panels-tables.css
    05-modals-details.css
    06-photos-viewer.css
    07-responsive.css
  js/
    00-loader.js
    01-state.js
    02-core.js
    03-overview-landlords.js
    04-properties.js
    05-payments-logs.js
    06-accounts.js
    07-data-actions.js
    08-detail-helpers.js
    09-admin-stats-page.js
    10-details.js
    11-events-main.js
    12-form-events.js
    13-document-actions.js
    14-boot.js
  partials/
    login.html
    sidebar.html
    overview.html
    landlords.html
    properties.html
    payments.html
    logs.html
    accounts.html
    modals.html
    payment-photo-modals.html
```

### Loader Sequence

`00-loader.js` does two things:

1. Loads HTML partials into the shell.
2. Loads JavaScript files in order.

The load order matters because later files depend on globals from earlier files.

## 11. UI Layout

The dashboard uses:

- fixed left sidebar
- independently scrolling main content area
- Inter font
- Student Nest blue branding
- white cards with subtle borders and shadows

Sidebar:

- fixed to the left
- height is `100vh`
- navigation remains visible while main content scrolls
- profile and logout button stay at the bottom

Main content:

- has left padding/margin to account for sidebar width
- scrolls independently
- avoids horizontal overflow

## 12. Dashboard Sections

### 12.1 Login

Partial:

```text
partials/login.html
```

Behavior:

- phone input uses `autocomplete="username"`
- password input uses `type="password"`
- submit is handled by JavaScript
- successful admin login stores token and user in local storage

Fallback behavior:

- accidental form POST to `/admin/` serves the admin page instead of exposing raw token JSON

### 12.2 Overview

Partial:

```text
partials/overview.html
```

Shows:

- platform metrics
- recent activity
- quick actions

Data sources:

```text
GET /api/admin/stats
GET /api/admin/landlords
GET /api/admin/properties
GET /api/admin/payments
```

Quick actions:

- Review landlords
- Review properties
- Check payments

Clicking a quick action changes the active tab.

### 12.3 Landlords

Partial:

```text
partials/landlords.html
```

Data source:

```text
GET /api/admin/landlords
```

Admin actions:

```text
PATCH  /api/admin/landlords/:id
DELETE /api/admin/landlords/:id
```

Visible columns:

- landlord name
- phone/email
- property count
- status
- created date
- actions

Search calculation:

```text
haystack = full_name + phone + email
matches = haystack.toLowerCase().includes(search.toLowerCase())
```

Status calculation:

```text
status = is_approved ? 'approved' : 'pending'
```

Property count calculation:

```text
landlord_property_count =
  count(properties where property.landlord_id === landlord.id)
```

### 12.4 Properties

Partial:

```text
partials/properties.html
```

Data source:

```text
GET /api/admin/properties
```

Backend joins:

- properties
- landlords
- schools
- room count
- photo count
- photo list

Room type count calculation:

```sql
SELECT property_id, COUNT(*) AS room_types
FROM rooms
GROUP BY property_id
```

Photo count calculation:

```sql
SELECT property_id, COUNT(*) AS photo_count
FROM photos
GROUP BY property_id
```

Photo list calculation:

```sql
JSON_AGG(
  JSON_BUILD_OBJECT(
    'id', id,
    'url', url,
    'is_cover', is_cover
  )
  ORDER BY is_cover DESC, id ASC
)
```

Search calculation:

```text
haystack = title + address + landlord_name + school_name
matches = haystack.toLowerCase().includes(search.toLowerCase())
```

Property status calculation in admin UI:

```text
if is_active is false:
  status = 'inactive'
else:
  status = is_approved ? 'approved' : 'pending'
```

Sort calculations:

```text
newest:  created_at descending
oldest:  created_at ascending
updated: updated_at descending, falling back to created_at
```

Completeness hints:

```text
if photo_count == 0 -> "No photos"
if room_types == 0 -> "No rooms"
if address/latitude/longitude missing -> "Incomplete address"
if nearest_school_id and school_name missing -> "No school link"
if no hints -> "Ready for review"
```

Expiry calculation:

```text
if listing_expires_at is null:
  status = 'pending'
  label = 'No expiry set'
  countdown = 'Payment needed'

else if listing_expires_at <= now:
  status = 'inactive'
  label = 'Expired'
  countdown = 'Expired <date>'

else:
  diff_ms = listing_expires_at - now
  days = floor(diff_ms / (24 * 60 * 60 * 1000))
  hours = floor((diff_ms / (60 * 60 * 1000)) % 24)
  isSoon = days < 7
  status = isSoon ? 'pending' : 'approved'
  label = isSoon ? 'Expiring soon' : 'Active'
  countdown = days > 0 ? '<days>d <hours>h left' : '<hours>h left'
```

Countdown refresh:

```text
Every 60 seconds while active tab is Properties.
```

### 12.5 Payments

Partial:

```text
partials/payments.html
```

Data source:

```text
GET /api/admin/payments
```

Manual payment creation:

```text
POST /api/admin/payments
```

Supported methods:

- mobile money
- bank transfer
- cash
- other

Mobile money providers:

- MTN
- Airtel
- Zamtel

Payment search calculation:

```text
haystack = landlord_name + property_title + payment_method + payment_reference
matches = haystack.toLowerCase().includes(search.toLowerCase())
```

Payment status filter:

```text
payment_status = payment.status || 'pending'
matches = selected_status == 'all' OR payment_status == selected_status
```

Payment expiry calculation:

```js
paid_at = new Date()
expires_at = new Date()
expires_at.setMonth(expires_at.getMonth() + (duration_months || 12))
```

When a payment is saved:

1. Backend validates the selected property exists.
2. Backend resolves the true `landlord_id` from the property.
3. If provided landlord does not match property landlord, request fails.
4. Payment is inserted.
5. Property is activated.
6. Property `listing_expires_at` is set to payment expiry.
7. Admin log is recorded.

Property activation query:

```sql
UPDATE properties
SET is_active = true,
    listing_expires_at = $1
WHERE id = $2
```

Confirmed revenue includes only confirmed payments:

```sql
SELECT COALESCE(SUM(amount), 0)
FROM payments
WHERE status = 'confirmed'
```

### 12.6 Logs

Partial:

```text
partials/logs.html
```

Data source:

```text
GET /api/admin/logs
```

Backend filter inputs:

- `search`
- `action`
- `entityType`
- `status`
- `dateFrom`
- `dateTo`
- `limit`

Search condition:

```sql
message ILIKE search
OR action ILIKE search
OR entity_type ILIKE search
OR entity_id ILIKE search
OR metadata::text ILIKE search
```

Date range calculation:

```sql
created_at >= dateFrom
created_at < (dateTo::date + INTERVAL '1 day')
```

Limit calculation:

```js
safeLimit = Math.min(Math.max(Number(limit) || 100, 1), 500)
```

This means:

- default limit is 100
- minimum limit is 1
- maximum limit is 500

Logged actions include:

- `landlord_approved`
- `landlord_suspended`
- `landlord_updated`
- `landlord_deleted`
- `landlord_password_reset`
- `property_approved`
- `property_rejected`
- `property_deleted`
- `payment_recorded`
- `admin_created`
- `admin_deleted`
- `admin_access_updated`
- `admin_profile_updated`

### 12.7 Accounts

Partial:

```text
partials/accounts.html
```

Data sources:

```text
GET   /api/admin/profile
GET   /api/admin/admins
GET   /api/admin/admins/:id/details
PATCH /api/admin/profile
POST  /api/admin/create-admin
PATCH /api/admin/admins/:id/access
DELETE /api/admin/admins/:id
```

The Accounts page has:

- My admin profile
- Admin accounts card list
- Add admin modal
- Admin stats page

Admin initials calculation:

```js
initials =
  full_name
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map(first character uppercase)
    .join('')

fallback = 'A'
```

Access update behavior:

```text
If target admin is owner:
  action label = Make manager
  payload access_level = manager

If target admin is manager:
  action label = Give full access
  payload access_level = owner
```

Only owner admins can update access levels.

Delete behavior:

- owners can delete manager admins
- owner admins cannot be deleted
- admins cannot delete themselves through the card action

## 13. Dashboard Metric Calculations

Endpoint:

```text
GET /api/admin/stats
```

### Total Landlords

```sql
SELECT COUNT(*)
FROM users
WHERE role = 'landlord'
```

### Approved Landlords

```sql
SELECT COUNT(*)
FROM users
WHERE role = 'landlord'
  AND is_approved = true
```

### Pending Landlords

```sql
SELECT COUNT(*)
FROM users
WHERE role = 'landlord'
  AND is_approved = false
```

### Total Properties

```sql
SELECT COUNT(*)
FROM properties
```

### Approved Properties

```sql
SELECT COUNT(*)
FROM properties
WHERE is_approved = true
```

### Pending Properties

```sql
SELECT COUNT(*)
FROM properties
WHERE is_approved = false
```

### Rejected/Suspended Properties

Current calculation:

```text
rejected_properties = 0
```

Reason:

The current schema does not have a separate rejected/suspended property status. Rejection currently sets `is_approved = false`, which is the same storage value used for pending.

Future improvement:

Add a `moderation_status` column:

```text
pending | approved | rejected | suspended
```

### Active Properties

```sql
SELECT COUNT(*)
FROM properties
WHERE is_approved = true
  AND is_active = true
```

### Total Payments

```sql
SELECT COUNT(*)
FROM payments
```

### Successful Payments

```sql
SELECT COUNT(*)
FROM payments
WHERE status = 'confirmed'
```

### Pending Payments

```sql
SELECT COUNT(*)
FROM payments
WHERE status = 'pending'
```

### Failed Payments

```sql
SELECT COUNT(*)
FROM payments
WHERE status = 'failed'
```

### Pending/Failed Card

Frontend calculation:

```js
pending_failed = pending_payments + failed_payments
```

### Confirmed Revenue

```sql
SELECT COALESCE(SUM(amount), 0) AS total
FROM payments
WHERE status = 'confirmed'
```

Frontend formatting:

```js
new Intl.NumberFormat('en-ZM', {
  style: 'currency',
  currency: 'ZMW',
  maximumFractionDigits: 0,
})
```

Example:

```text
0 -> K0 or K 0 depending browser currency spacing
2500 -> K2,500
```

## 14. Recent Activity Calculation

The Overview recent activity list is built on the client from loaded dashboard data.

Landlord events:

```js
state.data.landlords.slice(0, 3)
```

Property events:

```js
state.data.properties.slice(0, 3)
```

Payment events:

```js
state.data.payments.slice(0, 3)
```

Combined list:

```js
events = [...landlordEvents, ...propertyEvents, ...paymentEvents].slice(0, 8)
```

Empty state appears when the combined list has zero items.

## 15. Admin Stats Calculations

Endpoint:

```text
GET /api/admin/admins/:id/details
```

Permission:

```text
owner admin OR same admin id
```

### Total Actions

```sql
SELECT COUNT(*)::int AS count
FROM admin_logs
WHERE admin_id = $1
```

### Action Breakdown

```sql
SELECT action, COUNT(*)::int AS count
FROM admin_logs
WHERE admin_id = $1
GROUP BY action
ORDER BY count DESC, action ASC
```

### Entity Breakdown

```sql
SELECT entity_type, COUNT(*)::int AS count
FROM admin_logs
WHERE admin_id = $1
GROUP BY entity_type
ORDER BY count DESC, entity_type ASC
```

### Daily Activity

```sql
SELECT DATE(created_at) AS day, COUNT(*)::int AS count
FROM admin_logs
WHERE admin_id = $1
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY day DESC
LIMIT 30
```

### Recent Actions

```sql
SELECT action, entity_type, entity_id, message, status, created_at
FROM admin_logs
WHERE admin_id = $1
ORDER BY created_at DESC
LIMIT 8
```

### Derived Admin Stats

```js
payments_recorded =
  count where action === 'payment_recorded'

properties_approved =
  count where action === 'property_approved'

properties_rejected =
  count where action === 'property_rejected'

landlords_approved =
  count where action === 'landlord_approved'

landlords_suspended =
  count where action === 'landlord_suspended'
```

Destructive actions:

```js
destructive_actions =
  actionBreakdown
    .filter(action includes 'deleted' OR 'suspended' OR 'rejected')
    .reduce(sum + count)
```

## 16. Listing Expiry Job

Service:

```text
StudentNest/src/services/listingExpiryService.js
```

On server startup:

```js
startListingExpiryJob()
```

The job runs:

- immediately on server start
- every 6 hours

Interval calculation:

```js
sixHours = 6 * 60 * 60 * 1000
```

Expired listing update:

```sql
UPDATE properties
SET is_active = false,
    updated_at = NOW()
WHERE is_active = true
  AND listing_expires_at IS NOT NULL
  AND listing_expires_at <= NOW()
RETURNING id, title, listing_expires_at
```

## 17. Photo Handling

Photo upload uses Cloudinary.

Cloudinary config:

```text
StudentNest/src/config/cloudinary.js
```

Required variables:

```env
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
```

Admin property details can display property photos and open them in a full-screen photo viewer.

Photo keyboard controls:

- Escape closes viewer
- ArrowLeft shows previous photo
- ArrowRight shows next photo

Photo index wrap calculation:

```js
activePhotoIndex = (index + activePhotos.length) % activePhotos.length
```

## 18. Security

### Helmet

The backend uses Helmet with a custom Content Security Policy.

Allowed:

- scripts from self
- styles from self and Google Fonts
- fonts from self and Google Fonts static host
- images from self, `data:`, and HTTPS
- connects to self

### Passwords

Passwords are stored as bcrypt hashes.

Landlord/admin password hashing:

```js
bcrypt.hash(password, 10)
```

Login verification:

```js
bcrypt.compare(password, user.password_hash)
```

### JWT

JWT secret:

```env
JWT_SECRET=
```

Rotate `JWT_SECRET` if a token is accidentally exposed.

### Admin API Protection

Every admin API route requires:

```text
Authorization: Bearer <token>
```

## 19. Render Deployment

Render service type:

```text
Web Service
```

Root directory:

```text
StudentNest
```

Build command:

```bash
npm install
```

Start command:

```bash
npm start
```

The service redeploys when changes are pushed to GitHub.

## 20. Database Setup Without Render Shell

Use the Render PostgreSQL External Database URL from your laptop.

PowerShell:

```powershell
cd A:\work\student_nest\StudentNest

$env:DATABASE_URL = Read-Host "Paste Render External Database URL"
$env:DB_SSL = "true"

npm run db:schema
```

Create admin:

```powershell
$env:ADMIN_FULL_NAME = Read-Host "Admin full name"
$env:ADMIN_PHONE = Read-Host "Admin phone"
$env:ADMIN_EMAIL = Read-Host "Admin email"
$env:ADMIN_PASSWORD = Read-Host "Admin password"

npm run create-admin
```

## 21. First Admin Ownership

Service:

```text
StudentNest/src/services/adminAccessService.js
```

Startup behavior:

1. Ensures `users.access_level` exists.
2. Sets existing admins without access level to `manager`.
3. Checks if any owner exists.
4. If no owner exists, promotes the earliest-created admin to owner.

Owner selection:

```sql
SELECT id
FROM users
WHERE role = 'admin'
ORDER BY created_at ASC
LIMIT 1
```

## 22. Important API Routes

### Auth

```text
POST /api/auth/register
POST /api/auth/login
```

### Admin Profile

```text
GET   /api/admin/profile
PATCH /api/admin/profile
```

### Admin Accounts

```text
GET    /api/admin/admins
GET    /api/admin/admins/:id/details
PATCH  /api/admin/admins/:id/access
DELETE /api/admin/admins/:id
POST   /api/admin/create-admin
```

### Stats

```text
GET /api/admin/stats
```

### Landlords

```text
GET    /api/admin/landlords
PATCH  /api/admin/landlords/:id
DELETE /api/admin/landlords/:id
PATCH  /api/admin/landlords/:id/reset-password
```

### Properties

```text
GET    /api/admin/properties
PATCH  /api/admin/properties/:id
DELETE /api/admin/properties/:id
```

### Payments

```text
GET  /api/admin/payments
POST /api/admin/payments
```

### Logs

```text
GET /api/admin/logs
```

## 23. Operational Workflows

### Approve A Landlord

1. Admin opens Landlords tab.
2. Admin clicks Approve.
3. UI shows confirmation.
4. Frontend sends:

```json
{
  "is_approved": true
}
```

5. Backend updates user where `role = 'landlord'`.
6. Backend records `landlord_approved` log.
7. Dashboard reloads data.

### Suspend A Landlord

Same as approval, but:

```json
{
  "is_approved": false
}
```

Log action:

```text
landlord_suspended
```

### Approve A Property

Payload:

```json
{
  "is_approved": true
}
```

Effects:

- `properties.is_approved = true`
- `properties.updated_at = NOW()`
- log action `property_approved`

### Reject A Property

Payload:

```json
{
  "is_approved": false
}
```

Effects:

- `properties.is_approved = false`
- `properties.updated_at = NOW()`
- log action `property_rejected`

### Record Manual Payment

Required:

- property
- amount
- payment method
- duration months
- status

Effects:

- inserts payment
- activates property
- sets listing expiry
- records log

### Add Admin

Owner-only.

Required:

- full name
- phone
- password
- access level

Optional:

- email

Effects:

- inserts new user with `role = 'admin'`
- sets `is_approved = true`
- sets `access_level`
- records `admin_created`

### Change Admin Access

Owner-only.

Payload:

```json
{
  "access_level": "owner"
}
```

or:

```json
{
  "access_level": "manager"
}
```

The backend normalizes any value other than `owner` to `manager`.

## 24. Known Limitations

### Rejected Properties Are Not Stored Separately

Rejected and pending properties both use:

```text
is_approved = false
```

The dashboard currently displays rejected/suspended as `0`.

Recommended future fix:

```sql
ALTER TABLE properties
ADD COLUMN moderation_status VARCHAR(40)
CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'suspended'));
```

### Moderation Notes Are Not Persisted

The UI can ask for reasons during some confirmation dialogs, but the current schema does not persist moderation notes as first-class fields.

Recommended future fix:

```sql
CREATE TABLE moderation_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID REFERENCES users(id),
  entity_type VARCHAR(80) NOT NULL,
  entity_id TEXT NOT NULL,
  reason TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Payment Gateway Automation Is Not Implemented

Payments are manual records. Automated mobile money or bank callbacks would need:

- provider credentials
- webhook route
- signature verification
- idempotency handling
- status reconciliation

### Some Legacy Text Encoding Exists

Some older frontend strings contain malformed separator characters like `Â·`. These do not usually break functionality but should be cleaned over time.

## 25. Troubleshooting

### Admin Page Shows Old Styling

Hard refresh:

```text
Ctrl + F5
```

### Admin Login Returns JSON Instead Of Dashboard

Expected fix is already in place:

- login button submits through JavaScript
- fallback form action posts to `/admin/`
- backend serves admin page on accidental `/admin/` POST

Hard refresh and retry.

### Refresh Sends User Back To Login

Check:

- token exists in local storage
- `studentNestAdminLastActive` is within 30 minutes
- backend is not returning token/unauthorized errors
- JWT secret has not been rotated

### Make Manager Button Does Nothing

Expected fix is already in place:

```js
event.target.closest('button, [data-admin-access], [data-delete-admin]')
```

This allows clicks on action spans inside admin account cards.

### API Root Health Check

```bash
curl https://student-nest-api.onrender.com/
```

Expected:

```json
{"message":"Student Nest API is running"}
```

### Public Properties Check

```bash
curl https://student-nest-api.onrender.com/api/properties
```

Expected shape:

```json
{
  "count": 0,
  "properties": []
}
```

## 26. Change And Deployment Flow

For web/admin changes:

```powershell
git add StudentNest/public/admin StudentNest/src
git commit -m "Describe web admin change"
git push origin main
```

Render redeploys automatically.

No APK rebuild is needed for admin website changes.

APK rebuild is only needed for Flutter/mobile changes such as:

```text
lib/
assets/
android/
pubspec.yaml
```

## 27. Important Commands

Install backend dependencies:

```bash
npm install
```

Run backend locally:

```bash
npm run dev
```

Run backend in production:

```bash
npm start
```

Apply database schema:

```bash
npm run db:schema
```

Create first admin:

```bash
npm run create-admin
```

## 28. Summary

The Student Nest web admin is a static browser dashboard served by the Node/Express backend. It uses JWT auth, PostgreSQL, admin access levels, audit logs, manual payment records, property approval workflows, listing expiry automation, and a fixed-sidebar management UI.

The most important operational rules are:

- Only admins can access `/api/admin/*`.
- Owners control admin accounts.
- Managers handle day-to-day operations.
- Confirmed payments activate listings and set expiry dates.
- Expired listings are automatically suspended by a 6-hour background job.
- Dashboard statistics come directly from database counts and confirmed payment sums.
- Admin sessions persist across refresh and expire after 30 minutes of inactivity.

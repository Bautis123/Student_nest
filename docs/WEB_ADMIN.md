# Student Nest Web Admin

The web admin dashboard lives in the backend project and is served from:

```text
StudentNest/public/admin
```

When the backend is running, open:

```text
http://localhost:5000/admin
```

## Why Admin Is Web-Based

Admin work is better suited to a browser because it needs larger tables, review workflows, payment checks, account management, logs, and detailed property/photo inspection. The Flutter app remains focused on students and landlords.

## Admin Dashboard Sections

### Overview

Shows platform-level health and recent activity:

- landlord counts
- property counts
- payment counts
- confirmed revenue
- pending approvals
- recent activity
- quick action cards

### Landlords

Admins can:

- view all landlords
- search landlords
- filter by status
- approve or suspend landlords
- open landlord details
- see linked property counts

High-impact actions use confirmation dialogs.

### Properties

Admins can:

- view all listings
- search/filter/sort listings
- inspect linked landlord details
- approve or reject listings
- delete listings when needed
- view listing photos
- open photos full screen
- see completeness warnings for missing rooms, photos, address, or school link
- see expiry status and countdown

### Payments

Admins can manually record payments for:

- mobile money
- bank transfer
- cash
- other methods

Mobile money stores the provider:

- MTN Mobile Money
- Airtel Money
- Zamtel Kwacha

Bank transfers store:

- bank name
- reference

Cash payments hide provider and reference fields.

Confirmed payments activate listings and set expiry dates.

### Logs

The Logs page reads from `admin_logs` and supports filters for:

- search
- action
- entity type
- status
- date range

Logged actions include:

- landlord approval/suspension/update/delete
- landlord password resets
- property approval/rejection/delete
- payment recording
- admin creation/deletion/access updates
- profile updates

### Accounts

Admins can manage admin accounts depending on access level.

Access levels:

- `owner`
  - full access
  - cannot be deleted
  - can create admins
  - can give or remove owner access
  - can delete manager admins
  - can view all admin stats
- `manager`
  - operational access
  - cannot manage admin accounts
  - cannot delete admins
  - cannot view other admins' stats

Clicking the sidebar profile opens the logged-in admin's stats page.

Clicking an admin card opens stats if allowed:

- owners can view any admin
- managers can only view themselves

## File Organization

The admin frontend is split into small files.

```text
StudentNest/public/admin/
  index.html
  styles.css
  css/
  js/
  partials/
  assets/
```

`index.html` is a small shell. `js/00-loader.js` loads HTML partials first and then loads the JavaScript files in order.

## Backend Routes

Admin routes are mounted at:

```text
/api/admin
```

Important routes:

```text
GET    /api/admin/profile
PATCH  /api/admin/profile
GET    /api/admin/admins
GET    /api/admin/admins/:id/details
PATCH  /api/admin/admins/:id/access
DELETE /api/admin/admins/:id
GET    /api/admin/logs
GET    /api/admin/stats
GET    /api/admin/landlords
PATCH  /api/admin/landlords/:id
GET    /api/admin/properties
PATCH  /api/admin/properties/:id
DELETE /api/admin/properties/:id
GET    /api/admin/payments
POST   /api/admin/payments
```

All admin API routes are protected by JWT admin middleware.

## Listing Expiry Behavior

When a confirmed payment is recorded:

- a payment record is saved
- `payments.expires_at` is set
- `properties.listing_expires_at` is set
- the property is marked active

Expired listings are hidden from student-facing APIs. A backend maintenance job also marks expired listings inactive:

- once on server startup
- every 6 hours

## Notes

- Rejection/suspension reasons are currently collected in the UI but need dedicated backend audit/note columns to persist as first-class moderation notes.
- Payment gateway callbacks are not faked. The current flow supports real manual records and is ready for future automated provider integration.

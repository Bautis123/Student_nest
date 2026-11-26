# Student Nest

Student Nest is a Zambia-focused student accommodation marketplace. The active frontend is now a React web app prepared for Vercel. It serves students and landlords; the existing Node/PostgreSQL backend and protected admin dashboard remain on Render.

## Start the Web App

```powershell
cd web-app
npm ci
npm run dev
```

Open the local URL printed by Vite. Requests under `/api` proxy to the existing Render API. For a local backend, copy `web-app/.env.example` to `web-app/.env` and set `API_PROXY_TARGET=http://localhost:5000`.

The web app supports campus/text/budget filtering, saved homes, property details, direct landlord contact, landlord registration and login, property creation and editing, room availability, and photo upload/cover/deletion. Payments remain manually verified in the existing admin dashboard.

**Deployment:** import the repository into a new Vercel project and set **Root Directory** to `web-app`, **Framework** to Vite, **Build Command** to `npm run build`, and **Output Directory** to `dist`. Redeploy the backend changes first: private landlord detail and property editing routes are required by the new management UI. See [Web launch guide](docs/WEB_LAUNCH.md).

## Project Structure

```text
web-app/                     Active React/Vite frontend (Vercel)
StudentNest/                 Node.js + Express backend
StudentNest/public/admin/    Web admin dashboard
docs/                        Project documentation
```

## Backend

The backend provides:

- Authentication and role-based JWT access
- Landlord/property APIs
- Photo upload through Cloudinary
- Admin APIs for approvals, listings, payments, accounts, logs, and stats
- Listing expiry maintenance

Run the backend:

```powershell
cd StudentNest
npm run dev
```

Default backend port:

```text
http://localhost:5000
```

## Web Admin

Open the admin dashboard:

```text
http://localhost:5000/admin
```

The web admin includes:

- Overview stats and recent activity
- Landlord review and approval/suspension
- Property review, completeness checks, photos, and expiry countdowns
- Manual payment recording for mobile money, bank transfer, cash, and other methods
- Admin logs and filters
- Admin accounts, access levels, and per-admin stats

Admin access levels:

- `owner`: full access, can create admins, change access levels, delete manager admins, and cannot be deleted.
- `manager`: operational admin access, cannot manage admin accounts or view other admins' stats.

On backend startup, if no owner exists, the first existing admin is assigned owner access automatically.

## Listing Publishing Flow

Recommended production flow:

1. Landlord submits a listing with details, rooms, and photos.
2. Admin reviews and approves or rejects the listing.
3. Landlord pays for the approved listing.
4. Admin records/verifies payment.
5. Listing becomes active and visible to students until expiry.

Student-facing listing APIs only return listings that are approved, active, and not expired.

## Listing Expiry

Confirmed payments set:

- `payments.expires_at`
- `properties.listing_expires_at`

The backend:

- hides expired listings from student APIs immediately
- auto-suspends expired listings on startup and every 6 hours by setting `is_active = false`

## Useful Checks

Web checks:

```powershell
cd web-app
npm run build
npm test
npm run test:e2e
```

Browser checks use installed Google Chrome and test fixtures; they do not mutate the live API.

Backend regression checks:

```powershell
node --test StudentNest/tests/web-properties.test.js
```

Backend syntax:

```powershell
node --check StudentNest\src\app.js
node --check StudentNest\src\controllers\admin.js
node --check StudentNest\public\admin\js\00-loader.js
```

## More Documentation

- [Web Admin Guide](docs/WEB_ADMIN.md)

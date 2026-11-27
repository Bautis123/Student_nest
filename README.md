# Student Nest

Student Nest is a Zambia-focused student accommodation marketplace. The active frontend is now a React web app prepared for Vercel. It serves students and landlords; the existing Node/PostgreSQL backend and protected admin dashboard remain on Render.

## Start the Web App

```powershell
cd web-app
npm ci
npm run dev
```

Open the local URL printed by Vite. Requests under `/api` proxy to the existing Render API. For a local backend, copy `web-app/.env.example` to `web-app/.env` and set `API_PROXY_TARGET=http://localhost:5000`.

The web app supports campus/text/budget filtering, a map view of homes and campuses (Leaflet + OpenStreetMap, no API key), estimated walking and minibus times to campus, saved homes, property details, direct landlord contact, landlord registration and login, property creation and editing, room availability, and photo upload/cover/deletion. Payments remain manually verified in the existing admin dashboard.

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
3. Landlord pays for the approved listing in the web app with MTN, Airtel or Zamtel mobile money (or an admin records a cash/bank payment).
4. The payment is confirmed automatically by the payment provider.
5. Listing becomes active and visible to students until expiry.

Student-facing listing APIs only return listings that are approved, active, and not expired.

## Mobile Money Payments

Landlords choose a plan on their listing page, enter their mobile money number and approve the prompt on their phone. Plans are defined in `StudentNest/src/config/listingPlans.js`:

| Plan | Price | Length |
| --- | --- | --- |
| Basic | K300 | 12 months |
| Premium (Featured label) | K750 | 12 months |

Payments go through [Lenco](https://lenco.co), which collects from MTN, Airtel and Zamtel with one integration. A confirmed payment activates the listing; paying again extends it from the current expiry.

Backend settings (Render environment):

| Variable | Value |
| --- | --- |
| `PAYMENT_PROVIDER` | `lenco` for real payments, `mock` for demos, unset to switch in-app payments off |
| `LENCO_API_TOKEN` | API token from the Lenco Pay section of the Lenco dashboard |
| `LENCO_API_BASE_URL` | Optional. Defaults to `https://api.lenco.co/access/v2`; set Lenco's sandbox host while testing |

In the Lenco dashboard, set the webhook URL to `https://student-nest-api.onrender.com/api/payments/webhooks/lenco`. Webhooks are verified with Lenco's `X-Lenco-Signature` header; the app also checks status directly with Lenco while the landlord waits, so payments confirm even if a webhook is delayed.

With `PAYMENT_PROVIDER=mock`, numbers ending in `1111111` (e.g. `0961111111`) succeed after a few seconds and any other number is declined. No money moves.

## Tenant Reviews

Students who lived in a home can review it from the home's page: five ratings (overall, landlord, water & power, security, value for money), when they moved in and out, a written review, an optional display name, and a phone number.

- **No account; confirmed by an admin.** The phone number is never shown publicly; admins use it to confirm the stay before publishing (admin portal → **Reviews**). Reviews are moderated for honesty, not to remove negative but genuine feedback.
- **One review per phone number per home.** A rejected reviewer can submit again.
- **Landlord replies.** The landlord sees approved reviews on their listing page and can post one public reply (editable). Landlords cannot delete reviews.
- **Ratings on listings.** Cards show the average and count (e.g. ★ 4.5 (2)); the home page shows the average, a breakdown by category and every published review.

## Roommate Matching

Students looking to share a room post a short request at `/roommates/new`: first name, campus, monthly budget, optional move-in date, lifestyle tags, who they would share with, and a WhatsApp number. There are no student accounts:

- **Private link instead of a login.** Posting returns a one-time link (`/roommates/manage/<token>`) to edit or remove the post. Only a SHA-256 hash of the token is stored, so a lost link can't be recovered; the student just posts again.
- **Admin approval first.** New and edited posts wait in the admin portal's **Roommates** tab (the sidebar shows how many are waiting). Approved posts are visible for 30 days.
- **Numbers on tap.** Phone numbers never appear in the public listing; a student taps **Show WhatsApp** on an approved post to reveal it (each reveal is counted for admins).
- **Reports.** Anyone can report a post with a reason. Three reports hide it until an admin reviews it again; re-approving clears the count.
- **Limits.** A number can have at most two active posts.

Students can filter by campus, budget and who a post is open to. Homes with shared rooms link to roommate requests for the same campus.

## Listing Expiry

Confirmed payments set:

- `payments.expires_at`
- `properties.listing_expires_at`

The backend:

- hides expired listings from student APIs immediately
- auto-suspends expired listings on startup and every 6 hours by setting `is_active = false`

### Bringing an expired listing back

- **Landlord:** pays again from the listing page; the new period starts from today (or from the current expiry if it hasn't passed yet).
- **Admin, without a payment** (demo listings, complimentary time, corrections): in the admin portal, open **Properties**, filter by **Expired**, click **Reactivate**, choose 7 days to 12 months and add a note. On a live listing the same button says **Extend** and adds time after the current expiry. Every use is recorded in the admin logs with the admin, the period and the note.
- **Demo listings:** re-run the seed script; it recreates deleted demo listings and refreshes expired ones instead of skipping them:

```powershell
cd StudentNest
npm run seed:demo -- --days=30
```

`--days` accepts 1 to 90 (default 7). The script only runs against the project's Supabase database.

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
cd StudentNest
npm ci
npm test
```

These use a database double and never touch real data.

`node_modules/` is not committed; Render installs dependencies during its build. On startup the backend runs idempotent schema migrations (`src/services/schemaService.js`) before accepting requests, and refuses to start without `JWT_SECRET`.

## More Documentation

- [Web Admin Guide](docs/WEB_ADMIN.md)

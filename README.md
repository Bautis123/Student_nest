# Student Nest

Student Nest is a Zambia-focused student accommodation marketplace. The Flutter app serves students and landlords, while admin operations run through a protected web dashboard on the Node/PostgreSQL backend.

## Project Structure

```text
lib/                         Flutter mobile app
StudentNest/                 Node.js + Express backend
StudentNest/public/admin/    Web admin dashboard
docs/                        Project documentation
```

## Mobile App

The Flutter app is focused on:

- Student browsing and property details
- Landlord registration/login
- Landlord listing creation and management
- Listing photos, rooms, payments, and profile/settings flows

Admin screens were moved out of the Flutter app. Admins should use the web dashboard instead.

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

Backend syntax:

```powershell
node --check StudentNest\src\app.js
node --check StudentNest\src\controllers\admin.js
node --check StudentNest\public\admin\js\00-loader.js
```

Flutter checks:

```powershell
dart format lib
flutter analyze
flutter test
```

## More Documentation

- [Web Admin Guide](docs/WEB_ADMIN.md)
- [Codebase Refactor Guide](docs/CODEBASE_REFACTOR_GUIDE.md)

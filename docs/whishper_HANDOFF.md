# Student Nest Project Handoff

This document is for a collaborator joining the Student Nest project. It explains the app, backend, database, setup flow, and the main files worth knowing first.

## What This Project Is

Student Nest is a Zambia-focused student accommodation marketplace.

- Students browse approved, active accommodation listings near schools.
- Landlords register, wait for admin approval, create listings, add rooms, upload photos, and manage availability.
- Admins use a protected web dashboard to approve landlords/listings, record payments, manage admin accounts, and view logs.

## Repository Map

```text
lib/                         Flutter app
lib/screens/student/         Student browsing and property detail screens
lib/screens/landlord/        Landlord auth, dashboard, listing, payment screens
lib/core/services/           Newer Flutter service layer
lib/services/api_service.dart Older all-in-one Flutter API service
StudentNest/                 Node.js + Express backend
StudentNest/src/routes/      Express route definitions
StudentNest/src/controllers/ Route handlers and SQL queries
StudentNest/src/config/      PostgreSQL and Cloudinary config
StudentNest/public/admin/    Browser-based admin dashboard
StudentNest/database/        Database bootstrap SQL
docs/                        Project documentation
```

## Tech Stack

- Frontend/mobile: Flutter, Dart, Provider, HTTP, SharedPreferences, Google Maps, image picker.
- Backend: Node.js, Express, PostgreSQL, JWT auth, bcrypt password hashing.
- File storage: Cloudinary for listing photos.
- Admin UI: static HTML/CSS/JavaScript served by Express at `/admin`.

## Local Setup

Install these first:

- Flutter SDK matching Dart `^3.7.2`
- Node.js and npm
- PostgreSQL
- A Cloudinary account if you need photo upload

Backend setup:

```powershell
cd StudentNest
npm install
Copy-Item .env.example .env
```

Edit `StudentNest/.env` with local database credentials, a long `JWT_SECRET`, and Cloudinary credentials.

Database setup:

```powershell
createdb -U postgres student_nest
psql -U postgres -d student_nest -f database/schema.sql
```

Run the backend:

```powershell
cd StudentNest
npm run dev
```

Backend URLs:

```text
API health:      http://localhost:5000/
API base:        http://localhost:5000/api
Admin dashboard: http://localhost:5000/admin
```

Flutter setup:

```powershell
flutter pub get
flutter run
```

Important: update `lib/utils/constants.dart` so `AppConstants.baseUrl` points to the backend reachable from the device. For an Android emulator this is usually `http://10.0.2.2:5000/api`; for a physical phone, use the computer's LAN IP, such as `http://192.168.x.x:5000/api`.

## Database You Will need Needs

The app expects PostgreSQL. The bootstrap schema is in:


StudentNest/database/schema.sql

Main tables:

- `users`: landlords and admins. Admins use `role = 'admin'`; landlords use `role = 'landlord'`.
- `schools`: schools used for listing location/filtering.
- `properties`: accommodation listings owned by landlords.
- `rooms`: room types, prices, total rooms, and availability.
- `photos`: Cloudinary image URLs attached to properties.
- `payments`: manual listing payments recorded by admins.
- `admin_logs`: audit log of admin actions.

Visibility rule for student browsing:


properties.is_approved = true
properties.is_active = true
properties.listing_expires_at is null or in the future


Payments affect visibility. When an admin records a confirmed payment, the backend activates the property and sets `listing_expires_at`.

## Creating the First Admin

There is no public admin registration route. Use the helper script after the database schema has been loaded:

```powershell
$env:ADMIN_FULL_NAME="Owner Admin"
$env:ADMIN_PHONE="+260970000000"
$env:ADMIN_EMAIL="admin@studentnest.local"
$env:ADMIN_PASSWORD="change-this-password"
npm run create-admin
```

The script creates the first admin as `access_level = 'owner'`. Later admins are created as managers unless changed by an owner.

Owner admins can create other admins from the web dashboard. Manager admins can perform operational admin work but cannot manage admin accounts.

## Core API Areas

Auth:

- `POST /api/auth/register` registers a landlord.
- `POST /api/auth/login` logs in a landlord or admin and returns a JWT.

Properties:

- `GET /api/properties` lists student-visible properties.
- `GET /api/properties/:id` returns property details with rooms/photos.
- `POST /api/properties` creates a landlord listing.
- `POST /api/properties/:property_id/rooms` adds room types.
- `GET /api/properties/schools` returns filter schools.
- `GET /api/properties/landlord/my-properties` returns the logged-in landlord's listings.

Photos:

- `POST /api/photos/:property_id` uploads up to 10 photos to Cloudinary.
- `DELETE /api/photos/:photo_id` deletes a photo.
- `PATCH /api/photos/:photo_id/cover` sets a cover photo.

Admin:

- `GET /api/admin/stats`
- `GET /api/admin/landlords`
- `PATCH /api/admin/landlords/:id`
- `GET /api/admin/properties`
- `PATCH /api/admin/properties/:id`
- `POST /api/admin/payments`
- `GET /api/admin/logs`
- `GET /api/admin/admins`
- `POST /api/admin/create-admin`

## Main Product Flow

1. A landlord registers in the Flutter app.
2. An admin approves the landlord in the web dashboard.
3. The landlord logs in and creates a listing.
4. The landlord adds rooms and photos.
5. An admin approves the listing.
6. An admin records payment.
7. Students can now see the listing until it expires.

## Known Notes For Collaboration

- `StudentNest/.env` contains secrets and should not be committed.
- `StudentNest/node_modules/` is present locally but should not be edited.
- `lib/services/api_service.dart` and `lib/core/services/*` overlap; future cleanup should consolidate API access into one layer.
- `lib/utils/constants.dart` currently contains environment-specific values. Moving API URLs and keys into build-time config would make collaboration easier.
- The backend has no migration tool yet. For now, use `StudentNest/database/schema.sql` as the source of truth for new local databases.

## Useful Checks

Backend:

```powershell
node --check StudentNest/src/app.js
node --check StudentNest/src/controllers/admin.js
node --check StudentNest/src/controllers/properties.js
```

Flutter:

```powershell
dart format lib
flutter analyze
flutter test
```

## Suggested First Tasks

- Set up PostgreSQL with `StudentNest/database/schema.sql`.
- Create the first owner admin.
- Confirm backend login works with Postman or the admin dashboard.
- Point `AppConstants.baseUrl` at the local backend.
- Run the landlord flow from registration to listing creation.
- Run the admin flow from approval to payment recording.

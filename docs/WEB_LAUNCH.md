



# Student Nest web launch

## Verification status — 19 October 2026

- Production frontend build passed.
- Twelve focused frontend/backend checks passed; twelve browser cases passed across desktop and mobile with mocked API responses.
- Live Render health route `/` returned HTTP 200, but `/api/properties/schools` and `/api/properties` both returned HTTP 500. This is a launch blocker. Inspect the Render service logs and its PostgreSQL connection/schema before performing live smoke tests; the cause has not been established.
- A read-only check using the local backend environment connected successfully and confirmed `schools` and `properties` exist. This does not verify Render's deployed environment variables.
- No Vercel project has been created and no backend deployment was performed in this workspace session.

## Architecture

- `web-app/`: React + Vite frontend; build to `web-app/dist` and host on Vercel.
- `StudentNest/`: existing Express API, PostgreSQL connection, Cloudinary uploads and admin dashboard; keep on Render.
- Vercel rewrites `/api/*` to `https://student-nest-api.onrender.com/api/*`, then serves frontend routes through `index.html`.
- Local Vite development uses the same API proxy by default. `API_PROXY_TARGET` overrides it locally. `VITE_API_BASE_URL` is an optional public build-time API URL; never put database or Cloudinary secrets in a `VITE_` variable.
- Saved homes live in browser local storage. Landlord authentication lives in session storage and clears when the tab session ends. A 401 clears the session and redirects protected pages to sign-in.
- Listing photos are uploaded as browser multipart files. Maps open Google Maps links; the web app does not need a map API key.

## Deploy the backend first

Deploy the backend changes in this repository through the existing Render service workflow. Keep its current environment variables and database. No schema migration is required for this change.

New routes:

```text
GET   /api/properties/landlord/my-properties/:id
PATCH /api/properties/:id
```

Both require a landlord token and constrain access to the owner. The private detail endpoint includes rooms and photos even when a listing is unpublished. Detail edits clear approval and activation for admin re-review. Clients cannot activate listings through PATCH. Room capacity and coordinate validation were added, and cover-photo changes use the owned photo's property ID.

For a read-only connectivity and table-existence diagnostic, run `node scripts/checkDatabase.js` from `StudentNest/` in the target environment. It prints no credentials and does not alter data.

Do not put the existing Express process on Vercel as-is: its recurring expiry timer belongs with the persistent Render process. Payment confirmation and activation stay in the existing admin dashboard.

## Create the Vercel project

1. Push the reviewed changes to your repository.
2. In Vercel, choose **Add New → Project** and import the repository.
3. Set **Root Directory** to `web-app` (relative to the Git repository root, `student_nest`).
4. Select **Vite**, build command `npm run build`, output `dist`, install command `npm ci`, and Node.js 22 or 24.
5. No new environment variables are required for the current Render URL. If the API moves, update both `vercel.json` and the development proxy target.
6. Deploy, then complete the live smoke checks below.

The checked-in `vercel.json` handles API forwarding and refreshing routes such as `/homes/:id` and `/landlord`.

Configuration follows [Vercel's Vite guide](https://vercel.com/docs/frameworks/frontend/vite) and [rewrite documentation](https://vercel.com/docs/routing/rewrites).

## Local checks

```powershell
cd web-app
npm ci
npm run build
npm test
npm run test:e2e
```

The browser suite uses installed Google Chrome, a local Vite server and mocked API responses on desktop and mobile viewports. It covers filtering, saved homes, details and route refresh, unavailable API states, registration, protected routes, property creation, availability, multipart uploads, expired sessions and overflow. It does not create production accounts, upload real Cloudinary photos or verify a live database transaction.

From the repository root:

```powershell
node --test StudentNest/tests/web-properties.test.js
```

If a restricted Windows shell forbids test child processes, run the unit checks with `node --test --test-isolation=none web-app/tests/utils.test.js StudentNest/tests/web-properties.test.js`.

## Live smoke checks

1. Browse real listings and campuses; check rent, photos and empty states.
2. Refresh a property URL and confirm it opens correctly.
3. Register a designated test landlord, approve it through the existing admin dashboard, and sign in.
4. Create a test property, add a room and upload a photo. Check cover selection and availability updates.
5. Verify that unpublished properties are visible only in the owner's workspace.
6. Review/activate through the existing admin flow, then check public visibility and landlord contact links.
7. Edit property details and confirm that re-review is required.
8. Confirm expiry behavior remains correct on Render.

## Current scope

This first web release provides the core student and landlord flows. There is no password reset or student account system. Homes can be browsed on an OpenStreetMap map (Leaflet), and each home shows estimated walking and minibus times to its campus; these are estimates from straight-line distance, not routed directions. Registration requires admin approval. The public catalogue uses client-side filters over the API's current result set; add server pagination when inventory warrants it. Public listing content is client-rendered, so search-engine indexing should be evaluated before an SEO-focused launch.

The frontend build and automated tests can be completed locally. Production publication, backend redeployment and authenticated live smoke tests require the hosting accounts and a designated test landlord.

# Mazr3a Server

REST API for the Mazr3a farm warehouse desktop app. The Flutter app keeps its own SQLite database and syncs with this API in the background. There are no user accounts. One API key protects every route except `/health`.

Currency is EGP. Names and notes may be Arabic or English. The API speaks UTF-8 JSON, and dates are ISO 8601 UTC strings such as `2026-11-16T14:30:00.000Z`.

The field-by-field contract for the Retrofit client is in [API.md](API.md).

## Setup

Requires Node.js 18 or newer.

```powershell
cd mazr3a-server
npm install
copy .env.example .env
```

Edit `.env`:

| Variable | Required | Notes |
|---|---|---|
| `MONGODB_URI` | yes | Atlas connection string. Put the database name in the path (`...mongodb.net/mazr3a?retryWrites=true&w=majority`). Without it, MongoDB stores data in the default `test` database. |
| `API_KEY` | yes | Shared secret sent as `x-api-key`. At least 24 characters. The process exits if it is missing or shorter. |
| `PORT` | no | Defaults to `3000`. Render and Railway set this for you. |

Generate a key:

```powershell
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

`.env` is git-ignored. Never commit it and never paste the Atlas URI into the host's build logs.

In Atlas, open Network Access and allow your PC for local development. For Render or Railway, allow that host or `0.0.0.0/0` (the free tier has no IP allow-list of its own).

## Run

```powershell
npm start
```

`npm run dev` restarts the process when a file changes (`node --watch`).

Open http://localhost:3000/health. A connected database returns `200` and `{"status":"ok"}`. If MongoDB is down the same URL returns `503` and `{"status":"db_unavailable"}`.

The server listens for `SIGINT` and `SIGTERM`, closes the HTTP port, then closes MongoDB.

## Test

```powershell
npm test
```

Tests use `node:test`, Supertest, and `mongodb-memory-server`. They do not touch your Atlas cluster. The first run downloads a MongoDB binary and can take a minute.

## Backup

The free Atlas tier has no automatic backups. Export both collections, including soft-deleted rows:

```powershell
npm run backup
```

This writes timestamped JSON files under `backups\`. That folder is git-ignored. Copy the files somewhere safe (another disk or cloud drive) on a schedule you control.

## Import

Restore a backup file, a `GET /inbound` or `GET /outbound` page (`{ "items": [ ... ] }`), a sync payload (`{ "inbound": [ ... ], "outbound": [ ... ] }`), or one record object:

```powershell
npm run import -- .\backups\inboundreceipts-2026-11-16T14-00-00-000Z.json
```

- A missing `clientId` is filled with a new UUID.
- A `clientId` that already exists is left unchanged.
- `amount` is read as `quantity` when `quantity` is absent.
- `total` is recalculated on the server.
- `deletedAt` is kept, so tombstones stay deleted.

The script prints `inserted`, `skipped`, and `invalid`.

## Deploy (Render or Railway)

Use a European region so the app stays close to the Atlas cluster (Render: Frankfurt; Railway: EU West).

- Build command: `npm install`
- Start command: `npm start`
- Health check path: `/health`
- Environment variables: `MONGODB_URI`, `API_KEY`. Do not commit them. Leave `PORT` to the platform.

After the first deploy, call `/health`, then run `npm run backup` from your PC against the same database before you rely on it.

## Calling the API from Windows

Every `/api/v1` request needs the header `x-api-key`. `/health` does not.

In Windows PowerShell 5.1, send JSON as UTF-8 bytes so Arabic names are not re-encoded:

```powershell
$apiKey = "YOUR_KEY"
$headers = @{ "x-api-key" = $apiKey }

function Send-Json($Method, $Url, $Json) {
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($Json)
  return Invoke-RestMethod -Method $Method -Uri $Url -Headers $headers -ContentType "application/json; charset=utf-8" -Body $bytes
}
```

In Postman, create an environment variable `apiKey` and a header `x-api-key: {{apiKey}}`. Body type is raw JSON. For Arabic text, Postman's raw body is already UTF-8.

### GET /health

```powershell
Invoke-RestMethod http://localhost:3000/health
```

Postman: `GET http://localhost:3000/health`. No header.

### GET /api/v1/inbound?limit=10&page=1

```powershell
Invoke-RestMethod -Headers $headers "http://localhost:3000/api/v1/inbound?limit=10&page=1"
```

Postman: `GET` the same URL with the `x-api-key` header.

`GET /api/v1/outbound?limit=10&page=1` is the same call with `outbound` in the path.

### POST /api/v1/inbound

```powershell
$json = @'
{
  "clientId": "3f2b8c1e-5d4a-4b7e-9c11-0a1b2c3d4e5f",
  "date": "2026-10-09T10:00:00.000Z",
  "itemName": "أسمدة",
  "category": "مدخلات",
  "type": "NPK",
  "quantity": 100,
  "unit": "kg",
  "unitPrice": 12.5,
  "supplier": "Ahmed",
  "paymentType": "cash"
}
'@
Send-Json POST "http://localhost:3000/api/v1/inbound" $json
```

Postman: `POST http://localhost:3000/api/v1/inbound`, header `x-api-key`, raw body as above. The first insert returns `201`. The same `clientId` again returns `200` and the original row.

### DELETE /api/v1/inbound/:clientId

```powershell
Invoke-RestMethod -Method Delete -Headers $headers "http://localhost:3000/api/v1/inbound/3f2b8c1e-5d4a-4b7e-9c11-0a1b2c3d4e5f"
```

Postman: `DELETE` that URL with the `x-api-key` header. The response is always `200` and `{ "ok": true }`.

### POST /api/v1/outbound

```powershell
$json = @'
{
  "clientId": "4f2b8c1e-5d4a-4b7e-9c11-0a1b2c3d4e5a",
  "date": "2026-10-10T10:00:00.000Z",
  "product": "أسمدة",
  "type": "NPK",
  "field": "North Lot",
  "unit": "kg",
  "quantity": 50,
  "unitPrice": 15
}
'@
Send-Json POST "http://localhost:3000/api/v1/outbound" $json
```

Postman: `POST http://localhost:3000/api/v1/outbound` with the same body. `paymentType` is optional and defaults to `"cash"`. `field` is optional and defaults to `""`.

### DELETE /api/v1/outbound/:clientId

```powershell
Invoke-RestMethod -Method Delete -Headers $headers "http://localhost:3000/api/v1/outbound/4f2b8c1e-5d4a-4b7e-9c11-0a1b2c3d4e5a"
```

Postman: `DELETE` that URL with the `x-api-key` header.

### GET /api/v1/sync/changes

```powershell
Invoke-RestMethod -Headers $headers "http://localhost:3000/api/v1/sync/changes?limit=1000"
Invoke-RestMethod -Headers $headers "http://localhost:3000/api/v1/sync/changes?since=2026-11-16T14:30:00.000Z&until=2026-11-16T14:31:00.000Z&limit=1000"
```

Postman: `GET` those URLs with the `x-api-key` header. Store `serverTime` and send it back as `since` on the next sync. While `hasMore` is true, keep requesting with `since` set to `nextSince`. See [API.md](API.md) for the full cursor loop.

### GET /api/v1/dashboard/summary

```powershell
Invoke-RestMethod -Headers $headers http://localhost:3000/api/v1/dashboard/summary
```

Postman: `GET http://localhost:3000/api/v1/dashboard/summary` with the `x-api-key` header.

### GET /api/v1/inventory

```powershell
Invoke-RestMethod -Headers $headers http://localhost:3000/api/v1/inventory
```

Postman: `GET http://localhost:3000/api/v1/inventory` with the `x-api-key` header.

# HabitFlow REST API Server

Local Node.js + Express server for HabitFlow iOS app.

## Setup

```bash
# Install dependencies
npm install

# Start server
npm start
```

## Endpoints

- `GET /api/health` - Server health check
- `GET /api/habits` - Get all habits
- `GET /api/habits/:id` - Get single habit
- `POST /api/habits` - Create new habit
- `PUT /api/habits/:id` - Update habit
- `DELETE /api/habits/:id` - Delete habit

## Data Storage

Habits are stored in `habits.json` file in the same directory.

## Testing

Server runs on: http://localhost:3000

Test with curl:
```bash
# Health check
curl http://localhost:3000/api/health

# Get all habits
curl http://localhost:3000/api/habits
```

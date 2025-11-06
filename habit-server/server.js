// HabitFlow REST API Server
// Node.js + Express server for habit CRUD operations
// Stores data in habits.json file

const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;
const DATA_FILE = path.join(__dirname, 'habits.json');

// Middleware
app.use(express.json());

// CORS middleware for local development
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Request logging middleware
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.path}`);
  next();
});

// Load habits from file
function loadHabits() {
  try {
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE, 'utf8');
      return JSON.parse(data);
    }
    return [];
  } catch (error) {
    console.error('❌ Error loading habits:', error.message);
    return [];
  }
}

// Save habits to file
function saveHabits(habits) {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(habits, null, 2), 'utf8');
    console.log(`💾 Saved ${habits.length} habits to database`);
    return true;
  } catch (error) {
    console.error('❌ Error saving habits:', error.message);
    return false;
  }
}

// Initialize with empty array if file doesn't exist
let habits = loadHabits();
console.log(`📦 Loaded ${habits.length} habits from database`);

// ==================== API ENDPOINTS ====================

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    habitsCount: habits.length
  });
});

// GET all habits
app.get('/api/habits', (req, res) => {
  habits = loadHabits(); // Reload from file
  console.log(`✅ Fetched ${habits.length} habits`);
  res.json({ habits });
});

// GET single habit by ID
app.get('/api/habits/:id', (req, res) => {
  habits = loadHabits();
  const habit = habits.find(h => h.id === req.params.id);

  if (habit) {
    console.log(`✅ Found habit: ${habit.name}`);
    res.json({ habit });
  } else {
    console.log(`❌ Habit not found: ${req.params.id}`);
    res.status(404).json({ error: 'Habit not found' });
  }
});

// POST create new habit
app.post('/api/habits', (req, res) => {
  habits = loadHabits();
  const newHabit = req.body;

  // Validate required fields
  if (!newHabit.id || !newHabit.name) {
    console.log('❌ Invalid habit data');
    return res.status(400).json({ error: 'Missing required fields (id, name)' });
  }

  // Check for duplicate ID
  if (habits.find(h => h.id === newHabit.id)) {
    console.log(`❌ Duplicate habit ID: ${newHabit.id}`);
    return res.status(409).json({ error: 'Habit with this ID already exists' });
  }

  habits.push(newHabit);

  if (saveHabits(habits)) {
    console.log(`✅ Created habit: ${newHabit.name}`);
    res.status(201).json({ habit: newHabit });
  } else {
    res.status(500).json({ error: 'Failed to save habit' });
  }
});

// PUT update existing habit
app.put('/api/habits/:id', (req, res) => {
  habits = loadHabits();
  const index = habits.findIndex(h => h.id === req.params.id);

  if (index === -1) {
    console.log(`❌ Habit not found for update: ${req.params.id}`);
    return res.status(404).json({ error: 'Habit not found' });
  }

  const updatedHabit = req.body;

  // Preserve ID and creation date
  updatedHabit.id = habits[index].id;
  if (!updatedHabit.createdDate) {
    updatedHabit.createdDate = habits[index].createdDate;
  }

  habits[index] = updatedHabit;

  if (saveHabits(habits)) {
    console.log(`✅ Updated habit: ${updatedHabit.name}`);
    res.json({ habit: updatedHabit });
  } else {
    res.status(500).json({ error: 'Failed to update habit' });
  }
});

// DELETE habit
app.delete('/api/habits/:id', (req, res) => {
  habits = loadHabits();
  const index = habits.findIndex(h => h.id === req.params.id);

  if (index === -1) {
    console.log(`❌ Habit not found for deletion: ${req.params.id}`);
    return res.status(404).json({ error: 'Habit not found' });
  }

  const deletedHabit = habits[index];
  habits.splice(index, 1);

  if (saveHabits(habits)) {
    console.log(`🗑️  Deleted habit: ${deletedHabit.name}`);
    res.json({ success: true, message: 'Habit deleted successfully' });
  } else {
    res.status(500).json({ error: 'Failed to delete habit' });
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('❌ Server error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  console.log('\n' + '='.repeat(50));
  console.log('🚀 HabitFlow REST API Server');
  console.log('='.repeat(50));
  console.log(`📡 Server running on: http://localhost:${PORT}`);
  console.log(`📁 Data file: ${DATA_FILE}`);
  console.log(`📊 Current habits count: ${habits.length}`);
  console.log('='.repeat(50) + '\n');
  console.log('Available endpoints:');
  console.log('  GET    /api/health');
  console.log('  GET    /api/habits');
  console.log('  GET    /api/habits/:id');
  console.log('  POST   /api/habits');
  console.log('  PUT    /api/habits/:id');
  console.log('  DELETE /api/habits/:id');
  console.log('\n' + '='.repeat(50) + '\n');
});

import 'package:flutter/material.dart';

void main() {
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HabitListScreen(),
    );
  }
}

// Model
class Habit {
  final String id;
  String title;
  String description;
  Color color;
  IconData icon;
  String frequency;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.frequency,
  });
}

// In-memory data storage
class HabitStorage {
  static final List<Habit> _habits = [
    Habit(
      id: '1',
      title: 'Morning Exercise',
      description: 'Do 30 minutes of cardio and stretching',
      color: Colors.blue,
      icon: Icons.fitness_center,
      frequency: 'Daily',
    ),
    Habit(
      id: '2',
      title: 'Read Books',
      description: 'Read at least 20 pages of any book',
      color: Colors.green,
      icon: Icons.book,
      frequency: 'Daily',
    ),
    Habit(
      id: '3',
      title: 'Drink Water',
      description: 'Drink 8 glasses of water throughout the day',
      color: Colors.cyan,
      icon: Icons.water_drop,
      frequency: 'Daily',
    ),
  ];

  static List<Habit> get habits => _habits;

  static void addHabit(Habit habit) {
    _habits.add(habit);
  }

  static void updateHabit(String id, Habit updatedHabit) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = updatedHabit;
    }
  }

  static void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
  }

  static Habit? getHabit(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }
}

// 1. MAIN LIST SCREEN (READ)
class HabitListScreen extends StatefulWidget {
  const HabitListScreen({Key? key}) : super(key: key);

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: HabitStorage.habits.isEmpty
          ? const Center(
              child: Text('No habits yet. Add one to get started!'),
            )
          : ListView.builder(
              itemCount: HabitStorage.habits.length,
              itemBuilder: (context, index) {
                final habit = HabitStorage.habits[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: habit.color,
                      child: Icon(habit.icon, color: Colors.white),
                    ),
                    title: Text(habit.title),
                    subtitle: Text(habit.frequency),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteHabit(habit.id);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewHabitScreen(habitId: habit.id),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHabitScreen()),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteHabit(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                HabitStorage.deleteHabit(id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// 2. VIEW HABIT DETAIL SCREEN (READ ONE)
class ViewHabitScreen extends StatelessWidget {
  final String habitId;

  const ViewHabitScreen({Key? key, required this.habitId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final habit = HabitStorage.getHabit(habitId);

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Not Found')),
        body: const Center(child: Text('Habit not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(habitId: habitId),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: habit.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(habit.icon, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailCard('Title', habit.title),
            const SizedBox(height: 16),
            _buildDetailCard('Description', habit.description),
            const SizedBox(height: 16),
            _buildDetailCard('Frequency', habit.frequency),
            const SizedBox(height: 16),
            _buildColorCard('Color', habit.color),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCard(String label, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  color.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 3. ADD HABIT SCREEN (CREATE)
class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({Key? key}) : super(key: key);

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.star;
  String _selectedFrequency = 'Daily';

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
  ];

  final List<IconData> _icons = [
    Icons.star,
    Icons.fitness_center,
    Icons.book,
    Icons.water_drop,
    Icons.restaurant,
    Icons.bedtime,
    Icons.emoji_emotions,
    Icons.work,
  ];

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Frequency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _frequencies.map((freq) {
                  return DropdownMenuItem(value: freq, child: Text(freq));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Select Icon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _icons.map((icon) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon ? Colors.blue.shade100 : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Habit', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final newHabit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        color: _selectedColor,
        icon: _selectedIcon,
        frequency: _selectedFrequency,
      );

      HabitStorage.addHabit(newHabit);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// 4. EDIT HABIT SCREEN (UPDATE)
class EditHabitScreen extends StatefulWidget {
  final String habitId;

  const EditHabitScreen({Key? key, required this.habitId}) : super(key: key);

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  late Color _selectedColor;
  late IconData _selectedIcon;
  late String _selectedFrequency;

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
  ];

  final List<IconData> _icons = [
    Icons.star,
    Icons.fitness_center,
    Icons.book,
    Icons.water_drop,
    Icons.restaurant,
    Icons.bedtime,
    Icons.emoji_emotions,
    Icons.work,
  ];

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    final habit = HabitStorage.getHabit(widget.habitId);
    if (habit != null) {
      _titleController = TextEditingController(text: habit.title);
      _descriptionController = TextEditingController(text: habit.description);
      _selectedColor = habit.color;
      _selectedIcon = habit.icon;
      _selectedFrequency = habit.frequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = HabitStorage.getHabit(widget.habitId);

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Not Found')),
        body: const Center(child: Text('Habit not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Frequency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _frequencies.map((freq) {
                  return DropdownMenuItem(value: freq, child: Text(freq));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Select Icon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _icons.map((icon) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon ? Colors.blue.shade100 : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update Habit', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateHabit() {
    if (_formKey.currentState!.validate()) {
      final updatedHabit = Habit(
        id: widget.habitId,
        title: _titleController.text,
        description: _descriptionController.text,
        color: _selectedColor,
        icon: _selectedIcon,
        frequency: _selectedFrequency,
      );

      HabitStorage.updateHabit(widget.habitId, updatedHabit);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
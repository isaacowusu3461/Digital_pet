import 'dart:async';

import 'package:flutter/material.dart';

import 'pet_model.dart';

void main() {
  runApp(const DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const PetPage(),
    );
  }
}

class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage>
    with SingleTickerProviderStateMixin {
  final PetModel _pet = PetModel();

  final TextEditingController _nameController =
      TextEditingController(text: 'Pip');

  Timer? _hungerTimer;
  Timer? _highMoodTimer;
  Timer? _reactionTimer;

  late AnimationController _breathingController;

  bool _gameOver = false;
  bool _hasWon = false;
  String _reaction = '';

  @override
  void initState() {
    super.initState();

    _startHungerTimer();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.98,
      upperBound: 1.02,
    )..repeat(reverse: true);
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (!mounted || _gameOver || _hasWon) {
          _hungerTimer?.cancel();
          return;
        }

        setState(() {
          _pet.hungerTick();
        });

        _updateOutcome();
      },
    );
  }

  void _updateOutcome() {
    if (_gameOver || _hasWon) return;

    if (_pet.isLoss) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;

      _hungerTimer?.cancel();

      setState(() {
        _gameOver = true;
      });

      return;
    }

    if (_pet.happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    _highMoodTimer ??= Timer(
      const Duration(minutes: 3),
      () {
        _highMoodTimer = null;

        if (!mounted ||
            _gameOver ||
            _pet.happiness <= 80) {
          return;
        }

        setState(() {
          _hasWon = true;
        });

        _hungerTimer?.cancel();
      },
    );
  }

  void _feedPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      _pet.feed();
      _reaction = '🍖';
    });

    _startReaction();
    _updateOutcome();
  }

  void _playPet() {
    if (_gameOver || _hasWon) return;

    if (_pet.energy < 15) {
      _showMessage('Not enough energy to play.');
      return;
    }

    setState(() {
      _pet.play();
      _reaction = '🎾';
    });

    _startReaction();
    _updateOutcome();
  }

  void _runPet() {
    if (_gameOver || _hasWon) return;

    if (_pet.energy < 25) {
      _showMessage('Not enough energy to run.');
      return;
    }

    setState(() {
      _pet.run();
      _reaction = '🏃';
    });

    _startReaction();
    _updateOutcome();
  }

  void _sleepPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      _pet.sleep();
      _reaction = '💤';
    });

    _startReaction();
    _updateOutcome();
  }

  void _startReaction() {
    _reactionTimer?.cancel();

    _reactionTimer = Timer(
      const Duration(milliseconds: 900),
      () {
        if (!mounted) return;

        setState(() {
          _reaction = '';
        });
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmName() {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      _showMessage('Please enter a name.');
      return;
    }

    setState(() {
      _pet.name = newName;
    });

    _showMessage('Pet name updated.');
  }

  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    _hungerTimer?.cancel();

    setState(() {
      _pet.reset();
      _gameOver = false;
      _hasWon = false;
      _reaction = '';
    });

    _startHungerTimer();
  }

  Color get _moodColor {
    if (_pet.happiness > 70) {
      return Colors.green;
    }

    if (_pet.happiness >= 30) {
      return Colors.yellow.shade700;
    }

    return Colors.red;
  }

  double get _petScale {
    if (_pet.happiness > 70) {
      return 1.06;
    }

    if (_pet.happiness < 30) {
      return 0.94;
    }

    return 1.0;
  }

  String get _petMessage {
    if (_gameOver) {
      return 'I need a rest.';
    }

    if (_hasWon) {
      return 'Best day ever!';
    }

    if (_pet.hunger > 80) {
      return "I'm starving!";
    }

    if (_pet.energy < 20) {
      return 'So sleepy...';
    }

    if (_pet.happiness <= 30) {
      return 'Play with me?';
    }

    return "Hi, I'm ${_pet.name}!";
  }

  String get _outcomeText {
    if (_gameOver) {
      return 'Game Over';
    }

    if (_hasWon) {
      return 'You Win!';
    }

    return _pet.mood;
  }

  Widget _buildMeter({
    required String label,
    required int value,
    required IconData icon,
  }) {
    final reduceMotion =
        MediaQuery.of(context).disableAnimations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              '$label: $value',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: value / 100,
          ),
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 400),
          builder: (context, progress, child) {
            return LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPet() {
    final reduceMotion =
        MediaQuery.of(context).disableAnimations;

    Widget petImage = ColorFiltered(
      colorFilter: ColorFilter.mode(
        _moodColor,
        BlendMode.modulate,
      ),
      child: Image.asset(
        'assets/pet.png',
        width: 180,
        height: 180,
        fit: BoxFit.contain,
      ),
    );

    petImage = AnimatedScale(
      scale: _petScale,
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      child: petImage,
    );

    if (!reduceMotion) {
      petImage = AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingController.value,
            child: child,
          );
        },
        child: petImage,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        petImage,

        if (_reaction.isNotEmpty)
          Positioned(
            right: 15,
            top: 5,
            child: AnimatedOpacity(
              opacity: _reaction.isEmpty ? 0 : 1,
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              child: Text(
                _reaction,
                style: const TextStyle(fontSize: 38),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton.icon(
          onPressed:
              (_gameOver || _hasWon) ? null : onPressed,
          icon: Icon(icon),
          label: Text(text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.of(context).disableAnimations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                _outcomeText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _moodColor,
                ),
              ),

              const SizedBox(height: 8),

              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                child: Text(
                  _petMessage,
                  key: ValueKey(_petMessage),
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _buildPet(),

              const SizedBox(height: 10),

              Text(
                _pet.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _buildMeter(
                label: 'Happiness',
                value: _pet.happiness,
                icon: Icons.favorite,
              ),

              _buildMeter(
                label: 'Hunger',
                value: _pet.hunger,
                icon: Icons.restaurant,
              ),

              _buildMeter(
                label: 'Energy',
                value: _pet.energy,
                icon: Icons.bolt,
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _nameController,
                enabled: !_gameOver && !_hasWon,
                decoration: const InputDecoration(
                  labelText: 'Pet name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      (_gameOver || _hasWon)
                          ? null
                          : _confirmName,
                  child: const Text('Confirm Name'),
                ),
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  _buildActionButton(
                    text: 'Feed',
                    icon: Icons.restaurant,
                    onPressed: _feedPet,
                  ),
                  _buildActionButton(
                    text: 'Play',
                    icon: Icons.sports_tennis,
                    onPressed: _playPet,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  _buildActionButton(
                    text: 'Run',
                    icon: Icons.directions_run,
                    onPressed: _runPet,
                  ),
                  _buildActionButton(
                    text: 'Sleep',
                    icon: Icons.bedtime,
                    onPressed: _sleepPet,
                  ),
                ],
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _resetPet,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'Keep happiness above 80 for 3 minutes to win.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    _reactionTimer?.cancel();

    _nameController.dispose();
    _breathingController.dispose();

    super.dispose();
  }
}
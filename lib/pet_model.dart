class PetModel {
  String name;
  int happiness;
  int hunger;
  int energy;

  PetModel({
    this.name = 'Pip',
    this.happiness = 50,
    this.hunger = 50,
    this.energy = 70,
  });

  int clampMeter(int value) {
    return value.clamp(0, 100);
  }

  void reset() {
    name = 'Pip';
    happiness = 50;
    hunger = 50;
    energy = 70;
  }

  void feed() {
    hunger = clampMeter(hunger - 10);

    if (hunger < 30) {
      happiness = clampMeter(happiness - 20);
    } else {
      happiness = clampMeter(happiness + 10);
    }
  }

  void play() {
    if (energy < 15) return;

    happiness = clampMeter(happiness + 15);
    hunger = clampMeter(hunger + 5);
    energy = clampMeter(energy - 15);
  }

  void run() {
    if (energy < 25) return;

    happiness = clampMeter(happiness + 20);
    hunger = clampMeter(hunger + 10);
    energy = clampMeter(energy - 25);
  }

  void sleep() {
    energy = clampMeter(energy + 30);
    hunger = clampMeter(hunger + 5);
    happiness = clampMeter(happiness + 5);
  }

  void hungerTick() {
    if (hunger + 5 > 100) {
      hunger = 100;
      happiness = clampMeter(happiness - 20);
    } else {
      hunger += 5;
    }
  }

  String get mood {
    if (happiness > 70) return 'Happy';
    if (happiness >= 30) return 'Neutral';
    return 'Unhappy';
  }

  bool get isLoss {
    return hunger == 100 && happiness <= 10;
  }
}
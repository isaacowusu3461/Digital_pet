import 'package:flutter_test/flutter_test.dart';

import 'package:digital_pet/pet_model.dart';

void main() {
  group('PetModel tests', () {
    test('pet starts with the correct values', () {
      final pet = PetModel();

      expect(pet.name, 'Pip');
      expect(pet.happiness, 50);
      expect(pet.hunger, 50);
      expect(pet.energy, 70);
    });

    test('feed decreases hunger and increases happiness', () {
      final pet = PetModel(
        happiness: 50,
        hunger: 50,
        energy: 70,
      );

      pet.feed();

      expect(pet.hunger, 40);
      expect(pet.happiness, 60);
    });

    test('play increases happiness and uses energy', () {
      final pet = PetModel(
        happiness: 50,
        hunger: 50,
        energy: 70,
      );

      pet.play();

      expect(pet.happiness, 65);
      expect(pet.hunger, 55);
      expect(pet.energy, 55);
    });

    test('run uses more energy than play', () {
      final pet = PetModel(
        happiness: 50,
        hunger: 50,
        energy: 70,
      );

      pet.run();

      expect(pet.happiness, 70);
      expect(pet.hunger, 60);
      expect(pet.energy, 45);
    });

    test('sleep restores energy', () {
      final pet = PetModel(
        happiness: 50,
        hunger: 50,
        energy: 30,
      );

      pet.sleep();

      expect(pet.energy, 60);
      expect(pet.hunger, 55);
      expect(pet.happiness, 55);
    });

    test('meters never go below zero', () {
      final pet = PetModel(
        happiness: 5,
        hunger: 5,
        energy: 5,
      );

      pet.feed();

      expect(pet.hunger, greaterThanOrEqualTo(0));
      expect(pet.happiness, greaterThanOrEqualTo(0));
      expect(pet.energy, greaterThanOrEqualTo(0));
    });

    test('meters never go above 100', () {
      final pet = PetModel(
        happiness: 100,
        hunger: 100,
        energy: 100,
      );

      pet.sleep();

      expect(pet.happiness, lessThanOrEqualTo(100));
      expect(pet.hunger, lessThanOrEqualTo(100));
      expect(pet.energy, lessThanOrEqualTo(100));
    });

    test('loss condition is true at hunger 100 and happiness 10', () {
      final pet = PetModel(
        happiness: 10,
        hunger: 100,
        energy: 20,
      );

      expect(pet.isLoss, true);
    });

    test('loss condition is false when happiness is above 10', () {
      final pet = PetModel(
        happiness: 11,
        hunger: 100,
        energy: 20,
      );

      expect(pet.isLoss, false);
    });

    test('reset restores the initial values', () {
      final pet = PetModel(
        name: 'Max',
        happiness: 90,
        hunger: 90,
        energy: 20,
      );

      pet.reset();

      expect(pet.name, 'Pip');
      expect(pet.happiness, 50);
      expect(pet.hunger, 50);
      expect(pet.energy, 70);
    });

    test('mood changes at the required happiness boundaries', () {
      final unhappy = PetModel(happiness: 29);
      final neutral = PetModel(happiness: 30);
      final happy = PetModel(happiness: 71);

      expect(unhappy.mood, 'Unhappy');
      expect(neutral.mood, 'Neutral');
      expect(happy.mood, 'Happy');
    });

    test('play cannot happen when energy is too low', () {
      final pet = PetModel(
        happiness: 50,
        hunger: 50,
        energy: 10,
      );

      pet.play();

      expect(pet.happiness, 50);
      expect(pet.hunger, 50);
      expect(pet.energy, 10);
    });

    test('run cannot happen when energy is too low', () {
      final pet = PetModel(
        happiness: 50,
        hunger: 50,
        energy: 20,
      );

      pet.run();

      expect(pet.happiness, 50);
      expect(pet.hunger, 50);
      expect(pet.energy, 20);
    });

    test('hunger tick increases hunger', () {
      final pet = PetModel(
        happiness: 50,
        hunger: 50,
        energy: 70,
      );

      pet.hungerTick();

      expect(pet.hunger, 55);
    });

    test('hunger overflow reduces happiness', () {
      final pet = PetModel(
        happiness: 50,
        hunger: 100,
        energy: 70,
      );

      pet.hungerTick();

      expect(pet.hunger, 100);
      expect(pet.happiness, 30);
    });
  });
}
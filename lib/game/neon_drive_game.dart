import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'components/road.dart';
import 'components/player_car.dart';
import 'components/traffic_car.dart';
import 'components/coin.dart';

enum GameState { playing, dead, paused }

class NeonDriveGame extends FlameGame {
  double currentSpeed = GameConstants.initialSpeed;
  double distanceTraveled = 0;
  int coinsCollected = 0;
  int lives = GameConstants.maxLives;
  GameState state = GameState.playing;

  late PlayerCar _player;
  late Road _road;
  late TrafficSpawner _trafficSpawner;
  late CoinSpawner _coinSpawner;

  double _roadLeft = 0;

  final VoidCallback onGameOver;
  final Function(int coins, double distance) onStatsUpdate;

  NeonDriveGame({
    required this.onGameOver,
    required this.onStatsUpdate,
  });

  @override
  Color backgroundColor() => const Color(0xFF0A0A1A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _roadLeft = (size.x - GameConstants.roadWidth) / 2;

    _road = Road();
    await add(_road);

    _player = PlayerCar()
      ..position = Vector2(
        _roadLeft + GameConstants.roadWidth / 2,
        size.y * 0.75,
      );
    await add(_player);

    _trafficSpawner = TrafficSpawner();
    await add(_trafficSpawner);

    _coinSpawner = CoinSpawner();
    await add(_coinSpawner);

    add(FpsTextComponent(position: Vector2(4, 4)));
  }

  @override
  void update(double dt) {
    if (state != GameState.playing) return;
    super.update(dt);

    currentSpeed = min(
      GameConstants.maxSpeed,
      currentSpeed + GameConstants.speedIncrement * dt,
    );
    distanceTraveled += currentSpeed * dt / 100;

    _checkCollisions();
    _cleanupOffscreenComponents();
    onStatsUpdate(coinsCollected, distanceTraveled);
  }

  void _checkCollisions() {
    final playerRect = Rect.fromCenter(
      center: Offset(_player.x, _player.y),
      width: GameConstants.playerCarWidth * 0.7,
      height: GameConstants.playerCarHeight * 0.8,
    );

    for (final component in children) {
      if (component is TrafficCar) {
        final trafficRect = Rect.fromCenter(
          center: Offset(component.x, component.y),
          width: GameConstants.trafficCarWidth * 0.7,
          height: GameConstants.trafficCarHeight * 0.8,
        );
        if (playerRect.overlaps(trafficRect)) {
          _handleCrash(component);
        }
      }
      if (component is Coin) {
        final coinRect = Rect.fromCenter(
          center: Offset(component.x, component.y),
          width: 20,
          height: 20,
        );
        if (playerRect.overlaps(coinRect)) {
          coinsCollected += GameConstants.coinValue.toInt();
          component.removeFromParent();
        }
      }
    }
  }

  void _handleCrash(TrafficCar car) {
    car.removeFromParent();
    lives--;
    if (lives <= 0) {
      state = GameState.dead;
      onGameOver();
    }
  }

  void _cleanupOffscreenComponents() {
    final toRemove = <Component>[];
    for (final component in children) {
      if (component is TrafficCar && (component.isOffScreen || component.isAboveScreen)) {
        toRemove.add(component);
      }
      if (component is Coin && component.isOffScreen) {
        toRemove.add(component);
      }
    }
    for (final c in toRemove) {
      c.removeFromParent();
    }
  }

  void moveLeft() => _player.moveLeft(_roadLeft);
  void moveRight() => _player.moveRight(_roadLeft);

  void revive() {
    lives = 1;
    currentSpeed = GameConstants.initialSpeed;
    state = GameState.playing;
    // Remove all traffic
    for (final component in children.toList()) {
      if (component is TrafficCar) component.removeFromParent();
    }
  }

  void pause() => state = GameState.paused;
  void resume() => state = GameState.playing;
}

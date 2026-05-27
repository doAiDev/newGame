import 'package:flutter/material.dart';

class AdManager {
  static final AdManager _instance = AdManager._();
  factory AdManager() => _instance;
  AdManager._();

  Future<void> initialize() async {}
  void showInterstitialOnGameOver() {}
  bool get isRewardedReady => false;
  void showRewardedForRevive({required VoidCallback onRewarded}) {}
}

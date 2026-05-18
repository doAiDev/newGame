import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants.dart';

class AdManager {
  static final AdManager _instance = AdManager._();
  factory AdManager() => _instance;
  AdManager._();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _sessionCount = 0;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdIds.interstitialTest,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AdIds.rewardedTest,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  void showInterstitialOnGameOver() {
    _sessionCount++;
    // Show interstitial every 3 game overs
    if (_sessionCount % 3 != 0) return;
    _interstitialAd?.show();
    _interstitialAd = null;
    _loadInterstitial();
  }

  void showRewardedForRevive({required VoidCallback onRewarded}) {
    if (_rewardedAd == null) return;
    _rewardedAd!.show(
      onUserEarnedReward: (_, __) => onRewarded(),
    );
    _rewardedAd = null;
    _loadRewarded();
  }

  bool get isRewardedReady => _rewardedAd != null;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AdIds.bannerTest,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }
}

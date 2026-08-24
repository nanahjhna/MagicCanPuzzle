import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({Key? key}) : super(key: key);

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // 💡 테스트용 광고 단위 ID (실제 출시 시 발급받은 배너 광고 ID로 교체하세요)
  //final String _adUnitId = 'ca-app-pub-3940256099942544/6331489573';
  final String _adUnitId = 'ca-app-pub-1474045642143501/6339356213';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('BannerAd failed to load: $err');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        color: Colors.red, // 📌 광고가 여기에 자리를 잡는지 확인용
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // 로딩 중일 때도 빨간색이 뜨는지 확인
    return Container(
      height: 50,
      color: Colors.blue,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
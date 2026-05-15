import 'dart:async';
import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'jeon_ban_ggul_view.dart';
import 'quant_dashboard_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KOOSPI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Pretendard', useMaterial3: true),
      home: const ScannerHome(),
    );
  }
}

class ScannerHome extends StatefulWidget {
  const ScannerHome({super.key});

  @override
  State<ScannerHome> createState() => _ScannerHomeState();
}

class _ScannerHomeState extends State<ScannerHome> {
  final SupabaseService _supabaseService = SupabaseService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _scannerKey = GlobalKey();

  List<dynamic> results = [];
  bool isScanning = false;
  int scanProgress = 0;
  bool scanComplete = false;
  bool inguMode = false;

  // 이스터에그 툴팁 상태
  bool showTooltip = false;
  String tooltipMessage = "";
  int _clickCount = 0;
  DateTime _lastSecretClickTime = DateTime.now();
  Timer? _tooltipTimer;

  void startScan() async {
    setState(() {
      isScanning = true;
      scanComplete = false;
      scanProgress = 0;
      results = [];
    });

    for (int i = 0; i <= 100; i += 20) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => scanProgress = i);
    }

    try {
      if (!inguMode) {
        final data = await _supabaseService.fetchSignals();
        if (mounted) {
          setState(() {
            results = data;
          });
        }
      } else {
        final data = await _supabaseService.fetchInguSignals();
        if (mounted) {
          setState(() {
            results = data;
          });
        }
      }
    } catch (error) {
      debugPrint("스캔 중 오류 발생: $error");
    } finally {
      if (mounted) {
        setState(() {
          isScanning = false;
          scanComplete = true;
        });
      }
    }
  }

  void _toggleMode() {
    if (inguMode) {
      setState(() {
        inguMode = false;
        results = []; // 데이터 혼선 방지를 위해 결과 초기화
        _clickCount = 0;
        showTooltip = true;
        tooltipMessage = "퀀트 엔진 복구 완료";
      });
      _tooltipTimer?.cancel();
      _tooltipTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => showTooltip = false);
      });
      return;
    }

    final now = DateTime.now();
    setState(() {
      if (now.difference(_lastSecretClickTime).inMilliseconds > 800) {
        _clickCount = 1;
      } else {
        _clickCount++;
      }
      _lastSecretClickTime = now;
      showTooltip = true;

      if (_clickCount <= 3) {
        tooltipMessage = "이걸 누르면 어떤 일이 일어날 것 같은 느낌이...";
      } else if (_clickCount <= 7) {
        tooltipMessage = "뭔가 변하는 것 같은데?";
      } else if (_clickCount == 8) {
        tooltipMessage = "전인구 프로토콜 가동";
      } else if (_clickCount >= 9) {
        inguMode = true;
        results = [];
        _clickCount = 0;
        tooltipMessage = "전반꿀 알파 엔진 가동!";
      }
    });

    _tooltipTimer?.cancel();
    _tooltipTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => showTooltip = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (inguMode) {
      return JeonBanGgulView(
        results: results,
        isScanning: isScanning,
        scanProgress: scanProgress,
        scanComplete: scanComplete,
        onStartScan: startScan,
        onToggleMode: _toggleMode,
        scrollController: _scrollController,
        scannerKey: _scannerKey,
        showTooltip: showTooltip,
        tooltipMessage: tooltipMessage,
      );
    } else {
      return QuantDashboardView(
        results: results,
        isScanning: isScanning,
        scanProgress: scanProgress,
        scanComplete: scanComplete,
        onStartScan: startScan,
        onToggleMode: _toggleMode,
        scrollController: _scrollController,
        scannerKey: _scannerKey,
        showTooltip: showTooltip,
        tooltipMessage: tooltipMessage,
      );
    }
  }
}

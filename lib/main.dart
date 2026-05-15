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
    _clickCount++;
    if (_clickCount >= 3) {
      setState(() {
        inguMode = !inguMode;
        results = []; // 데이터 혼선 방지를 위해 결과 초기화
        _clickCount = 0;
        showTooltip = true;
        tooltipMessage = inguMode ? "전반꿀 모드 활성화!" : "퀀트 엔진 복구 완료";
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => showTooltip = false);
      });
    } else {
      setState(() {
        showTooltip = true;
        tooltipMessage = "비밀 모드 접근까지 ${3 - _clickCount}회 남음";
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => showTooltip = false);
      });
    }
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

import 'package:flutter/material.dart';

class QuantDashboardView extends StatelessWidget {
  final List<dynamic> results;
  final bool isScanning;
  final int scanProgress;
  final bool scanComplete;
  final VoidCallback onStartScan;
  final VoidCallback onToggleMode;
  final ScrollController scrollController;
  final GlobalKey scannerKey;
  final bool showTooltip;
  final String tooltipMessage;

  const QuantDashboardView({
    super.key,
    required this.results,
    required this.isScanning,
    required this.scanProgress,
    required this.scanComplete,
    required this.onStartScan,
    required this.onToggleMode,
    required this.scrollController,
    required this.scannerKey,
    required this.showTooltip,
    required this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            _buildHeader(context),
            _buildHero(),
            _buildScannerTool(),
            _buildFeaturesGrid(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onToggleMode,
              child: Row(
                children: [
                  _iconBox(Icons.auto_graph, Colors.blue),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("IN_KOOSPI",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                          if (showTooltip) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tooltipMessage,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Text("QUANT ENGINE V2.1",
                          style: TextStyle(
                              fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                ],
              ),
            ),
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: color, size: 28),
      );

  Widget _loginButton() => ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _buildHero() => Container(
        padding: const EdgeInsets.all(80),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(30)),
              child: const Text("실시간 글로벌 기관 수급 데이터 분석 중", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 32),
            const Text("글로벌 고래들의\n포트폴리오를 스캔하다",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, height: 1.1, color: Color(0xFF0F172A), letterSpacing: -2)),
            const SizedBox(height: 32),
            const Text("13F 보고서와 실시간 공시를 AI가 교차 분석하여\n기관들이 조용히 매집 중인 종목을 가장 먼저 발견합니다.",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Color(0xFF64748B), height: 1.6)),
          ],
        ),
      );

  Widget _buildScannerTool() => Container(
        key: scannerKey,
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20))],
        ),
        child: Column(
          children: [
            const Text("실시간 종목 스캐너", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            const Text("설정된 알고리즘을 기반으로 글로벌 시장의 최적 투자 후보군을 실시간 추출합니다.", style: TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: isScanning ? null : onStartScan,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: Text(isScanning ? "분석 중..." : "스캔 시작",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            if (isScanning || scanComplete) _buildScanProgress(),
            if (scanComplete) _buildResultsList(),
          ],
        ),
      );

  Widget _buildScanProgress() => Column(
        children: [
          const SizedBox(height: 48),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
                value: scanProgress / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[100],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue)),
          ),
          const SizedBox(height: 16),
          Text("$scanProgress% 분석 완료...", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ],
      );

  Widget _buildResultsList() => Column(
        children: [
          const SizedBox(height: 60),
          ...results.map((item) => _resultCard(item as Map<String, dynamic>)),
        ],
      );

  Widget _resultCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item['name']} (${item['ticker']})",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "분석 일시: ${item['published_at']?.toString().split('T')[0] ?? '날짜 미상'}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (item['url'] != null && item['url'].toString().isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.open_in_new, color: Colors.blue),
                  onPressed: () {
                    // URL 오픈 로직
                  },
                ),
              _badge("신뢰도 ${item['score'] ?? 90}%", Icons.verified, Colors.blue),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFE2E8F0)),
          _infoLine("고래 분석", item['analysis_summary'] ?? '분석 데이터 없음', italic: true),
          const SizedBox(height: 12),
          _infoLine("포지션", item['whale_position'] ?? '포지션 미설정', color: Colors.blue[700]),
        ],
      ),
    );
  }

  Widget _badge(String text, IconData icon, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      );

  Widget _infoLine(String label, String value, {bool italic = false, Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color ?? const Color(0xFF334155),
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              fontWeight: italic ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {"icon": Icons.account_balance, "title": "기관 수급 분석", "desc": "글로벌 헤지펀드 및 거물급 투자자들의 13F 보고서를 실시간 추적합니다."},
      {"icon": Icons.psychology, "title": "AI 모멘텀 측정", "desc": "단순 수급을 넘어 현재 시장의 심리와 차트 모멘텀을 AI가 동시에 계산합니다."},
      {"icon": Icons.security, "title": "리스크 필터링", "desc": "급등주 추격 매수가 아닌, 안정적인 매집 구간의 종목만을 선별하여 제안합니다."}
    ];

    return Container(
      padding: const EdgeInsets.all(80),
      child: LayoutBuilder(builder: (context, constraints) {
        double cardWidth = (constraints.maxWidth - 80) / 3;
        if (constraints.maxWidth < 900) cardWidth = constraints.maxWidth;

        return Wrap(
          spacing: 40,
          runSpacing: 40,
          children: features.map((f) => _featureCard(f as Map<String, dynamic>, cardWidth)).toList(),
        );
      }),
    );
  }

  Widget _featureCard(Map<String, dynamic> f, double width) => Container(
        width: width,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconBox(f['icon'] as IconData, Colors.blue),
            const SizedBox(height: 32),
            Text(f['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            Text(f['desc'] as String, style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), height: 1.5)),
          ],
        ),
      );

  Widget _buildFooter() => Container(
        padding: const EdgeInsets.all(48),
        child: const Text("© 2026 IN_KOOSPI_QUANT_SYSTEM. ALL RIGHTS RESERVED.",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, letterSpacing: 2)),
      );
}

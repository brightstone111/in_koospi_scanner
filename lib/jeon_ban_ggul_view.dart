import 'package:flutter/material.dart';

class JeonBanGgulView extends StatelessWidget {
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

  const JeonBanGgulView({
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
    const bgColor = Color(0xFF050505);

    return Scaffold(
      backgroundColor: bgColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 900;
          final bool isMobile = constraints.maxWidth < 600;

          return Column(
            children: [
              _buildHeader(context, isMobile),
              _buildWarningBanner(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 24, 
                      vertical: isMobile ? 16 : 32
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopControlSection(isMobile),
                        SizedBox(height: isMobile ? 24 : 48),
                        if (!isMobile) _buildTableHeader(isCompact),
                        if (!isMobile) const Divider(color: Colors.white10, height: 1),
                        if (isScanning) _buildScanningState(),
                        if (!isScanning && scanComplete) 
                          isMobile ? _buildMobileResults() : _buildResultsList(isCompact),
                        if (!isScanning && !scanComplete) _buildEmptyState(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Colors.deepOrange.withOpacity(0.3)),
        ),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.deepOrange),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(isMobile ? 'KOOSPI' : '(인)KOOSPI',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                          if (showTooltip) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tooltipMessage,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Text('딥 알파 엔진 가동중',
                          style: TextStyle(fontSize: 10, color: Colors.deepOrange, letterSpacing: 1.5)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      color: Colors.deepOrange,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: const Center(
        child: Text(
          '접근 제한 영역: 전반꿀 알파 전략 활성화 - 데이터 역추적 모드',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5),
        ),
      ),
    );
  }

  Widget _buildTopControlSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.search, color: Colors.deepOrange, size: 32),
                      const SizedBox(width: 12),
                      const Text(
                        '비밀_알파_스캔_모드',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Text('고성능', style: TextStyle(color: Colors.deepOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '현재 시장의 모든 공포 지표와 세력의 의도를 교차 분석하여 최상위 매수 타점을 도출합니다.',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (!isMobile) _buildScanButton(),
          ],
        ),
        if (isMobile) const SizedBox(height: 24),
        if (isMobile) Center(child: _buildScanButton()),
      ],
    );
  }

  Widget _buildScanButton() {
    return ElevatedButton(
      onPressed: isScanning ? null : onStartScan,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 20,
        shadowColor: Colors.deepOrange.withOpacity(0.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('알파_엔진_가동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          SizedBox(width: 12),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildTableHeader(bool isCompact) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          _headerItem('종목 / 티커', 2),
          _headerItem('전인구의 예언', 3),
          _headerItem('당시의 기록', 3),
          if (!isCompact) _headerItem('포지션', 2),
          _headerItem('전반꿀 팩트체크', 2),
        ],
      ),
    );
  }

  Widget _headerItem(String label, int flex) => Expanded(
        flex: flex,
        child: Text(label, style: const TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold)),
      );

  Widget _buildScanningState() {
    return Container(
      padding: const EdgeInsets.all(100),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Colors.deepOrange),
          const SizedBox(height: 24),
          Text('$scanProgress% 동기화 중...', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(100),
        child: Text('알파 엔진을 가동하여 예언을 분석하세요.', style: TextStyle(color: Colors.white24)),
      ),
    );
  }

  Widget _buildResultsList(bool isCompact) {
    return Column(
      children: results.map((item) => _buildTableRow(item as Map<String, dynamic>, isCompact)).toList(),
    );
  }

  Widget _buildMobileResults() {
    return Column(
      children: results.map((item) => _buildMobileCard(item as Map<String, dynamic>)).toList(),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> item, bool isCompact) {
    final prediction = item['prediction_type'] ?? 'Bullish';
    final double returnRate = item['return_rate'] ?? 0.0;
    
    String factCheckText = "";
    Color factColor = Colors.white;
    if (prediction == 'Bullish') {
      factCheckText = "전인구 보고 샀으면 수익률: ${returnRate.toStringAsFixed(2)}%";
      factColor = returnRate >= 0 ? Colors.redAccent : Colors.blueAccent;
    } else {
      factCheckText = "전인구 보고 팔았으면 날린 수익: ${returnRate.toStringAsFixed(2)}%";
      factColor = returnRate >= 0 ? Colors.redAccent : Colors.blueAccent;
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            // 종목 / 티커
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _predictionIcon(prediction),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(item['ticker'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 전인구의 예언
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  "\"${item['analysis_summary'] ?? '분석 데이터 없음'}\"",
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            // 당시의 기록
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                      children: [
                        const TextSpan(text: '전인구는 당시 '),
                        TextSpan(text: '"${item['name']}"', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        TextSpan(text: prediction == 'Bullish' ? '을(를) 사라고 했습니다.' : '을(를) 팔라고 했습니다.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('발행일: ${item['published_at']?.toString().split('T')[0] ?? 'undefined'}', 
                      style: const TextStyle(color: Colors.white24, fontSize: 10, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            // 포지션
            if (!isCompact)
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _positionBadge(prediction),
                ),
              ),
            // 팩트체크
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('인구신 추종 시 결과', style: TextStyle(color: Colors.white38, fontSize: 9)),
                  const SizedBox(height: 4),
                  Text(
                    factCheckText,
                    style: TextStyle(color: factColor, fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCard(Map<String, dynamic> item) {
    final prediction = item['prediction_type'] ?? 'Bullish';
    final double returnRate = item['return_rate'] ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _predictionIcon(prediction),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(item['ticker'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              _positionBadge(prediction),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Text(
            "\"${item['analysis_summary'] ?? '분석 데이터 없음'}\"",
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Text(
            '인구신 추종 시 결과: ${returnRate >= 0 ? '+' : ''}${returnRate.toStringAsFixed(2)}%',
            style: TextStyle(
              color: returnRate >= 0 ? Colors.redAccent : Colors.blueAccent,
              fontSize: 14,
              fontWeight: FontWeight.w900
            ),
          ),
        ],
      ),
    );
  }

  Widget _predictionIcon(String prediction) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
      child: Icon(
        prediction == 'Bullish' ? Icons.keyboard_arrow_up : Icons.radio_button_unchecked,
        color: Colors.deepOrange,
        size: 14,
      ),
    );
  }

  Widget _positionBadge(String prediction) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 12, color: Colors.orange[300]),
          const SizedBox(width: 6),
          Text(
            prediction == 'Bullish' ? 'Bullish (매수)' : 'Bearish (매도)',
            style: TextStyle(color: Colors.orange[300], fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

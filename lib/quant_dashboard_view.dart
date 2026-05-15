import 'package:flutter/material.dart';
import 'dart:math' as math;

class QuantDashboardView extends StatefulWidget {
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
  State<QuantDashboardView> createState() => _QuantDashboardViewState();
}

class _QuantDashboardViewState extends State<QuantDashboardView>
    with TickerProviderStateMixin {
  String currentFilter = '전체';

  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;
  late AnimationController _shimmerController;
  bool isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 0.08,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.08,
          end: -0.08,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -0.08,
          end: 0.05,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.05,
          end: -0.05,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -0.05,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_buttonController);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void scrollToScanner() {
    if (widget.scannerKey.currentContext != null) {
      Scrollable.ensureVisible(
        widget.scannerKey.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFF8FAFC);
    final textColor = Colors.blueGrey[900]!;

    return AnimatedTheme(
      data: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: bgColor,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
        ),
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                child: Column(
                  children: [
                    _buildHeroSection(),
                    _buildFeaturesGrid(),
                    _buildScannerTool(),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: Colors.blueGrey[200]!)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: widget.onToggleMode,
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [],
                        ),
                        child: Icon(
                          Icons.account_balance,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey[900],
                          ),
                          children: [
                            TextSpan(
                              text: 'KOOSPI',
                              style: TextStyle(color: Colors.blue[600]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '통합 시장 스캐너 시스템',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[400],
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  if (widget.showTooltip)
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.tooltipMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[900],
                foregroundColor: Colors.white,
                elevation: 0,
                side: const BorderSide(color: Colors.transparent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[600]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.show_chart, size: 14, color: Colors.blue[600]),
                const SizedBox(width: 6),
                Text(
                  '실시간 데이터 피드 연결됨',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey[900],
                height: 1.1,
              ),
              children: const [
                TextSpan(text: '이거\n'),
                TextSpan(
                  text: '진짜에요?',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "글로벌 사모펀드의 13F 데이터와 리테일 심리 지표를 융합하여, 가장 정교한 매수 타점을 계산합니다. 시장의 노이즈를 제거하고 본질에 집중하세요.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: scrollToScanner,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              shadowColor: Colors.blue.withOpacity(0.5),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '지금 무료로 시작하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildTerminalWidget(),
        ],
      ),
    );
  }

  Widget _buildTerminalWidget() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.blueGrey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '터미널 v2.4.1',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [60, 45, 75, 50, 90, 65, 80, 55, 95, 70].map((h) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            height: (h / 100) * 150,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {
        "icon": Icons.account_balance,
        "title": "기관 수급 분석",
        "desc": "글로벌 헤지펀드의 포지션과 스마트 머니의 흐름을 추적합니다.",
      },
      {
        "icon": Icons.people,
        "title": "심리 엔진",
        "desc": "개인 투자자들의 데이터를 NLP로 분석하여 시장의 온도를 측정합니다.",
      },
      {
        "icon": Icons.trending_up,
        "title": "퀀트 전략",
        "desc": "반등이 예상되는 종목을 스캔합니다.",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: features.asMap().entries.map((entry) {
            final int index = entry.key;
            final Map<String, dynamic> f = entry.value;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index == features.length - 1 ? 0 : 24,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.blueGrey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        f['icon'] as IconData,
                        size: 28,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      f['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      f['desc'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.blueGrey[500],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildScannerTool() {
    return Container(
      key: widget.scannerKey,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: Colors.blueGrey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50]!.withOpacity(0.5),
              border: Border(bottom: BorderSide(color: Colors.blueGrey[100]!)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(48),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 32, color: Colors.blue[600]),
                    const SizedBox(width: 12),
                    Text(
                      '반등전 종목 스캐너',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '설정된 알고리즘을 기반으로 글로벌 시장의 최적 투자 후보군을 실시간 추출합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey[500]),
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _buttonAnimation,
                    _shimmerController,
                  ]),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _buttonAnimation.value,
                      child: Transform.scale(
                        scale: isButtonPressed ? 0.95 : 1.0,
                        child: GestureDetector(
                          onTapDown: (_) {
                            if (!widget.isScanning) {
                              setState(() => isButtonPressed = true);
                            }
                          },
                          onTapUp: (_) {
                            if (!widget.isScanning) {
                              setState(() => isButtonPressed = false);
                              _buttonController.forward(from: 0.0);
                              widget.onStartScan();
                            }
                          },
                          onTapCancel: () {
                            if (!widget.isScanning) {
                              setState(() => isButtonPressed = false);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: const [
                                  Color(0xFF89F7FE),
                                  Color(0xFF66A6FF),
                                  Color(0xFFFFBDE6),
                                  Color(0xFFE0C3FC),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                transform: GradientRotation(
                                  _shimmerController.value * 2 * math.pi,
                                ),
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.isScanning)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                else ...[
                                  const Text(
                                    '스캔 시작하기',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (widget.isScanning)
            Padding(
              padding: const EdgeInsets.all(80.0),
              child: Column(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[600]!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '수집된 시장 데이터 정밀 분석 중',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width:
                            MediaQuery.of(context).size.width *
                            0.7 *
                            (widget.scanProgress / 100),
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.scanProgress}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            )
          else if (widget.scanComplete) ...[
            _buildFilterChips(),
            _buildResultsTable(),
          ] else
            Padding(
              padding: const EdgeInsets.all(80.0),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.search,
                      size: 40,
                      color: Colors.blueGrey[200],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '시스템이 대기 중입니다',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '상단의 [스캔 시작하기] 버튼을 눌러 최신 시장 알파 데이터를 추출하세요.',
                    style: TextStyle(color: Colors.blueGrey[400]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    if (!widget.scanComplete || widget.results.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['전체', '기관픽', '개미지옥'].map((filter) {
          final isSelected = currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.blueGrey[700],
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.blue[600],
              backgroundColor: Colors.blueGrey[50],
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    currentFilter = filter;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsTable() {
    // 필터링 적용
    final filteredResults = widget.results.where((item) {
      if (currentFilter == '전체') return true;
      final title = (item['title'] ?? '') as String;
      if (currentFilter == '기관픽') {
        return title.contains('세력') || title.contains('수급');
      } else if (currentFilter == '개미지옥') {
        return title.contains('WhaleWisdom') ||
            title.contains('개미') ||
            title.contains('구조대') ||
            title.contains('상폐') ||
            title.contains('투매');
      }
      return true;
    }).toList();

    return Column(
      children: [
        if (filteredResults.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Text(
              "결과가 없습니다.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredResults.length,
            itemBuilder: (context, index) {
              final item = filteredResults[index];
              String dateStr = item['published_at'] ?? '';
              if (dateStr.length >= 10) dateStr = dateStr.substring(0, 10);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blueGrey[100]!, width: 1),
                ),
                elevation: 2,
                shadowColor: Colors.blueGrey.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blue[50],
                                child: Text(
                                  (item['ticker'] ?? '?')[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${item['name']} (${item['ticker']})",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.blueGrey[900],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "포착일: $dateStr",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Icon(
                            Icons.open_in_new,
                            size: 20,
                            color: Colors.blue[400],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 18,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['analysis_summary'] ?? '분석 데이터가 없습니다.',
                                style: TextStyle(
                                  color: Colors.blueGrey[800],
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(48),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Text(
                "최종 분석 결과 ${filteredResults.length}개의 유효 시그널 매칭 완료",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.blueGrey[100]!)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'KOOSPI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueGrey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '본 서비스는 개인 투자자의 의사결정을 돕기 위한 보조 도구일 뿐, 투자에 따른 최종 책임은 본인에게 있습니다. 인구신 지표는 특히 맹신하지 마시고 유머로 즐겨주시기 바랍니다.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey[400],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 32),
          Text(
            '© 2026 KOOSPI 데이터 분석 시스템. 모든 권리 보유.',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.blueGrey[500],
            ),
          ),
        ],
      ),
    );
  }
}

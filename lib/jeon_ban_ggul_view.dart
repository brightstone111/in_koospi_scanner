import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

class JeonBanGgulView extends StatefulWidget {
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
  State<JeonBanGgulView> createState() => _JeonBanGgulViewState();
}

class _JeonBanGgulViewState extends State<JeonBanGgulView>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;
  late AnimationController _shimmerController;
  bool isButtonPressed = false;
  final AudioPlayer audioPlayer = AudioPlayer();

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

    audioPlayer.setVolume(0.4);
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.play(
      UrlSource(
        "https://assets.mixkit.co/active_storage/sfx/133/133-preview.mp3",
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _buttonController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void handleSecretClick() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("시스템 알림"),
        content: const Text("인구신의 가호를 포기하고 일반 모드로 복구하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              audioPlayer.stop();
              widget.onToggleMode();
            },
            child: const Text("복구"),
          ),
        ],
      ),
    );
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
    const bgColor = Color(0xFF050505);
    final textColor = Colors.grey[100]!;

    return AnimatedTheme(
      data: ThemeData(
        brightness: Brightness.dark,
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
            _buildWarningBanner(),
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
        color: Colors.black.withOpacity(0.8),
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
              onTap: handleSecretClick,
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bolt, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(text: '(인)'),
                            TextSpan(
                              text: 'KOOSPI',
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '딥 알파 엔진 가동중',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange.withOpacity(0.7),
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
                          color: Colors.deepOrange,
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
                backgroundColor: Colors.deepOrange.withOpacity(0.2),
                foregroundColor: Colors.deepOrange,
                elevation: 0,
                side: BorderSide(color: Colors.deepOrange.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '시스템_관리자',
                style: TextStyle(fontWeight: FontWeight.bold),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange, Colors.red, Colors.deepOrange],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            '접근 제한 영역: 전반꿀 알파 전략 활성화 - 모든 기관 필터링 우회 중',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.warning, color: Colors.white, size: 16),
        ],
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
              color: Colors.deepOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.show_chart, size: 14, color: Colors.deepOrange),
                SizedBox(width: 6),
                Text(
                  '실시간 데이터 피드 연결됨',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
              ),
              children: [
                TextSpan(text: '개미의 절망을\n'),
                TextSpan(
                  text: '수익으로 전환하라',
                  style: TextStyle(color: Colors.deepOrange),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "세력은 당신의 공포를 먹고 자랍니다. 우리는 그 공포의 정점에서 전설적인 반대 매매 시그널을 추출합니다. 이 데이터는 오직 당신에게만 허락됩니다.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: scrollToScanner,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              shadowColor: Colors.deepOrange.withOpacity(0.5),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '어둠의 지표 실행',
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
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.deepOrange.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.1),
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
                        color: Colors.deepOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '터미널 v2.4.1',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
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
                              color: Colors.deepOrange.withOpacity(0.4),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.coronavirus, size: 64, color: Colors.deepOrange),
                  SizedBox(height: 16),
                  Text(
                    '알파 지표 잠금해제',
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
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
        "title": "전반꿀 알파",
        "desc": "기관의 인위적인 시장 조작을 역으로 추적하여 시장의 진실을 파헤칩니다.",
      },
      {
        "icon": Icons.people,
        "title": "패닉 리버설",
        "desc": "대중의 절망이 극에 달하는 순간을 포착하여 최대 반등 타점을 도출합니다.",
      },
      {
        "icon": Icons.trending_up,
        "title": "썬더 스트라이크",
        "desc": "폭발적인 변동성 직전의 응축 구간을 포착하는 독자적인 알고리즘입니다.",
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
                  color: const Color(0xFF0F0F0F),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.deepOrange.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.05),
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
                        color: Colors.deepOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        f['icon'] as IconData,
                        size: 28,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      f['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      f['desc'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey[400],
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
        color: Colors.black,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: Colors.deepOrange.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.1),
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
              color: Colors.deepOrange.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: Colors.deepOrange.withOpacity(0.3)),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(48),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search,
                      size: 32,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '인구신_모드',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '고성능',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '현재 시장의 모든 공포 지표와 세력의 의도를 교차 분석하여 최상위 매수 타점을 도출합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400]),
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
                                colors: [
                                  Colors.deepOrange[700]!,
                                  Colors.red[900]!,
                                  Colors.deepOrange[800]!,
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
                                    '알파_엔진_가동',
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
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '서버 동기화 중 (Supabase DB)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
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
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.scanProgress}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            )
          else if (widget.scanComplete)
            _buildResultsTable()
          else
            Padding(
              padding: const EdgeInsets.all(80.0),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.search,
                      size: 40,
                      color: Colors.deepOrange[900],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '비밀 지표가 활성화되었습니다',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '상단의 [알파_엔진_가동] 버튼을 눌러 최신 시장 알파 데이터를 추출하세요.',
                    style: TextStyle(color: Colors.blueGrey[400]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    return Column(
      children: [
        if (widget.results.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Text(
              "해당 조건에 맞는 시그널이 없습니다.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.results.length,
            itemBuilder: (context, index) {
              final item = widget.results[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                color: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Colors.deepOrange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                elevation: 5,
                shadowColor: Colors.deepOrange.withOpacity(0.2),
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
                                backgroundColor: Colors.deepOrange.withOpacity(
                                  0.1,
                                ),
                                child: Text(
                                  (item['ticker'] ?? '?')[0],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${item['name']} (${item['ticker']})",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "AI 분석 점수: ${item['score'] ?? 90}점",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: (item['score'] ?? 0) >= 95
                                          ? Colors.redAccent
                                          : Colors.blueGrey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.blueGrey[300],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "토스 패닉 지수: ${item['tossPanic'] ?? 'N/A'}",
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "투심: ${item['krxSentiment'] ?? 'N/A'}",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "상태: ${item['chartStatus'] ?? 'N/A'}",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "키워드: ${item['tossKeyword'] ?? 'N/A'}",
                              style: TextStyle(
                                color: Colors.deepOrange[300],
                                fontStyle: FontStyle.italic,
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
            color: Colors.deepOrange.withOpacity(0.05),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(48),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, color: Colors.deepOrange),
              const SizedBox(width: 12),
              Text(
                "Supabase DB 기반 필터링된 ${widget.results.length}개의 전반꿀 데이터",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
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
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.deepOrange.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance, color: Colors.deepOrange),
              SizedBox(width: 8),
              Text(
                '(인)KOOSPI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '본 서비스는 개인 투자자의 의사결정을 돕기 위한 보조 도구일 뿐, 투자에 따른 최종 책임은 본인에게 있습니다. 인구신 지표는 특히 맹신하지 마시고 유머로 즐겨주시기 바랍니다.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 32),
          Text(
            '© 2026 (인)KOOSPI 데이터 분석 시스템. 모든 권리 보유.',
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

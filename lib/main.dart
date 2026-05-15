import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

// ==========================================
// 은혁님이 제공한 Supabase 연결 정보
// ==========================================
const String SUPABASE_URL = "https://isxcbhwbrravbjlfhgil.supabase.co";
const String SUPABASE_ANON_KEY =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlzeGNiaHdicnJhdmJqbGZoZ2lsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3OTIxMDUsImV4cCI6MjA5NDM2ODEwNX0.q_vXt9UdH4WWRzhG3AuWl_kZa2oS9JkpOoRT2iwGoZU";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '(인)KOOSPI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const KoospiDashboard(),
    );
  }
}

class KoospiDashboard extends StatefulWidget {
  const KoospiDashboard({super.key});

  @override
  State<KoospiDashboard> createState() => _KoospiDashboardState();
}

class _KoospiDashboardState extends State<KoospiDashboard>
    with SingleTickerProviderStateMixin {
  bool isScanning = false;
  bool scanComplete = false;
  int scanProgress = 0;
  List<dynamic> results = [];
  String currentFilter = '전체';

  // 이스터 에그 상태 관리
  int secretClicks = 0;
  bool inguMode = false;
  bool glitchActive = false;
  bool showTooltip = false;
  String tooltipMessage = "";
  Timer? tooltipTimer;

  final AudioPlayer audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _scannerKey = GlobalKey();

  late AnimationController _glitchController;

  @override
  void initState() {
    super.initState();
    _glitchController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 100),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _glitchController.reverse();
          } else if (status == AnimationStatus.dismissed && glitchActive) {
            _glitchController.forward();
          }
        });
  }

  @override
  void dispose() {
    tooltipTimer?.cancel();
    audioPlayer.dispose();
    _glitchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void triggerTooltip(String message) {
    setState(() {
      showTooltip = true;
      tooltipMessage = message;
    });
    tooltipTimer?.cancel();
    tooltipTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showTooltip = false;
          tooltipMessage = "";
        });
      }
    });
  }

  void handleSecretClick() {
    if (inguMode) {
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
                setState(() {
                  inguMode = false;
                  secretClicks = 0;
                  results = [];
                });
                audioPlayer.stop();
                triggerTooltip("시스템 정상화 완료");
              },
              child: const Text("복구"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      secretClicks++;
    });

    if (secretClicks < 3) {
      triggerTooltip("보안 접근 시도... ($secretClicks/9)");
    } else if (secretClicks < 6) {
      triggerTooltip("데이터 패킷 유출 중... ($secretClicks/9)");
    } else if (secretClicks < 9) {
      triggerTooltip("전반꿀 엔진 동기화 중... ($secretClicks/9)");
    }

    if (secretClicks == 9) {
      setState(() {
        glitchActive = true;
      });
      _glitchController.forward();

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            inguMode = true;
            glitchActive = false;
            scanComplete = false;
            isScanning = false;
          });
          _glitchController.stop();
          audioPlayer.setVolume(0.4);
          audioPlayer.setReleaseMode(ReleaseMode.loop);
          audioPlayer.play(
            UrlSource(
              "https://assets.mixkit.co/active_storage/sfx/133/133-preview.mp3",
            ),
          );
          triggerTooltip("ALPHA_ENGINE_ONLINE");
        }
      });
    }
  }

  final List<Map<String, dynamic>> mockResults = [
    {
      "id": 1,
      "ticker": "PLTR",
      "name": "팔란티어",
      "arkBuy": "+4.2%",
      "institutions": ["ARK 인베스트", "르네상스", "블랙록"],
      "tossPanic": "98%",
      "krxSentiment": "극단적 공포 (투매)",
      "tossKeyword": "상폐, 사기, 구조대",
      "chartStatus": "매수 강세 (거래량 폭증)",
      "score": 99,
    },
    {
      "id": 2,
      "ticker": "TSLA",
      "name": "테슬라",
      "arkBuy": "+2.8%",
      "institutions": ["뱅가드", "블랙록", "ARK"],
      "tossPanic": "92%",
      "krxSentiment": "공포 (패닉셀)",
      "tossKeyword": "일론머스크, 손절, 끝남",
      "chartStatus": "이평선 수렴 (상승 돌파)",
      "score": 94,
    },
  ];

  Future<void> startScan() async {
    setState(() {
      isScanning = true;
      scanComplete = false;
      scanProgress = 0;
    });

    Timer? progressTimer;
    progressTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted) {
        setState(() {
          if (scanProgress >= 90) {
            timer.cancel();
            scanProgress = 90;
          } else {
            scanProgress += 10;
          }
        });
      }
    });

    try {
      if (!inguMode) {
        final response = await http.get(
          Uri.parse(
            '$SUPABASE_URL/rest/v1/ingu_signals?select=*&order=id.desc',
          ),
          headers: {
            'apikey': SUPABASE_ANON_KEY,
            'Authorization': 'Bearer $SUPABASE_ANON_KEY',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List<dynamic>;

          // 점수 부여 및 정렬 로직 (DB에 score가 없다면 임의 부여)
          for (var item in data) {
            if (item['score'] == null) {
              // 텍스트 기반 가중치
              if ((item['title'] ?? '').contains('세력'))
                item['score'] = 98;
              else if ((item['title'] ?? '').contains('수상한'))
                item['score'] = 92;
              else
                item['score'] = 85;
            }
          }
          data.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

          if (mounted) {
            setState(() {
              results = data;
            });
          }
        } else {
          throw Exception('Supabase 요청 실패: ${response.statusCode}');
        }
      } else {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            results = mockResults;
          });
        }
      }
    } catch (error) {
      print("Supabase 데이터 로드 실패: $error");
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("DB 연결 실패"),
            content: Text("은혁님께 테이블 이름을 확인해달라고 요청하세요!\n(에러: $error)"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("확인"),
              ),
            ],
          ),
        );
        setState(() {
          results = [];
        });
      }
    } finally {
      progressTimer.cancel();
      if (mounted) {
        setState(() {
          scanProgress = 100;
        });
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            isScanning = false;
            scanComplete = true;
          });
        }
      });
    }
  }

  void scrollToScanner() {
    if (_scannerKey.currentContext != null) {
      Scrollable.ensureVisible(
        _scannerKey.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = inguMode
        ? const Color(0xFF050505)
        : const Color(0xFFF8FAFC);
    final textColor = inguMode ? Colors.grey[100]! : Colors.blueGrey[900]!;

    return AnimatedTheme(
      data: ThemeData(
        brightness: inguMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: bgColor,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
        ),
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: AnimatedBuilder(
          animation: _glitchController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                glitchActive ? (_glitchController.value * 10 - 5) : 0,
                0,
              ),
              child: child,
            );
          },
          child: Column(
            children: [
              _buildHeader(),
              if (inguMode) _buildWarningBanner(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: inguMode
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: inguMode
                ? Colors.deepOrange.withOpacity(0.3)
                : Colors.blueGrey[200]!,
          ),
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
                          color: inguMode
                              ? Colors.deepOrange.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: inguMode
                              ? [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.3),
                                    blurRadius: 15,
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          inguMode ? Icons.bolt : Icons.account_balance,
                          color: inguMode
                              ? Colors.deepOrange
                              : Colors.blue[600],
                        ),
                      ),
                      if (showTooltip)
                        Positioned(
                          left: 50,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: inguMode ? Colors.deepOrange : Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tooltipMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
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
                            color: inguMode
                                ? Colors.white
                                : Colors.blueGrey[900],
                          ),
                          children: [
                            const TextSpan(text: '(인)'),
                            TextSpan(
                              text: 'KOOSPI',
                              style: TextStyle(
                                color: inguMode
                                    ? Colors.deepOrange
                                    : Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        inguMode ? '딥 알파 엔진 가동중' : '통합 시장 스캐너 시스템',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: inguMode
                              ? Colors.deepOrange.withOpacity(0.7)
                              : Colors.blueGrey[400],
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Desktop nav items omitted for simplicity on mobile/Flutter
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: inguMode
                    ? Colors.deepOrange.withOpacity(0.2)
                    : Colors.blueGrey[900],
                foregroundColor: inguMode ? Colors.deepOrange : Colors.white,
                elevation: 0,
                side: BorderSide(
                  color: inguMode
                      ? Colors.deepOrange.withOpacity(0.3)
                      : Colors.transparent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                inguMode ? '시스템_관리자' : '로그인',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
              color: inguMode
                  ? Colors.deepOrange.withOpacity(0.1)
                  : Colors.blue[600]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.show_chart,
                  size: 14,
                  color: inguMode ? Colors.deepOrange : Colors.blue[600],
                ),
                const SizedBox(width: 6),
                Text(
                  '실시간 데이터 피드 연결됨',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: inguMode ? Colors.deepOrange : Colors.blue[600],
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
                color: inguMode ? Colors.white : Colors.blueGrey[900],
                height: 1.1,
              ),
              children: inguMode
                  ? const [
                      TextSpan(text: '개미의 절망을\n'),
                      TextSpan(
                        text: '수익으로 전환하라',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ]
                  : [
                      const TextSpan(text: '차세대\n'),
                      TextSpan(
                        text: '퀀트 인텔리전스',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            inguMode
                ? "세력은 당신의 공포를 먹고 자랍니다. 우리는 그 공포의 정점에서 전설적인 반대 매매 시그널을 추출합니다. 이 데이터는 오직 당신에게만 허락됩니다."
                : "글로벌 사모펀드의 13F 데이터와 리테일 심리 지표를 융합하여, 가장 정교한 매수 타점을 계산합니다. 시장의 노이즈를 제거하고 본질에 집중하세요.",
            style: TextStyle(
              fontSize: 16,
              color: inguMode ? Colors.grey[400] : Colors.blueGrey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: scrollToScanner,
            style: ElevatedButton.styleFrom(
              backgroundColor: inguMode ? Colors.deepOrange : Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              shadowColor: inguMode
                  ? Colors.deepOrange.withOpacity(0.5)
                  : Colors.blue.withOpacity(0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  inguMode ? '어둠의 지표 실행' : '지금 무료로 시작하기',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
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
        color: inguMode ? const Color(0xFF0F0F0F) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: inguMode
              ? Colors.deepOrange.withOpacity(0.4)
              : Colors.blueGrey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: inguMode
                ? Colors.deepOrange.withOpacity(0.1)
                : Colors.blueGrey.withOpacity(0.1),
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
                        color: inguMode
                            ? Colors.deepOrange.withOpacity(0.1)
                            : Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '터미널 v2.4.1',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: inguMode ? Colors.deepOrange : Colors.blue,
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
                              color: inguMode
                                  ? Colors.deepOrange.withOpacity(0.4)
                                  : Colors.blue.withOpacity(0.2),
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
          if (inguMode)
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
        "title": "기관 수급 분석",
        "inguTitle": "전반꿀 알파",
        "desc": "글로벌 헤지펀드의 포지션과 스마트 머니의 흐름을 실시간으로 추적합니다.",
        "inguDesc": "기관의 인위적인 시장 조작을 역으로 추적하여 시장의 진실을 파헤칩니다.",
      },
      {
        "icon": Icons.people,
        "title": "심리 엔진",
        "inguTitle": "패닉 리버설",
        "desc": "수백만 명의 개인 투자자 데이터를 NLP로 분석하여 시장의 온도를 측정합니다.",
        "inguDesc": "대중의 절망이 극에 달하는 순간을 포착하여 최대 반등 타점을 도출합니다.",
      },
      {
        "icon": Icons.trending_up,
        "title": "퀀트 전략",
        "inguTitle": "썬더 스트라이크",
        "desc": "12가지 이상의 기술적 지표를 변동성에 맞춰 수학적으로 최적화합니다.",
        "inguDesc": "폭발적인 변동성 직전의 응축 구간을 포착하는 독자적인 알고리즘입니다.",
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
                margin: EdgeInsets.only(right: index == features.length - 1 ? 0 : 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: inguMode ? const Color(0xFF0F0F0F) : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: inguMode
                        ? Colors.deepOrange.withOpacity(0.3)
                        : Colors.blueGrey[200]!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: inguMode
                          ? Colors.deepOrange.withOpacity(0.05)
                          : Colors.blueGrey.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: inguMode
                            ? Colors.deepOrange.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        f['icon'] as IconData,
                        size: 28,
                        color: inguMode ? Colors.deepOrange : Colors.blue[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      (inguMode ? f['inguTitle'] : f['title']) as String,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: inguMode ? Colors.white : Colors.blueGrey[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      (inguMode ? f['inguDesc'] : f['desc']) as String,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: inguMode ? Colors.grey[400] : Colors.blueGrey[500],
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
      key: _scannerKey,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: inguMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(
          color: inguMode
              ? Colors.deepOrange.withOpacity(0.5)
              : Colors.blueGrey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: inguMode
                ? Colors.deepOrange.withOpacity(0.1)
                : Colors.blueGrey.withOpacity(0.1),
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
              color: inguMode
                  ? Colors.deepOrange.withOpacity(0.05)
                  : Colors.blueGrey[50]!.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: inguMode
                      ? Colors.deepOrange.withOpacity(0.3)
                      : Colors.blueGrey[100]!,
                ),
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
                    Icon(
                      Icons.search,
                      size: 32,
                      color: inguMode ? Colors.deepOrange : Colors.blue[600],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      inguMode ? '비밀_알파_스캔_모드' : '실시간 종목 스캐너',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: inguMode ? Colors.white : Colors.blueGrey[900],
                      ),
                    ),
                    if (inguMode) ...[
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
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  inguMode
                      ? '현재 시장의 모든 공포 지표와 세력의 의도를 교차 분석하여 최상위 매수 타점을 도출합니다.'
                      : '설정된 알고리즘을 기반으로 글로벌 시장의 최적 투자 후보군을 실시간 추출합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: inguMode ? Colors.grey[400] : Colors.blueGrey[500],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isScanning ? null : startScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: inguMode
                        ? Colors.deepOrange
                        : Colors.blue[600],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isScanning)
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
                        Text(
                          inguMode ? '알파_엔진_가동' : '스캔 시작하기',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.chevron_right),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isScanning)
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
                        inguMode ? Colors.deepOrange : Colors.blue[600]!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    inguMode ? '서버 동기화 중 (Supabase DB)' : '수집된 시장 데이터 정밀 분석 중',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: inguMode ? Colors.white : Colors.blueGrey[900],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: inguMode ? Colors.grey[900] : Colors.blueGrey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width:
                            MediaQuery.of(context).size.width *
                            0.7 *
                            (scanProgress / 100),
                        height: 8,
                        decoration: BoxDecoration(
                          color: inguMode
                              ? Colors.deepOrange
                              : Colors.blue[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$scanProgress%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: inguMode ? Colors.deepOrange : Colors.blue[600],
                    ),
                  ),
                ],
              ),
            )
          else if (scanComplete) ...[
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
                      color: inguMode
                          ? Colors.deepOrange.withOpacity(0.05)
                          : Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.search,
                      size: 40,
                      color: inguMode
                          ? Colors.deepOrange[900]
                          : Colors.blueGrey[200],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    inguMode ? '비밀 지표가 활성화되었습니다' : '시스템이 대기 중입니다',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: inguMode ? Colors.white : Colors.blueGrey[900],
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
    if (inguMode || !scanComplete || results.isEmpty)
      return const SizedBox.shrink();

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
                  color: isSelected
                      ? Colors.white
                      : (inguMode ? Colors.white70 : Colors.blueGrey[700]),
                ),
              ),
              selected: isSelected,
              selectedColor: inguMode ? Colors.deepOrange : Colors.blue[600],
              backgroundColor: inguMode
                  ? Colors.grey[900]
                  : Colors.blueGrey[50],
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
    final filteredResults = results.where((item) {
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
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              inguMode ? "해당 조건에 맞는 시그널이 없습니다." : "결과가 없습니다.",
              style: const TextStyle(color: Colors.grey),
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                color: inguMode ? const Color(0xFF1A1A1A) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: inguMode
                        ? Colors.deepOrange.withOpacity(0.3)
                        : Colors.blueGrey[100]!,
                    width: 1,
                  ),
                ),
                elevation: inguMode ? 5 : 2,
                shadowColor: inguMode
                    ? Colors.deepOrange.withOpacity(0.2)
                    : Colors.blueGrey.withOpacity(0.1),
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
                                backgroundColor: inguMode
                                    ? Colors.deepOrange.withOpacity(0.1)
                                    : Colors.blue[50],
                                child: Text(
                                  (item['ticker'] ?? '?')[0],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: inguMode
                                        ? Colors.deepOrange
                                        : Colors.blue[700],
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
                                      color: inguMode
                                          ? Colors.white
                                          : Colors.blueGrey[900],
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
                          color: inguMode ? Colors.black : Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!inguMode) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.insights,
                                    size: 16,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "포지션: ${item['ingu_position'] ?? '데이터 없음'}",
                                      style: TextStyle(
                                        color: Colors.blue[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    size: 16,
                                    color: Colors.greenAccent[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "기대 수익: ${item['ban_ggul_return'] ?? '+${(item['score'] ?? 90) * 1.5}% (추정)'}",
                                    style: TextStyle(
                                      color: Colors.greenAccent[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (item['video_id'] != null &&
                                  item['video_id'].toString().startsWith(
                                    '13F_',
                                  )) ...[
                                const SizedBox(height: 12),
                                Divider(color: Colors.blueGrey[200]),
                                const SizedBox(height: 8),
                                Text(
                                  "매수 기관 상세 내역:",
                                  style: TextStyle(
                                    color: Colors.blueGrey[400],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...item['video_id']
                                    .toString()
                                    .split('_')
                                    .skip(2)
                                    .join('_')
                                    .split('|')
                                    .map((fund) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 14,
                                              color: Colors.blue[400],
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                fund,
                                                style: TextStyle(
                                                  color: Colors.blueGrey[700],
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                    .toList(),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "인구신 한마디: \"${item['title'] ?? '...'}\"",
                                      style: TextStyle(
                                        color: Colors.blueGrey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
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
            color: inguMode
                ? Colors.deepOrange.withOpacity(0.05)
                : Colors.blueGrey[50],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(48),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                color: inguMode ? Colors.deepOrange : Colors.blue[600],
              ),
              const SizedBox(width: 12),
              Text(
                inguMode
                    ? "Supabase DB 기반 필터링된 ${filteredResults.length}개의 전반꿀 데이터"
                    : "최종 분석 결과 ${filteredResults.length}개의 유효 시그널 매칭 완료",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: inguMode ? Colors.deepOrange : Colors.blue[600],
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
        color: inguMode ? Colors.black : Colors.white,
        border: Border(
          top: BorderSide(
            color: inguMode
                ? Colors.deepOrange.withOpacity(0.3)
                : Colors.blueGrey[100]!,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: inguMode ? Colors.deepOrange : Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Text(
                '(인)KOOSPI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: inguMode ? Colors.white : Colors.blueGrey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '본 서비스는 개인 투자자의 의사결정을 돕기 위한 보조 도구일 뿐, 투자에 따른 최종 책임은 본인에게 있습니다. 인구신 지표는 특히 맹신하지 마시고 유머로 즐겨주시기 바랍니다.',
            style: TextStyle(
              fontSize: 12,
              color: inguMode ? Colors.grey[600] : Colors.blueGrey[400],
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

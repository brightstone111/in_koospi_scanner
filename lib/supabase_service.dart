import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SupabaseService {
  static const String url = "https://isxcbhwbrravbjlfhgil.supabase.co";
  static const String anonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlzeGNiaHdicnJhdmJqbGZoZ2lsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3OTIxMDUsImV4cCI6MjA5NDM2ODEwNX0.q_vXt9UdH4WWRzhG3AuWl_kZa2oS9JkpOoRT2iwGoZU";

  Future<List<Map<String, dynamic>>> fetchSignals() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$url/rest/v1/whale_signals?select=*,stock_metadata(*)&order=published_at.desc',
        ),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // 데이터 가공 및 수익률 계산 로직
        return data.map((item) {
          final metadata = item['stock_metadata'] as Map<String, dynamic>?;
          final currentPrice = (metadata?['current_price'] ?? 0).toDouble();
          final uploadPrice = (item['price_at_upload'] ?? 0).toDouble();
          final name = metadata?['name'] ?? item['name'] ?? "데이터 없음";
          final title = item['title'] ?? "";

          // 점수 로직
          int score = item['score'] ?? 85;
          if (title.contains('세력')) score = 98;
          else if (title.contains('수상한')) score = 92;

          // 수익률 계산
          double rawReturn = 0;
          if (uploadPrice > 0 && currentPrice > 0) {
            rawReturn = ((currentPrice - uploadPrice) / uploadPrice * 100);
          }

          final String profitStr =
              "${rawReturn >= 0 ? '+' : ''}${rawReturn.toStringAsFixed(2)}%";

          // 고래 분석(title) 추출 로직 보강
          String analysisSummary = "기관 분석 데이터 없음";
          final List<String> analysisKeys = ['title', 'analysis_summary', 'video_title', 'content'];
          for (var key in analysisKeys) {
            if (item[key] != null && item[key].toString().trim().isNotEmpty) {
              analysisSummary = item[key].toString();
              break;
            }
          }

          // 고래 포지션(ingu_position) 추출 로직 보강
          String whalePosition = "포지션 미설정";
          final List<String> positionKeys = ['ingu_position', 'whale_position', 'position'];
          for (var key in positionKeys) {
            if (item[key] != null && item[key].toString().trim().isNotEmpty) {
              whalePosition = item[key].toString();
              break;
            }
          }

          return <String, dynamic>{
            ...Map<String, dynamic>.from(item),
            'name': name,
            'score': score,
            'analysis_summary': analysisSummary,
            'whale_position': whalePosition,
            'upload_date': item['published_at'] != null
                ? item['published_at'].toString().split('T')[0]
                : '알 수 없음',
            'ban_ggul_return': "수익률: $profitStr",
            'profitColor': rawReturn >= 0 ? Colors.redAccent : Colors.blueAccent,
          };
        }).toList().cast<Map<String, dynamic>>();
      } else {
        throw Exception('데이터 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchInguSignals() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$url/rest/v1/ingu_signals?select=*,stock_metadata(*)&order=published_at.desc',
        ),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) {
          final metadata = item['stock_metadata'] as Map<String, dynamic>?;
          final currentPrice = (metadata?['current_price'] ?? 0.0).toDouble();
          final uploadPrice = (item['price_at_upload'] ?? 0.0).toDouble();
          final name = metadata?['name'] ?? item['name'] ?? "데이터 없음";
          final ticker = item['ticker'] ?? "Unknown";

          // 수익률 계산 (인구신 반대로 하면 꿀)
          double rawReturn = 0;
          if (uploadPrice > 0 && currentPrice > 0) {
            rawReturn = ((currentPrice - uploadPrice) / uploadPrice * 100);
          }

          final String positionText = item['ingu_position'] ?? 'Bullish'; 
          final bool isBullish = positionText.toLowerCase().contains('buy') || 
                               positionText.toLowerCase().contains('bull') ||
                               positionText.contains('매수');

          final String profitStr = "${rawReturn >= 0 ? '+' : ''}${rawReturn.toStringAsFixed(2)}%";

          // 예언(title) 추출 로직 보강
          String prophecy = "예언을 분석할 수 없습니다.";
          final List<String> potentialKeys = ['title', 'analysis_summary', 'prophecy', 'video_title', 'content'];
          for (var key in potentialKeys) {
            if (item[key] != null && item[key].toString().trim().isNotEmpty) {
              prophecy = item[key].toString();
              break;
            }
          }

          return <String, dynamic>{
            ...Map<String, dynamic>.from(item),
            'name': name,
            'ticker': ticker,
            'analysis_summary': prophecy,
            'whale_position': isBullish ? '매수 권유' : '매도 권유',
            'return_rate': rawReturn,
            'profit_text': profitStr,
            'prediction_type': isBullish ? 'Bullish' : 'Bearish',
            'published_at': item['published_at'],
          };
        }).toList().cast<Map<String, dynamic>>();
      } else {
        throw Exception('데이터 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

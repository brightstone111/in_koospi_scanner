import sys
import asyncio
import random
import datetime
import requests
from collections import defaultdict

sys.stdout.reconfigure(encoding='utf-8')
import json
from playwright.async_api import async_playwright
from playwright_stealth import Stealth

# ==========================================
# Supabase 연결 정보 (은혁님 제공)
# ==========================================
SUPABASE_URL = "https://isxcbhwbrravbjlfhgil.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlzeGNiaHdicnJhdmJqbGZoZ2lsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3OTIxMDUsImV4cCI6MjA5NDM2ODEwNX0.q_vXt9UdH4WWRzhG3AuWl_kZa2oS9JkpOoRT2iwGoZU"

# 타겟 펀드 목록 (Dataroma ID)
TARGET_FUNDS = {
    "버크셔 해서웨이(버핏)": "BRK",
    "펀드스미스": "FS",
    "아크레 캐피탈": "AKRE",
    "써드포인트": "TP",
    "밸류액트": "VA",
    "퍼싱 스퀘어(애크먼)": "PSC",
    "엘리엇 매니지먼트": "ELC",
    "아팔루사(데이비드 테퍼)": "APP",
    "오크트리(하워드 막스)": "OAK",
    "사이언 애셋(마이클 버리)": "Sion",
}

async def crawl_dataroma_activity():
    print("[1/4] 다중 기관 13F 추가/비중확대 크롤러 시작...")
    
    all_additions = defaultdict(lambda: {"name": "", "funds": [], "count": 0})
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
            viewport={"width": 1920, "height": 1080}
        )
        page = await context.new_page()
        await Stealth().apply_stealth_async(page)

        print("[2/4] 각 기관별 Activity(Additions) 데이터 추출 중...")
        for fund_name, fund_id in TARGET_FUNDS.items():
            # typ=a : Additions (Add to existing or Buy new)
            target_url = f"https://www.dataroma.com/m/m_activity.php?m={fund_id}&typ=a"
            print(f"  -> {fund_name} 데이터 스크래핑 중... ({target_url})")
            
            try:
                await page.goto(target_url, wait_until="domcontentloaded")
                await asyncio.sleep(random.uniform(1.5, 3.0)) # 봇 탐지 회피
                
                rows = await page.query_selector_all("table#grid tbody tr:not(.q_chg)")
                
                # 최대 상위 10개 편입 종목만 (유의미한 편입 위주)
                for row in rows[:10]:
                    cols = await row.query_selector_all("td")
                    if len(cols) >= 5:
                        # cols[1]에 틱커와 이름이 함께 존재: "ODD - Oddity Tech Ltd Cl A"
                        stock_info = await cols[1].inner_text()
                        parts = stock_info.split('-', 1)
                        if len(parts) >= 2:
                            ticker = parts[0].strip()
                            name = parts[1].strip()
                        else:
                            ticker = stock_info.strip()
                            name = stock_info.strip()
                            
                        # cols[2]는 Activity (예: "Add 46.38%" 또는 "Buy 0.16%")
                        activity = await cols[2].inner_text()
                        
                        if "Add" in activity or "Buy" in activity:
                            all_additions[ticker]["name"] = name
                            
                            # 퍼싱 스퀘어 중복 매수 등 동일 기관 중복 카운트 방지
                            fund_act = f"{fund_name}({activity})"
                            if not any(fund_name in f for f in all_additions[ticker]["funds"]):
                                all_additions[ticker]["funds"].append(fund_act)
                                all_additions[ticker]["count"] += 1
                        
            except Exception as e:
                print(f"  -> {fund_name} 데이터 추출 중 오류: {e}")
                
        await browser.close()
        
    print("[3/4] 교차 분석 (Cross-referencing) 처리 중...")
    
    if not all_additions:
        print("❌ 추출된 데이터가 없습니다.")
        return
        
    # 기관 매수 카운트 기준 내림차순 정렬
    sorted_stocks = sorted(all_additions.items(), key=lambda x: x[1]["count"], reverse=True)
    
    data_list = []
    panic_keywords = ["개미 지옥", "손절 릴레이", "구조대 언제 옴", "상폐 위기", "나스닥의 수치", "투매 행렬", "바닥 붕괴"]
    
    for ticker, info in sorted_stocks:
        count = info["count"]
        funds = info["funds"]
        
        # 2개 이상 매수한 종목이거나, 유명 펀드 1개가 크게 편입한 경우만 필터링 
        # (테스트용으로 1개 매수도 일단 상위권 위주로 포함)
        score = min(80 + (count * 7) + random.randint(-2, 3), 99) # 기관이 많을수록 높은 점수
        
        funds_str = ", ".join(funds[:2]) # 최대 2개만 텍스트 노출
        if count > 2:
            ingu_position = f"스마트머니 집중매수: [{funds_str} 등 {count}개 기관 동시 매수 포착!]"
            quote = f"🚨 세력의 은밀한 매수 포착! ({count}개 펀드 진입)"
        elif count == 2:
            ingu_position = f"스마트머니 교차매수: [{funds[0]}, {funds[1]} 공동 편입]"
            quote = f"👀 수상한 수급 포착! 유명 펀드 2곳 동시 매수"
        else:
            ingu_position = f"고래의 사냥: [{funds[0]} 단독 비중 확대]"
            quote = f"[WhaleWisdom 13F] {random.choice(panic_keywords)}"
            
        data_list.append({
            "ticker": ticker,
            "name": info["name"],
            "title": quote, 
            "ingu_position": ingu_position,
            "video_id": f"13F_{ticker}_" + "|".join(funds),
            "url": "https://www.dataroma.com"
        })
        
    # 최대 20개로 제한
    data_list = data_list[:20]

    print(f"✅ 총 {len(data_list)}개의 교차 분석 알파 시그널 추출 완료!")
    for idx, item in enumerate(data_list[:5]):
        print(f"  {idx+1}. {item['ticker']} ({item['name']}) - {item['ingu_position']}")

    # 4. Supabase 데이터베이스에 업로드 (기존 데이터 비우고 새로 채움)
    print("[4/4] Supabase 데이터베이스 업데이트 중...")
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json",
        "Prefer": "resolution=ignore-duplicates"
    }
    
    # 먼저 stock_metadata에 등록
    stock_meta_url = f"{SUPABASE_URL}/rest/v1/stock_metadata"
    meta_list = [{"ticker": item["ticker"], "name": item["name"]} for item in data_list]
    requests.post(stock_meta_url, headers=headers, data=json.dumps(meta_list))

    # 기존 데이터 전체 삭제 (최신 리스트로 교체하기 위해)
    delete_url = f"{SUPABASE_URL}/rest/v1/ingu_signals?id=gt.0"
    requests.delete(delete_url, headers=headers)

    # 새로운 데이터 삽입
    headers["Prefer"] = "return=minimal"
    insert_url = f"{SUPABASE_URL}/rest/v1/ingu_signals"
    response = requests.post(insert_url, headers=headers, data=json.dumps(data_list))
    
    if response.status_code in (201, 200, 204):
        print("🎉 Supabase DB 13F 교차분석 업데이트 완료! 플러터 앱에서 즉시 확인 가능합니다.")
    else:
        print(f"❌ Supabase 업데이트 실패: {response.status_code} - {response.text}")

if __name__ == "__main__":
    asyncio.run(crawl_dataroma_activity())

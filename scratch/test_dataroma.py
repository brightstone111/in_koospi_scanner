import sys
import asyncio
from playwright.async_api import async_playwright
from playwright_stealth import Stealth

async def test_dataroma():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
            viewport={"width": 1920, "height": 1080}
        )
        page = await context.new_page()
        await Stealth().apply_stealth_async(page)
        
        funds = {"Fundsmith": "FS", "Akre Capital": "AKRE", "Third Point": "TP"}
        
        for name, m in funds.items():
            url = f"https://www.dataroma.com/m/holdings.php?m={m}"
            print(f"Navigating to {url}")
            
            await page.goto(url, wait_until="domcontentloaded")
            await asyncio.sleep(2)
            
            try:
                rows = await page.query_selector_all("table#grid tbody tr")
                print(f"{name}: Found {len(rows)} holdings.")
                for row in rows[:3]:
                    cols = await row.query_selector_all("td")
                    if len(cols) >= 6:
                        ticker_full = await cols[1].inner_text()
                        change = await cols[5].inner_text()
                        print(f"  {ticker_full} - Change: {change}")
            except Exception as e:
                print(f"Error on {name}: {e}")
            
        await browser.close()

if __name__ == "__main__":
    asyncio.run(test_dataroma())

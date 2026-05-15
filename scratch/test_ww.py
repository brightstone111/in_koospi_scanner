import sys
import asyncio
from playwright.async_api import async_playwright
from playwright_stealth import Stealth

async def test_ww():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        await Stealth().apply_stealth_async(page)
        
        url = "https://www.dataroma.com/m/m_activity.php?m=FS&typ=a"
        await page.goto(url, wait_until="domcontentloaded")
        await asyncio.sleep(2)
        
        tables = await page.evaluate('''() => {
            return Array.from(document.querySelectorAll('table')).map(t => t.id || t.className);
        }''')
        print("Tables found:", tables)
        
        # Check if table has rows
        rows = await page.query_selector_all("table tbody tr")
        print(f"Total rows in any table: {len(rows)}")
        
        # Take a screenshot to verify
        await page.screenshot(path="scratch/dataroma_activity.png")
        
        # Print table HTML
        table = await page.query_selector("table")
        if table:
            html = await table.inner_html()
            print("First table HTML snippet:", html[:1000])
        
        await browser.close()

if __name__ == "__main__":
    asyncio.run(test_ww())

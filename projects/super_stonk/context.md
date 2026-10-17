# super_stonk

## Identity

- **Repo:** `ateate-roro/super_stonk` (private)
- **Local clone:** `C:\Users\19198\orca\super_stonk`
- **URL:** https://github.com/ateate-roro/super_stonk
- **Owner:** Rob Bass (`svarog.llc.2022@gmail.com` / `ateate-roro`)
- **Language:** Python
- **Status:** Early prototype (single script). Last commit 2026-05-10 ("first").
- **Tracked in Hub:** yes

## What it does

Single-file market-data fetcher (`market_data_scraper.py`) that pulls company financials
and market data via `yfinance`, for:

1. **S&P 500** - all ~500 tickers scraped from Wikipedia.
2. **NASDAQ-100** - tickers scraped from Wikipedia.
3. **Custom list** - `--tickers AAPL MSFT ...`.
4. Implicit demo mode when run with no args (10 large caps).

Output: CSV (`market_cap.csv` / demo CSV) with ~60 fields per ticker, sorted by Market Cap descending.

## Key fields captured (FIELDS dict)

Identity, market data (cap, EV, price, 52W range, beta), valuation (P/E, P/B, P/S, EV/EBITDA),
profitability (revenue, margins, EBITDA, net income), balance sheet (cash, debt, ratios),
returns (ROE, ROA), dividends (yield, rate, payout), growth (earnings/revenue YoY),
shares/float/ownership, analyst rating & target price.

## Tech / dependencies

- Python 3
- `yfinance`, `pandas`, `requests`, `lxml`, `beautifulsoup4`, `tqdm`
- Data sources: Wikipedia (ticker lists) + Yahoo Finance (financials via yfinance)

## CLI

```
python market_data_scraper.py --mode sp500|nasdaq100|custom --tickers ... --output file.csv --delay 0.3
```

- Rate-limit mitigation: `time.sleep(delay)` between tickers (default 0.3s).
- Progress bar via `tqdm`.
- Graceful per-ticker error capture (`{"Ticker": ..., "Error": ...}`).

## Known issues / gaps

- Print statement uses mojibake arrow (`[~]` etc.) from an encoding mismatch - cosmetic.
- No tests, no requirements file, no packaging, no retries/backoff for yfinance.
- Wikipedia table selection fragile (NASDAQ-100 loops looking for "Ticker" column).
- No caching; re-running re-fetches everything.
- Output naming fixed default `market_data.csv` (overwrites).
- `.idea/` committed (IDE metadata).

## Conventions / context worth remembering

- Ticker normalization replaces `.` with `-` for S&P 500 (e.g. `BRK.B` -> `BRK-B`).
- Intended workflow appears to be "pull latest universe then enrich"; CSV is the artifact.

## Suggested next steps

- Add `requirements.txt` and `README` usage (minimal README is just `# super_stonk`).
- Add retry/backoff + caching per ticker.
- Separate universe collection from fetching; make output timestamped.
- Add smoke test for `fetch_ticker_data` with a mocked info dict.

## Workflow gate checklist (last run)

- [ ] `workflows/new-project.md` (N/A - existing)
- [ ] `workflows/modify-project.md`
- [ ] `workflows/multi-model-review.md` (if a change ships)

_Last updated: 2026-10-14 (hub bootstrap)._
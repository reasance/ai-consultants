# Model reference: Artificial Analysis Intelligence Index v5.0.1

Generated from controller-models; snapshot 2026-11-15. Each score belongs to its measured effort and benchmark revision.

| Model | Measured effort | Index v5.0.1 | AA USD/task | Serving evidence |
|---|---|---:|---:|---|
| Claude Fable 5.2 | max | 64.6 | $26.54 | API / Claude Code >=2.1.321 |
| Claude Fable 5.2 | xhigh | 62.2 | $14.83 | API / Claude Code >=2.1.321 |
| Claude Fable 5.2 | high | 61.8 | $9.08 | API / Claude Code >=2.1.321 |
| Claude Fable 5.2 | medium | 56.4 | $3.80 | API / Claude Code >=2.1.321 |
| Claude Fable 5.2 | low | 53.9 | $3.10 | API / Claude Code >=2.1.321 |
| Gemini 4 Carbon | high | 60 | $5.48 | agy documented; Ultra/Enterprise; inventory required |
| Gemini 4 Carbon | medium | 58.3 | $4.68 | agy documented; Ultra/Enterprise; inventory required |
| Gemini 4 Carbon | low | 54.2 | $5.22 | agy documented; Ultra/Enterprise; inventory required |
| Gemini 4 Hydrogen | xhigh | 53.9 | $3.16 | agy IDs locally observed / API |
| Gemini 4 Hydrogen | high | 50.8 | $1.87 | agy IDs locally observed / API |
| Gemini 4 Hydrogen | medium | 41.2 | $0.80 | agy IDs locally observed / API |
| Gemini 4 Hydrogen | low | 26.9 | $0.29 | agy IDs locally observed / API |
| Gemini 4 Argon | high | 50.4 | $4.97 | registered transports |
| Gemini 4 Argon | medium | 47.6 | $4.31 | registered transports |
| Gemini 3.8 Flash | high | 30.8 | $7.77 | registered transports |
| Gemini 3.8 Flash | medium | 30.1 | $6.26 | registered transports |
| Gemini 3.8 Flash | low | 22.5 | unknown | registered transports |

## Integration decision

Google economy uses Hydrogen/medium, standard high, premium and the default maximum xhigh. Carbon/high is an explicit CLI-only maximum option: set GEMINI_FRONTIER_CLI_MODEL=gemini-4-carbon-high and GEMINI_USE_API=false before selecting max_quality. It is never selected automatically and an unavailable model fails before dispatch. Claude keeps Fable 5.2/high for premium, max for maximum and Opus/medium for standard. Active model pins and explicit efforts stay user-owned.

## Provider contracts

Fable 5.2 uses `claude-fable-5-2`, adaptive thinking always on, and low/medium/high/xhigh/max effort (API default high). Claude Code requires version 2.1.321 or later and an eligible plan or usage credits. Standard API token rates are $8 input / $40 output per million; fast mode costs $16/$80 and is not enabled by this integration. Fable 5.1 remains a supported explicit choice. AA labels its Fable measurements Default Fallback; this does not authorize local silent fallbacks or additional model calls.

Google made `gemini-4-carbon` publicly available on November 10. Only the separate cyber-permissive variant remains allowlisted. The standard model supports low/medium/high thinking, default medium. A high benchmark score therefore requires explicitly requesting high. Google documents agy IDs gemini-4-carbon-low/medium/high. Carbon requires an enabled Ultra/Enterprise account and is absent from the checked local agy 1.5.9 inventory (November 15, 2026). The integrations check the exact requested ID and fail without a substitute.

Hydrogen uses gemini-4-hydrogen on the API and exact level IDs gemini-4-hydrogen-low/medium/high/xhigh on agy. It defaults to high, supports all four thinking levels, and costs $1.50/$7.50 per million input/output tokens at standard API rates. These rates estimate CLI equivalents, not subscription invoices. Argon and Flash stay selectable.

Carbon has a unified 1,048,576-token input/output window. Foreground generation supports up to 65,536 output tokens when streaming and 32,768 when non-streaming in the Cloud contract. These provider API limits are not agy CLI output limits. ai-consultants keeps a configured 32,768-token API budget; Carbon remains CLI-only here. Long decode needs continuation or background support and is not enabled by these integrations. Do not send thinking_budget or MINIMAL; sampling overrides are ignored. Explicit context caching is unsupported.

Carbon standard API input/output prices are $2/$10 per million tokens through November 30, 2026, then $4/$20 from December 1. Thinking tokens count as output. ai-consultants uses list rates for conservative estimates; delegation-kit's catalog uses the current promotional rate. Neither estimate is a subscription invoice.

## Comparison scope

AA v5.0.1 incorporates a CritPt v2 regrade across models. The language/models/free API exposes major.minor as numeric 5; the patch revision is pinned from AA methodology. Refresh all rows together rather than mixing old 5.0 figures with this snapshot. The API is paginated; the retired data/llms/models endpoint returns 410.

AA USD/task is a weighted benchmark cost. This refreshed snapshot uses the API's current cost figures, including Carbon's promotional rates. It is not a forecast for repository work. Separate Coding/Agentic Index fields remain unknown where AA returns null; legacy fields are not invented from the overall Intelligence Index.

Under the existing 8/20-point rule, the maximum is 64.6: frontier starts at 56.6 and mid at 44.6. Bands are relative, so an unchanged model can move down when a new leader arrives. In particular Terra/high and Sonnet/high now fall below the mid floor. A generic index is advisory evidence and does not qualify a reviewer for a specific repository.

Sources: [AA methodology](https://artificialanalysis.ai/methodology/intelligence-benchmarking), [AA API](https://artificialanalysis.ai/data-api/docs/reference), [Fable 5.2](https://platform.claude.com/docs/en/models/fable-5-2/overview), [Carbon API](https://aistudio.google.com/docs/models/gemini-4-carbon), [Carbon Cloud limits](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/4-carbon), [Carbon pricing](https://aistudio.google.com/docs/pricing#gemini-4-carbon).

# AI Consultants Recipes

Copy-paste configurations for common workflows. Persistent settings belong in
`~/.config/ai-consultants/.env`; prefix a single command with variables when you
only need a temporary override.

Start once with:

```bash
ai-consultants init
$EDITOR ~/.config/ai-consultants/.env
ai-consultants doctor --live
```

All boolean values are lowercase `true` or `false`. At least two consultants
must be enabled.

## 1. Everyday balanced panel

Use three complementary CLI consultants (Gemini, Codex and Mistral) and
synthesize their answers with the default coverage strategy.

```dotenv
DEFAULT_PRESET=balanced
DEFAULT_STRATEGY=coverage
ENABLE_SYNTHESIS=true
```

```bash
ai-consultants "Redis or Memcached for a write-heavy session store?"
```

## 2. Fast and inexpensive check

The `fast` preset selects two consultants and economy models.

```bash
ai-consultants --preset fast "Is this SQL index definition valid?"
```

For a persistent low-cost setup:

```dotenv
DEFAULT_PRESET=fast
DEFAULT_STRATEGY=cost_capped
ENABLE_BUDGET_LIMIT=true
MAX_SESSION_COST=0.10
BUDGET_ACTION=stop
```

## 3. Security review

```dotenv
DEFAULT_STRATEGY=security_first
```

```bash
ai-consultants --preset security \
  "Find authentication bypasses and unsafe trust boundaries" \
  src/auth.ts@PRIMARY src/session.ts@PRIMARY src/config.ts@CONTEXT
```

Never include credentials, tokens, or private keys in consultation context.

## 4. Compare two approaches without a recommendation

Use `--strategy compare_only` when you want the trade-offs laid out without a
single winner.

```bash
ai-consultants --strategy compare_only \
  "For this API, compare REST and GraphQL"
```

## 5. Reliable panel with health gate and quorum

Ping selected consultants before the full run and stop when too few respond.
The health gate adds one small call per selected consultant.

```dotenv
ENABLE_HEALTH_GATE=true
HEALTH_GATE_TIMEOUT=30
QUORUM_MIN=3
QUORUM_ACTION=stop
MAX_RETRIES=2
RETRY_DELAY_SECONDS=5
```

```bash
ai-consultants doctor --live
ai-consultants "Make a release recommendation from the attached evidence" \
  release-notes.md@PRIMARY test-results.md@CONTEXT
```

## 6. Hard budget ceiling

Track estimated spend and stop rather than crossing the session limit. The
check runs before Round 1 (on an estimate), before any escalation, and before
synthesis (whose estimated cost is included in the session total). A stop
before Round 1 aborts the run; a stop before synthesis keeps the consultant
responses and skips synthesis.

```dotenv
ENABLE_COST_TRACKING=true
ENABLE_BUDGET_LIMIT=true
MAX_SESSION_COST=0.50
WARN_AT_COST=0.25
BUDGET_ACTION=stop
ENABLE_COST_AWARE_ROUTING=true
```

`cost-capped` lowers only the stock `$1.00` cap to `$0.10`; the explicit
`MAX_SESSION_COST=0.50` above is kept. `ENABLE_COST_AWARE_ROUTING` uses
economy models for simple questions and may re-ask a low-confidence
structured answer on the premium model (budget permitting).

```bash
ai-consultants --preset cost-capped --strategy cost_capped \
  "Propose the smallest safe fix for this regression"
```

## 7. CLI-only operation

Keep every switchable consultant on its installed CLI. CLI authentication is
handled by each provider's own login flow.

```dotenv
GEMINI_USE_API=false
CODEX_USE_API=false
CLAUDE_USE_API=false
MISTRAL_USE_API=false
QWEN3_USE_API=false
MINIMAX_USE_API=false
META_USE_API=false
GROK_USE_API=false
KIMI_MODEL=kimi-code/k3.1-pro

ENABLE_GLM=false
ENABLE_DEEPSEEK=false
```

```bash
ai-consultants doctor --live
```

`KIMI_MODEL` is passed to the Kimi CLI with `--model`, so this recipe uses K3.1 Pro
even when the Kimi CLI's own configuration (`~/.kimi-code/config.toml`) still
names an older default model.

## 8. Hybrid CLI and API panel

Enable API transport only where needed. Grok normally uses Grok Build and
automatically falls back to the xAI API if the CLI cannot run. Gemini,
MiniMax and Meta automatically choose API mode when their API key is present
unless `*_USE_API` is explicitly set.

```dotenv
CODEX_USE_API=false
CLAUDE_USE_API=false
MISTRAL_USE_API=false
QWEN3_USE_API=true
QWEN3_API_KEY=your-dashscope-key

ENABLE_GROK=true
GROK_USE_API=false
GROK_API_KEY=your-xai-key
GROK_MODEL=grok-4.7

ENABLE_GLM=false
ENABLE_DEEPSEEK=false
```

Keep `~/.config/ai-consultants/.env` at mode `600` because it may contain keys.

## 9. Large or awkward prompts

Use `--query-file` to avoid shell quoting and argument-size problems. Mark the
main files with `@PRIMARY` and supporting files with `@CONTEXT`.

```bash
q=$(mktemp) && chmod 600 "$q"
$EDITOR "$q"    # write the question
ai-consultants --query-file "$q" \
  src/auth.ts@PRIMARY \
  src/cache.ts@CONTEXT \
  docs/architecture.md@CONTEXT
rm -f "$q"
```

## 10. Long-running consultations

Nothing times out by default, so a slow reasoning model is waited for. Run the
consultation in the background and decide when to stop waiting from its log:

```bash
ai-consultants --preset max_quality "..." 2> run.log &
grep 'Output:' run.log                  # the output directory
tail -f run.log                         # "Still waiting after Ns for: ..." every 30 s
touch "<output dir>/.proceed"           # continue with the answers received
touch "<output dir>/.abort"             # or end the run
```

For an unattended hard limit instead, set a positive timeout per consultant,
for example `GEMINI_TIMEOUT=600`.

## Useful diagnostics

```bash
ai-consultants doctor
ai-consultants doctor --live
ai-consultants doctor --json
ai-consultants doctor --suggest-config
ai-consultants doctor --suggest-preset --question "How should I secure uploads?"
ai-consultants update-clis --dry-run
```

For every available variable and its default, see
[`references/configuration.md`](../references/configuration.md). The executable
source of truth is [`scripts/config.sh`](../scripts/config.sh).

## Qwen via Qwen Cloud Token Plan

`qwen4-max` is the final default/premium model; maximum requests `xhigh` on
OpenAI-compatible API calls. `qwen3.8-flash` stays standard/economy.
`QWEN3_*` environment names remain compatible. Qwen3.8 Max remains an explicit
choice; a current unmarked or pinned model and an explicit effort are preserved.
`configure` upgrades only marked generated Qwen3.8 defaults. Retired older IDs
still follow their recorded migration rules.

On November 16, 2026, the authenticated Token Plan endpoint listed both
`qwen4-max` and `qwen4-max-preview`. One non-thinking ping to **qwen4-max**
returned HTTP 200, `PONG` and provider-reported `qwen4-max` in 4.03 seconds,
with 32 input and 3 output tokens, no retry and no fallback. That verifies API
access, not coding quality or the Qwen/Claude CLI paths. The preview is a
separate deployment and is never substituted.

### API mode

```bash
QWEN3_USE_API=true
QWEN3_FORMAT=openai
QWEN3_API_URL=https://token-plan.maas.qwencloudapi.com/compatible-mode/v1/chat/completions
QWEN3_MODEL=qwen4-max
QWEN3_API_KEY=<your matching Token Plan key>
QWEN3_REASONING_EFFORT=high
QWEN3_API_MAX_TOKENS=16384
```

Pass the full `/chat/completions` URL. Fresh configurations default to this
Token Plan endpoint and the OpenAI-compatible wire. An existing explicit
endpoint or key is never repointed. Qwen4 refuses the old DashScope
text-generation wire before dispatch; its native DashScope protocol uses the
multimodal endpoint even for text. To use pay-as-you-go, explicitly set the
regional QwenCloud compatible URL and its matching pay-as-you-go key.

The final model's canonical thinking levels are `low`, `high` and `xhigh`
(default `high`). The provider maps `minimal` to low, `medium` to high and
`max` to xhigh. Use canonical values when comparing runs. The API budget
limits thinking **plus** the visible answer; a short answer-only budget can
truncate reasoning. The configured 16,384-token ceiling can be raised explicitly
up to the provider's 262,144-token combined limit. Non-thinking output is
limited to 131,072 tokens. The preview's 393,216 limit does not apply.

Token Plan spends credits. Qwen models remain explicitly unpriced in local
session totals; zero does not mean free. Singapore list prices ($1.50/$4.50
per million input/output tokens) are reference API rates, not a subscription
invoice. A key must match its endpoint and current plan; authentication and
request errors are surfaced without switching providers or models.


An explicit Qwen3.8 Max or Flash model pin without a custom endpoint keeps the
legacy implicit DashScope endpoint/wire. Existing keys are not silently moved
to a different plan. New Qwen4 configurations use the compatible Token Plan
endpoint; set its matching key deliberately.

### CLI mode

The `qwen` CLI has no per-request reasoning-effort flag. ai-consultants warns
when `QWEN3_REASONING_EFFORT` is set in CLI mode; the setting belongs in Qwen
Code. Append this provider entry to the existing `modelProviders.openai`
array in `~/.qwen/settings.json`, keeping other entries and credentials:

```json
{
  "id": "qwen4-max",
  "name": "[QwenCloud Token Plan] qwen4-max",
  "baseUrl": "https://token-plan.maas.qwencloudapi.com/compatible-mode/v1",
  "envKey": "QWENCLOUD_TOKEN_PLAN_API_KEY",
  "capabilities": {
    "reasoning": {
      "thinking": true,
      "efforts": ["low", "high", "xhigh"],
      "defaultEffort": "high",
      "disableField": "reasoning_effort"
    }
  },
  "generationConfig": { "contextWindowSize": 1000000 }
}
```

Provide `QWENCLOUD_TOKEN_PLAN_API_KEY` privately through Qwen Code's credential
configuration or the environment. Set `model.reasoningEffort` to the intended
level. This is configuration guidance; the API ping above did not test this
CLI entry. No installer rewrites an existing Qwen provider or credential.

[Final model and limits](https://docs.qwencloud.com/developer-guides/getting-started/latest-model)
· [Official pricing](https://docs.qwencloud.com/developer-guides/getting-started/pricing)
· [AA benchmark](https://artificialanalysis.ai/models/qwen4-max)

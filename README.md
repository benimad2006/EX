# MyEx

Breakup-recovery app for iPhone (Flutter + Supabase + RevenueCat).

| Path | What it is |
|---|---|
| `myex_app/` | Flutter app (see its README for setup, placeholders and demo mode) |
| `MyEx_Glass_Premium.html` | Clickable iOS prototype of the monetization flow |
| `MyEx_Design_Spec.md` | Design spec and tokens |
| `MyEx_Monetization_Prompts.md` | Build prompts for Flutter, Supabase and RevenueCat |
| `MyEx_Paywall_Inspiration.md` | Paywall and onboarding research |

iOS Simulator (no keys needed, runs in demo mode): `cd myex_app && flutter run -d <simulator-id>`.
See "Run on the iOS Simulator" in `myex_app/README.md` for setup and troubleshooting.

Demo APK (no keys needed): `cd myex_app && flutter build apk --release --dart-define=DEMO=true`

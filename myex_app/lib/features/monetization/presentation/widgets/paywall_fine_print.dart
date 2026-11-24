import 'package:flutter/material.dart';

import '../../../../core/config/env.dart';
import '../../../../core/design/design.dart';
import '../../../../core/util/context_x.dart';

/// Terms of Use · Privacy Policy (Restore lives top-right on the paywall).
class PaywallLinks extends StatelessWidget {
  const PaywallLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // Wrap, not Row: stays on screen at large Dynamic Type sizes.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextLinkButton(
          label: l.commonTermsOfUse,
          onPressed: () => Links.openInApp(Env.termsUrl),
          tone: TextLinkTone.muted,
          small: true,
        ),
        ExcludeSemantics(
          child: Text('·', style: TextStyle(color: MyExColors.ink3)),
        ),
        TextLinkButton(
          label: l.commonPrivacyPolicy,
          onPressed: () => Links.openInApp(Env.privacyUrl),
          tone: TextLinkTone.muted,
          small: true,
        ),
      ],
    );
  }
}

/// Auto-renewal legal text (Guideline 3.1.2), quiet footnote.
class PaywallLegalText extends StatelessWidget {
  const PaywallLegalText({super.key});

  @override
  Widget build(BuildContext context) => Footnote(context.l10n.paywallFineLegal);
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MyEx'**
  String get appTitle;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonRetry;

  /// No description provided for @commonContinueFree.
  ///
  /// In en, this message translates to:
  /// **'Continue Free'**
  String get commonContinueFree;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// No description provided for @commonTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get commonTermsOfUse;

  /// No description provided for @commonPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get commonPrivacyPolicy;

  /// No description provided for @commonNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get commonNotNow;

  /// No description provided for @configMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration missing'**
  String get configMissingTitle;

  /// No description provided for @configMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Run the app with --dart-define-from-file=env/dev.json. Missing: {keys}'**
  String configMissingBody(String keys);

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t connect. Check your connection and try again.'**
  String get startupError;

  /// No description provided for @planReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plan is ready.'**
  String get planReadyTitle;

  /// No description provided for @planReadySub.
  ///
  /// In en, this message translates to:
  /// **'Built from your answers. It starts small, tonight.'**
  String get planReadySub;

  /// No description provided for @planReadyWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get planReadyWhatHappened;

  /// No description provided for @planReadyAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment style'**
  String get planReadyAttachment;

  /// No description provided for @planReadyFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get planReadyFocus;

  /// No description provided for @planReadyFirstStep.
  ///
  /// In en, this message translates to:
  /// **'First step'**
  String get planReadyFirstStep;

  /// No description provided for @planReadyFirstStepValue.
  ///
  /// In en, this message translates to:
  /// **'Tonight · {minutes} min'**
  String planReadyFirstStepValue(int minutes);

  /// No description provided for @planReadyNote.
  ///
  /// In en, this message translates to:
  /// **'Grounded in CBT and attachment research. Mira is a coach, not a therapist.'**
  String get planReadyNote;

  /// No description provided for @planReadyCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get planReadyCta;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'30 days to feel like you again.'**
  String get paywallTitle;

  /// No description provided for @paywallSub.
  ///
  /// In en, this message translates to:
  /// **'Your full plan, and Mira whenever it gets hard.'**
  String get paywallSub;

  /// No description provided for @paywallStripCaption.
  ///
  /// In en, this message translates to:
  /// **'You’re on Day {day}. Premium opens the rest.'**
  String paywallStripCaption(int day);

  /// No description provided for @paywallBenefitMiraTitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to Mira anytime'**
  String get paywallBenefitMiraTitle;

  /// No description provided for @paywallBenefitMiraSub.
  ///
  /// In en, this message translates to:
  /// **'No nightly message limit'**
  String get paywallBenefitMiraSub;

  /// No description provided for @paywallBenefitPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'All 30 days of your plan'**
  String get paywallBenefitPlanTitle;

  /// No description provided for @paywallBenefitPlanSub.
  ///
  /// In en, this message translates to:
  /// **'Free stops after Day {day}'**
  String paywallBenefitPlanSub(int day);

  /// No description provided for @paywallBenefitAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Your full analysis'**
  String get paywallBenefitAnalysisTitle;

  /// No description provided for @paywallBenefitAnalysisSub.
  ///
  /// In en, this message translates to:
  /// **'All three patterns, not just one'**
  String get paywallBenefitAnalysisSub;

  /// No description provided for @paywallPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get paywallPickerLabel;

  /// No description provided for @paywallYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get paywallYearly;

  /// No description provided for @paywallMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallMonthly;

  /// No description provided for @paywallSave.
  ///
  /// In en, this message translates to:
  /// **'Save {pct}'**
  String paywallSave(String pct);

  /// No description provided for @paywallYearlyDetailTrial.
  ///
  /// In en, this message translates to:
  /// **'{days} days free · {monthly}/month'**
  String paywallYearlyDetailTrial(int days, String monthly);

  /// No description provided for @paywallYearlyDetail.
  ///
  /// In en, this message translates to:
  /// **'{monthly}/month'**
  String paywallYearlyDetail(String monthly);

  /// No description provided for @paywallNoTrial.
  ///
  /// In en, this message translates to:
  /// **'No free trial'**
  String get paywallNoTrial;

  /// No description provided for @paywallPerYear.
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get paywallPerYear;

  /// No description provided for @paywallPerMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get paywallPerMonth;

  /// No description provided for @paywallTimelineToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get paywallTimelineToday;

  /// No description provided for @paywallTimelineTodayBody.
  ///
  /// In en, this message translates to:
  /// **'Full access. No charge.'**
  String get paywallTimelineTodayBody;

  /// No description provided for @paywallTimelineRemindBody.
  ///
  /// In en, this message translates to:
  /// **'We’ll send you a reminder.'**
  String get paywallTimelineRemindBody;

  /// No description provided for @paywallTimelineRemindOffBody.
  ///
  /// In en, this message translates to:
  /// **'No reminder. You can turn it on here.'**
  String get paywallTimelineRemindOffBody;

  /// No description provided for @paywallTimelineEndBody.
  ///
  /// In en, this message translates to:
  /// **'Your plan starts at {price}/year. Cancel before then and you won’t be charged.'**
  String paywallTimelineEndBody(String price);

  /// No description provided for @paywallRemindSemantics.
  ///
  /// In en, this message translates to:
  /// **'Remind me before my trial ends'**
  String get paywallRemindSemantics;

  /// No description provided for @paywallPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your conversations stay private.'**
  String get paywallPrivacyNote;

  /// No description provided for @paywallCtaTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get paywallCtaTrial;

  /// No description provided for @paywallCtaSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get paywallCtaSubscribe;

  /// No description provided for @paywallFineTrial.
  ///
  /// In en, this message translates to:
  /// **'{days} days free, then {price}/year. Cancel anytime in Settings.'**
  String paywallFineTrial(int days, String price);

  /// No description provided for @paywallFineYearly.
  ///
  /// In en, this message translates to:
  /// **'{price}/year. Cancel anytime in Settings.'**
  String paywallFineYearly(String price);

  /// No description provided for @paywallFineMonthly.
  ///
  /// In en, this message translates to:
  /// **'{price}/month. Cancel anytime in Settings.'**
  String paywallFineMonthly(String price);

  /// No description provided for @paywallFineCoins.
  ///
  /// In en, this message translates to:
  /// **'Premium includes {count} coins a month.'**
  String paywallFineCoins(int count);

  /// No description provided for @paywallFineLegal.
  ///
  /// In en, this message translates to:
  /// **'Payment is charged to your Apple ID when you confirm (or when the free trial ends). The subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in Settings › Apple ID › Subscriptions.'**
  String get paywallFineLegal;

  /// No description provided for @paywallError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the plans.'**
  String get paywallError;

  /// No description provided for @paywallPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get paywallPending;

  /// No description provided for @paywallFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase didn’t go through. You weren’t charged.'**
  String get paywallFailed;

  /// No description provided for @paywallRestoreNone.
  ///
  /// In en, this message translates to:
  /// **'No purchases to restore'**
  String get paywallRestoreNone;

  /// No description provided for @paywallRestoreDone.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get paywallRestoreDone;

  /// No description provided for @paywallPlanSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}. {billed}. {detail}'**
  String paywallPlanSemantics(String name, String billed, String detail);

  /// No description provided for @compareHeader.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get compareHeader;

  /// No description provided for @compareFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get compareFree;

  /// No description provided for @comparePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get comparePremium;

  /// No description provided for @compareRowPlan.
  ///
  /// In en, this message translates to:
  /// **'Daily plan'**
  String get compareRowPlan;

  /// No description provided for @compareRowPlanFree.
  ///
  /// In en, this message translates to:
  /// **'Day 1–{day}'**
  String compareRowPlanFree(int day);

  /// No description provided for @compareRowPlanPremium.
  ///
  /// In en, this message translates to:
  /// **'All 30'**
  String get compareRowPlanPremium;

  /// No description provided for @compareRowMira.
  ///
  /// In en, this message translates to:
  /// **'Talks with Mira'**
  String get compareRowMira;

  /// No description provided for @compareRowMiraFree.
  ///
  /// In en, this message translates to:
  /// **'{count} a day'**
  String compareRowMiraFree(int count);

  /// No description provided for @compareUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get compareUnlimited;

  /// No description provided for @compareRowSos.
  ///
  /// In en, this message translates to:
  /// **'SOS and helplines'**
  String get compareRowSos;

  /// No description provided for @compareIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get compareIncluded;

  /// No description provided for @compareNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'Not included'**
  String get compareNotIncluded;

  /// No description provided for @compareRowDraft.
  ///
  /// In en, this message translates to:
  /// **'Unsent drafts (Draft Jail)'**
  String get compareRowDraft;

  /// No description provided for @compareRowDraftFree.
  ///
  /// In en, this message translates to:
  /// **'{count} a day'**
  String compareRowDraftFree(int count);

  /// No description provided for @compareRowAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Relationship analysis'**
  String get compareRowAnalysis;

  /// No description provided for @compareRowAnalysisFree.
  ///
  /// In en, this message translates to:
  /// **'1 insight'**
  String get compareRowAnalysisFree;

  /// No description provided for @compareRowAnalysisPremium.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get compareRowAnalysisPremium;

  /// No description provided for @compareRowCoins.
  ///
  /// In en, this message translates to:
  /// **'Bonus coins'**
  String get compareRowCoins;

  /// No description provided for @compareRowCoinsPremium.
  ///
  /// In en, this message translates to:
  /// **'{count} a month'**
  String compareRowCoinsPremium(int count);

  /// No description provided for @exitSheetLabel.
  ///
  /// In en, this message translates to:
  /// **'Special offer'**
  String get exitSheetLabel;

  /// No description provided for @exitTitleHalf.
  ///
  /// In en, this message translates to:
  /// **'Your first year, half price.'**
  String get exitTitleHalf;

  /// No description provided for @exitTitlePct.
  ///
  /// In en, this message translates to:
  /// **'Your first year, {pct} off.'**
  String exitTitlePct(String pct);

  /// No description provided for @exitBody.
  ///
  /// In en, this message translates to:
  /// **'{offer} for your first year, then {annual}/year. Cancel anytime.'**
  String exitBody(String offer, String annual);

  /// No description provided for @exitCta.
  ///
  /// In en, this message translates to:
  /// **'Try a Year for {offer}'**
  String exitCta(String offer);

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re all set, {name}.'**
  String welcomeTitle(String name);

  /// No description provided for @welcomeTitleNoName.
  ///
  /// In en, this message translates to:
  /// **'You’re all set.'**
  String get welcomeTitleNoName;

  /// No description provided for @welcomeSubTrialRemind.
  ///
  /// In en, this message translates to:
  /// **'Everything’s open. We’ll remind you on {date}, two days before your trial ends.'**
  String welcomeSubTrialRemind(String date);

  /// No description provided for @welcomeSubTrial.
  ///
  /// In en, this message translates to:
  /// **'Everything’s open. Your trial ends on {date}.'**
  String welcomeSubTrial(String date);

  /// No description provided for @welcomeSubPaid.
  ///
  /// In en, this message translates to:
  /// **'Everything’s open. Take it one day at a time.'**
  String get welcomeSubPaid;

  /// No description provided for @welcomeAll30.
  ///
  /// In en, this message translates to:
  /// **'All 30 days'**
  String get welcomeAll30;

  /// No description provided for @welcomeMira.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Mira'**
  String get welcomeMira;

  /// No description provided for @welcomeAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Full relationship analysis'**
  String get welcomeAnalysis;

  /// No description provided for @welcomeCoinsAdded.
  ///
  /// In en, this message translates to:
  /// **'+{count} coins added'**
  String welcomeCoinsAdded(int count);

  /// No description provided for @welcomeCoinsPending.
  ///
  /// In en, this message translates to:
  /// **'+{count} coins on the way'**
  String welcomeCoinsPending(int count);

  /// No description provided for @welcomeCta.
  ///
  /// In en, this message translates to:
  /// **'Go to Your Plan'**
  String get welcomeCta;

  /// No description provided for @welcomeFine.
  ///
  /// In en, this message translates to:
  /// **'Manage anytime in Me › Subscription'**
  String get welcomeFine;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeTitle;

  /// No description provided for @homeGreetingLate.
  ///
  /// In en, this message translates to:
  /// **'Still up'**
  String get homeGreetingLate;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingName.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String homeGreetingName(String greeting, String name);

  /// No description provided for @homeHeroLabel.
  ///
  /// In en, this message translates to:
  /// **'No contact'**
  String get homeHeroLabel;

  /// No description provided for @homeHeroUnit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day} other{days}}'**
  String homeHeroUnit(int count);

  /// No description provided for @homeHeroNext.
  ///
  /// In en, this message translates to:
  /// **'{remaining, plural, =1{1 more day to {target} days} other{{remaining} more days to {target} days}}'**
  String homeHeroNext(int remaining, int target);

  /// No description provided for @homeHeroStart.
  ///
  /// In en, this message translates to:
  /// **'Start your no-contact streak today.'**
  String get homeHeroStart;

  /// No description provided for @homeHeroStartCta.
  ///
  /// In en, this message translates to:
  /// **'Start Today'**
  String get homeHeroStartCta;

  /// No description provided for @homePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your 30-day plan'**
  String get homePlanTitle;

  /// No description provided for @homePlanSub.
  ///
  /// In en, this message translates to:
  /// **'Free covers Days 1–{day}'**
  String homePlanSub(int day);

  /// No description provided for @homeMiraTitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to Mira'**
  String get homeMiraTitle;

  /// No description provided for @homeMiraFreeLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No free messages left tonight} =1{1 free message left tonight} other{{count} free messages left tonight}}'**
  String homeMiraFreeLeft(int count);

  /// No description provided for @homeMiraUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Anytime, no limit'**
  String get homeMiraUnlimited;

  /// No description provided for @homeSosTitle.
  ///
  /// In en, this message translates to:
  /// **'About to text them?'**
  String get homeSosTitle;

  /// No description provided for @homeSosSub.
  ///
  /// In en, this message translates to:
  /// **'Pause first. SOS is always free.'**
  String get homeSosSub;

  /// No description provided for @homeUpsellTitle.
  ///
  /// In en, this message translates to:
  /// **'Day 4 is part of Premium'**
  String get homeUpsellTitle;

  /// No description provided for @homeUpsellTryFree.
  ///
  /// In en, this message translates to:
  /// **'Try free'**
  String get homeUpsellTryFree;

  /// No description provided for @homeUpsellSeePlans.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get homeUpsellSeePlans;

  /// No description provided for @homeTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Free trial: 1 day left} other{Free trial: {count} days left}}'**
  String homeTrialTitle(int count);

  /// No description provided for @homeTrialSub.
  ///
  /// In en, this message translates to:
  /// **'See your subscription'**
  String get homeTrialSub;

  /// No description provided for @coinChipSemantics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 coin. Open coins} other{{count} coins. Open coins}}'**
  String coinChipSemantics(int count);

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get tabPlan;

  /// No description provided for @tabCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get tabCoach;

  /// No description provided for @tabMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabMe;

  /// No description provided for @sosButton.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sosButton;

  /// No description provided for @sosButtonSemantics.
  ///
  /// In en, this message translates to:
  /// **'SOS, always free'**
  String get sosButtonSemantics;

  /// No description provided for @coachTitle.
  ///
  /// In en, this message translates to:
  /// **'Mira'**
  String get coachTitle;

  /// No description provided for @coachGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi. I’m here. How’s tonight going?'**
  String get coachGreeting;

  /// No description provided for @coachHint.
  ///
  /// In en, this message translates to:
  /// **'Message Mira'**
  String get coachHint;

  /// No description provided for @coachSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get coachSend;

  /// No description provided for @coachMeter.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No free messages left tonight} =1{1 free message left tonight} other{{count} free messages left tonight}}'**
  String coachMeter(int count);

  /// No description provided for @coachGetMore.
  ///
  /// In en, this message translates to:
  /// **'Get More'**
  String get coachGetMore;

  /// No description provided for @coachSosMode.
  ///
  /// In en, this message translates to:
  /// **'SOS mode · no limits'**
  String get coachSosMode;

  /// No description provided for @coachTyping.
  ///
  /// In en, this message translates to:
  /// **'Mira is typing'**
  String get coachTyping;

  /// No description provided for @coachError.
  ///
  /// In en, this message translates to:
  /// **'Mira couldn’t answer. Your message is still here.'**
  String get coachError;

  /// No description provided for @limitSheetLabel.
  ///
  /// In en, this message translates to:
  /// **'Message limit'**
  String get limitSheetLabel;

  /// No description provided for @limitTitle.
  ///
  /// In en, this message translates to:
  /// **'Mira’s still here.'**
  String get limitTitle;

  /// No description provided for @limitBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You’ve used tonight’s free message.} other{You’ve used tonight’s {count} free messages.}}'**
  String limitBody(int count);

  /// No description provided for @limitPremium.
  ///
  /// In en, this message translates to:
  /// **'Keep Talking with Premium'**
  String get limitPremium;

  /// No description provided for @limitPremiumTrialNote.
  ///
  /// In en, this message translates to:
  /// **'Includes a {days}-day free trial.'**
  String limitPremiumTrialNote(int days);

  /// No description provided for @limitCoins.
  ///
  /// In en, this message translates to:
  /// **'{count} More Messages for {cost} Coins'**
  String limitCoins(int count, int cost);

  /// No description provided for @limitGetCoins.
  ///
  /// In en, this message translates to:
  /// **'Get Coins'**
  String get limitGetCoins;

  /// No description provided for @limitWait.
  ///
  /// In en, this message translates to:
  /// **'Wait Until {time}'**
  String limitWait(String time);

  /// No description provided for @limitSos.
  ///
  /// In en, this message translates to:
  /// **'Struggling right now? SOS is always free.'**
  String get limitSos;

  /// No description provided for @limitCreditsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} messages added'**
  String limitCreditsAdded(int count);

  /// No description provided for @coinsTitle.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coinsTitle;

  /// No description provided for @coinsUnit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{coin} other{coins}}'**
  String coinsUnit(int count);

  /// No description provided for @coinsGetHeader.
  ///
  /// In en, this message translates to:
  /// **'Get coins'**
  String get coinsGetHeader;

  /// No description provided for @coinsPackTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} coins'**
  String coinsPackTitle(int count);

  /// No description provided for @coinsPackBonus.
  ///
  /// In en, this message translates to:
  /// **'+{count} bonus'**
  String coinsPackBonus(int count);

  /// No description provided for @coinsBestValueBonus.
  ///
  /// In en, this message translates to:
  /// **'Best value · +{count} bonus'**
  String coinsBestValueBonus(int count);

  /// No description provided for @coinsBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get coinsBestValue;

  /// No description provided for @coinsUnlockHeader.
  ///
  /// In en, this message translates to:
  /// **'What you can unlock'**
  String get coinsUnlockHeader;

  /// No description provided for @coinsItemMsgs.
  ///
  /// In en, this message translates to:
  /// **'{count} more messages with Mira'**
  String coinsItemMsgs(int count);

  /// No description provided for @coinsItemPlanDay.
  ///
  /// In en, this message translates to:
  /// **'Unlock one plan day'**
  String get coinsItemPlanDay;

  /// No description provided for @coinsItemAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Full relationship analysis'**
  String get coinsItemAnalysis;

  /// No description provided for @coinsCrossSell.
  ///
  /// In en, this message translates to:
  /// **'Premium includes {count} coins a month'**
  String coinsCrossSell(int count);

  /// No description provided for @coinsAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding your coins…'**
  String get coinsAdding;

  /// No description provided for @coinsOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Your coins are on the way. Pull to refresh.'**
  String get coinsOnTheWay;

  /// No description provided for @coinsAdded.
  ///
  /// In en, this message translates to:
  /// **'+{count} coins added'**
  String coinsAdded(int count);

  /// No description provided for @coinsError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the coin packs.'**
  String get coinsError;

  /// No description provided for @sosTitle.
  ///
  /// In en, this message translates to:
  /// **'Pause. Breathe.'**
  String get sosTitle;

  /// No description provided for @sosBreatheIn.
  ///
  /// In en, this message translates to:
  /// **'Breathe in'**
  String get sosBreatheIn;

  /// No description provided for @sosBreatheOut.
  ///
  /// In en, this message translates to:
  /// **'Breathe out'**
  String get sosBreatheOut;

  /// No description provided for @sosBodyStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You’ve gone 1 day without reaching out. Let’s get through the next ten minutes together.} other{You’ve gone {count} days without reaching out. Let’s get through the next ten minutes together.}}'**
  String sosBodyStreak(int count);

  /// No description provided for @sosBody.
  ///
  /// In en, this message translates to:
  /// **'You don’t have to decide anything right now. Let’s get through the next ten minutes together.'**
  String get sosBody;

  /// No description provided for @sosTalk.
  ///
  /// In en, this message translates to:
  /// **'Talk to Mira'**
  String get sosTalk;

  /// No description provided for @sosUrgent.
  ///
  /// In en, this message translates to:
  /// **'I Need Urgent Help'**
  String get sosUrgent;

  /// No description provided for @sosFree.
  ///
  /// In en, this message translates to:
  /// **'SOS is always free.'**
  String get sosFree;

  /// No description provided for @crisisSheetLabel.
  ///
  /// In en, this message translates to:
  /// **'Crisis support'**
  String get crisisSheetLabel;

  /// No description provided for @crisisTitle.
  ///
  /// In en, this message translates to:
  /// **'You don’t have to handle this alone.'**
  String get crisisTitle;

  /// No description provided for @crisisBody.
  ///
  /// In en, this message translates to:
  /// **'If you might hurt yourself, please reach a real person now.'**
  String get crisisBody;

  /// No description provided for @crisisCallEmergency.
  ///
  /// In en, this message translates to:
  /// **'Call Emergency Services'**
  String get crisisCallEmergency;

  /// No description provided for @crisisCallHelpline.
  ///
  /// In en, this message translates to:
  /// **'Call a Helpline'**
  String get crisisCallHelpline;

  /// No description provided for @crisisNumbers.
  ///
  /// In en, this message translates to:
  /// **'Emergency {emergency}'**
  String crisisNumbers(String emergency);

  /// No description provided for @crisisNumbersHelpline.
  ///
  /// In en, this message translates to:
  /// **'Emergency {emergency} · Helpline {helpline}'**
  String crisisNumbersHelpline(String emergency, String helpline);

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Your 30 Days'**
  String get planTitle;

  /// No description provided for @planNotReady.
  ///
  /// In en, this message translates to:
  /// **'Your daily plan is being prepared. Check back soon.'**
  String get planNotReady;

  /// No description provided for @meTitle.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTitle;

  /// No description provided for @meStatusFree.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get meStatusFree;

  /// No description provided for @meStatusTrial.
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get meStatusTrial;

  /// No description provided for @meStatusPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get meStatusPremium;

  /// No description provided for @meFreeCardTitleTrial.
  ///
  /// In en, this message translates to:
  /// **'Try Premium free for {days} days'**
  String meFreeCardTitleTrial(int days);

  /// No description provided for @meFreeCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get meFreeCardTitle;

  /// No description provided for @meFreeCardBody.
  ///
  /// In en, this message translates to:
  /// **'All 30 days, unlimited Mira, full analysis.'**
  String get meFreeCardBody;

  /// No description provided for @meTryFree.
  ///
  /// In en, this message translates to:
  /// **'Try Free'**
  String get meTryFree;

  /// No description provided for @meSeePlans.
  ///
  /// In en, this message translates to:
  /// **'See Plans'**
  String get meSeePlans;

  /// No description provided for @meSubscriptionHeader.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get meSubscriptionHeader;

  /// No description provided for @mePlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get mePlan;

  /// No description provided for @mePlanYearlyTrial.
  ///
  /// In en, this message translates to:
  /// **'Yearly · Free trial'**
  String get mePlanYearlyTrial;

  /// No description provided for @mePlanYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get mePlanYearly;

  /// No description provided for @mePlanMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get mePlanMonthly;

  /// No description provided for @mePlanPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get mePlanPremium;

  /// No description provided for @meRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews'**
  String get meRenews;

  /// No description provided for @meEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get meEnds;

  /// No description provided for @meManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get meManage;

  /// No description provided for @meCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get meCancel;

  /// No description provided for @meBillingIssue.
  ///
  /// In en, this message translates to:
  /// **'There’s a problem with your payment. Update it in the App Store to keep Premium.'**
  String get meBillingIssue;

  /// No description provided for @meAccountHeader.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get meAccountHeader;

  /// No description provided for @meCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get meCoins;

  /// No description provided for @meRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get meRestore;

  /// No description provided for @meSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get meSupport;

  /// No description provided for @onbStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onbStep(int step, int total);

  /// No description provided for @onbContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onbContinue;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Which language do you prefer?'**
  String get onbLanguageTitle;

  /// No description provided for @onbLanguageSub.
  ///
  /// In en, this message translates to:
  /// **'You can change it later in Settings.'**
  String get onbLanguageSub;

  /// No description provided for @onbLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get onbLanguageEn;

  /// No description provided for @onbLanguageTr.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get onbLanguageTr;

  /// No description provided for @onbWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get onbWhatTitle;

  /// No description provided for @onbWhatSub.
  ///
  /// In en, this message translates to:
  /// **'There’s no wrong answer.'**
  String get onbWhatSub;

  /// No description provided for @whatTheyEnded.
  ///
  /// In en, this message translates to:
  /// **'They ended it'**
  String get whatTheyEnded;

  /// No description provided for @whatIEnded.
  ///
  /// In en, this message translates to:
  /// **'I ended it'**
  String get whatIEnded;

  /// No description provided for @whatMutual.
  ///
  /// In en, this message translates to:
  /// **'It was mutual'**
  String get whatMutual;

  /// No description provided for @whatComplicated.
  ///
  /// In en, this message translates to:
  /// **'It’s complicated'**
  String get whatComplicated;

  /// No description provided for @onbDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'A little more, if you like'**
  String get onbDetailsTitle;

  /// No description provided for @onbDetailsSub.
  ///
  /// In en, this message translates to:
  /// **'Both optional. Only you will see their name.'**
  String get onbDetailsSub;

  /// No description provided for @onbYourName.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get onbYourName;

  /// No description provided for @onbExName.
  ///
  /// In en, this message translates to:
  /// **'Their name'**
  String get onbExName;

  /// No description provided for @onbExNameHint.
  ///
  /// In en, this message translates to:
  /// **'Only you will see this'**
  String get onbExNameHint;

  /// No description provided for @onbLength.
  ///
  /// In en, this message translates to:
  /// **'How long were you together?'**
  String get onbLength;

  /// No description provided for @onbDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onbDone;

  /// No description provided for @lenLt6m.
  ///
  /// In en, this message translates to:
  /// **'Less than 6 months'**
  String get lenLt6m;

  /// No description provided for @len6to12m.
  ///
  /// In en, this message translates to:
  /// **'6–12 months'**
  String get len6to12m;

  /// No description provided for @len1to3y.
  ///
  /// In en, this message translates to:
  /// **'1–3 years'**
  String get len1to3y;

  /// No description provided for @lenGt3y.
  ///
  /// In en, this message translates to:
  /// **'More than 3 years'**
  String get lenGt3y;

  /// No description provided for @onbFeelingsTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you right now?'**
  String get onbFeelingsTitle;

  /// No description provided for @onbMoodLow.
  ///
  /// In en, this message translates to:
  /// **'Barely holding on'**
  String get onbMoodLow;

  /// No description provided for @onbMoodHigh.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get onbMoodHigh;

  /// No description provided for @onbMoodSemantics.
  ///
  /// In en, this message translates to:
  /// **'Mood {value} of 10'**
  String onbMoodSemantics(int value);

  /// No description provided for @onbFeelingsSub.
  ///
  /// In en, this message translates to:
  /// **'What feels loudest today? Pick any.'**
  String get onbFeelingsSub;

  /// No description provided for @feelSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get feelSad;

  /// No description provided for @feelLonely.
  ///
  /// In en, this message translates to:
  /// **'Lonely'**
  String get feelLonely;

  /// No description provided for @feelAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get feelAnxious;

  /// No description provided for @feelAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get feelAngry;

  /// No description provided for @feelNumb.
  ///
  /// In en, this message translates to:
  /// **'Numb'**
  String get feelNumb;

  /// No description provided for @feelConfused.
  ///
  /// In en, this message translates to:
  /// **'Confused'**
  String get feelConfused;

  /// No description provided for @feelRelieved.
  ///
  /// In en, this message translates to:
  /// **'Relieved'**
  String get feelRelieved;

  /// No description provided for @onbAttachTitle.
  ///
  /// In en, this message translates to:
  /// **'How true are these for you?'**
  String get onbAttachTitle;

  /// No description provided for @onbAttachSub.
  ///
  /// In en, this message translates to:
  /// **'A starting point, not a diagnosis.'**
  String get onbAttachSub;

  /// No description provided for @attachQ0.
  ///
  /// In en, this message translates to:
  /// **'I worry they’ll forget me.'**
  String get attachQ0;

  /// No description provided for @attachQ1.
  ///
  /// In en, this message translates to:
  /// **'I’d rather not need anyone.'**
  String get attachQ1;

  /// No description provided for @attachQ2.
  ///
  /// In en, this message translates to:
  /// **'I replay what I could have said.'**
  String get attachQ2;

  /// No description provided for @onbGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want most right now?'**
  String get onbGoalsTitle;

  /// No description provided for @onbGoalsSub.
  ///
  /// In en, this message translates to:
  /// **'Pick up to three. The first one is your focus.'**
  String get onbGoalsSub;

  /// No description provided for @goalNoContact.
  ///
  /// In en, this message translates to:
  /// **'Stop texting them'**
  String get goalNoContact;

  /// No description provided for @goalCalm.
  ///
  /// In en, this message translates to:
  /// **'Sleep better'**
  String get goalCalm;

  /// No description provided for @goalSelfWorth.
  ///
  /// In en, this message translates to:
  /// **'Feel like myself again'**
  String get goalSelfWorth;

  /// No description provided for @goalUnderstand.
  ///
  /// In en, this message translates to:
  /// **'Understand what went wrong'**
  String get goalUnderstand;

  /// No description provided for @onbBuildingTitle.
  ///
  /// In en, this message translates to:
  /// **'Building your plan'**
  String get onbBuildingTitle;

  /// No description provided for @onbBuildStep1.
  ///
  /// In en, this message translates to:
  /// **'Reading your answers'**
  String get onbBuildStep1;

  /// No description provided for @onbBuildStep2.
  ///
  /// In en, this message translates to:
  /// **'Choosing your first steps'**
  String get onbBuildStep2;

  /// No description provided for @onbBuildStep3.
  ///
  /// In en, this message translates to:
  /// **'Getting Mira ready for you'**
  String get onbBuildStep3;

  /// No description provided for @attachSecure.
  ///
  /// In en, this message translates to:
  /// **'Fairly secure'**
  String get attachSecure;

  /// No description provided for @attachAnxious.
  ///
  /// In en, this message translates to:
  /// **'Leaning anxious'**
  String get attachAnxious;

  /// No description provided for @attachAvoidant.
  ///
  /// In en, this message translates to:
  /// **'Leaning avoidant'**
  String get attachAvoidant;

  /// No description provided for @attachFearful.
  ///
  /// In en, this message translates to:
  /// **'Anxious and avoidant'**
  String get attachFearful;

  /// No description provided for @focusNoContact.
  ///
  /// In en, this message translates to:
  /// **'No contact'**
  String get focusNoContact;

  /// No description provided for @focusCalm.
  ///
  /// In en, this message translates to:
  /// **'Better sleep'**
  String get focusCalm;

  /// No description provided for @focusSelfWorth.
  ///
  /// In en, this message translates to:
  /// **'Self-worth'**
  String get focusSelfWorth;

  /// No description provided for @focusUnderstand.
  ///
  /// In en, this message translates to:
  /// **'Understanding what happened'**
  String get focusUnderstand;

  /// No description provided for @planReadyTitleNamed.
  ///
  /// In en, this message translates to:
  /// **'{name}, your plan is ready.'**
  String planReadyTitleNamed(String name);

  /// No description provided for @paywallSubNamed.
  ///
  /// In en, this message translates to:
  /// **'{name}, your full plan, and Mira whenever it gets hard.'**
  String paywallSubNamed(String name);

  /// No description provided for @paywallBenefitPlanSubFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus: {focus}. Free stops after Day {day}.'**
  String paywallBenefitPlanSubFocus(String focus, int day);

  /// No description provided for @planSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of 30'**
  String planSubtitle(int day);

  /// No description provided for @planDoneCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of 30 days done'**
  String planDoneCount(int done);

  /// No description provided for @planStageWeek1.
  ///
  /// In en, this message translates to:
  /// **'Week 1'**
  String get planStageWeek1;

  /// No description provided for @planStageWeek2.
  ///
  /// In en, this message translates to:
  /// **'Week 2'**
  String get planStageWeek2;

  /// No description provided for @planStageWeek3.
  ///
  /// In en, this message translates to:
  /// **'Week 3'**
  String get planStageWeek3;

  /// No description provided for @planStageRebuild.
  ///
  /// In en, this message translates to:
  /// **'Rebuild'**
  String get planStageRebuild;

  /// No description provided for @planRowDone.
  ///
  /// In en, this message translates to:
  /// **'Day {day} · Done'**
  String planRowDone(int day);

  /// No description provided for @planRowToday.
  ///
  /// In en, this message translates to:
  /// **'Day {day} · Today · {minutes} min'**
  String planRowToday(int day, int minutes);

  /// No description provided for @planRowOpensAt.
  ///
  /// In en, this message translates to:
  /// **'Day {day} · Opens at {time}'**
  String planRowOpensAt(int day, String time);

  /// No description provided for @planRowAfter.
  ///
  /// In en, this message translates to:
  /// **'Day {day} · After Day {prev}'**
  String planRowAfter(int day, int prev);

  /// No description provided for @planRowLocked.
  ///
  /// In en, this message translates to:
  /// **'Day {day} · Premium'**
  String planRowLocked(int day);

  /// No description provided for @planWaitingToast.
  ///
  /// In en, this message translates to:
  /// **'This day opens at {time}'**
  String planWaitingToast(String time);

  /// No description provided for @planAfterToast.
  ///
  /// In en, this message translates to:
  /// **'Finish Day {prev} first'**
  String planAfterToast(int prev);

  /// No description provided for @planError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your plan.'**
  String get planError;

  /// No description provided for @planFinished.
  ///
  /// In en, this message translates to:
  /// **'You finished all 30 days.'**
  String get planFinished;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String taskTitle(int day);

  /// No description provided for @taskEntryLabel.
  ///
  /// In en, this message translates to:
  /// **'{n}'**
  String taskEntryLabel(int n);

  /// No description provided for @taskEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Write it down'**
  String get taskEntryHint;

  /// No description provided for @taskComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete Day {day}'**
  String taskComplete(int day);

  /// No description provided for @taskPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only you can see what you write.'**
  String get taskPrivate;

  /// No description provided for @taskDoneNote.
  ///
  /// In en, this message translates to:
  /// **'You completed this day.'**
  String get taskDoneNote;

  /// No description provided for @taskNotOpen.
  ///
  /// In en, this message translates to:
  /// **'This day isn’t open yet.'**
  String get taskNotOpen;

  /// No description provided for @taskError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load this day.'**
  String get taskError;

  /// No description provided for @taskSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t save. Your answers are still here.'**
  String get taskSaveError;

  /// No description provided for @dayCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {day} complete'**
  String dayCompleteTitle(int day);

  /// No description provided for @dayCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You showed up for yourself today.'**
  String get dayCompleteBody;

  /// No description provided for @dayCompleteNext.
  ///
  /// In en, this message translates to:
  /// **'Day {day} opens tomorrow at {time}.'**
  String dayCompleteNext(int day, String time);

  /// No description provided for @dayCompleteNextLocked.
  ///
  /// In en, this message translates to:
  /// **'Day {day} is part of Premium.'**
  String dayCompleteNextLocked(int day);

  /// No description provided for @dayCompleteAll.
  ///
  /// In en, this message translates to:
  /// **'That was Day 30. You stayed with yourself.'**
  String get dayCompleteAll;

  /// No description provided for @dayCompleteDone.
  ///
  /// In en, this message translates to:
  /// **'Back to Your Plan'**
  String get dayCompleteDone;

  /// No description provided for @lockDaySheetLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked day'**
  String get lockDaySheetLabel;

  /// No description provided for @lockDayFoot.
  ///
  /// In en, this message translates to:
  /// **'Day {day} · {minutes} min'**
  String lockDayFoot(int day, int minutes);

  /// No description provided for @lockDayBody.
  ///
  /// In en, this message translates to:
  /// **'Free covers Days 1–{days}. Premium opens all 30, plus the Rebuild stage.'**
  String lockDayBody(int days);

  /// No description provided for @lockDayPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock All 30 Days'**
  String get lockDayPremium;

  /// No description provided for @lockDayTrialNote.
  ///
  /// In en, this message translates to:
  /// **'{days} days free'**
  String lockDayTrialNote(int days);

  /// No description provided for @lockDayCoins.
  ///
  /// In en, this message translates to:
  /// **'Unlock Day {day} for {cost} Coins'**
  String lockDayCoins(int day, int cost);

  /// No description provided for @lockDayGetCoins.
  ///
  /// In en, this message translates to:
  /// **'Get Coins to Unlock Day {day}'**
  String lockDayGetCoins(int day);

  /// No description provided for @lockDayUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Day {day} unlocked'**
  String lockDayUnlocked(int day);

  /// No description provided for @draftTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft Jail'**
  String get draftTitle;

  /// No description provided for @draftSub.
  ///
  /// In en, this message translates to:
  /// **'Write what you want to send. It stays locked for 24 hours. If you still want to send it then, it’ll be here.'**
  String get draftSub;

  /// No description provided for @draftHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to say?'**
  String get draftHint;

  /// No description provided for @draftFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get draftFieldLabel;

  /// No description provided for @draftLock.
  ///
  /// In en, this message translates to:
  /// **'Lock for 24 Hours'**
  String get draftLock;

  /// No description provided for @draftLockedToast.
  ///
  /// In en, this message translates to:
  /// **'Locked for 24 hours'**
  String get draftLockedToast;

  /// No description provided for @draftLockedHeader.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get draftLockedHeader;

  /// No description provided for @draftReadyHeader.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get draftReadyHeader;

  /// No description provided for @draftLockedRow.
  ///
  /// In en, this message translates to:
  /// **'Locked draft'**
  String get draftLockedRow;

  /// No description provided for @draftWords.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word} other{{count} words}}'**
  String draftWords(int count);

  /// No description provided for @draftUnlocksIn.
  ///
  /// In en, this message translates to:
  /// **'Unlocks in {time}'**
  String draftUnlocksIn(String time);

  /// No description provided for @draftReadyRow.
  ///
  /// In en, this message translates to:
  /// **'Ready to read'**
  String get draftReadyRow;

  /// No description provided for @draftUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get draftUnlock;

  /// No description provided for @draftCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get draftCopy;

  /// No description provided for @draftCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get draftCopied;

  /// No description provided for @draftDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get draftDelete;

  /// No description provided for @draftDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this draft forever?'**
  String get draftDeleteTitle;

  /// No description provided for @draftDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It will be gone for good. This can’t be undone.'**
  String get draftDeleteBody;

  /// No description provided for @draftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get draftDeleted;

  /// No description provided for @draftStillLocked.
  ///
  /// In en, this message translates to:
  /// **'Still locked. Give it a little more time.'**
  String get draftStillLocked;

  /// No description provided for @draftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing locked right now.'**
  String get draftEmpty;

  /// No description provided for @draftError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t lock it. Your text is still here.'**
  String get draftError;

  /// No description provided for @draftListError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your drafts.'**
  String get draftListError;

  /// No description provided for @draftSheetLabel.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draftSheetLabel;

  /// No description provided for @draftFromSos.
  ///
  /// In en, this message translates to:
  /// **'Written in SOS'**
  String get draftFromSos;

  /// No description provided for @draftLimitSheetLabel.
  ///
  /// In en, this message translates to:
  /// **'Draft Jail limit'**
  String get draftLimitSheetLabel;

  /// No description provided for @draftLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'One draft a day on the free plan.'**
  String get draftLimitTitle;

  /// No description provided for @draftLimitBody.
  ///
  /// In en, this message translates to:
  /// **'Today’s free Draft Jail is used. Your text is still here.'**
  String get draftLimitBody;

  /// No description provided for @draftLimitPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Drafts with Premium'**
  String get draftLimitPremium;

  /// No description provided for @homeDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft Jail'**
  String get homeDraftTitle;

  /// No description provided for @homeDraftSub.
  ///
  /// In en, this message translates to:
  /// **'Write it here instead of sending it'**
  String get homeDraftSub;

  /// No description provided for @sosDraft.
  ///
  /// In en, this message translates to:
  /// **'Write It in Draft Jail'**
  String get sosDraft;

  /// No description provided for @reminderTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'Your trial ends in 2 days'**
  String get reminderTrialTitle;

  /// No description provided for @reminderTrialBody.
  ///
  /// In en, this message translates to:
  /// **'{talks} talks with Mira and {drafts} unsent texts so far. If it’s not for you, cancel anytime in Settings.'**
  String reminderTrialBody(int talks, int drafts);

  /// No description provided for @reminderTrialBodyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your free trial ends in 2 days. If it’s not for you, cancel anytime in Settings.'**
  String get reminderTrialBodyEmpty;

  /// No description provided for @reminderEndingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Premium ends soon'**
  String get reminderEndingTitle;

  /// No description provided for @reminderEndingBody.
  ///
  /// In en, this message translates to:
  /// **'Premium ends on {date}. Your streak, plan and SOS stay with you.'**
  String reminderEndingBody(String date);

  /// No description provided for @welcomeNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on the reminder?'**
  String get welcomeNotifTitle;

  /// No description provided for @welcomeNotifBody.
  ///
  /// In en, this message translates to:
  /// **'We’ll send one notification on {date}, two days before your trial ends. Nothing else.'**
  String welcomeNotifBody(String date);

  /// No description provided for @welcomeNotifAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get welcomeNotifAllow;

  /// No description provided for @welcomeNotifDenied.
  ///
  /// In en, this message translates to:
  /// **'No problem. You can turn it on later in Settings.'**
  String get welcomeNotifDenied;

  /// No description provided for @welcomeNotifOn.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for {date}'**
  String welcomeNotifOn(String date);

  /// No description provided for @trialTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Trial'**
  String get trialTitle;

  /// No description provided for @trialDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day left} other{days left}}'**
  String trialDaysLeft(int count);

  /// No description provided for @trialFreeUntil.
  ///
  /// In en, this message translates to:
  /// **'Free until {date}'**
  String trialFreeUntil(String date);

  /// No description provided for @trialThen.
  ///
  /// In en, this message translates to:
  /// **'Then {price}/year. Cancel anytime before.'**
  String trialThen(String price);

  /// No description provided for @trialThenNoPrice.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime before and you won’t be charged.'**
  String get trialThenNoPrice;

  /// No description provided for @trialEndsNoCharge.
  ///
  /// In en, this message translates to:
  /// **'Premium ends on {date}. You won’t be charged.'**
  String trialEndsNoCharge(String date);

  /// No description provided for @trialSoFar.
  ///
  /// In en, this message translates to:
  /// **'So far'**
  String get trialSoFar;

  /// No description provided for @trialTalks.
  ///
  /// In en, this message translates to:
  /// **'Talks with Mira'**
  String get trialTalks;

  /// No description provided for @trialDrafts.
  ///
  /// In en, this message translates to:
  /// **'Texts not sent'**
  String get trialDrafts;

  /// No description provided for @trialDaysDone.
  ///
  /// In en, this message translates to:
  /// **'Days done'**
  String get trialDaysDone;

  /// No description provided for @trialNextTitle.
  ///
  /// In en, this message translates to:
  /// **'Next up: Rebuild'**
  String get trialNextTitle;

  /// No description provided for @trialNextBody.
  ///
  /// In en, this message translates to:
  /// **'Days 8–30 rebuild self-worth and routines.'**
  String get trialNextBody;

  /// No description provided for @trialBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get trialBack;

  /// No description provided for @trialNotActive.
  ///
  /// In en, this message translates to:
  /// **'You’re not in a free trial right now.'**
  String get trialNotActive;

  /// No description provided for @winbackTitle.
  ///
  /// In en, this message translates to:
  /// **'We kept your place.'**
  String get winbackTitle;

  /// No description provided for @winbackSub.
  ///
  /// In en, this message translates to:
  /// **'Your streak, plan and drafts are all still here.'**
  String get winbackSub;

  /// No description provided for @winbackSubStreak.
  ///
  /// In en, this message translates to:
  /// **'Your {count}-day streak and your plan are all still here.'**
  String winbackSubStreak(int count);

  /// No description provided for @winbackOfferLabel.
  ///
  /// In en, this message translates to:
  /// **'Returning member offer'**
  String get winbackOfferLabel;

  /// No description provided for @winbackFor.
  ///
  /// In en, this message translates to:
  /// **'for {months} months, then {monthly}/month'**
  String winbackFor(int months, String monthly);

  /// No description provided for @winbackFine.
  ///
  /// In en, this message translates to:
  /// **'{promo} for {months} months, then {monthly}/month. Cancel anytime.'**
  String winbackFine(String promo, int months, String monthly);

  /// No description provided for @winbackCta.
  ///
  /// In en, this message translates to:
  /// **'Continue My Plan'**
  String get winbackCta;

  /// No description provided for @winbackNo.
  ///
  /// In en, this message translates to:
  /// **'Stay on Free'**
  String get winbackNo;

  /// No description provided for @billingIssueCta.
  ///
  /// In en, this message translates to:
  /// **'Update Payment'**
  String get billingIssueCta;

  /// No description provided for @billingIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment problem'**
  String get billingIssueTitle;

  /// No description provided for @meTrialProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Trial Progress'**
  String get meTrialProgress;

  /// No description provided for @checkinTitle.
  ///
  /// In en, this message translates to:
  /// **'Mira'**
  String get checkinTitle;

  /// No description provided for @checkinBody.
  ///
  /// In en, this message translates to:
  /// **'How was today? I’m here if you want to talk.'**
  String get checkinBody;

  /// No description provided for @cancelSheetLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get cancelSheetLabel;

  /// No description provided for @cancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Mind sharing why?'**
  String get cancelTitle;

  /// No description provided for @cancelSub.
  ///
  /// In en, this message translates to:
  /// **'It helps us improve MyEx. You can skip this.'**
  String get cancelSub;

  /// No description provided for @cancelReasonPrice.
  ///
  /// In en, this message translates to:
  /// **'It’s too expensive'**
  String get cancelReasonPrice;

  /// No description provided for @cancelReasonBetter.
  ///
  /// In en, this message translates to:
  /// **'I’m feeling better'**
  String get cancelReasonBetter;

  /// No description provided for @cancelReasonUnused.
  ///
  /// In en, this message translates to:
  /// **'I’m not using it'**
  String get cancelReasonUnused;

  /// No description provided for @cancelReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get cancelReasonOther;

  /// No description provided for @cancelPriceTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay for {promo} for a year'**
  String cancelPriceTitle(String promo);

  /// No description provided for @cancelPriceBody.
  ///
  /// In en, this message translates to:
  /// **'Half price, same everything. Applied as an App Store offer.'**
  String get cancelPriceBody;

  /// No description provided for @cancelPriceCta.
  ///
  /// In en, this message translates to:
  /// **'Keep Premium for Less'**
  String get cancelPriceCta;

  /// No description provided for @cancelSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to Yearly and save {pct}'**
  String cancelSwitchTitle(String pct);

  /// No description provided for @cancelSwitchBody.
  ///
  /// In en, this message translates to:
  /// **'{price}/year instead of paying monthly.'**
  String cancelSwitchBody(String price);

  /// No description provided for @cancelSwitchCta.
  ///
  /// In en, this message translates to:
  /// **'Switch to Yearly'**
  String get cancelSwitchCta;

  /// No description provided for @cancelBetter.
  ///
  /// In en, this message translates to:
  /// **'That’s the whole point. Your streak, journal and SOS stay free. Come back anytime.'**
  String get cancelBetter;

  /// No description provided for @cancelUnusedTitle.
  ///
  /// In en, this message translates to:
  /// **'Want a short check-in each night?'**
  String get cancelUnusedTitle;

  /// No description provided for @cancelUnusedBody.
  ///
  /// In en, this message translates to:
  /// **'One message from Mira at 10 PM.'**
  String get cancelUnusedBody;

  /// No description provided for @cancelUnusedCta.
  ///
  /// In en, this message translates to:
  /// **'Turn On Check-ins'**
  String get cancelUnusedCta;

  /// No description provided for @cancelCheckinOn.
  ///
  /// In en, this message translates to:
  /// **'Check-ins on. See you at 10 PM.'**
  String get cancelCheckinOn;

  /// No description provided for @cancelCheckinDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off. You can turn them on in Settings.'**
  String get cancelCheckinDenied;

  /// No description provided for @cancelOther.
  ///
  /// In en, this message translates to:
  /// **'Thank you for telling us. It helps us make MyEx better.'**
  String get cancelOther;

  /// No description provided for @cancelNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Anything else? (optional)'**
  String get cancelNoteLabel;

  /// No description provided for @cancelContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to Cancel'**
  String get cancelContinue;

  /// No description provided for @cancelKept.
  ///
  /// In en, this message translates to:
  /// **'Premium kept. Thank you.'**
  String get cancelKept;

  /// No description provided for @meSwitchYearly.
  ///
  /// In en, this message translates to:
  /// **'Switch to Yearly'**
  String get meSwitchYearly;

  /// No description provided for @meTrialEnds.
  ///
  /// In en, this message translates to:
  /// **'Trial ends'**
  String get meTrialEnds;

  /// No description provided for @meCancelledNote.
  ///
  /// In en, this message translates to:
  /// **'Cancelled. Premium stays on until {date}.'**
  String meCancelledNote(String date);

  /// No description provided for @meDayStatus.
  ///
  /// In en, this message translates to:
  /// **'Day {day} · {status}'**
  String meDayStatus(int day, String status);

  /// No description provided for @meNameFallback.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get meNameFallback;

  /// No description provided for @onbHelpNow.
  ///
  /// In en, this message translates to:
  /// **'Need Help Now?'**
  String get onbHelpNow;

  /// No description provided for @onbNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onbNameTitle;

  /// No description provided for @onbNameSub.
  ///
  /// In en, this message translates to:
  /// **'Optional. Only used inside the app.'**
  String get onbNameSub;

  /// No description provided for @onbWhenTitle.
  ///
  /// In en, this message translates to:
  /// **'When did it end?'**
  String get onbWhenTitle;

  /// No description provided for @whenThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get whenThisWeek;

  /// No description provided for @whenWeeks.
  ///
  /// In en, this message translates to:
  /// **'1–4 weeks ago'**
  String get whenWeeks;

  /// No description provided for @whenMonths.
  ///
  /// In en, this message translates to:
  /// **'1–6 months ago'**
  String get whenMonths;

  /// No description provided for @whenLonger.
  ///
  /// In en, this message translates to:
  /// **'Longer'**
  String get whenLonger;

  /// No description provided for @onbContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you still in touch?'**
  String get onbContactTitle;

  /// No description provided for @contactNone.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get contactNone;

  /// No description provided for @contactSometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get contactSometimes;

  /// No description provided for @contactMostDays.
  ///
  /// In en, this message translates to:
  /// **'Most days'**
  String get contactMostDays;

  /// No description provided for @contactShared.
  ///
  /// In en, this message translates to:
  /// **'We share kids or work'**
  String get contactShared;

  /// No description provided for @onbHardestTitle.
  ///
  /// In en, this message translates to:
  /// **'When is it hardest?'**
  String get onbHardestTitle;

  /// No description provided for @onbHardestSub.
  ///
  /// In en, this message translates to:
  /// **'Pick any.'**
  String get onbHardestSub;

  /// No description provided for @hardLateNight.
  ///
  /// In en, this message translates to:
  /// **'Late at night'**
  String get hardLateNight;

  /// No description provided for @hardMornings.
  ///
  /// In en, this message translates to:
  /// **'Mornings'**
  String get hardMornings;

  /// No description provided for @hardWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get hardWeekends;

  /// No description provided for @hardPosts.
  ///
  /// In en, this message translates to:
  /// **'When I see their posts'**
  String get hardPosts;

  /// No description provided for @onbMiraTitle.
  ///
  /// In en, this message translates to:
  /// **'Mira’s there at 2 AM.'**
  String get onbMiraTitle;

  /// No description provided for @onbMiraBody.
  ///
  /// In en, this message translates to:
  /// **'And SOS is always free, whenever you need it.'**
  String get onbMiraBody;

  /// No description provided for @goalStopChecking.
  ///
  /// In en, this message translates to:
  /// **'Stop checking their profile'**
  String get goalStopChecking;

  /// No description provided for @focusStopChecking.
  ///
  /// In en, this message translates to:
  /// **'Stop checking'**
  String get focusStopChecking;

  /// No description provided for @ansAgree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get ansAgree;

  /// No description provided for @ansNotReally.
  ///
  /// In en, this message translates to:
  /// **'Not really'**
  String get ansNotReally;

  /// No description provided for @onbUnsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Anything you wish you could tell them?'**
  String get onbUnsentTitle;

  /// No description provided for @onbUnsentSub.
  ///
  /// In en, this message translates to:
  /// **'It won’t be sent. It goes into Draft Jail.'**
  String get onbUnsentSub;

  /// No description provided for @onbUnsentHint.
  ///
  /// In en, this message translates to:
  /// **'Write it here. It won’t be sent.'**
  String get onbUnsentHint;

  /// No description provided for @onbUnsentSave.
  ///
  /// In en, this message translates to:
  /// **'Save Unsent'**
  String get onbUnsentSave;

  /// No description provided for @onbUnsentSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. It stays unsent for 24 hours.'**
  String get onbUnsentSaved;

  /// No description provided for @onbCheckinTitle.
  ///
  /// In en, this message translates to:
  /// **'Want a check-in when it’s hardest?'**
  String get onbCheckinTitle;

  /// No description provided for @onbCheckinSub.
  ///
  /// In en, this message translates to:
  /// **'One message from Mira at {time}. You can change the time.'**
  String onbCheckinSub(String time);

  /// No description provided for @onbCheckinChange.
  ///
  /// In en, this message translates to:
  /// **'Change Time'**
  String get onbCheckinChange;

  /// No description provided for @onbCheckinAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow Check-ins'**
  String get onbCheckinAllow;

  /// No description provided for @onbCheckinOn.
  ///
  /// In en, this message translates to:
  /// **'Check-ins on at {time}'**
  String onbCheckinOn(String time);

  /// No description provided for @onbBuildFocus.
  ///
  /// In en, this message translates to:
  /// **'Matching your focus: {focus}'**
  String onbBuildFocus(String focus);

  /// No description provided for @onbBuildHardest.
  ///
  /// In en, this message translates to:
  /// **'Planning for your hardest time: {time}'**
  String onbBuildHardest(String time);

  /// No description provided for @onbBuildDay1.
  ///
  /// In en, this message translates to:
  /// **'Choosing Day 1: {minutes} minutes, tonight'**
  String onbBuildDay1(int minutes);

  /// No description provided for @onbBuildTrack.
  ///
  /// In en, this message translates to:
  /// **'Setting your track: {track}'**
  String onbBuildTrack(String track);

  /// No description provided for @planReadyWhen.
  ///
  /// In en, this message translates to:
  /// **'When it ended'**
  String get planReadyWhen;

  /// No description provided for @planReadyTrack.
  ///
  /// In en, this message translates to:
  /// **'Your track'**
  String get planReadyTrack;

  /// No description provided for @planTrackNoContact.
  ///
  /// In en, this message translates to:
  /// **'No contact'**
  String get planTrackNoContact;

  /// No description provided for @planTrackLowContact.
  ///
  /// In en, this message translates to:
  /// **'Low contact (shared kids or work)'**
  String get planTrackLowContact;

  /// No description provided for @planReadyFirstDays.
  ///
  /// In en, this message translates to:
  /// **'Your first 3 days'**
  String get planReadyFirstDays;

  /// No description provided for @planReadyDayRow.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String planReadyDayRow(int day);

  /// No description provided for @planReadyTonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight · {minutes} min'**
  String planReadyTonight(int minutes);

  /// No description provided for @planReadySupport.
  ///
  /// In en, this message translates to:
  /// **'{time}: Mira’s here, and SOS is always free.'**
  String planReadySupport(String time);

  /// No description provided for @planReadyLocked.
  ///
  /// In en, this message translates to:
  /// **'Days 4–30 open with Premium.'**
  String get planReadyLocked;

  /// No description provided for @paywallSubTrial.
  ///
  /// In en, this message translates to:
  /// **'{days} days free, then {price}/year.'**
  String paywallSubTrial(int days, String price);

  /// No description provided for @paywallSubYearly.
  ///
  /// In en, this message translates to:
  /// **'{price}/year. Cancel anytime.'**
  String paywallSubYearly(String price);

  /// No description provided for @paywallSubMonthly.
  ///
  /// In en, this message translates to:
  /// **'{price}/month. No free trial.'**
  String paywallSubMonthly(String price);

  /// No description provided for @paywallNoPaymentToday.
  ///
  /// In en, this message translates to:
  /// **'No payment today'**
  String get paywallNoPaymentToday;

  /// No description provided for @paywallTimelineBuild.
  ///
  /// In en, this message translates to:
  /// **'Build your plan'**
  String get paywallTimelineBuild;

  /// No description provided for @paywallTimelineBuildBody.
  ///
  /// In en, this message translates to:
  /// **'Done. Based on your answers.'**
  String get paywallTimelineBuildBody;

  /// No description provided for @paywallNotifOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for MyEx.'**
  String get paywallNotifOff;

  /// No description provided for @paywallOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get paywallOpenSettings;

  /// No description provided for @paywallHowCancel.
  ///
  /// In en, this message translates to:
  /// **'How do I cancel?'**
  String get paywallHowCancel;

  /// No description provided for @paywallHowCancelIos.
  ///
  /// In en, this message translates to:
  /// **'Settings › your name › Subscriptions › MyEx › Cancel Subscription. Takes under a minute. Your streak and journal stay.'**
  String get paywallHowCancelIos;

  /// No description provided for @paywallHowCancelAndroid.
  ///
  /// In en, this message translates to:
  /// **'Play Store › your profile › Payments & subscriptions › Subscriptions › MyEx › Cancel. Takes under a minute. Your streak and journal stay.'**
  String get paywallHowCancelAndroid;

  /// No description provided for @tabJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get tabJournal;

  /// No description provided for @commonSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save. Try again.'**
  String get commonSaveFailed;

  /// No description provided for @homeMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you, right now?'**
  String get homeMoodTitle;

  /// No description provided for @homeMoodDone.
  ///
  /// In en, this message translates to:
  /// **'Today you felt {mood}.'**
  String homeMoodDone(String mood);

  /// No description provided for @homeMoodWrite.
  ///
  /// In en, this message translates to:
  /// **'Write About It'**
  String get homeMoodWrite;

  /// No description provided for @homeMoodAgain.
  ///
  /// In en, this message translates to:
  /// **'Check In Again'**
  String get homeMoodAgain;

  /// No description provided for @homeDayHeader.
  ///
  /// In en, this message translates to:
  /// **'Your day'**
  String get homeDayHeader;

  /// No description provided for @homeJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get homeJournalTitle;

  /// No description provided for @homeJournalSub.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Write tonight’s first line} =1{1 entry so far} other{{count} entries so far}}'**
  String homeJournalSub(int count);

  /// No description provided for @homeWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeWeekTitle;

  /// No description provided for @homeWeekSee.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get homeWeekSee;

  /// No description provided for @homeHeroChooseGoal.
  ///
  /// In en, this message translates to:
  /// **'Choose a Goal'**
  String get homeHeroChooseGoal;

  /// No description provided for @homeHeroChosen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day you chose yourself} other{{count} days you chose yourself}}'**
  String homeHeroChosen(int count);

  /// No description provided for @moodLevel1.
  ///
  /// In en, this message translates to:
  /// **'heavy'**
  String get moodLevel1;

  /// No description provided for @moodLevel2.
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get moodLevel2;

  /// No description provided for @moodLevel3.
  ///
  /// In en, this message translates to:
  /// **'okay'**
  String get moodLevel3;

  /// No description provided for @moodLevel4.
  ///
  /// In en, this message translates to:
  /// **'lighter'**
  String get moodLevel4;

  /// No description provided for @moodLevel5.
  ///
  /// In en, this message translates to:
  /// **'good'**
  String get moodLevel5;

  /// No description provided for @moodSheetFeelings.
  ///
  /// In en, this message translates to:
  /// **'What’s in there?'**
  String get moodSheetFeelings;

  /// No description provided for @moodSheetNote.
  ///
  /// In en, this message translates to:
  /// **'Anything to add? (optional)'**
  String get moodSheetNote;

  /// No description provided for @moodSheetSave.
  ///
  /// In en, this message translates to:
  /// **'Save Check-in'**
  String get moodSheetSave;

  /// No description provided for @moodSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. Thanks for checking in.'**
  String get moodSaved;

  /// No description provided for @moodScaleSemantics.
  ///
  /// In en, this message translates to:
  /// **'Mood {level} of 5, {word}'**
  String moodScaleSemantics(int level, String word);

  /// No description provided for @moodWordHeartbroken.
  ///
  /// In en, this message translates to:
  /// **'Heartbroken'**
  String get moodWordHeartbroken;

  /// No description provided for @moodWordLonely.
  ///
  /// In en, this message translates to:
  /// **'Lonely'**
  String get moodWordLonely;

  /// No description provided for @moodWordAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get moodWordAngry;

  /// No description provided for @moodWordAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodWordAnxious;

  /// No description provided for @moodWordNumb.
  ///
  /// In en, this message translates to:
  /// **'Numb'**
  String get moodWordNumb;

  /// No description provided for @moodWordConfused.
  ///
  /// In en, this message translates to:
  /// **'Confused'**
  String get moodWordConfused;

  /// No description provided for @moodWordTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get moodWordTired;

  /// No description provided for @moodWordHopeful.
  ///
  /// In en, this message translates to:
  /// **'Hopeful'**
  String get moodWordHopeful;

  /// No description provided for @moodWordCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodWordCalm;

  /// No description provided for @moodWordRelieved.
  ///
  /// In en, this message translates to:
  /// **'Relieved'**
  String get moodWordRelieved;

  /// No description provided for @moodWordProud.
  ///
  /// In en, this message translates to:
  /// **'Proud'**
  String get moodWordProud;

  /// No description provided for @moodWordGrateful.
  ///
  /// In en, this message translates to:
  /// **'Grateful'**
  String get moodWordGrateful;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @journalNew.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get journalNew;

  /// No description provided for @journalSearch.
  ///
  /// In en, this message translates to:
  /// **'Search your journal'**
  String get journalSearch;

  /// No description provided for @journalFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get journalFilterAll;

  /// No description provided for @journalKindReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get journalKindReflection;

  /// No description provided for @journalKindLetter.
  ///
  /// In en, this message translates to:
  /// **'Unsent letter'**
  String get journalKindLetter;

  /// No description provided for @journalKindGratitude.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get journalKindGratitude;

  /// No description provided for @journalKindList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get journalKindList;

  /// No description provided for @journalPromptToday.
  ///
  /// In en, this message translates to:
  /// **'Tonight’s prompt'**
  String get journalPromptToday;

  /// No description provided for @journalWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get journalWrite;

  /// No description provided for @journalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pages are private.'**
  String get journalEmptyTitle;

  /// No description provided for @journalEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Write what you can’t say out loud. Only you can see it.'**
  String get journalEmptyBody;

  /// No description provided for @journalEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Write Your First Entry'**
  String get journalEmptyCta;

  /// No description provided for @journalNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”.'**
  String journalNoResults(String query);

  /// No description provided for @journalPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only you can see your journal.'**
  String get journalPrivate;

  /// No description provided for @journalEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Start anywhere.'**
  String get journalEditorHint;

  /// No description provided for @journalSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get journalSave;

  /// No description provided for @journalAnotherPrompt.
  ///
  /// In en, this message translates to:
  /// **'Another Prompt'**
  String get journalAnotherPrompt;

  /// No description provided for @journalMoodOptional.
  ///
  /// In en, this message translates to:
  /// **'How did writing leave you? (optional)'**
  String get journalMoodOptional;

  /// No description provided for @journalDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get journalDelete;

  /// No description provided for @journalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get journalDeleteTitle;

  /// No description provided for @journalDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It can’t be recovered.'**
  String get journalDeleteBody;

  /// No description provided for @journalDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this entry?'**
  String get journalDiscardTitle;

  /// No description provided for @journalDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'What you wrote won’t be saved.'**
  String get journalDiscardBody;

  /// No description provided for @journalDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get journalDiscard;

  /// No description provided for @journalKeepWriting.
  ///
  /// In en, this message translates to:
  /// **'Keep Writing'**
  String get journalKeepWriting;

  /// No description provided for @journalSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your journal.'**
  String get journalSaved;

  /// No description provided for @journalPromptReflection1.
  ///
  /// In en, this message translates to:
  /// **'What was hardest today?'**
  String get journalPromptReflection1;

  /// No description provided for @journalPromptReflection2.
  ///
  /// In en, this message translates to:
  /// **'What do you miss, and what don’t you?'**
  String get journalPromptReflection2;

  /// No description provided for @journalPromptReflection3.
  ///
  /// In en, this message translates to:
  /// **'When did you feel most like yourself this week?'**
  String get journalPromptReflection3;

  /// No description provided for @journalPromptReflection4.
  ///
  /// In en, this message translates to:
  /// **'What would you tell a friend going through this?'**
  String get journalPromptReflection4;

  /// No description provided for @journalPromptLetter1.
  ///
  /// In en, this message translates to:
  /// **'A letter you won’t send'**
  String get journalPromptLetter1;

  /// No description provided for @journalPromptLetter2.
  ///
  /// In en, this message translates to:
  /// **'What you never got to say'**
  String get journalPromptLetter2;

  /// No description provided for @journalPromptLetter3.
  ///
  /// In en, this message translates to:
  /// **'Goodbye, in your own words'**
  String get journalPromptLetter3;

  /// No description provided for @journalPromptGratitude1.
  ///
  /// In en, this message translates to:
  /// **'One small thing that went right today'**
  String get journalPromptGratitude1;

  /// No description provided for @journalPromptGratitude2.
  ///
  /// In en, this message translates to:
  /// **'Someone who showed up for you'**
  String get journalPromptGratitude2;

  /// No description provided for @journalPromptGratitude3.
  ///
  /// In en, this message translates to:
  /// **'Something you did for yourself today'**
  String get journalPromptGratitude3;

  /// No description provided for @journalPromptList1.
  ///
  /// In en, this message translates to:
  /// **'Three things you won’t miss'**
  String get journalPromptList1;

  /// No description provided for @journalPromptList2.
  ///
  /// In en, this message translates to:
  /// **'Five things that are yours again'**
  String get journalPromptList2;

  /// No description provided for @journalPromptList3.
  ///
  /// In en, this message translates to:
  /// **'Things you want to try on your own'**
  String get journalPromptList3;

  /// No description provided for @noContactTitle.
  ///
  /// In en, this message translates to:
  /// **'No contact'**
  String get noContactTitle;

  /// No description provided for @noContactIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Give yourself space.'**
  String get noContactIntroTitle;

  /// No description provided for @noContactIntroBody.
  ///
  /// In en, this message translates to:
  /// **'No texts, no checking their profile. Pick a goal. If you slip, you restart kindly, and every day still counts.'**
  String get noContactIntroBody;

  /// No description provided for @noContactGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get noContactGoal;

  /// No description provided for @noContactGoalDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String noContactGoalDays(int count);

  /// No description provided for @noContactStart.
  ///
  /// In en, this message translates to:
  /// **'Start Today'**
  String get noContactStart;

  /// No description provided for @noContactOfGoal.
  ///
  /// In en, this message translates to:
  /// **'of {goal}'**
  String noContactOfGoal(String goal);

  /// No description provided for @noContactNext.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Next milestone tomorrow} other{Next milestone in {count} days}}'**
  String noContactNext(int count);

  /// No description provided for @noContactGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached. Keep going if it feels right.'**
  String get noContactGoalReached;

  /// No description provided for @noContactChosen.
  ///
  /// In en, this message translates to:
  /// **'Days you chose yourself'**
  String get noContactChosen;

  /// No description provided for @noContactChosenNote.
  ///
  /// In en, this message translates to:
  /// **'Counts every day of every run. It never resets.'**
  String get noContactChosenNote;

  /// No description provided for @noContactBest.
  ///
  /// In en, this message translates to:
  /// **'Best run'**
  String get noContactBest;

  /// No description provided for @noContactRuns.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get noContactRuns;

  /// No description provided for @noContactMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get noContactMilestones;

  /// No description provided for @noContactMilestone1.
  ///
  /// In en, this message translates to:
  /// **'The first night'**
  String get noContactMilestone1;

  /// No description provided for @noContactMilestone3.
  ///
  /// In en, this message translates to:
  /// **'The hardest stretch for many'**
  String get noContactMilestone3;

  /// No description provided for @noContactMilestone7.
  ///
  /// In en, this message translates to:
  /// **'One week of choosing you'**
  String get noContactMilestone7;

  /// No description provided for @noContactMilestone14.
  ///
  /// In en, this message translates to:
  /// **'New habits take root'**
  String get noContactMilestone14;

  /// No description provided for @noContactMilestone30.
  ///
  /// In en, this message translates to:
  /// **'A month of space'**
  String get noContactMilestone30;

  /// No description provided for @noContactMilestone60.
  ///
  /// In en, this message translates to:
  /// **'Two months, your own rhythm'**
  String get noContactMilestone60;

  /// No description provided for @noContactMilestone90.
  ///
  /// In en, this message translates to:
  /// **'A new normal'**
  String get noContactMilestone90;

  /// No description provided for @noContactHistory.
  ///
  /// In en, this message translates to:
  /// **'Past runs'**
  String get noContactHistory;

  /// No description provided for @noContactRun.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}} · {range}'**
  String noContactRun(int days, String range);

  /// No description provided for @noContactReachedOut.
  ///
  /// In en, this message translates to:
  /// **'I Reached Out'**
  String get noContactReachedOut;

  /// No description provided for @noContactRestartTitle.
  ///
  /// In en, this message translates to:
  /// **'That’s okay.'**
  String get noContactRestartTitle;

  /// No description provided for @noContactRestartBody.
  ///
  /// In en, this message translates to:
  /// **'Reaching out doesn’t erase what you did. Your {days, plural, =1{1 day} other{{days} days}} still count.'**
  String noContactRestartBody(int days);

  /// No description provided for @noContactReflection.
  ///
  /// In en, this message translates to:
  /// **'What happened? What would help next time? (optional)'**
  String get noContactReflection;

  /// No description provided for @noContactRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart Today'**
  String get noContactRestart;

  /// No description provided for @noContactRestarted.
  ///
  /// In en, this message translates to:
  /// **'New run started. Your days still count.'**
  String get noContactRestarted;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @insightsMood.
  ///
  /// In en, this message translates to:
  /// **'Your last 14 days'**
  String get insightsMood;

  /// No description provided for @insightsNonLinear.
  ///
  /// In en, this message translates to:
  /// **'Healing isn’t a straight line. Ups and downs are part of it.'**
  String get insightsNonLinear;

  /// No description provided for @insightsWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get insightsWeek;

  /// No description provided for @insightsWeekCheckins.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{You haven’t checked in yet this week.} =1{You checked in once.} other{You checked in {count} times.}}'**
  String insightsWeekCheckins(int count);

  /// No description provided for @insightsWeekUp.
  ///
  /// In en, this message translates to:
  /// **'Your days felt a little lighter than the week before.'**
  String get insightsWeekUp;

  /// No description provided for @insightsWeekDown.
  ///
  /// In en, this message translates to:
  /// **'This week was heavier than the last. That’s part of it too.'**
  String get insightsWeekDown;

  /// No description provided for @insightsWeekSame.
  ///
  /// In en, this message translates to:
  /// **'About the same as last week. Steady counts too.'**
  String get insightsWeekSame;

  /// No description provided for @insightsWeekFeelings.
  ///
  /// In en, this message translates to:
  /// **'Most often: {feelings}.'**
  String insightsWeekFeelings(String feelings);

  /// No description provided for @insightsCheckins.
  ///
  /// In en, this message translates to:
  /// **'Check-ins'**
  String get insightsCheckins;

  /// No description provided for @insightsEntries.
  ///
  /// In en, this message translates to:
  /// **'Journal entries'**
  String get insightsEntries;

  /// No description provided for @insightsPlanDays.
  ///
  /// In en, this message translates to:
  /// **'Plan days done'**
  String get insightsPlanDays;

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pattern shows up here.'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Check in for a few days and you’ll see how your weeks move.'**
  String get insightsEmptyBody;

  /// No description provided for @insightsCheckInNow.
  ///
  /// In en, this message translates to:
  /// **'Check In Now'**
  String get insightsCheckInNow;

  /// No description provided for @insightsChartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Mood over the last 14 days. {summary}'**
  String insightsChartSemantics(String summary);

  /// No description provided for @coachAiLabel.
  ///
  /// In en, this message translates to:
  /// **'AI · not therapy'**
  String get coachAiLabel;

  /// No description provided for @coachSuggestTitle.
  ///
  /// In en, this message translates to:
  /// **'Not sure where to start?'**
  String get coachSuggestTitle;

  /// No description provided for @coachSuggest1.
  ///
  /// In en, this message translates to:
  /// **'I want to text them right now.'**
  String get coachSuggest1;

  /// No description provided for @coachSuggest2.
  ///
  /// In en, this message translates to:
  /// **'I keep checking their profile.'**
  String get coachSuggest2;

  /// No description provided for @coachSuggest3.
  ///
  /// In en, this message translates to:
  /// **'I can’t sleep tonight.'**
  String get coachSuggest3;

  /// No description provided for @coachSuggest4.
  ///
  /// In en, this message translates to:
  /// **'Why do I still miss them?'**
  String get coachSuggest4;

  /// No description provided for @coachNew.
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get coachNew;

  /// No description provided for @coachNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation?'**
  String get coachNewTitle;

  /// No description provided for @coachNewBody.
  ///
  /// In en, this message translates to:
  /// **'Mira starts fresh. Earlier messages won’t show here anymore.'**
  String get coachNewBody;

  /// No description provided for @coachNewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start New'**
  String get coachNewConfirm;

  /// No description provided for @meAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get meAppearance;

  /// No description provided for @meAppearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get meAppearanceSystem;

  /// No description provided for @meAppearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get meAppearanceLight;

  /// No description provided for @meAppearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get meAppearanceDark;

  /// No description provided for @meProgressHeader.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get meProgressHeader;

  /// No description provided for @draftJailEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing locked right now.'**
  String get draftJailEmptyTitle;

  /// No description provided for @draftJailEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When the urge hits, write it here first. You can decide tomorrow.'**
  String get draftJailEmptyBody;

  /// No description provided for @paywallIncludes.
  ///
  /// In en, this message translates to:
  /// **'Everything in Premium'**
  String get paywallIncludes;

  /// No description provided for @paywallBrandBadge.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get paywallBrandBadge;

  /// No description provided for @paywallMedalMira.
  ///
  /// In en, this message translates to:
  /// **'Mira, anytime'**
  String get paywallMedalMira;

  /// No description provided for @paywallMedalPlan.
  ///
  /// In en, this message translates to:
  /// **'All 30 days'**
  String get paywallMedalPlan;

  /// No description provided for @paywallMedalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Full analysis'**
  String get paywallMedalAnalysis;

  /// No description provided for @paywallMedalDrafts.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Draft Jail'**
  String get paywallMedalDrafts;

  /// No description provided for @paywallMedalCoins.
  ///
  /// In en, this message translates to:
  /// **'+{count} coins a month'**
  String paywallMedalCoins(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

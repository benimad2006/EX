// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyEx';

  @override
  String get commonRetry => 'Try Again';

  @override
  String get commonContinueFree => 'Continue Free';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRestore => 'Restore';

  @override
  String get commonTermsOfUse => 'Terms of Use';

  @override
  String get commonPrivacyPolicy => 'Privacy Policy';

  @override
  String get commonNotNow => 'Not Now';

  @override
  String get configMissingTitle => 'Configuration missing';

  @override
  String configMissingBody(String keys) {
    return 'Run the app with --dart-define-from-file=env/dev.json. Missing: $keys';
  }

  @override
  String get startupError =>
      'We couldn’t connect. Check your connection and try again.';

  @override
  String get planReadyTitle => 'Your plan is ready.';

  @override
  String get planReadySub =>
      'Built from your answers. It starts small, tonight.';

  @override
  String get planReadyWhatHappened => 'What happened';

  @override
  String get planReadyAttachment => 'Attachment style';

  @override
  String get planReadyFocus => 'Focus';

  @override
  String get planReadyFirstStep => 'First step';

  @override
  String planReadyFirstStepValue(int minutes) {
    return 'Tonight · $minutes min';
  }

  @override
  String get planReadyNote =>
      'Grounded in CBT and attachment research. Mira is a coach, not a therapist.';

  @override
  String get planReadyCta => 'Continue';

  @override
  String get paywallTitle => '30 days to feel like you again.';

  @override
  String get paywallSub => 'Your full plan, and Mira whenever it gets hard.';

  @override
  String paywallStripCaption(int day) {
    return 'You’re on Day $day. Premium opens the rest.';
  }

  @override
  String get paywallBenefitMiraTitle => 'Talk to Mira anytime';

  @override
  String get paywallBenefitMiraSub => 'No nightly message limit';

  @override
  String get paywallBenefitPlanTitle => 'All 30 days of your plan';

  @override
  String paywallBenefitPlanSub(int day) {
    return 'Free stops after Day $day';
  }

  @override
  String get paywallBenefitAnalysisTitle => 'Your full analysis';

  @override
  String get paywallBenefitAnalysisSub => 'All three patterns, not just one';

  @override
  String get paywallPickerLabel => 'Choose a plan';

  @override
  String get paywallYearly => 'Yearly';

  @override
  String get paywallMonthly => 'Monthly';

  @override
  String paywallSave(String pct) {
    return 'Save $pct';
  }

  @override
  String paywallYearlyDetailTrial(int days, String monthly) {
    return '$days days free · $monthly/month';
  }

  @override
  String paywallYearlyDetail(String monthly) {
    return '$monthly/month';
  }

  @override
  String get paywallNoTrial => 'No free trial';

  @override
  String get paywallPerYear => 'per year';

  @override
  String get paywallPerMonth => 'per month';

  @override
  String get paywallTimelineToday => 'Today';

  @override
  String get paywallTimelineTodayBody => 'Full access. No charge.';

  @override
  String get paywallTimelineRemindBody => 'We’ll send you a reminder.';

  @override
  String get paywallTimelineRemindOffBody =>
      'No reminder. You can turn it on here.';

  @override
  String paywallTimelineEndBody(String price) {
    return 'Your plan starts at $price/year. Cancel before then and you won’t be charged.';
  }

  @override
  String get paywallRemindSemantics => 'Remind me before my trial ends';

  @override
  String get paywallPrivacyNote => 'Your conversations stay private.';

  @override
  String get paywallCtaTrial => 'Start Free Trial';

  @override
  String get paywallCtaSubscribe => 'Subscribe';

  @override
  String paywallFineTrial(int days, String price) {
    return '$days days free, then $price/year. Cancel anytime in Settings.';
  }

  @override
  String paywallFineYearly(String price) {
    return '$price/year. Cancel anytime in Settings.';
  }

  @override
  String paywallFineMonthly(String price) {
    return '$price/month. Cancel anytime in Settings.';
  }

  @override
  String paywallFineCoins(int count) {
    return 'Premium includes $count coins a month.';
  }

  @override
  String get paywallFineLegal =>
      'Payment is charged to your Apple ID when you confirm (or when the free trial ends). The subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in Settings › Apple ID › Subscriptions.';

  @override
  String get paywallError => 'We couldn’t load the plans.';

  @override
  String get paywallPending => 'Waiting for approval';

  @override
  String get paywallFailed =>
      'The purchase didn’t go through. You weren’t charged.';

  @override
  String get paywallRestoreNone => 'No purchases to restore';

  @override
  String get paywallRestoreDone => 'Purchases restored';

  @override
  String paywallPlanSemantics(String name, String billed, String detail) {
    return '$name. $billed. $detail';
  }

  @override
  String get compareHeader => 'What you get';

  @override
  String get compareFree => 'Free';

  @override
  String get comparePremium => 'Premium';

  @override
  String get compareRowPlan => 'Daily plan';

  @override
  String compareRowPlanFree(int day) {
    return 'Day 1–$day';
  }

  @override
  String get compareRowPlanPremium => 'All 30';

  @override
  String get compareRowMira => 'Talks with Mira';

  @override
  String compareRowMiraFree(int count) {
    return '$count a day';
  }

  @override
  String get compareUnlimited => 'Unlimited';

  @override
  String get compareRowSos => 'SOS and helplines';

  @override
  String get compareIncluded => 'Included';

  @override
  String get compareNotIncluded => 'Not included';

  @override
  String get compareRowDraft => 'Unsent drafts (Draft Jail)';

  @override
  String compareRowDraftFree(int count) {
    return '$count a day';
  }

  @override
  String get compareRowAnalysis => 'Relationship analysis';

  @override
  String get compareRowAnalysisFree => '1 insight';

  @override
  String get compareRowAnalysisPremium => 'Full';

  @override
  String get compareRowCoins => 'Bonus coins';

  @override
  String compareRowCoinsPremium(int count) {
    return '$count a month';
  }

  @override
  String get exitSheetLabel => 'Special offer';

  @override
  String get exitTitleHalf => 'Your first year, half price.';

  @override
  String exitTitlePct(String pct) {
    return 'Your first year, $pct off.';
  }

  @override
  String exitBody(String offer, String annual) {
    return '$offer for your first year, then $annual/year. Cancel anytime.';
  }

  @override
  String exitCta(String offer) {
    return 'Try a Year for $offer';
  }

  @override
  String welcomeTitle(String name) {
    return 'You’re all set, $name.';
  }

  @override
  String get welcomeTitleNoName => 'You’re all set.';

  @override
  String welcomeSubTrialRemind(String date) {
    return 'Everything’s open. We’ll remind you on $date, two days before your trial ends.';
  }

  @override
  String welcomeSubTrial(String date) {
    return 'Everything’s open. Your trial ends on $date.';
  }

  @override
  String get welcomeSubPaid => 'Everything’s open. Take it one day at a time.';

  @override
  String get welcomeAll30 => 'All 30 days';

  @override
  String get welcomeMira => 'Unlimited Mira';

  @override
  String get welcomeAnalysis => 'Full relationship analysis';

  @override
  String welcomeCoinsAdded(int count) {
    return '+$count coins added';
  }

  @override
  String welcomeCoinsPending(int count) {
    return '+$count coins on the way';
  }

  @override
  String get welcomeCta => 'Go to Your Plan';

  @override
  String get welcomeFine => 'Manage anytime in Me › Subscription';

  @override
  String get homeTitle => 'Today';

  @override
  String get homeGreetingLate => 'Still up';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String homeGreetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get homeHeroLabel => 'No contact';

  @override
  String homeHeroUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String homeHeroNext(int remaining, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining more days to $target days',
      one: '1 more day to $target days',
    );
    return '$_temp0';
  }

  @override
  String get homeHeroStart => 'Start your no-contact streak today.';

  @override
  String get homeHeroStartCta => 'Start Today';

  @override
  String get homePlanTitle => 'Your 30-day plan';

  @override
  String homePlanSub(int day) {
    return 'Free covers Days 1–$day';
  }

  @override
  String get homeMiraTitle => 'Talk to Mira';

  @override
  String homeMiraFreeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free messages left tonight',
      one: '1 free message left tonight',
      zero: 'No free messages left tonight',
    );
    return '$_temp0';
  }

  @override
  String get homeMiraUnlimited => 'Anytime, no limit';

  @override
  String get homeSosTitle => 'About to text them?';

  @override
  String get homeSosSub => 'Pause first. SOS is always free.';

  @override
  String get homeUpsellTitle => 'Day 4 is part of Premium';

  @override
  String get homeUpsellTryFree => 'Try free';

  @override
  String get homeUpsellSeePlans => 'See plans';

  @override
  String homeTrialTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Free trial: $count days left',
      one: 'Free trial: 1 day left',
    );
    return '$_temp0';
  }

  @override
  String get homeTrialSub => 'See your subscription';

  @override
  String coinChipSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coins. Open coins',
      one: '1 coin. Open coins',
    );
    return '$_temp0';
  }

  @override
  String get tabHome => 'Home';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabCoach => 'Coach';

  @override
  String get tabMe => 'Me';

  @override
  String get sosButton => 'SOS';

  @override
  String get sosButtonSemantics => 'SOS, always free';

  @override
  String get coachTitle => 'Mira';

  @override
  String get coachGreeting => 'Hi. I’m here. How’s tonight going?';

  @override
  String get coachHint => 'Message Mira';

  @override
  String get coachSend => 'Send';

  @override
  String coachMeter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free messages left tonight',
      one: '1 free message left tonight',
      zero: 'No free messages left tonight',
    );
    return '$_temp0';
  }

  @override
  String get coachGetMore => 'Get More';

  @override
  String get coachSosMode => 'SOS mode · no limits';

  @override
  String get coachTyping => 'Mira is typing';

  @override
  String get coachError => 'Mira couldn’t answer. Your message is still here.';

  @override
  String get limitSheetLabel => 'Message limit';

  @override
  String get limitTitle => 'Mira’s still here.';

  @override
  String limitBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You’ve used tonight’s $count free messages.',
      one: 'You’ve used tonight’s free message.',
    );
    return '$_temp0';
  }

  @override
  String get limitPremium => 'Keep Talking with Premium';

  @override
  String limitPremiumTrialNote(int days) {
    return 'Includes a $days-day free trial.';
  }

  @override
  String limitCoins(int count, int cost) {
    return '$count More Messages for $cost Coins';
  }

  @override
  String get limitGetCoins => 'Get Coins';

  @override
  String limitWait(String time) {
    return 'Wait Until $time';
  }

  @override
  String get limitSos => 'Struggling right now? SOS is always free.';

  @override
  String limitCreditsAdded(int count) {
    return '$count messages added';
  }

  @override
  String get coinsTitle => 'Coins';

  @override
  String coinsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'coins',
      one: 'coin',
    );
    return '$_temp0';
  }

  @override
  String get coinsGetHeader => 'Get coins';

  @override
  String coinsPackTitle(int count) {
    return '$count coins';
  }

  @override
  String coinsPackBonus(int count) {
    return '+$count bonus';
  }

  @override
  String coinsBestValueBonus(int count) {
    return 'Best value · +$count bonus';
  }

  @override
  String get coinsBestValue => 'Best value';

  @override
  String get coinsUnlockHeader => 'What you can unlock';

  @override
  String coinsItemMsgs(int count) {
    return '$count more messages with Mira';
  }

  @override
  String get coinsItemPlanDay => 'Unlock one plan day';

  @override
  String get coinsItemAnalysis => 'Full relationship analysis';

  @override
  String coinsCrossSell(int count) {
    return 'Premium includes $count coins a month';
  }

  @override
  String get coinsAdding => 'Adding your coins…';

  @override
  String get coinsOnTheWay => 'Your coins are on the way. Pull to refresh.';

  @override
  String coinsAdded(int count) {
    return '+$count coins added';
  }

  @override
  String get coinsError => 'We couldn’t load the coin packs.';

  @override
  String get sosTitle => 'Pause. Breathe.';

  @override
  String get sosBreatheIn => 'Breathe in';

  @override
  String get sosBreatheOut => 'Breathe out';

  @override
  String sosBodyStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You’ve gone $count days without reaching out. Let’s get through the next ten minutes together.',
      one:
          'You’ve gone 1 day without reaching out. Let’s get through the next ten minutes together.',
    );
    return '$_temp0';
  }

  @override
  String get sosBody =>
      'You don’t have to decide anything right now. Let’s get through the next ten minutes together.';

  @override
  String get sosTalk => 'Talk to Mira';

  @override
  String get sosUrgent => 'I Need Urgent Help';

  @override
  String get sosFree => 'SOS is always free.';

  @override
  String get crisisSheetLabel => 'Crisis support';

  @override
  String get crisisTitle => 'You don’t have to handle this alone.';

  @override
  String get crisisBody =>
      'If you might hurt yourself, please reach a real person now.';

  @override
  String get crisisCallEmergency => 'Call Emergency Services';

  @override
  String get crisisCallHelpline => 'Call a Helpline';

  @override
  String crisisNumbers(String emergency) {
    return 'Emergency $emergency';
  }

  @override
  String crisisNumbersHelpline(String emergency, String helpline) {
    return 'Emergency $emergency · Helpline $helpline';
  }

  @override
  String get planTitle => 'Your 30 Days';

  @override
  String get planNotReady =>
      'Your daily plan is being prepared. Check back soon.';

  @override
  String get meTitle => 'Me';

  @override
  String get meStatusFree => 'Free plan';

  @override
  String get meStatusTrial => 'Free trial';

  @override
  String get meStatusPremium => 'Premium';

  @override
  String meFreeCardTitleTrial(int days) {
    return 'Try Premium free for $days days';
  }

  @override
  String get meFreeCardTitle => 'Get Premium';

  @override
  String get meFreeCardBody => 'All 30 days, unlimited Mira, full analysis.';

  @override
  String get meTryFree => 'Try Free';

  @override
  String get meSeePlans => 'See Plans';

  @override
  String get meSubscriptionHeader => 'Subscription';

  @override
  String get mePlan => 'Plan';

  @override
  String get mePlanYearlyTrial => 'Yearly · Free trial';

  @override
  String get mePlanYearly => 'Yearly';

  @override
  String get mePlanMonthly => 'Monthly';

  @override
  String get mePlanPremium => 'Premium';

  @override
  String get meRenews => 'Renews';

  @override
  String get meEnds => 'Ends';

  @override
  String get meManage => 'Manage Subscription';

  @override
  String get meCancel => 'Cancel Subscription';

  @override
  String get meBillingIssue =>
      'There’s a problem with your payment. Update it in the App Store to keep Premium.';

  @override
  String get meAccountHeader => 'Account';

  @override
  String get meCoins => 'Coins';

  @override
  String get meRestore => 'Restore Purchases';

  @override
  String get meSupport => 'Contact Support';

  @override
  String onbStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onbContinue => 'Continue';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbLanguageTitle => 'Which language do you prefer?';

  @override
  String get onbLanguageSub => 'You can change it later in Settings.';

  @override
  String get onbLanguageEn => 'English';

  @override
  String get onbLanguageTr => 'Türkçe';

  @override
  String get onbWhatTitle => 'What happened?';

  @override
  String get onbWhatSub => 'There’s no wrong answer.';

  @override
  String get whatTheyEnded => 'They ended it';

  @override
  String get whatIEnded => 'I ended it';

  @override
  String get whatMutual => 'It was mutual';

  @override
  String get whatComplicated => 'It’s complicated';

  @override
  String get onbDetailsTitle => 'A little more, if you like';

  @override
  String get onbDetailsSub => 'Both optional. Only you will see their name.';

  @override
  String get onbYourName => 'Your first name';

  @override
  String get onbExName => 'Their name';

  @override
  String get onbExNameHint => 'Only you will see this';

  @override
  String get onbLength => 'How long were you together?';

  @override
  String get onbDone => 'Done';

  @override
  String get lenLt6m => 'Less than 6 months';

  @override
  String get len6to12m => '6–12 months';

  @override
  String get len1to3y => '1–3 years';

  @override
  String get lenGt3y => 'More than 3 years';

  @override
  String get onbFeelingsTitle => 'How are you right now?';

  @override
  String get onbMoodLow => 'Barely holding on';

  @override
  String get onbMoodHigh => 'Okay';

  @override
  String onbMoodSemantics(int value) {
    return 'Mood $value of 10';
  }

  @override
  String get onbFeelingsSub => 'What feels loudest today? Pick any.';

  @override
  String get feelSad => 'Sad';

  @override
  String get feelLonely => 'Lonely';

  @override
  String get feelAnxious => 'Anxious';

  @override
  String get feelAngry => 'Angry';

  @override
  String get feelNumb => 'Numb';

  @override
  String get feelConfused => 'Confused';

  @override
  String get feelRelieved => 'Relieved';

  @override
  String get onbAttachTitle => 'How true are these for you?';

  @override
  String get onbAttachSub => 'A starting point, not a diagnosis.';

  @override
  String get attachQ0 => 'I worry they’ll forget me.';

  @override
  String get attachQ1 => 'I’d rather not need anyone.';

  @override
  String get attachQ2 => 'I replay what I could have said.';

  @override
  String get onbGoalsTitle => 'What do you want most right now?';

  @override
  String get onbGoalsSub => 'Pick up to three. The first one is your focus.';

  @override
  String get goalNoContact => 'Stop texting them';

  @override
  String get goalCalm => 'Sleep better';

  @override
  String get goalSelfWorth => 'Feel like myself again';

  @override
  String get goalUnderstand => 'Understand what went wrong';

  @override
  String get onbBuildingTitle => 'Building your plan';

  @override
  String get onbBuildStep1 => 'Reading your answers';

  @override
  String get onbBuildStep2 => 'Choosing your first steps';

  @override
  String get onbBuildStep3 => 'Getting Mira ready for you';

  @override
  String get attachSecure => 'Fairly secure';

  @override
  String get attachAnxious => 'Leaning anxious';

  @override
  String get attachAvoidant => 'Leaning avoidant';

  @override
  String get attachFearful => 'Anxious and avoidant';

  @override
  String get focusNoContact => 'No contact';

  @override
  String get focusCalm => 'Better sleep';

  @override
  String get focusSelfWorth => 'Self-worth';

  @override
  String get focusUnderstand => 'Understanding what happened';

  @override
  String planReadyTitleNamed(String name) {
    return '$name, your plan is ready.';
  }

  @override
  String paywallSubNamed(String name) {
    return '$name, your full plan, and Mira whenever it gets hard.';
  }

  @override
  String paywallBenefitPlanSubFocus(String focus, int day) {
    return 'Focus: $focus. Free stops after Day $day.';
  }

  @override
  String planSubtitle(int day) {
    return 'Day $day of 30';
  }

  @override
  String planDoneCount(int done) {
    return '$done of 30 days done';
  }

  @override
  String get planStageWeek1 => 'Week 1';

  @override
  String get planStageWeek2 => 'Week 2';

  @override
  String get planStageWeek3 => 'Week 3';

  @override
  String get planStageRebuild => 'Rebuild';

  @override
  String planRowDone(int day) {
    return 'Day $day · Done';
  }

  @override
  String planRowToday(int day, int minutes) {
    return 'Day $day · Today · $minutes min';
  }

  @override
  String planRowOpensAt(int day, String time) {
    return 'Day $day · Opens at $time';
  }

  @override
  String planRowAfter(int day, int prev) {
    return 'Day $day · After Day $prev';
  }

  @override
  String planRowLocked(int day) {
    return 'Day $day · Premium';
  }

  @override
  String planWaitingToast(String time) {
    return 'This day opens at $time';
  }

  @override
  String planAfterToast(int prev) {
    return 'Finish Day $prev first';
  }

  @override
  String get planError => 'We couldn’t load your plan.';

  @override
  String get planFinished => 'You finished all 30 days.';

  @override
  String taskTitle(int day) {
    return 'Day $day';
  }

  @override
  String taskEntryLabel(int n) {
    return '$n';
  }

  @override
  String get taskEntryHint => 'Write it down';

  @override
  String taskComplete(int day) {
    return 'Complete Day $day';
  }

  @override
  String get taskPrivate => 'Only you can see what you write.';

  @override
  String get taskDoneNote => 'You completed this day.';

  @override
  String get taskNotOpen => 'This day isn’t open yet.';

  @override
  String get taskError => 'We couldn’t load this day.';

  @override
  String get taskSaveError => 'We couldn’t save. Your answers are still here.';

  @override
  String dayCompleteTitle(int day) {
    return 'Day $day complete';
  }

  @override
  String get dayCompleteBody => 'You showed up for yourself today.';

  @override
  String dayCompleteNext(int day, String time) {
    return 'Day $day opens tomorrow at $time.';
  }

  @override
  String dayCompleteNextLocked(int day) {
    return 'Day $day is part of Premium.';
  }

  @override
  String get dayCompleteAll => 'That was Day 30. You stayed with yourself.';

  @override
  String get dayCompleteDone => 'Back to Your Plan';

  @override
  String get lockDaySheetLabel => 'Locked day';

  @override
  String lockDayFoot(int day, int minutes) {
    return 'Day $day · $minutes min';
  }

  @override
  String lockDayBody(int days) {
    return 'Free covers Days 1–$days. Premium opens all 30, plus the Rebuild stage.';
  }

  @override
  String get lockDayPremium => 'Unlock All 30 Days';

  @override
  String lockDayTrialNote(int days) {
    return '$days days free';
  }

  @override
  String lockDayCoins(int day, int cost) {
    return 'Unlock Day $day for $cost Coins';
  }

  @override
  String lockDayGetCoins(int day) {
    return 'Get Coins to Unlock Day $day';
  }

  @override
  String lockDayUnlocked(int day) {
    return 'Day $day unlocked';
  }

  @override
  String get draftTitle => 'Draft Jail';

  @override
  String get draftSub =>
      'Write what you want to send. It stays locked for 24 hours. If you still want to send it then, it’ll be here.';

  @override
  String get draftHint => 'What do you want to say?';

  @override
  String get draftFieldLabel => 'Your message';

  @override
  String get draftLock => 'Lock for 24 Hours';

  @override
  String get draftLockedToast => 'Locked for 24 hours';

  @override
  String get draftLockedHeader => 'Locked';

  @override
  String get draftReadyHeader => 'Ready';

  @override
  String get draftLockedRow => 'Locked draft';

  @override
  String draftWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String draftUnlocksIn(String time) {
    return 'Unlocks in $time';
  }

  @override
  String get draftReadyRow => 'Ready to read';

  @override
  String get draftUnlock => 'Unlock';

  @override
  String get draftCopy => 'Copy Text';

  @override
  String get draftCopied => 'Copied';

  @override
  String get draftDelete => 'Delete Forever';

  @override
  String get draftDeleteTitle => 'Delete this draft forever?';

  @override
  String get draftDeleteBody =>
      'It will be gone for good. This can’t be undone.';

  @override
  String get draftDeleted => 'Deleted';

  @override
  String get draftStillLocked => 'Still locked. Give it a little more time.';

  @override
  String get draftEmpty => 'Nothing locked right now.';

  @override
  String get draftError => 'We couldn’t lock it. Your text is still here.';

  @override
  String get draftListError => 'We couldn’t load your drafts.';

  @override
  String get draftSheetLabel => 'Draft';

  @override
  String get draftFromSos => 'Written in SOS';

  @override
  String get draftLimitSheetLabel => 'Draft Jail limit';

  @override
  String get draftLimitTitle => 'One draft a day on the free plan.';

  @override
  String get draftLimitBody =>
      'Today’s free Draft Jail is used. Your text is still here.';

  @override
  String get draftLimitPremium => 'Unlimited Drafts with Premium';

  @override
  String get homeDraftTitle => 'Draft Jail';

  @override
  String get homeDraftSub => 'Write it here instead of sending it';

  @override
  String get sosDraft => 'Write It in Draft Jail';

  @override
  String get reminderTrialTitle => 'Your trial ends in 2 days';

  @override
  String reminderTrialBody(int talks, int drafts) {
    return '$talks talks with Mira and $drafts unsent texts so far. If it’s not for you, cancel anytime in Settings.';
  }

  @override
  String get reminderTrialBodyEmpty =>
      'Your free trial ends in 2 days. If it’s not for you, cancel anytime in Settings.';

  @override
  String get reminderEndingTitle => 'Your Premium ends soon';

  @override
  String reminderEndingBody(String date) {
    return 'Premium ends on $date. Your streak, plan and SOS stay with you.';
  }

  @override
  String get welcomeNotifTitle => 'Turn on the reminder?';

  @override
  String welcomeNotifBody(String date) {
    return 'We’ll send one notification on $date, two days before your trial ends. Nothing else.';
  }

  @override
  String get welcomeNotifAllow => 'Allow Notifications';

  @override
  String get welcomeNotifDenied =>
      'No problem. You can turn it on later in Settings.';

  @override
  String welcomeNotifOn(String date) {
    return 'Reminder set for $date';
  }

  @override
  String get trialTitle => 'Your Trial';

  @override
  String trialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days left',
      one: 'day left',
    );
    return '$_temp0';
  }

  @override
  String trialFreeUntil(String date) {
    return 'Free until $date';
  }

  @override
  String trialThen(String price) {
    return 'Then $price/year. Cancel anytime before.';
  }

  @override
  String get trialThenNoPrice =>
      'Cancel anytime before and you won’t be charged.';

  @override
  String trialEndsNoCharge(String date) {
    return 'Premium ends on $date. You won’t be charged.';
  }

  @override
  String get trialSoFar => 'So far';

  @override
  String get trialTalks => 'Talks with Mira';

  @override
  String get trialDrafts => 'Texts not sent';

  @override
  String get trialDaysDone => 'Days done';

  @override
  String get trialNextTitle => 'Next up: Rebuild';

  @override
  String get trialNextBody => 'Days 8–30 rebuild self-worth and routines.';

  @override
  String get trialBack => 'Back to Today';

  @override
  String get trialNotActive => 'You’re not in a free trial right now.';

  @override
  String get winbackTitle => 'We kept your place.';

  @override
  String get winbackSub => 'Your streak, plan and drafts are all still here.';

  @override
  String winbackSubStreak(int count) {
    return 'Your $count-day streak and your plan are all still here.';
  }

  @override
  String get winbackOfferLabel => 'Returning member offer';

  @override
  String winbackFor(int months, String monthly) {
    return 'for $months months, then $monthly/month';
  }

  @override
  String winbackFine(String promo, int months, String monthly) {
    return '$promo for $months months, then $monthly/month. Cancel anytime.';
  }

  @override
  String get winbackCta => 'Continue My Plan';

  @override
  String get winbackNo => 'Stay on Free';

  @override
  String get billingIssueCta => 'Update Payment';

  @override
  String get billingIssueTitle => 'Payment problem';

  @override
  String get meTrialProgress => 'Your Trial Progress';

  @override
  String get checkinTitle => 'Mira';

  @override
  String get checkinBody => 'How was today? I’m here if you want to talk.';

  @override
  String get cancelSheetLabel => 'Cancel subscription';

  @override
  String get cancelTitle => 'Mind sharing why?';

  @override
  String get cancelSub => 'It helps us improve MyEx. You can skip this.';

  @override
  String get cancelReasonPrice => 'It’s too expensive';

  @override
  String get cancelReasonBetter => 'I’m feeling better';

  @override
  String get cancelReasonUnused => 'I’m not using it';

  @override
  String get cancelReasonOther => 'Something else';

  @override
  String cancelPriceTitle(String promo) {
    return 'Stay for $promo for a year';
  }

  @override
  String get cancelPriceBody =>
      'Half price, same everything. Applied as an App Store offer.';

  @override
  String get cancelPriceCta => 'Keep Premium for Less';

  @override
  String cancelSwitchTitle(String pct) {
    return 'Switch to Yearly and save $pct';
  }

  @override
  String cancelSwitchBody(String price) {
    return '$price/year instead of paying monthly.';
  }

  @override
  String get cancelSwitchCta => 'Switch to Yearly';

  @override
  String get cancelBetter =>
      'That’s the whole point. Your streak, journal and SOS stay free. Come back anytime.';

  @override
  String get cancelUnusedTitle => 'Want a short check-in each night?';

  @override
  String get cancelUnusedBody => 'One message from Mira at 10 PM.';

  @override
  String get cancelUnusedCta => 'Turn On Check-ins';

  @override
  String get cancelCheckinOn => 'Check-ins on. See you at 10 PM.';

  @override
  String get cancelCheckinDenied =>
      'Notifications are off. You can turn them on in Settings.';

  @override
  String get cancelOther =>
      'Thank you for telling us. It helps us make MyEx better.';

  @override
  String get cancelNoteLabel => 'Anything else? (optional)';

  @override
  String get cancelContinue => 'Continue to Cancel';

  @override
  String get cancelKept => 'Premium kept. Thank you.';

  @override
  String get meSwitchYearly => 'Switch to Yearly';

  @override
  String get meTrialEnds => 'Trial ends';

  @override
  String meCancelledNote(String date) {
    return 'Cancelled. Premium stays on until $date.';
  }

  @override
  String meDayStatus(int day, String status) {
    return 'Day $day · $status';
  }

  @override
  String get meNameFallback => 'You';

  @override
  String get onbHelpNow => 'Need Help Now?';

  @override
  String get onbNameTitle => 'What should we call you?';

  @override
  String get onbNameSub => 'Optional. Only used inside the app.';

  @override
  String get onbWhenTitle => 'When did it end?';

  @override
  String get whenThisWeek => 'This week';

  @override
  String get whenWeeks => '1–4 weeks ago';

  @override
  String get whenMonths => '1–6 months ago';

  @override
  String get whenLonger => 'Longer';

  @override
  String get onbContactTitle => 'Are you still in touch?';

  @override
  String get contactNone => 'No';

  @override
  String get contactSometimes => 'Sometimes';

  @override
  String get contactMostDays => 'Most days';

  @override
  String get contactShared => 'We share kids or work';

  @override
  String get onbHardestTitle => 'When is it hardest?';

  @override
  String get onbHardestSub => 'Pick any.';

  @override
  String get hardLateNight => 'Late at night';

  @override
  String get hardMornings => 'Mornings';

  @override
  String get hardWeekends => 'Weekends';

  @override
  String get hardPosts => 'When I see their posts';

  @override
  String get onbMiraTitle => 'Mira’s there at 2 AM.';

  @override
  String get onbMiraBody => 'And SOS is always free, whenever you need it.';

  @override
  String get goalStopChecking => 'Stop checking their profile';

  @override
  String get focusStopChecking => 'Stop checking';

  @override
  String get ansAgree => 'Agree';

  @override
  String get ansNotReally => 'Not really';

  @override
  String get onbUnsentTitle => 'Anything you wish you could tell them?';

  @override
  String get onbUnsentSub => 'It won’t be sent. It goes into Draft Jail.';

  @override
  String get onbUnsentHint => 'Write it here. It won’t be sent.';

  @override
  String get onbUnsentSave => 'Save Unsent';

  @override
  String get onbUnsentSaved => 'Saved. It stays unsent for 24 hours.';

  @override
  String get onbCheckinTitle => 'Want a check-in when it’s hardest?';

  @override
  String onbCheckinSub(String time) {
    return 'One message from Mira at $time. You can change the time.';
  }

  @override
  String get onbCheckinChange => 'Change Time';

  @override
  String get onbCheckinAllow => 'Allow Check-ins';

  @override
  String onbCheckinOn(String time) {
    return 'Check-ins on at $time';
  }

  @override
  String onbBuildFocus(String focus) {
    return 'Matching your focus: $focus';
  }

  @override
  String onbBuildHardest(String time) {
    return 'Planning for your hardest time: $time';
  }

  @override
  String onbBuildDay1(int minutes) {
    return 'Choosing Day 1: $minutes minutes, tonight';
  }

  @override
  String onbBuildTrack(String track) {
    return 'Setting your track: $track';
  }

  @override
  String get planReadyWhen => 'When it ended';

  @override
  String get planReadyTrack => 'Your track';

  @override
  String get planTrackNoContact => 'No contact';

  @override
  String get planTrackLowContact => 'Low contact (shared kids or work)';

  @override
  String get planReadyFirstDays => 'Your first 3 days';

  @override
  String planReadyDayRow(int day) {
    return 'Day $day';
  }

  @override
  String planReadyTonight(int minutes) {
    return 'Tonight · $minutes min';
  }

  @override
  String planReadySupport(String time) {
    return '$time: Mira’s here, and SOS is always free.';
  }

  @override
  String get planReadyLocked => 'Days 4–30 open with Premium.';

  @override
  String paywallSubTrial(int days, String price) {
    return '$days days free, then $price/year.';
  }

  @override
  String paywallSubYearly(String price) {
    return '$price/year. Cancel anytime.';
  }

  @override
  String paywallSubMonthly(String price) {
    return '$price/month. No free trial.';
  }

  @override
  String get paywallNoPaymentToday => 'No payment today';

  @override
  String get paywallTimelineBuild => 'Build your plan';

  @override
  String get paywallTimelineBuildBody => 'Done. Based on your answers.';

  @override
  String get paywallNotifOff => 'Notifications are off for MyEx.';

  @override
  String get paywallOpenSettings => 'Open Settings';

  @override
  String get paywallHowCancel => 'How do I cancel?';

  @override
  String get paywallHowCancelIos =>
      'Settings › your name › Subscriptions › MyEx › Cancel Subscription. Takes under a minute. Your streak and journal stay.';

  @override
  String get paywallHowCancelAndroid =>
      'Play Store › your profile › Payments & subscriptions › Subscriptions › MyEx › Cancel. Takes under a minute. Your streak and journal stay.';

  @override
  String get tabJournal => 'Journal';

  @override
  String get commonSaveFailed => 'Couldn’t save. Try again.';

  @override
  String get homeMoodTitle => 'How are you, right now?';

  @override
  String homeMoodDone(String mood) {
    return 'Today you felt $mood.';
  }

  @override
  String get homeMoodWrite => 'Write About It';

  @override
  String get homeMoodAgain => 'Check In Again';

  @override
  String get homeDayHeader => 'Your day';

  @override
  String get homeJournalTitle => 'Journal';

  @override
  String homeJournalSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries so far',
      one: '1 entry so far',
      zero: 'Write tonight’s first line',
    );
    return '$_temp0';
  }

  @override
  String get homeWeekTitle => 'This week';

  @override
  String get homeWeekSee => 'Insights';

  @override
  String get homeHeroChooseGoal => 'Choose a Goal';

  @override
  String homeHeroChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days you chose yourself',
      one: '1 day you chose yourself',
    );
    return '$_temp0';
  }

  @override
  String get moodLevel1 => 'heavy';

  @override
  String get moodLevel2 => 'low';

  @override
  String get moodLevel3 => 'okay';

  @override
  String get moodLevel4 => 'lighter';

  @override
  String get moodLevel5 => 'good';

  @override
  String get moodSheetFeelings => 'What’s in there?';

  @override
  String get moodSheetNote => 'Anything to add? (optional)';

  @override
  String get moodSheetSave => 'Save Check-in';

  @override
  String get moodSaved => 'Saved. Thanks for checking in.';

  @override
  String moodScaleSemantics(int level, String word) {
    return 'Mood $level of 5, $word';
  }

  @override
  String get moodWordHeartbroken => 'Heartbroken';

  @override
  String get moodWordLonely => 'Lonely';

  @override
  String get moodWordAngry => 'Angry';

  @override
  String get moodWordAnxious => 'Anxious';

  @override
  String get moodWordNumb => 'Numb';

  @override
  String get moodWordConfused => 'Confused';

  @override
  String get moodWordTired => 'Tired';

  @override
  String get moodWordHopeful => 'Hopeful';

  @override
  String get moodWordCalm => 'Calm';

  @override
  String get moodWordRelieved => 'Relieved';

  @override
  String get moodWordProud => 'Proud';

  @override
  String get moodWordGrateful => 'Grateful';

  @override
  String get journalTitle => 'Journal';

  @override
  String get journalNew => 'New Entry';

  @override
  String get journalSearch => 'Search your journal';

  @override
  String get journalFilterAll => 'All';

  @override
  String get journalKindReflection => 'Reflection';

  @override
  String get journalKindLetter => 'Unsent letter';

  @override
  String get journalKindGratitude => 'Gratitude';

  @override
  String get journalKindList => 'List';

  @override
  String get journalPromptToday => 'Tonight’s prompt';

  @override
  String get journalWrite => 'Write';

  @override
  String get journalEmptyTitle => 'Your pages are private.';

  @override
  String get journalEmptyBody =>
      'Write what you can’t say out loud. Only you can see it.';

  @override
  String get journalEmptyCta => 'Write Your First Entry';

  @override
  String journalNoResults(String query) {
    return 'Nothing matches “$query”.';
  }

  @override
  String get journalPrivate => 'Only you can see your journal.';

  @override
  String get journalEditorHint => 'Start anywhere.';

  @override
  String get journalSave => 'Save';

  @override
  String get journalAnotherPrompt => 'Another Prompt';

  @override
  String get journalMoodOptional => 'How did writing leave you? (optional)';

  @override
  String get journalDelete => 'Delete Entry';

  @override
  String get journalDeleteTitle => 'Delete this entry?';

  @override
  String get journalDeleteBody => 'It can’t be recovered.';

  @override
  String get journalDiscardTitle => 'Discard this entry?';

  @override
  String get journalDiscardBody => 'What you wrote won’t be saved.';

  @override
  String get journalDiscard => 'Discard';

  @override
  String get journalKeepWriting => 'Keep Writing';

  @override
  String get journalSaved => 'Saved to your journal.';

  @override
  String get journalPromptReflection1 => 'What was hardest today?';

  @override
  String get journalPromptReflection2 =>
      'What do you miss, and what don’t you?';

  @override
  String get journalPromptReflection3 =>
      'When did you feel most like yourself this week?';

  @override
  String get journalPromptReflection4 =>
      'What would you tell a friend going through this?';

  @override
  String get journalPromptLetter1 => 'A letter you won’t send';

  @override
  String get journalPromptLetter2 => 'What you never got to say';

  @override
  String get journalPromptLetter3 => 'Goodbye, in your own words';

  @override
  String get journalPromptGratitude1 => 'One small thing that went right today';

  @override
  String get journalPromptGratitude2 => 'Someone who showed up for you';

  @override
  String get journalPromptGratitude3 => 'Something you did for yourself today';

  @override
  String get journalPromptList1 => 'Three things you won’t miss';

  @override
  String get journalPromptList2 => 'Five things that are yours again';

  @override
  String get journalPromptList3 => 'Things you want to try on your own';

  @override
  String get noContactTitle => 'No contact';

  @override
  String get noContactIntroTitle => 'Give yourself space.';

  @override
  String get noContactIntroBody =>
      'No texts, no checking their profile. Pick a goal. If you slip, you restart kindly, and every day still counts.';

  @override
  String get noContactGoal => 'Goal';

  @override
  String noContactGoalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get noContactStart => 'Start Today';

  @override
  String noContactOfGoal(String goal) {
    return 'of $goal';
  }

  @override
  String noContactNext(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Next milestone in $count days',
      one: 'Next milestone tomorrow',
    );
    return '$_temp0';
  }

  @override
  String get noContactGoalReached =>
      'Goal reached. Keep going if it feels right.';

  @override
  String get noContactChosen => 'Days you chose yourself';

  @override
  String get noContactChosenNote =>
      'Counts every day of every run. It never resets.';

  @override
  String get noContactBest => 'Best run';

  @override
  String get noContactRuns => 'Runs';

  @override
  String get noContactMilestones => 'Milestones';

  @override
  String get noContactMilestone1 => 'The first night';

  @override
  String get noContactMilestone3 => 'The hardest stretch for many';

  @override
  String get noContactMilestone7 => 'One week of choosing you';

  @override
  String get noContactMilestone14 => 'New habits take root';

  @override
  String get noContactMilestone30 => 'A month of space';

  @override
  String get noContactMilestone60 => 'Two months, your own rhythm';

  @override
  String get noContactMilestone90 => 'A new normal';

  @override
  String get noContactHistory => 'Past runs';

  @override
  String noContactRun(int days, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0 · $range';
  }

  @override
  String get noContactReachedOut => 'I Reached Out';

  @override
  String get noContactRestartTitle => 'That’s okay.';

  @override
  String noContactRestartBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Reaching out doesn’t erase what you did. Your $_temp0 still count.';
  }

  @override
  String get noContactReflection =>
      'What happened? What would help next time? (optional)';

  @override
  String get noContactRestart => 'Restart Today';

  @override
  String get noContactRestarted => 'New run started. Your days still count.';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsMood => 'Your last 14 days';

  @override
  String get insightsNonLinear =>
      'Healing isn’t a straight line. Ups and downs are part of it.';

  @override
  String get insightsWeek => 'This week';

  @override
  String insightsWeekCheckins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You checked in $count times.',
      one: 'You checked in once.',
      zero: 'You haven’t checked in yet this week.',
    );
    return '$_temp0';
  }

  @override
  String get insightsWeekUp =>
      'Your days felt a little lighter than the week before.';

  @override
  String get insightsWeekDown =>
      'This week was heavier than the last. That’s part of it too.';

  @override
  String get insightsWeekSame =>
      'About the same as last week. Steady counts too.';

  @override
  String insightsWeekFeelings(String feelings) {
    return 'Most often: $feelings.';
  }

  @override
  String get insightsCheckins => 'Check-ins';

  @override
  String get insightsEntries => 'Journal entries';

  @override
  String get insightsPlanDays => 'Plan days done';

  @override
  String get insightsEmptyTitle => 'Your pattern shows up here.';

  @override
  String get insightsEmptyBody =>
      'Check in for a few days and you’ll see how your weeks move.';

  @override
  String get insightsCheckInNow => 'Check In Now';

  @override
  String insightsChartSemantics(String summary) {
    return 'Mood over the last 14 days. $summary';
  }

  @override
  String get coachAiLabel => 'AI · not therapy';

  @override
  String get coachSuggestTitle => 'Not sure where to start?';

  @override
  String get coachSuggest1 => 'I want to text them right now.';

  @override
  String get coachSuggest2 => 'I keep checking their profile.';

  @override
  String get coachSuggest3 => 'I can’t sleep tonight.';

  @override
  String get coachSuggest4 => 'Why do I still miss them?';

  @override
  String get coachNew => 'New Conversation';

  @override
  String get coachNewTitle => 'Start a new conversation?';

  @override
  String get coachNewBody =>
      'Mira starts fresh. Earlier messages won’t show here anymore.';

  @override
  String get coachNewConfirm => 'Start New';

  @override
  String get meAppearance => 'Appearance';

  @override
  String get meAppearanceSystem => 'Automatic';

  @override
  String get meAppearanceLight => 'Light';

  @override
  String get meAppearanceDark => 'Night';

  @override
  String get meProgressHeader => 'Your progress';

  @override
  String get draftJailEmptyTitle => 'Nothing locked right now.';

  @override
  String get draftJailEmptyBody =>
      'When the urge hits, write it here first. You can decide tomorrow.';

  @override
  String get paywallIncludes => 'Everything in Premium';

  @override
  String get paywallBrandBadge => 'Premium';

  @override
  String get paywallMedalMira => 'Mira, anytime';

  @override
  String get paywallMedalPlan => 'All 30 days';

  @override
  String get paywallMedalAnalysis => 'Full analysis';

  @override
  String get paywallMedalDrafts => 'Unlimited Draft Jail';

  @override
  String paywallMedalCoins(int count) {
    return '+$count coins a month';
  }
}

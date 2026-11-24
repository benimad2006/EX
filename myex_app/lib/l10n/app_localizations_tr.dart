// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'MyEx';

  @override
  String get commonRetry => 'Tekrar Dene';

  @override
  String get commonContinueFree => 'Ücretsiz Devam Et';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonCancel => 'Vazgeç';

  @override
  String get commonRestore => 'Geri Yükle';

  @override
  String get commonTermsOfUse => 'Kullanım Koşulları';

  @override
  String get commonPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get commonNotNow => 'Şimdi Değil';

  @override
  String get configMissingTitle => 'Yapılandırma eksik';

  @override
  String configMissingBody(String keys) {
    return 'Uygulamayı --dart-define-from-file=env/dev.json ile çalıştır. Eksik: $keys';
  }

  @override
  String get startupError =>
      'Bağlanamadık. Bağlantını kontrol edip tekrar dene.';

  @override
  String get planReadyTitle => 'Planın hazır.';

  @override
  String get planReadySub =>
      'Cevaplarından oluşturuldu. Bu gece küçük bir adımla başlıyor.';

  @override
  String get planReadyWhatHappened => 'Ne oldu';

  @override
  String get planReadyAttachment => 'Bağlanma stili';

  @override
  String get planReadyFocus => 'Odak';

  @override
  String get planReadyFirstStep => 'İlk adım';

  @override
  String planReadyFirstStepValue(int minutes) {
    return 'Bu gece · $minutes dk';
  }

  @override
  String get planReadyNote =>
      'BDT ve bağlanma araştırmalarına dayanır. Mira bir koçtur, terapist değildir.';

  @override
  String get planReadyCta => 'Devam Et';

  @override
  String get paywallTitle => '30 günde yeniden kendin gibi hisset.';

  @override
  String get paywallSub => 'Planının tamamı ve zorlandığın her an Mira.';

  @override
  String paywallStripCaption(int day) {
    return '$day. gündesin. Gerisini Premium açar.';
  }

  @override
  String get paywallBenefitMiraTitle => 'Mira ile istediğin zaman konuş';

  @override
  String get paywallBenefitMiraSub => 'Gece mesaj sınırı yok';

  @override
  String get paywallBenefitPlanTitle => 'Planının 30 günü';

  @override
  String paywallBenefitPlanSub(int day) {
    return 'Ücretsiz plan $day. günden sonra durur';
  }

  @override
  String get paywallBenefitAnalysisTitle => 'Tam analizin';

  @override
  String get paywallBenefitAnalysisSub => 'Tek bir kalıp değil, üçü de';

  @override
  String get paywallPickerLabel => 'Bir plan seç';

  @override
  String get paywallYearly => 'Yıllık';

  @override
  String get paywallMonthly => 'Aylık';

  @override
  String paywallSave(String pct) {
    return '$pct tasarruf';
  }

  @override
  String paywallYearlyDetailTrial(int days, String monthly) {
    return '$days gün ücretsiz · aylık $monthly';
  }

  @override
  String paywallYearlyDetail(String monthly) {
    return 'aylık $monthly';
  }

  @override
  String get paywallNoTrial => 'Ücretsiz deneme yok';

  @override
  String get paywallPerYear => 'yıllık';

  @override
  String get paywallPerMonth => 'aylık';

  @override
  String get paywallTimelineToday => 'Bugün';

  @override
  String get paywallTimelineTodayBody => 'Tam erişim. Ücret yok.';

  @override
  String get paywallTimelineRemindBody => 'Sana bir hatırlatma göndereceğiz.';

  @override
  String get paywallTimelineRemindOffBody =>
      'Hatırlatma kapalı. Buradan açabilirsin.';

  @override
  String paywallTimelineEndBody(String price) {
    return 'Planın yıllık $price ile başlar. Öncesinde iptal edersen ücret alınmaz.';
  }

  @override
  String get paywallRemindSemantics => 'Deneme bitmeden bana hatırlat';

  @override
  String get paywallPrivacyNote => 'Konuşmaların gizli kalır.';

  @override
  String get paywallCtaTrial => 'Ücretsiz Denemeyi Başlat';

  @override
  String get paywallCtaSubscribe => 'Abone Ol';

  @override
  String paywallFineTrial(int days, String price) {
    return '$days gün ücretsiz, ardından yıllık $price. İstediğin zaman Ayarlar\'dan iptal et.';
  }

  @override
  String paywallFineYearly(String price) {
    return 'Yıllık $price. İstediğin zaman Ayarlar\'dan iptal et.';
  }

  @override
  String paywallFineMonthly(String price) {
    return 'Aylık $price. İstediğin zaman Ayarlar\'dan iptal et.';
  }

  @override
  String paywallFineCoins(int count) {
    return 'Premium\'a her ay $count jeton dahildir.';
  }

  @override
  String get paywallFineLegal =>
      'Ödeme, onayladığında (veya ücretsiz deneme bittiğinde) Apple ID hesabından alınır. Abonelik, mevcut dönem bitmeden en az 24 saat önce iptal edilmezse otomatik olarak yenilenir. Ayarlar › Apple ID › Abonelikler\'den yönetebilir veya iptal edebilirsin.';

  @override
  String get paywallError => 'Planlar yüklenemedi.';

  @override
  String get paywallPending => 'Onay bekleniyor';

  @override
  String get paywallFailed => 'Satın alma tamamlanmadı. Senden ücret alınmadı.';

  @override
  String get paywallRestoreNone => 'Geri yüklenecek satın alma yok';

  @override
  String get paywallRestoreDone => 'Satın alımlar geri yüklendi';

  @override
  String paywallPlanSemantics(String name, String billed, String detail) {
    return '$name. $billed. $detail';
  }

  @override
  String get compareHeader => 'Neler var';

  @override
  String get compareFree => 'Ücretsiz';

  @override
  String get comparePremium => 'Premium';

  @override
  String get compareRowPlan => 'Günlük plan';

  @override
  String compareRowPlanFree(int day) {
    return '1–$day. gün';
  }

  @override
  String get compareRowPlanPremium => '30 günün tamamı';

  @override
  String get compareRowMira => 'Mira ile sohbet';

  @override
  String compareRowMiraFree(int count) {
    return 'Günde $count';
  }

  @override
  String get compareUnlimited => 'Sınırsız';

  @override
  String get compareRowSos => 'SOS ve yardım hatları';

  @override
  String get compareIncluded => 'Dahil';

  @override
  String get compareNotIncluded => 'Dahil değil';

  @override
  String get compareRowDraft => 'Gönderilmemiş taslaklar (Taslak Hapsi)';

  @override
  String compareRowDraftFree(int count) {
    return 'Günde $count';
  }

  @override
  String get compareRowAnalysis => 'İlişki analizi';

  @override
  String get compareRowAnalysisFree => '1 içgörü';

  @override
  String get compareRowAnalysisPremium => 'Tam';

  @override
  String get compareRowCoins => 'Hediye jeton';

  @override
  String compareRowCoinsPremium(int count) {
    return 'Ayda $count';
  }

  @override
  String get exitSheetLabel => 'Özel teklif';

  @override
  String get exitTitleHalf => 'İlk yılın yarı fiyatına.';

  @override
  String exitTitlePct(String pct) {
    return 'İlk yılında $pct indirim.';
  }

  @override
  String exitBody(String offer, String annual) {
    return 'İlk yılın için $offer, ardından yıllık $annual. İstediğin zaman iptal et.';
  }

  @override
  String exitCta(String offer) {
    return 'Bir Yılı $offer ile Dene';
  }

  @override
  String welcomeTitle(String name) {
    return 'Her şey hazır, $name.';
  }

  @override
  String get welcomeTitleNoName => 'Her şey hazır.';

  @override
  String welcomeSubTrialRemind(String date) {
    return 'Her şey açık. Denemen bitmeden iki gün önce, $date tarihinde sana hatırlatacağız.';
  }

  @override
  String welcomeSubTrial(String date) {
    return 'Her şey açık. Denemen $date tarihinde bitiyor.';
  }

  @override
  String get welcomeSubPaid => 'Her şey açık. Her günü kendi hızında yaşa.';

  @override
  String get welcomeAll30 => '30 günün tamamı';

  @override
  String get welcomeMira => 'Sınırsız Mira';

  @override
  String get welcomeAnalysis => 'Tam ilişki analizi';

  @override
  String welcomeCoinsAdded(int count) {
    return '+$count jeton eklendi';
  }

  @override
  String welcomeCoinsPending(int count) {
    return '+$count jeton yolda';
  }

  @override
  String get welcomeCta => 'Planına Git';

  @override
  String get welcomeFine => 'İstediğin zaman Ben › Abonelik\'ten yönet';

  @override
  String get homeTitle => 'Bugün';

  @override
  String get homeGreetingLate => 'Hâlâ uyanıksın';

  @override
  String get homeGreetingMorning => 'Günaydın';

  @override
  String get homeGreetingAfternoon => 'İyi günler';

  @override
  String get homeGreetingEvening => 'İyi akşamlar';

  @override
  String homeGreetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get homeHeroLabel => 'Temassız';

  @override
  String homeHeroUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'gün',
    );
    return '$_temp0';
  }

  @override
  String homeHeroNext(int remaining, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$target güne $remaining gün kaldı',
    );
    return '$_temp0';
  }

  @override
  String get homeHeroStart => 'Temassızlık serine bugün başla.';

  @override
  String get homeHeroStartCta => 'Bugün Başla';

  @override
  String get homePlanTitle => '30 günlük planın';

  @override
  String homePlanSub(int day) {
    return 'Ücretsiz plan 1–$day. günleri kapsar';
  }

  @override
  String get homeMiraTitle => 'Mira ile konuş';

  @override
  String homeMiraFreeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu gece $count ücretsiz mesajın kaldı',
      zero: 'Bu gece ücretsiz mesajın kalmadı',
    );
    return '$_temp0';
  }

  @override
  String get homeMiraUnlimited => 'İstediğin zaman, sınırsız';

  @override
  String get homeSosTitle => 'Ona yazmak üzere misin?';

  @override
  String get homeSosSub => 'Önce dur. SOS her zaman ücretsiz.';

  @override
  String get homeUpsellTitle => '4. gün Premium\'a dahil';

  @override
  String get homeUpsellTryFree => 'Ücretsiz dene';

  @override
  String get homeUpsellSeePlans => 'Planları gör';

  @override
  String homeTrialTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ücretsiz deneme: $count gün kaldı',
    );
    return '$_temp0';
  }

  @override
  String get homeTrialSub => 'Aboneliğini gör';

  @override
  String coinChipSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jeton. Jetonları aç',
    );
    return '$_temp0';
  }

  @override
  String get tabHome => 'Ana Sayfa';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabCoach => 'Koç';

  @override
  String get tabMe => 'Ben';

  @override
  String get sosButton => 'SOS';

  @override
  String get sosButtonSemantics => 'SOS, her zaman ücretsiz';

  @override
  String get coachTitle => 'Mira';

  @override
  String get coachGreeting => 'Merhaba. Buradayım. Bu gece nasıl geçiyor?';

  @override
  String get coachHint => 'Mira\'ya yaz';

  @override
  String get coachSend => 'Gönder';

  @override
  String coachMeter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu gece $count ücretsiz mesajın kaldı',
      zero: 'Bu gece ücretsiz mesajın kalmadı',
    );
    return '$_temp0';
  }

  @override
  String get coachGetMore => 'Daha Fazla';

  @override
  String get coachSosMode => 'SOS modu · sınır yok';

  @override
  String get coachTyping => 'Mira yazıyor';

  @override
  String get coachError => 'Mira cevap veremedi. Mesajın hâlâ burada.';

  @override
  String get limitSheetLabel => 'Mesaj sınırı';

  @override
  String get limitTitle => 'Mira hâlâ burada.';

  @override
  String limitBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu gecenin $count ücretsiz mesajını kullandın.',
    );
    return '$_temp0';
  }

  @override
  String get limitPremium => 'Premium ile Konuşmaya Devam Et';

  @override
  String limitPremiumTrialNote(int days) {
    return '$days günlük ücretsiz deneme dahil.';
  }

  @override
  String limitCoins(int count, int cost) {
    return '$cost Jetona $count Mesaj Daha';
  }

  @override
  String get limitGetCoins => 'Jeton Al';

  @override
  String limitWait(String time) {
    return 'Saat $time\'e Kadar Bekle';
  }

  @override
  String get limitSos => 'Şu an zorlanıyor musun? SOS her zaman ücretsiz.';

  @override
  String limitCreditsAdded(int count) {
    return '$count mesaj eklendi';
  }

  @override
  String get coinsTitle => 'Jetonlar';

  @override
  String coinsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jeton',
    );
    return '$_temp0';
  }

  @override
  String get coinsGetHeader => 'Jeton al';

  @override
  String coinsPackTitle(int count) {
    return '$count jeton';
  }

  @override
  String coinsPackBonus(int count) {
    return '+$count hediye';
  }

  @override
  String coinsBestValueBonus(int count) {
    return 'En avantajlı · +$count hediye';
  }

  @override
  String get coinsBestValue => 'En avantajlı';

  @override
  String get coinsUnlockHeader => 'Neleri açabilirsin';

  @override
  String coinsItemMsgs(int count) {
    return 'Mira ile $count mesaj daha';
  }

  @override
  String get coinsItemPlanDay => 'Bir plan gününü aç';

  @override
  String get coinsItemAnalysis => 'Tam ilişki analizi';

  @override
  String coinsCrossSell(int count) {
    return 'Premium\'a her ay $count jeton dahil';
  }

  @override
  String get coinsAdding => 'Jetonların ekleniyor…';

  @override
  String get coinsOnTheWay => 'Jetonların yolda. Yenilemek için aşağı çek.';

  @override
  String coinsAdded(int count) {
    return '+$count jeton eklendi';
  }

  @override
  String get coinsError => 'Jeton paketleri yüklenemedi.';

  @override
  String get sosTitle => 'Dur. Nefes al.';

  @override
  String get sosBreatheIn => 'Nefes al';

  @override
  String get sosBreatheOut => 'Nefes ver';

  @override
  String sosBodyStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count gündür ona ulaşmadın. Önümüzdeki on dakikayı birlikte atlatalım.',
    );
    return '$_temp0';
  }

  @override
  String get sosBody =>
      'Şu an hiçbir şeye karar vermek zorunda değilsin. Önümüzdeki on dakikayı birlikte atlatalım.';

  @override
  String get sosTalk => 'Mira ile Konuş';

  @override
  String get sosUrgent => 'Acil Yardıma İhtiyacım Var';

  @override
  String get sosFree => 'SOS her zaman ücretsiz.';

  @override
  String get crisisSheetLabel => 'Kriz desteği';

  @override
  String get crisisTitle => 'Bununla tek başına başa çıkmak zorunda değilsin.';

  @override
  String get crisisBody =>
      'Kendine zarar verebileceğini düşünüyorsan, lütfen hemen gerçek bir insana ulaş.';

  @override
  String get crisisCallEmergency => 'Acil Servisi Ara';

  @override
  String get crisisCallHelpline => 'Yardım Hattını Ara';

  @override
  String crisisNumbers(String emergency) {
    return 'Acil $emergency';
  }

  @override
  String crisisNumbersHelpline(String emergency, String helpline) {
    return 'Acil $emergency · Yardım hattı $helpline';
  }

  @override
  String get planTitle => '30 Günün';

  @override
  String get planNotReady => 'Günlük planın hazırlanıyor. Birazdan tekrar bak.';

  @override
  String get meTitle => 'Ben';

  @override
  String get meStatusFree => 'Ücretsiz plan';

  @override
  String get meStatusTrial => 'Ücretsiz deneme';

  @override
  String get meStatusPremium => 'Premium';

  @override
  String meFreeCardTitleTrial(int days) {
    return 'Premium\'u $days gün ücretsiz dene';
  }

  @override
  String get meFreeCardTitle => 'Premium\'a geç';

  @override
  String get meFreeCardBody => '30 günün tamamı, sınırsız Mira, tam analiz.';

  @override
  String get meTryFree => 'Ücretsiz Dene';

  @override
  String get meSeePlans => 'Planları Gör';

  @override
  String get meSubscriptionHeader => 'Abonelik';

  @override
  String get mePlan => 'Plan';

  @override
  String get mePlanYearlyTrial => 'Yıllık · Ücretsiz deneme';

  @override
  String get mePlanYearly => 'Yıllık';

  @override
  String get mePlanMonthly => 'Aylık';

  @override
  String get mePlanPremium => 'Premium';

  @override
  String get meRenews => 'Yenilenme';

  @override
  String get meEnds => 'Bitiş';

  @override
  String get meManage => 'Aboneliği Yönet';

  @override
  String get meCancel => 'Aboneliği İptal Et';

  @override
  String get meBillingIssue =>
      'Ödemende bir sorun var. Premium\'u korumak için App Store\'dan güncelle.';

  @override
  String get meAccountHeader => 'Hesap';

  @override
  String get meCoins => 'Jetonlar';

  @override
  String get meRestore => 'Satın Alımları Geri Yükle';

  @override
  String get meSupport => 'Destekle İletişime Geç';

  @override
  String onbStep(int step, int total) {
    return 'Adım $step / $total';
  }

  @override
  String get onbContinue => 'Devam Et';

  @override
  String get onbSkip => 'Geç';

  @override
  String get onbLanguageTitle => 'Hangi dili tercih edersin?';

  @override
  String get onbLanguageSub => 'Daha sonra Ayarlar’dan değiştirebilirsin.';

  @override
  String get onbLanguageEn => 'English';

  @override
  String get onbLanguageTr => 'Türkçe';

  @override
  String get onbWhatTitle => 'Ne oldu?';

  @override
  String get onbWhatSub => 'Yanlış cevap yok.';

  @override
  String get whatTheyEnded => 'O bitirdi';

  @override
  String get whatIEnded => 'Ben bitirdim';

  @override
  String get whatMutual => 'Karşılıklıydı';

  @override
  String get whatComplicated => 'Karmaşık';

  @override
  String get onbDetailsTitle => 'İstersen biraz daha';

  @override
  String get onbDetailsSub =>
      'İkisi de isteğe bağlı. Onun adını sadece sen görürsün.';

  @override
  String get onbYourName => 'Adın';

  @override
  String get onbExName => 'Onun adı';

  @override
  String get onbExNameHint => 'Bunu sadece sen görürsün';

  @override
  String get onbLength => 'Ne kadar birlikteydiniz?';

  @override
  String get onbDone => 'Tamam';

  @override
  String get lenLt6m => '6 aydan az';

  @override
  String get len6to12m => '6–12 ay';

  @override
  String get len1to3y => '1–3 yıl';

  @override
  String get lenGt3y => '3 yıldan fazla';

  @override
  String get onbFeelingsTitle => 'Şu an nasılsın?';

  @override
  String get onbMoodLow => 'Zar zor dayanıyorum';

  @override
  String get onbMoodHigh => 'İyiyim';

  @override
  String onbMoodSemantics(int value) {
    return 'Ruh hâli 10 üzerinden $value';
  }

  @override
  String get onbFeelingsSub =>
      'Bugün en çok ne hissediyorsun? İstediklerini seç.';

  @override
  String get feelSad => 'Üzgün';

  @override
  String get feelLonely => 'Yalnız';

  @override
  String get feelAnxious => 'Kaygılı';

  @override
  String get feelAngry => 'Öfkeli';

  @override
  String get feelNumb => 'Hissiz';

  @override
  String get feelConfused => 'Kafası karışık';

  @override
  String get feelRelieved => 'Rahatlamış';

  @override
  String get onbAttachTitle => 'Bunlar senin için ne kadar doğru?';

  @override
  String get onbAttachSub => 'Bir başlangıç noktası, teşhis değil.';

  @override
  String get attachQ0 => 'Beni unutacağından endişeleniyorum.';

  @override
  String get attachQ1 => 'Kimseye ihtiyaç duymamayı tercih ederim.';

  @override
  String get attachQ2 =>
      'Söyleyebileceklerimi kafamda tekrar tekrar kuruyorum.';

  @override
  String get onbGoalsTitle => 'Şu an en çok ne istiyorsun?';

  @override
  String get onbGoalsSub => 'En fazla üç tane seç. İlki odağın olur.';

  @override
  String get goalNoContact => 'Ona yazmayı bırakmak';

  @override
  String get goalCalm => 'Daha iyi uyumak';

  @override
  String get goalSelfWorth => 'Yeniden kendim gibi hissetmek';

  @override
  String get goalUnderstand => 'Neyin ters gittiğini anlamak';

  @override
  String get onbBuildingTitle => 'Planın hazırlanıyor';

  @override
  String get onbBuildStep1 => 'Cevapların okunuyor';

  @override
  String get onbBuildStep2 => 'İlk adımların seçiliyor';

  @override
  String get onbBuildStep3 => 'Mira senin için hazırlanıyor';

  @override
  String get attachSecure => 'Oldukça güvenli';

  @override
  String get attachAnxious => 'Kaygılıya yakın';

  @override
  String get attachAvoidant => 'Kaçıngana yakın';

  @override
  String get attachFearful => 'Kaygılı ve kaçıngan';

  @override
  String get focusNoContact => 'Temassızlık';

  @override
  String get focusCalm => 'Daha iyi uyku';

  @override
  String get focusSelfWorth => 'Öz değer';

  @override
  String get focusUnderstand => 'Olanları anlamak';

  @override
  String planReadyTitleNamed(String name) {
    return '$name, planın hazır.';
  }

  @override
  String paywallSubNamed(String name) {
    return '$name, planının tamamı ve zorlandığın her an Mira.';
  }

  @override
  String paywallBenefitPlanSubFocus(String focus, int day) {
    return 'Odak: $focus. Ücretsiz plan $day. günden sonra durur.';
  }

  @override
  String planSubtitle(int day) {
    return '30 günün $day. günü';
  }

  @override
  String planDoneCount(int done) {
    return '30 günden $done tanesi tamam';
  }

  @override
  String get planStageWeek1 => '1. hafta';

  @override
  String get planStageWeek2 => '2. hafta';

  @override
  String get planStageWeek3 => '3. hafta';

  @override
  String get planStageRebuild => 'Yeniden Kurulum';

  @override
  String planRowDone(int day) {
    return '$day. gün · Tamamlandı';
  }

  @override
  String planRowToday(int day, int minutes) {
    return '$day. gün · Bugün · $minutes dk';
  }

  @override
  String planRowOpensAt(int day, String time) {
    return '$day. gün · $time’de açılır';
  }

  @override
  String planRowAfter(int day, int prev) {
    return '$day. gün · $prev. günden sonra';
  }

  @override
  String planRowLocked(int day) {
    return '$day. gün · Premium';
  }

  @override
  String planWaitingToast(String time) {
    return 'Bu gün $time’de açılır';
  }

  @override
  String planAfterToast(int prev) {
    return 'Önce $prev. günü bitir';
  }

  @override
  String get planError => 'Planın yüklenemedi.';

  @override
  String get planFinished => '30 günün hepsini tamamladın.';

  @override
  String taskTitle(int day) {
    return '$day. gün';
  }

  @override
  String taskEntryLabel(int n) {
    return '$n';
  }

  @override
  String get taskEntryHint => 'Buraya yaz';

  @override
  String taskComplete(int day) {
    return '$day. Günü Tamamla';
  }

  @override
  String get taskPrivate => 'Yazdıklarını sadece sen görebilirsin.';

  @override
  String get taskDoneNote => 'Bu günü tamamladın.';

  @override
  String get taskNotOpen => 'Bu gün henüz açılmadı.';

  @override
  String get taskError => 'Bu gün yüklenemedi.';

  @override
  String get taskSaveError => 'Kaydedilemedi. Cevapların hâlâ burada.';

  @override
  String dayCompleteTitle(int day) {
    return '$day. gün tamamlandı';
  }

  @override
  String get dayCompleteBody => 'Bugün kendin için oradaydın.';

  @override
  String dayCompleteNext(int day, String time) {
    return '$day. gün yarın $time’de açılır.';
  }

  @override
  String dayCompleteNextLocked(int day) {
    return '$day. gün Premium’a dahil.';
  }

  @override
  String get dayCompleteAll => 'Bu 30. gündü. Kendinin yanında kaldın.';

  @override
  String get dayCompleteDone => 'Planına Dön';

  @override
  String get lockDaySheetLabel => 'Kilitli gün';

  @override
  String lockDayFoot(int day, int minutes) {
    return '$day. gün · $minutes dk';
  }

  @override
  String lockDayBody(int days) {
    return 'Ücretsiz plan 1–$days. günleri kapsar. Premium 30 günün tamamını ve Yeniden Kurulum aşamasını açar.';
  }

  @override
  String get lockDayPremium => '30 Günün Tamamını Aç';

  @override
  String lockDayTrialNote(int days) {
    return '$days gün ücretsiz';
  }

  @override
  String lockDayCoins(int day, int cost) {
    return '$day. Günü $cost Jetonla Aç';
  }

  @override
  String lockDayGetCoins(int day) {
    return '$day. Günü Açmak İçin Jeton Al';
  }

  @override
  String lockDayUnlocked(int day) {
    return '$day. gün açıldı';
  }

  @override
  String get draftTitle => 'Taslak Hapsi';

  @override
  String get draftSub =>
      'Göndermek istediğini yaz. 24 saat kilitli kalır. O zaman hâlâ göndermek istersen burada olacak.';

  @override
  String get draftHint => 'Ne söylemek istiyorsun?';

  @override
  String get draftFieldLabel => 'Mesajın';

  @override
  String get draftLock => '24 Saat Kilitle';

  @override
  String get draftLockedToast => '24 saat kilitlendi';

  @override
  String get draftLockedHeader => 'Kilitli';

  @override
  String get draftReadyHeader => 'Hazır';

  @override
  String get draftLockedRow => 'Kilitli taslak';

  @override
  String draftWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kelime',
    );
    return '$_temp0';
  }

  @override
  String draftUnlocksIn(String time) {
    return '$time sonra açılır';
  }

  @override
  String get draftReadyRow => 'Okumaya hazır';

  @override
  String get draftUnlock => 'Kilidi Aç';

  @override
  String get draftCopy => 'Metni Kopyala';

  @override
  String get draftCopied => 'Kopyalandı';

  @override
  String get draftDelete => 'Kalıcı Olarak Sil';

  @override
  String get draftDeleteTitle => 'Bu taslak kalıcı olarak silinsin mi?';

  @override
  String get draftDeleteBody => 'Tamamen silinecek. Bu işlem geri alınamaz.';

  @override
  String get draftDeleted => 'Silindi';

  @override
  String get draftStillLocked => 'Hâlâ kilitli. Biraz daha zaman tanı.';

  @override
  String get draftEmpty => 'Şu an kilitli bir şey yok.';

  @override
  String get draftError => 'Kilitlenemedi. Metnin hâlâ burada.';

  @override
  String get draftListError => 'Taslakların yüklenemedi.';

  @override
  String get draftSheetLabel => 'Taslak';

  @override
  String get draftFromSos => 'SOS’ta yazıldı';

  @override
  String get draftLimitSheetLabel => 'Taslak Hapsi sınırı';

  @override
  String get draftLimitTitle => 'Ücretsiz planda günde bir taslak.';

  @override
  String get draftLimitBody =>
      'Bugünkü ücretsiz Taslak Hapsi hakkını kullandın. Metnin hâlâ burada.';

  @override
  String get draftLimitPremium => 'Premium ile Sınırsız Taslak';

  @override
  String get homeDraftTitle => 'Taslak Hapsi';

  @override
  String get homeDraftSub => 'Göndermek yerine buraya yaz';

  @override
  String get sosDraft => 'Taslak Hapsine Yaz';

  @override
  String get reminderTrialTitle => 'Denemen 2 gün sonra bitiyor';

  @override
  String reminderTrialBody(int talks, int drafts) {
    return 'Şimdiye kadar Mira ile $talks sohbet ve gönderilmemiş $drafts mesaj. Sana göre değilse istediğin zaman Ayarlar’dan iptal et.';
  }

  @override
  String get reminderTrialBodyEmpty =>
      'Ücretsiz denemen 2 gün sonra bitiyor. Sana göre değilse istediğin zaman Ayarlar’dan iptal et.';

  @override
  String get reminderEndingTitle => 'Premium’un yakında bitiyor';

  @override
  String reminderEndingBody(String date) {
    return 'Premium $date tarihinde bitiyor. Serin, planın ve SOS seninle kalır.';
  }

  @override
  String get welcomeNotifTitle => 'Hatırlatmayı açalım mı?';

  @override
  String welcomeNotifBody(String date) {
    return 'Denemen bitmeden iki gün önce, $date tarihinde tek bir bildirim göndereceğiz. Başka bir şey değil.';
  }

  @override
  String get welcomeNotifAllow => 'Bildirimlere İzin Ver';

  @override
  String get welcomeNotifDenied =>
      'Sorun değil. Daha sonra Ayarlar’dan açabilirsin.';

  @override
  String welcomeNotifOn(String date) {
    return 'Hatırlatma $date için ayarlandı';
  }

  @override
  String get trialTitle => 'Denemen';

  @override
  String trialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'gün kaldı',
    );
    return '$_temp0';
  }

  @override
  String trialFreeUntil(String date) {
    return '$date tarihine kadar ücretsiz';
  }

  @override
  String trialThen(String price) {
    return 'Ardından yıllık $price. Öncesinde istediğin zaman iptal et.';
  }

  @override
  String get trialThenNoPrice => 'Öncesinde iptal edersen ücret alınmaz.';

  @override
  String trialEndsNoCharge(String date) {
    return 'Premium $date tarihinde bitiyor. Ücret alınmayacak.';
  }

  @override
  String get trialSoFar => 'Şimdiye kadar';

  @override
  String get trialTalks => 'Mira ile sohbet';

  @override
  String get trialDrafts => 'Gönderilmeyen mesaj';

  @override
  String get trialDaysDone => 'Tamamlanan gün';

  @override
  String get trialNextTitle => 'Sırada: Yeniden Kurulum';

  @override
  String get trialNextBody =>
      '8–30. günler öz değeri ve rutinleri yeniden kurar.';

  @override
  String get trialBack => 'Bugüne Dön';

  @override
  String get trialNotActive => 'Şu an ücretsiz denemede değilsin.';

  @override
  String get winbackTitle => 'Yerini sakladık.';

  @override
  String get winbackSub => 'Serin, planın ve taslakların hâlâ burada.';

  @override
  String winbackSubStreak(int count) {
    return '$count günlük serin ve planın hâlâ burada.';
  }

  @override
  String get winbackOfferLabel => 'Geri dönen üye teklifi';

  @override
  String winbackFor(int months, String monthly) {
    return '$months ay boyunca, ardından aylık $monthly';
  }

  @override
  String winbackFine(String promo, int months, String monthly) {
    return '$months ay $promo, ardından aylık $monthly. İstediğin zaman iptal et.';
  }

  @override
  String get winbackCta => 'Planıma Devam Et';

  @override
  String get winbackNo => 'Ücretsiz Devam Et';

  @override
  String get billingIssueCta => 'Ödemeyi Güncelle';

  @override
  String get billingIssueTitle => 'Ödeme sorunu';

  @override
  String get meTrialProgress => 'Deneme İlerlemen';

  @override
  String get checkinTitle => 'Mira';

  @override
  String get checkinBody => 'Bugün nasıldı? Konuşmak istersen buradayım.';

  @override
  String get cancelSheetLabel => 'Aboneliği iptal et';

  @override
  String get cancelTitle => 'Nedenini paylaşır mısın?';

  @override
  String get cancelSub =>
      'MyEx’i geliştirmemize yardımcı olur. Bunu geçebilirsin.';

  @override
  String get cancelReasonPrice => 'Çok pahalı';

  @override
  String get cancelReasonBetter => 'Artık daha iyiyim';

  @override
  String get cancelReasonUnused => 'Kullanmıyorum';

  @override
  String get cancelReasonOther => 'Başka bir sebep';

  @override
  String cancelPriceTitle(String promo) {
    return 'Bir yıl boyunca $promo ile kal';
  }

  @override
  String get cancelPriceBody =>
      'Yarı fiyat, her şey aynı. App Store teklifi olarak uygulanır.';

  @override
  String get cancelPriceCta => 'Premium’u Daha Uygun Fiyata Koru';

  @override
  String cancelSwitchTitle(String pct) {
    return 'Yıllığa geç, $pct tasarruf et';
  }

  @override
  String cancelSwitchBody(String price) {
    return 'Aylık ödemek yerine yıllık $price.';
  }

  @override
  String get cancelSwitchCta => 'Yıllığa Geç';

  @override
  String get cancelBetter =>
      'Amaç da buydu. Serin, günlüğün ve SOS ücretsiz kalır. İstediğin zaman geri gel.';

  @override
  String get cancelUnusedTitle => 'Her gece kısa bir hatırlatma ister misin?';

  @override
  String get cancelUnusedBody => 'Saat 22:00’de Mira’dan tek bir mesaj.';

  @override
  String get cancelUnusedCta => 'Hatırlatmaları Aç';

  @override
  String get cancelCheckinOn => 'Hatırlatmalar açık. Saat 22:00’de görüşürüz.';

  @override
  String get cancelCheckinDenied =>
      'Bildirimler kapalı. Ayarlar’dan açabilirsin.';

  @override
  String get cancelOther =>
      'Bize anlattığın için teşekkürler. MyEx’i daha iyi yapmamıza yardımcı oluyor.';

  @override
  String get cancelNoteLabel =>
      'Eklemek istediğin bir şey var mı? (isteğe bağlı)';

  @override
  String get cancelContinue => 'İptale Devam Et';

  @override
  String get cancelKept => 'Premium devam ediyor. Teşekkürler.';

  @override
  String get meSwitchYearly => 'Yıllığa Geç';

  @override
  String get meTrialEnds => 'Deneme bitişi';

  @override
  String meCancelledNote(String date) {
    return 'İptal edildi. Premium $date tarihine kadar açık.';
  }

  @override
  String meDayStatus(int day, String status) {
    return '$day. gün · $status';
  }

  @override
  String get meNameFallback => 'Sen';

  @override
  String get onbHelpNow => 'Şimdi Yardım mı Lazım?';

  @override
  String get onbNameTitle => 'Sana nasıl hitap edelim?';

  @override
  String get onbNameSub =>
      'İsteğe bağlı. Sadece uygulamanın içinde kullanılır.';

  @override
  String get onbWhenTitle => 'Ne zaman bitti?';

  @override
  String get whenThisWeek => 'Bu hafta';

  @override
  String get whenWeeks => '1–4 hafta önce';

  @override
  String get whenMonths => '1–6 ay önce';

  @override
  String get whenLonger => 'Daha uzun';

  @override
  String get onbContactTitle => 'Hâlâ görüşüyor musunuz?';

  @override
  String get contactNone => 'Hayır';

  @override
  String get contactSometimes => 'Bazen';

  @override
  String get contactMostDays => 'Çoğu gün';

  @override
  String get contactShared => 'Ortak çocuğumuz ya da işimiz var';

  @override
  String get onbHardestTitle => 'En zor ne zaman?';

  @override
  String get onbHardestSub => 'İstediklerini seç.';

  @override
  String get hardLateNight => 'Gece geç saatlerde';

  @override
  String get hardMornings => 'Sabahları';

  @override
  String get hardWeekends => 'Hafta sonları';

  @override
  String get hardPosts => 'Paylaşımlarını görünce';

  @override
  String get onbMiraTitle => 'Mira gece 2’de de yanında.';

  @override
  String get onbMiraBody =>
      'SOS ise her zaman, ihtiyacın olduğu her an ücretsiz.';

  @override
  String get goalStopChecking => 'Profiline bakmayı bırakmak';

  @override
  String get focusStopChecking => 'Kontrol etmeyi bırakmak';

  @override
  String get ansAgree => 'Katılıyorum';

  @override
  String get ansNotReally => 'Pek değil';

  @override
  String get onbUnsentTitle => 'Ona söylemek istediğin bir şey var mı?';

  @override
  String get onbUnsentSub => 'Gönderilmeyecek. Taslak Hapsi’ne gider.';

  @override
  String get onbUnsentHint => 'Buraya yaz. Gönderilmeyecek.';

  @override
  String get onbUnsentSave => 'Göndermeden Kaydet';

  @override
  String get onbUnsentSaved => 'Kaydedildi. 24 saat gönderilmeden kalır.';

  @override
  String get onbCheckinTitle => 'En zor anında bir hatırlatma ister misin?';

  @override
  String onbCheckinSub(String time) {
    return 'Saat $time’de Mira’dan tek bir mesaj. Saati değiştirebilirsin.';
  }

  @override
  String get onbCheckinChange => 'Saati Değiştir';

  @override
  String get onbCheckinAllow => 'Hatırlatmalara İzin Ver';

  @override
  String onbCheckinOn(String time) {
    return 'Hatırlatmalar $time için açık';
  }

  @override
  String onbBuildFocus(String focus) {
    return 'Odağına göre ayarlanıyor: $focus';
  }

  @override
  String onbBuildHardest(String time) {
    return 'En zor anın için plan yapılıyor: $time';
  }

  @override
  String onbBuildDay1(int minutes) {
    return '1. gün seçiliyor: $minutes dakika, bu gece';
  }

  @override
  String onbBuildTrack(String track) {
    return 'Yolun belirleniyor: $track';
  }

  @override
  String get planReadyWhen => 'Ne zaman bitti';

  @override
  String get planReadyTrack => 'Yolun';

  @override
  String get planTrackNoContact => 'Temassızlık';

  @override
  String get planTrackLowContact => 'Az temas (ortak çocuk ya da iş)';

  @override
  String get planReadyFirstDays => 'İlk 3 günün';

  @override
  String planReadyDayRow(int day) {
    return '$day. gün';
  }

  @override
  String planReadyTonight(int minutes) {
    return 'Bu gece · $minutes dk';
  }

  @override
  String planReadySupport(String time) {
    return '$time: Mira burada, SOS da her zaman ücretsiz.';
  }

  @override
  String get planReadyLocked => '4–30. günler Premium ile açılır.';

  @override
  String paywallSubTrial(int days, String price) {
    return '$days gün ücretsiz, ardından yıllık $price.';
  }

  @override
  String paywallSubYearly(String price) {
    return 'Yıllık $price. İstediğin zaman iptal et.';
  }

  @override
  String paywallSubMonthly(String price) {
    return 'Aylık $price. Ücretsiz deneme yok.';
  }

  @override
  String get paywallNoPaymentToday => 'Bugün ödeme yok';

  @override
  String get paywallTimelineBuild => 'Planını oluştur';

  @override
  String get paywallTimelineBuildBody => 'Tamamlandı. Cevaplarına göre.';

  @override
  String get paywallNotifOff => 'MyEx için bildirimler kapalı.';

  @override
  String get paywallOpenSettings => 'Ayarları Aç';

  @override
  String get paywallHowCancel => 'Nasıl iptal ederim?';

  @override
  String get paywallHowCancelIos =>
      'Ayarlar › adın › Abonelikler › MyEx › Aboneliği İptal Et. Bir dakikadan kısa sürer. Serin ve günlüğün kalır.';

  @override
  String get paywallHowCancelAndroid =>
      'Play Store › profilin › Ödemeler ve abonelikler › Abonelikler › MyEx › İptal et. Bir dakikadan kısa sürer. Serin ve günlüğün kalır.';

  @override
  String get tabJournal => 'Günlük';

  @override
  String get commonSaveFailed => 'Kaydedilemedi. Tekrar dene.';

  @override
  String get homeMoodTitle => 'Şu an nasılsın?';

  @override
  String homeMoodDone(String mood) {
    return 'Bugün kendini $mood hissettin.';
  }

  @override
  String get homeMoodWrite => 'Bunu Yaz';

  @override
  String get homeMoodAgain => 'Tekrar Kaydet';

  @override
  String get homeDayHeader => 'Günün';

  @override
  String get homeJournalTitle => 'Günlük';

  @override
  String homeJournalSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Şimdiye kadar $count yazı',
      zero: 'Bu gecenin ilk satırını yaz',
    );
    return '$_temp0';
  }

  @override
  String get homeWeekTitle => 'Bu hafta';

  @override
  String get homeWeekSee => 'İçgörüler';

  @override
  String get homeHeroChooseGoal => 'Hedef Seç';

  @override
  String homeHeroChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kendini seçtiğin $count gün',
    );
    return '$_temp0';
  }

  @override
  String get moodLevel1 => 'ağır';

  @override
  String get moodLevel2 => 'düşük';

  @override
  String get moodLevel3 => 'idare eder';

  @override
  String get moodLevel4 => 'daha hafif';

  @override
  String get moodLevel5 => 'iyi';

  @override
  String get moodSheetFeelings => 'İçinde neler var?';

  @override
  String get moodSheetNote =>
      'Eklemek istediğin bir şey var mı? (isteğe bağlı)';

  @override
  String get moodSheetSave => 'Kaydet';

  @override
  String get moodSaved => 'Kaydedildi. Kendine baktığın için teşekkürler.';

  @override
  String moodScaleSemantics(int level, String word) {
    return 'Ruh hâli 5 üzerinden $level, $word';
  }

  @override
  String get moodWordHeartbroken => 'Kalbi kırık';

  @override
  String get moodWordLonely => 'Yalnız';

  @override
  String get moodWordAngry => 'Öfkeli';

  @override
  String get moodWordAnxious => 'Kaygılı';

  @override
  String get moodWordNumb => 'Hissiz';

  @override
  String get moodWordConfused => 'Kafası karışık';

  @override
  String get moodWordTired => 'Yorgun';

  @override
  String get moodWordHopeful => 'Umutlu';

  @override
  String get moodWordCalm => 'Sakin';

  @override
  String get moodWordRelieved => 'Rahatlamış';

  @override
  String get moodWordProud => 'Gururlu';

  @override
  String get moodWordGrateful => 'Minnettar';

  @override
  String get journalTitle => 'Günlük';

  @override
  String get journalNew => 'Yeni Yazı';

  @override
  String get journalSearch => 'Günlüğünde ara';

  @override
  String get journalFilterAll => 'Tümü';

  @override
  String get journalKindReflection => 'Düşünce';

  @override
  String get journalKindLetter => 'Gönderilmeyen mektup';

  @override
  String get journalKindGratitude => 'Şükran';

  @override
  String get journalKindList => 'Liste';

  @override
  String get journalPromptToday => 'Bu gecenin sorusu';

  @override
  String get journalWrite => 'Yaz';

  @override
  String get journalEmptyTitle => 'Sayfaların sana özel.';

  @override
  String get journalEmptyBody =>
      'Yüksek sesle söyleyemediklerini yaz. Bunu yalnızca sen görebilirsin.';

  @override
  String get journalEmptyCta => 'İlk Yazını Yaz';

  @override
  String journalNoResults(String query) {
    return '“$query” ile eşleşen bir şey yok.';
  }

  @override
  String get journalPrivate => 'Günlüğünü yalnızca sen görebilirsin.';

  @override
  String get journalEditorHint => 'İstediğin yerden başla.';

  @override
  String get journalSave => 'Kaydet';

  @override
  String get journalAnotherPrompt => 'Başka Bir Soru';

  @override
  String get journalMoodOptional =>
      'Yazmak sana nasıl hissettirdi? (isteğe bağlı)';

  @override
  String get journalDelete => 'Yazıyı Sil';

  @override
  String get journalDeleteTitle => 'Bu yazı silinsin mi?';

  @override
  String get journalDeleteBody => 'Geri getirilemez.';

  @override
  String get journalDiscardTitle => 'Bu yazıdan vazgeçilsin mi?';

  @override
  String get journalDiscardBody => 'Yazdıkların kaydedilmeyecek.';

  @override
  String get journalDiscard => 'Vazgeç';

  @override
  String get journalKeepWriting => 'Yazmaya Devam Et';

  @override
  String get journalSaved => 'Günlüğüne kaydedildi.';

  @override
  String get journalPromptReflection1 => 'Bugün seni en çok ne zorladı?';

  @override
  String get journalPromptReflection2 => 'Neyi özlüyorsun, neyi özlemiyorsun?';

  @override
  String get journalPromptReflection3 =>
      'Bu hafta kendini en çok ne zaman kendin gibi hissettin?';

  @override
  String get journalPromptReflection4 =>
      'Bunu yaşayan bir arkadaşına ne söylerdin?';

  @override
  String get journalPromptLetter1 => 'Göndermeyeceğin bir mektup';

  @override
  String get journalPromptLetter2 => 'Söyleyemediğin şeyler';

  @override
  String get journalPromptLetter3 => 'Kendi sözlerinle veda';

  @override
  String get journalPromptGratitude1 => 'Bugün yolunda giden küçük bir şey';

  @override
  String get journalPromptGratitude2 => 'Senin için orada olan biri';

  @override
  String get journalPromptGratitude3 => 'Bugün kendin için yaptığın bir şey';

  @override
  String get journalPromptList1 => 'Özlemeyeceğin üç şey';

  @override
  String get journalPromptList2 => 'Yeniden senin olan beş şey';

  @override
  String get journalPromptList3 => 'Tek başına denemek istediğin şeyler';

  @override
  String get noContactTitle => 'İletişimsizlik';

  @override
  String get noContactIntroTitle => 'Kendine alan tanı.';

  @override
  String get noContactIntroBody =>
      'Mesaj yok, profiline bakmak yok. Bir hedef seç. Kayarsan nazikçe yeniden başlarsın ve her gün yine sayılır.';

  @override
  String get noContactGoal => 'Hedef';

  @override
  String noContactGoalDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün',
    );
    return '$_temp0';
  }

  @override
  String get noContactStart => 'Bugün Başla';

  @override
  String noContactOfGoal(String goal) {
    return '$goal hedefinden';
  }

  @override
  String noContactNext(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sonraki kilometre taşına $count gün',
      one: 'Sonraki kilometre taşı yarın',
    );
    return '$_temp0';
  }

  @override
  String get noContactGoalReached =>
      'Hedefe ulaştın. İçinden geliyorsa devam et.';

  @override
  String get noContactChosen => 'Kendini seçtiğin günler';

  @override
  String get noContactChosenNote =>
      'Her serinin her gününü sayar. Hiç sıfırlanmaz.';

  @override
  String get noContactBest => 'En uzun seri';

  @override
  String get noContactRuns => 'Seriler';

  @override
  String get noContactMilestones => 'Kilometre taşları';

  @override
  String get noContactMilestone1 => 'İlk gece';

  @override
  String get noContactMilestone3 => 'Birçokları için en zor kısım';

  @override
  String get noContactMilestone7 => 'Kendini seçtiğin bir hafta';

  @override
  String get noContactMilestone14 => 'Yeni alışkanlıklar kök salıyor';

  @override
  String get noContactMilestone30 => 'Bir aylık alan';

  @override
  String get noContactMilestone60 => 'İki ay, kendi ritmin';

  @override
  String get noContactMilestone90 => 'Yeni bir normal';

  @override
  String get noContactHistory => 'Önceki seriler';

  @override
  String noContactRun(int days, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün',
    );
    return '$_temp0 · $range';
  }

  @override
  String get noContactReachedOut => 'İletişime Geçtim';

  @override
  String get noContactRestartTitle => 'Sorun değil.';

  @override
  String noContactRestartBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days günün',
    );
    return 'Yazmış olman yaptıklarını silmez. $_temp0 hâlâ sayılıyor.';
  }

  @override
  String get noContactReflection =>
      'Ne oldu? Bir dahaki sefere ne yardımcı olur? (isteğe bağlı)';

  @override
  String get noContactRestart => 'Bugün Yeniden Başla';

  @override
  String get noContactRestarted =>
      'Yeni seri başladı. Günlerin hâlâ sayılıyor.';

  @override
  String get insightsTitle => 'İçgörüler';

  @override
  String get insightsMood => 'Son 14 günün';

  @override
  String get insightsNonLinear =>
      'İyileşme düz bir çizgi değil. İnişler ve çıkışlar da bunun parçası.';

  @override
  String get insightsWeek => 'Bu hafta';

  @override
  String insightsWeekCheckins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kez kendine baktın.',
      zero: 'Bu hafta henüz kayıt yapmadın.',
    );
    return '$_temp0';
  }

  @override
  String get insightsWeekUp =>
      'Günlerin bir önceki haftadan biraz daha hafifti.';

  @override
  String get insightsWeekDown =>
      'Bu hafta geçen haftadan daha ağırdı. Bu da sürecin bir parçası.';

  @override
  String get insightsWeekSame =>
      'Geçen haftayla hemen hemen aynı. İstikrar da önemli.';

  @override
  String insightsWeekFeelings(String feelings) {
    return 'En sık: $feelings.';
  }

  @override
  String get insightsCheckins => 'Kayıt';

  @override
  String get insightsEntries => 'Günlük yazısı';

  @override
  String get insightsPlanDays => 'Tamamlanan gün';

  @override
  String get insightsEmptyTitle => 'Örüntün burada görünecek.';

  @override
  String get insightsEmptyBody =>
      'Birkaç gün kayıt yap, haftalarının nasıl ilerlediğini gör.';

  @override
  String get insightsCheckInNow => 'Şimdi Kaydet';

  @override
  String insightsChartSemantics(String summary) {
    return 'Son 14 gündeki ruh hâli. $summary';
  }

  @override
  String get coachAiLabel => 'Yapay zekâ · terapi değil';

  @override
  String get coachSuggestTitle => 'Nereden başlayacağını bilmiyor musun?';

  @override
  String get coachSuggest1 => 'Şu an ona yazmak istiyorum.';

  @override
  String get coachSuggest2 => 'Sürekli profiline bakıyorum.';

  @override
  String get coachSuggest3 => 'Bu gece uyuyamıyorum.';

  @override
  String get coachSuggest4 => 'Neden hâlâ onu özlüyorum?';

  @override
  String get coachNew => 'Yeni Sohbet';

  @override
  String get coachNewTitle => 'Yeni bir sohbet başlasın mı?';

  @override
  String get coachNewBody =>
      'Mira baştan başlar. Önceki mesajlar artık burada görünmez.';

  @override
  String get coachNewConfirm => 'Yeni Başlat';

  @override
  String get meAppearance => 'Görünüm';

  @override
  String get meAppearanceSystem => 'Otomatik';

  @override
  String get meAppearanceLight => 'Açık';

  @override
  String get meAppearanceDark => 'Gece';

  @override
  String get meProgressHeader => 'İlerlemen';

  @override
  String get draftJailEmptyTitle => 'Şu an kilitli bir şey yok.';

  @override
  String get draftJailEmptyBody =>
      'Yazma isteği geldiğinde önce buraya yaz. Kararı yarın verebilirsin.';

  @override
  String get paywallIncludes => 'Premium’da her şey';

  @override
  String get paywallBrandBadge => 'Premium';

  @override
  String get paywallMedalMira => 'Mira, her an';

  @override
  String get paywallMedalPlan => '30 günün tamamı';

  @override
  String get paywallMedalAnalysis => 'Tam analiz';

  @override
  String get paywallMedalDrafts => 'Sınırsız Taslak Hapsi';

  @override
  String paywallMedalCoins(int count) {
    return 'Ayda +$count jeton';
  }

  @override
  String get journalTabEntries => 'Yazılar';

  @override
  String get journalTabCalendar => 'Takvim';

  @override
  String get journalTabPrompts => 'Sorular';

  @override
  String get journalLandscape => 'Duygu haritası';

  @override
  String get journalDayFelt => 'Hissettiklerin';

  @override
  String get journalDayNoMood => 'Bu gün kayıt yok.';

  @override
  String get journalDayEmpty => 'Bu gün bir şey yazılmadı.';

  @override
  String get journalDayWrite => 'Bugünü Yaz';

  @override
  String journalCalendarDay(String date, String state) {
    return '$date, $state';
  }

  @override
  String get journalCalendarWrote => 'bir şey yazıldı';

  @override
  String get journalCalendarNothing => 'kayıt yok';

  @override
  String get journalCollections => 'Rehberli günlükler';

  @override
  String get journalCollectionsSub =>
      'Bir tür seç, sonra bir soru. Ya da yazmaya başla.';

  @override
  String get journalCollReflection => 'Bugünü anlamlandır';

  @override
  String get journalCollLetter => 'Göndermeden söyle';

  @override
  String get journalCollGratitude => 'Her gün küçük bir iyi şey';

  @override
  String get journalCollList => 'Az çaba, gerçek netlik';

  @override
  String journalPromptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count soru',
    );
    return '$_temp0';
  }

  @override
  String get journalFreeWrite => 'Serbest Yaz';

  @override
  String get insightsPeriodWeek => 'Hafta';

  @override
  String get insightsPeriodMonth => 'Ay';

  @override
  String get insightsMoodWeek => 'Son 7 günün';

  @override
  String get insightsMoodMonth => 'Son 30 günün';

  @override
  String get insightsWords => 'Yazılan kelimeler';

  @override
  String insightsWordsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kelime',
      zero: 'Henüz kelime yok',
    );
    return '$_temp0';
  }

  @override
  String get insightsFeelingsTitle => 'En çok hissettiklerin';

  @override
  String get insightsFeelingsEmpty =>
      'Kayıt yaparken bir duygu seç, burada görünsün.';
}

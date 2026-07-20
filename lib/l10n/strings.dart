import '../state/settings_provider.dart' show AppLanguage;

/// Uygulamanın tüm arayüz metinleri (ders içeriği hariç — o
/// CourseRepository üzerinden dile göre ayrı JSON'dan yüklenir).
/// SettingsProvider dil değiştirdiğinde [setLanguage] çağrılır ve
/// uygulama kökten yeniden kurulur (bkz. app.dart), böylece her widget
/// güncel dili okur.
class Strings {
  Strings._();

  static AppLanguage _lang = AppLanguage.tr;

  static void setLanguage(AppLanguage lang) => _lang = lang;

  static bool get _isEn => _lang == AppLanguage.en;

  static bool get isEnglish => _isEn;

  static String _t(String tr, String en) => _isEn ? en : tr;

  // Sekmeler / kabuk
  static String get tabLearn => _t('Öğren', 'Learn');
  static String get tabAlphabet => _t('Alfabe', 'Alphabet');
  static String get tabReview => _t('Tekrar Çalış', 'Review');
  static String get tabFriends => _t('Arkadaşlar', 'Friends');
  static String get tabBadges => _t('Rozetler', 'Badges');
  static String get tabSky => _t('Gökyüzü', 'Sky');
  static String get skyWatchHint =>
      _t('Arkada uçan uçakları izle', 'Watch the planes flying in the background');
  static String get contentLoadError =>
      _t('İçerik yüklenemedi: ', 'Failed to load content: ');

  // Ders ekranı
  static String get quitLessonTitle =>
      _t('Dersten çıkılsın mı?', 'Quit the lesson?');
  static String get quitLessonBody => _t(
      'İlerlemen bu ders için kaydedilmeyecek.',
      'Your progress for this lesson won\'t be saved.');
  static String get keepGoing => _t('Devam et', 'Keep going');
  static String get quit => _t('Çık', 'Quit');

  // Sonuç ekranı
  static String get lessonCompleted =>
      _t('Ders tamamlandı!', 'Lesson completed!');
  static String get notThisTime => _t('Bu sefer olmadı', 'Not this time');
  static String failMessage(int pct) => _t(
      'Geçmek için en az %$pct doğru gerekiyor. Tekrar dene, bu sefer başaracaksın!',
      'You need at least $pct% correct to pass. Try again, you\'ll get it this time!');
  static String get xpEarnedLabel => _t('KAZANILAN XP', 'XP EARNED');
  static String get accuracyLabel => _t('İSABET', 'ACCURACY');
  static String get backToMap => _t('HARİTAYA DÖN', 'BACK TO MAP');
  static String get tryAgain => _t('TEKRAR DENE', 'TRY AGAIN');
  static String get backToMapLink => _t('Haritaya dön', 'Back to map');
  static String get reviewCompleted =>
      _t('Tekrar tamamlandı!', 'Review completed!');
  static String get backToReviewTab =>
      _t('TEKRAR SEKMESİNE DÖN', 'BACK TO REVIEW');

  // Tekrar Çalış
  static String get reviewSubtitle => _t(
      'Yanlış yaptığın sorular otomatik olarak burada birikir ve ustalaşana kadar karşına çıkar.',
      'Questions you get wrong collect here automatically and keep coming back until you master them.');
  static String get boxNew => _t('Yeni', 'New');
  static String get boxLearning => _t('Öğreniliyor', 'Learning');
  static String get boxAlmostDone => _t('Neredeyse tamam', 'Almost there');
  static String startPractice(int count) =>
      _t('PRATİĞE BAŞLA ($count)', 'START PRACTICE ($count)');
  static String get reviewEmptyTitle =>
      _t('Şu an tekrar yok!', 'Nothing to review!');
  static String get reviewEmptyBody => _t(
      'Derslerine devam et, yanlış yaptığın sorular otomatik olarak burada toplanacak.',
      'Keep going with your lessons — anything you get wrong will collect here automatically.');

  // Arkadaşlar
  static String get addFriend => _t('Arkadaş Ekle', 'Add Friend');
  static String get cancel => _t('Vazgeç', 'Cancel');
  static String get add => _t('Ekle', 'Add');
  static String rivalryBehind(String name, int diff) => _t(
      '$name seni sadece $diff XP ile geçti. Bir ders daha bitir, onu geç!',
      '$name just passed you by $diff XP. Finish one more lesson and take the lead!');
  static String get leagueLeader => _t(
      'Bu hafta lig liderisin! Zirvede kalmak için pratiğe devam et.',
      'You\'re leading the league this week! Keep practicing to stay on top.');
  static String get weeklyLeague => _t('BU HAFTA LİG', 'THIS WEEK\'S LEAGUE');
  static String get you => _t('Sen', 'You');
  static String get searchUsernameHint =>
      _t('Kullanıcı adı ara', 'Search username');
  static String get searchingLabel => _t('Aranıyor…', 'Searching…');
  static String get noSearchResults =>
      _t('Kullanıcı bulunamadı', 'No user found');
  static String get sendRequest => _t('İstek Gönder', 'Send Request');
  static String get requestSent => _t('İstek gönderildi', 'Request sent');
  static String get requestAlreadyExists => _t(
      'Zaten arkadaşsınız ya da bekleyen bir istek var',
      'You\'re already friends, or a request is already pending');
  static String get requestFailed =>
      _t('Bir şeyler ters gitti, tekrar dene', 'Something went wrong, try again');
  static String get incomingRequestsTitle =>
      _t('İSTEKLER', 'REQUESTS');
  static String get accept => _t('Kabul et', 'Accept');
  static String get decline => _t('Reddet', 'Decline');
  static String get pendingLabel => _t('Beklemede', 'Pending');
  static String get noFriendsYetTitle =>
      _t('Henüz arkadaşın yok', 'No friends yet');
  static String get noFriendsYetBody => _t(
      'Kullanıcı adıyla arayıp istek gönder, birlikte pratik yapmaya başlayın.',
      'Search by username and send a request to start practicing together.');
  static String get friendsLoadErrorTitle =>
      _t('Arkadaşlar yüklenemedi', 'Couldn\'t load friends');
  static String get friendsLoadErrorBody => _t(
      'Bağlantı ya da izin sorunu olabilir. Tekrar dene.',
      'This could be a connection or permission issue. Try again.');

  // Alfabe
  static String get alphabetSubtitle => _t(
      'ICAO fonetik alfabesinin tamamı — istediğin zaman gözden geçir.',
      'The complete ICAO phonetic alphabet — review it anytime.');

  // Egzersiz alt bilgisi / öğretici kart
  static String get correctFeedback => _t('Doğru!', 'Correct!');
  static String get correctAnswerLabel =>
      _t('Doğru cevap:', 'Correct answer:');
  static String get continueLabel => _t('DEVAM', 'CONTINUE');
  static String get checkLabel => _t('KONTROL ET', 'CHECK');
  static String get learnBadge => _t('ÖĞREN', 'LEARN');
  static String get writeYourAnswer =>
      _t('Cevabını yaz…', 'Write your answer…');
  static String get listeningPrompt =>
      _t('Dinle ve doğru anlamı seç', 'Listen and choose the correct meaning');
  static String get tapToListen => _t('Dinlemek için dokun', 'Tap to listen');

  // Ayarlar
  static String get settingsTitle => _t('Ayarlar', 'Settings');
  static String get languageLabel => _t('Dil', 'Language');
  static String get turkish => _t('Türkçe', 'Turkish');
  static String get english => _t('İngilizce', 'English');
  static String get themeLabel => _t('Renk Teması', 'Color Theme');
  static String get themeBlue => _t('Koyu Mavi', 'Dark Blue');
  static String get themeBlack => _t('Koyu Siyah', 'Dark Black');
  static String get themeLight => _t('Aydınlık', 'Light');
  static String get themePink => _t('Tatlış Pembe', 'Sweet Pink');
  static String get close => _t('Kapat', 'Close');

  // Giriş / Kayıt
  static String get welcomeTitle => _t('Hoş geldin', 'Welcome');
  static String get loginSubtitle =>
      _t('Devam etmek için giriş yap', 'Log in to continue');
  static String get emailOrUsername =>
      _t('E-posta veya kullanıcı adı', 'Email or username');
  static String get email => _t('E-posta', 'Email');
  static String get username => _t('Kullanıcı adı', 'Username');
  static String get password => _t('Şifre', 'Password');
  static String get logIn => _t('GİRİŞ YAP', 'LOG IN');
  static String get signUp => _t('KAYIT OL', 'SIGN UP');
  static String get noAccountYet =>
      _t('Hesabın yok mu? Kayıt ol', 'No account yet? Sign up');
  static String get haveAccount =>
      _t('Zaten hesabın var mı? Giriş yap', 'Already have an account? Log in');
  static String get forgotPassword => _t('Şifremi unuttum', 'Forgot password');
  static String get resetPasswordTitle =>
      _t('Şifre sıfırlama', 'Reset password');
  static String get resetPasswordBody => _t(
      'E-posta adresini yaz, sana bir sıfırlama linki gönderelim.',
      'Enter your email and we\'ll send you a reset link.');
  static String get send => _t('Gönder', 'Send');
  static String get resetEmailSent => _t(
      'Sıfırlama e-postası gönderildi, gelen kutunu kontrol et.',
      'Reset email sent, check your inbox.');
  static String get createAccountTitle =>
      _t('Hesap oluştur', 'Create account');
  static String get signUpSubtitle => _t(
      'Havacılık İngilizcesi öğrenmeye başlamak için bir hesap aç',
      'Create an account to start learning Aviation English');
  static String get usernameHint => _t(
      'Sadece harf, rakam, alt çizgi — en az 3 karakter',
      'Letters, numbers, underscore only — at least 3 characters');
  static String get passwordHint =>
      _t('En az 6 karakter', 'At least 6 characters');

  // E-posta doğrulama ekranı
  static String get verifyEmailTitle =>
      _t('E-postanı onayla', 'Verify your email');
  static String verifyEmailBody(String email) => _t(
      '$email adresine bir onay linki gönderdik. Gelen kutunu (ve spam '
      'klasörünü) kontrol et, linke tıkla, sonra aşağıdaki butona bas.',
      'We sent a verification link to $email. Check your inbox (and spam '
      'folder), tap the link, then press the button below.');
  static String get iVerified => _t('ONAYLADIM, DEVAM ET', 'I VERIFIED, CONTINUE');
  static String get resendEmail => _t('E-postayı tekrar gönder', 'Resend email');
  static String get emailResent =>
      _t('E-posta tekrar gönderildi.', 'Email resent.');
  static String get stillNotVerified => _t(
      'Henüz onaylanmamış görünüyor, e-postanı kontrol et.',
      'Still not verified — please check your email.');
  static String get signOut => _t('Çıkış yap', 'Log out');

  // Profil / hesap
  static String get account => _t('Hesap', 'Account');
  static String get loggedInAs => _t('Giriş yapan:', 'Logged in as:');

  // Giriş/kayıt hataları
  static String get errUsernameTooShort =>
      _t('Kullanıcı adı en az 3 karakter olmalı.',
          'Username must be at least 3 characters.');
  static String get errUsernameFormat => _t(
      'Kullanıcı adı sadece harf, rakam ve alt çizgi (_) içerebilir.',
      'Username can only contain letters, numbers and underscore (_).');
  static String get errUsernameTaken =>
      _t('Bu kullanıcı adı zaten alınmış.', 'This username is already taken.');
  static String get errUsernameTakenRace => _t(
      'Bu kullanıcı adı az önce başkası tarafından alındı, farklı bir tane dene.',
      'This username was just claimed by someone else — try a different one.');
  static String get errUsernameNotFound => _t(
      'Bu kullanıcı adıyla eşleşen bir hesap bulunamadı.',
      'No account matches this username.');
  static String get errEmailInUse =>
      _t('Bu e-posta zaten kayıtlı.', 'This email is already registered.');
  static String get errInvalidEmail =>
      _t('Geçersiz e-posta adresi.', 'Invalid email address.');
  static String get errWeakPassword => _t(
      'Şifre çok zayıf, en az 6 karakter olmalı.',
      'Password is too weak, must be at least 6 characters.');
  static String get errWrongCredentials =>
      _t('E-posta veya şifre hatalı.', 'Email or password is incorrect.');
  static String get errTooManyRequests => _t(
      'Çok fazla deneme yapıldı, biraz sonra tekrar dene.',
      'Too many attempts, please try again shortly.');
  static String errGeneric(String code) => _t(
      'Bir şeyler ters gitti ($code). Tekrar dener misin?',
      'Something went wrong ($code). Could you try again?');

  // Parkur seçimi (onboarding + ayarlar)
  static String get chooseTrackTitle =>
      _t('Ne öğrenmek istiyorsun?', 'What do you want to learn?');
  static String get chooseTrackSubtitle => _t(
      'Sana en uygun kelime dağarcığını gösterelim — istediğin zaman '
      'ayarlardan değiştirebilirsin.',
      'Let\'s show you the vocabulary that fits you best — you can change '
      'this anytime from settings.');
  static String get trackTechnicalTitle => _t('Teknik Personel', 'Technical Staff');
  static String get trackTechnicalDesc => _t(
      'Mühendis ve teknisyenler için: uçak yapısı, sistemler ve bakım terimleri.',
      'For engineers and technicians: aircraft structure, systems and maintenance terms.');
  static String get trackPilotTitle => _t('Pilot', 'Pilot');
  static String get trackPilotDesc => _t(
      'Telsiz frazeolojisi, ICAO alfabesi ve standart pilot ifadeleri.',
      'Radio phraseology, the ICAO alphabet and standard pilot phrases.');
  static String get trackGeneralTitle => _t('Genel / Meraklı', 'General / Enthusiast');
  static String get trackGeneralDesc => _t(
      'Uçağa binen ya da havacılığı seven herkes için temel terimler.',
      'Essential terms for anyone who flies or simply loves aviation.');
  static String get learningTrackLabel => _t('Öğrenme Alanı', 'Learning Track');
  static String get soundLabel => _t('Ses Efektleri', 'Sound Effects');
  static String get soundSubtitle => _t(
      'Doğru/yanlış cevap ve tıklama sesleri', 'Correct/wrong answer and tap sounds');
  static String get changeTrackWarning => _t(
      'Alanı değiştirince yeni bir ders içeriğine geçersin, mevcut XP ve '
      'serin korunur.',
      'Switching tracks moves you to new lesson content — your XP and '
      'streak are kept.');

  // Uygulama tanıtım turu (ilk kayıttan sonra bir kez gösterilir)
  static String get onboardNext => _t('İLERİ', 'NEXT');
  static String get onboardStart => _t('BAŞLA', 'GET STARTED');
  static String get onboardSkip => _t('Geç', 'Skip');
  static String get onboardWelcomeTitle =>
      _t('Skyphrase\'e hoş geldin!', 'Welcome to Skyphrase!');
  static String get onboardWelcomeBody => _t(
      'Havacılık İngilizcesini eğlenerek öğreneceksin. Uygulamada neyin '
      'nerede olduğunu kısaca gösterelim.',
      'You\'re about to learn Aviation English the fun way. Let\'s quickly '
      'show you where everything is.');
  static String get onboardLearnTitle => _t('Öğren sekmesi', 'Learn tab');
  static String get onboardLearnBody => _t(
      'Ana ekranın burası: ders haritasında düğümlere dokunarak ilerlersin. '
      'Bir dersi bitirince bir sonraki kilidi açılır.',
      'This is your home screen: tap the nodes on the lesson map to '
      'progress. Finishing a lesson unlocks the next one.');
  static String get onboardAlphabetTitle => _t('Alfabe sekmesi', 'Alphabet tab');
  static String get onboardAlphabetBody => _t(
      'ICAO fonetik alfabesinin tamamını (Alpha, Bravo, Charlie…) istediğin '
      'zaman buradan gözden geçirebilirsin. Kartlara dokun, akılda kalıcı '
      'bir örnek cümle görürsün.',
      'Review the entire ICAO phonetic alphabet (Alpha, Bravo, Charlie…) '
      'here anytime. Tap a card to see a short, memorable example sentence.');
  static String get onboardReviewTitle => _t('Tekrar Çalış sekmesi', 'Review tab');
  static String get onboardReviewBody => _t(
      'Yanlış yaptığın sorular otomatik olarak burada birikir ve '
      'ustalaşana kadar karşına çıkar.',
      'Questions you get wrong collect here automatically and keep coming '
      'back until you master them.');
  static String get onboardFriendsTitle => _t(
      'Arkadaşlar, seri ve ayarlar', 'Friends, streak and settings');
  static String get onboardFriendsBody => _t(
      'Arkadaş ekleyip haftalık ligde yarışabilirsin. Üstteki 🔥 günlük '
      'serini, ⚡ toplam XP\'ni gösterir. Sağ üstteki dişli simgesinden '
      'dil, tema ve öğrenme alanını değiştirebilirsin.',
      'Add friends and compete in the weekly league. The 🔥 up top shows '
      'your daily streak, ⚡ your total XP. Use the gear icon in the top '
      'right to change language, theme and your learning track.');

  // Rozetler — uçuş temalı bir ilerleme hikayesi: kalkış, irtifa kazanma,
  // uzun menzil, ünite/parkur ustalığı.
  static String get badgesSubtitle => _t(
      'İlerledikçe açılan rozetler — hepsini toplamaya çalış!',
      'Badges that unlock as you progress — try to collect them all!');
  static String get badgeLocked => _t('Kilitli', 'Locked');
  static String get badgeUnlocked => _t('Kazanıldı', 'Unlocked');
  static String get badgeFirstTakeoffTitle => _t('İlk Kalkış', 'First Takeoff');
  static String get badgeFirstTakeoffDesc =>
      _t('İlk dersini tamamla', 'Complete your first lesson');
  static String get badgeCruisingAltitudeTitle =>
      _t('Seyir İrtifası', 'Cruising Altitude');
  static String get badgeCruisingAltitudeDesc => _t(
      '3 gün üst üste pratik yaparak seyir irtifasına ulaş',
      'Reach cruising altitude with a 3-day streak');
  static String get badgeLongHaulTitle => _t('Uzun Menzil', 'Long Haul');
  static String get badgeLongHaulDesc => _t(
      '7 gün üst üste pratik yap — gerçek bir uzun menzil uçuşu!',
      'Practice 7 days in a row — a true long-haul flight!');
  static String get badgeUnitCaptainTitle => _t('Ünite Kaptanı', 'Unit Captain');
  static String get badgeUnitCaptainDesc => _t(
      'İlk üniteyi tamamen bitir', 'Finish the entire first unit');
  static String get badgeCaptainsWingsTitle =>
      _t('Kaptan Rütbesi', 'Captain\'s Wings');
  static String get badgeCaptainsWingsDesc => _t(
      'Parkurundaki tüm dersleri tamamla', 'Complete every lesson in your track');

  // Seri takvimi
  static const _monthNamesTr = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];
  static const _monthNamesEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static String monthName(int month) =>
      _t(_monthNamesTr[month - 1], _monthNamesEn[month - 1]);
  static String get streakWordLabel => _t('Seri', 'Streak');
  // Pazar (Sunday) ilk sütun olacak şekilde — mini takvim tasarımı buna göre.
  static const _weekdayInitialsTr = ['Pz', 'Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct'];
  static const _weekdayInitialsEn = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  static List<String> get weekdayInitials =>
      _isEn ? _weekdayInitialsEn : _weekdayInitialsTr;
}

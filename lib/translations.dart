// lib/translations.dart
// ============================================================
// CENTRALIZED TRANSLATIONS FILE - COMPLETE
// ============================================================

class Translations {
  static const Map<String, Map<String, String>> _translations = {
    'English': {
      // ========== APP GENERAL ==========
      'appTitle': 'Daily Quran',
      'appTitleShort': 'Daily Quran',
      'appSubtitle': 'Your Daily Quran Habit',

      // ========== SPLASH & ONBOARDING ==========
      'yourDaily': 'YOUR DAILY',
      'quranHabit': 'QURAN HABIT',
      'skip': 'Skip',
      'next': 'Next',
      'getStarted': 'Get Started',

      // ========== ONBOARDING ==========
      'onboarding1': 'Daily Quran Verses',
      'onboarding1Desc':
          'Start your day with a verse from the Quran with translation and Tafsir.',
      'onboarding2': 'Track Your Progress',
      'onboarding2Desc':
          'Monitor your reading progress and stay consistent with your Quran habit.',
      'onboarding3': 'Prayer Times & Dua',
      'onboarding3Desc':
          'Never miss a prayer and find authentic duas for every occasion.',

      // ========== HOME SCREEN ==========
      'home': 'Home',
      'today': 'Today',
      'todayDate': 'Today',
      'ramadan': 'RAMADAN',
      'salam': 'Salam',
      'verseOfTheDay': '📖 Verse of the Day',
      'todayVerse': 'Sourate Al-Insān · verse 8',
      'todayVerseArabic':
          'وَيُطْعِمُونَ الْطَعَامَ عَلَى حَبِيهِ\nمِسْكِينًا وَيَتَيْمًا وَأَسِيرًا',
      'verseTranslation':
          '« Et ils offrent la nourriture, malgré son amour, au pauvre, à l\'orphelin et au captif. »',
      'dailyInspiration': '💚 Daily Inspiration',
      'translation': 'Translation',
      'translationCredit':
          'Translation Muhammad Hamidullah, éd. révisée 2021 — licence vérifiée',
      'tafsir':
          'Tafsir — The verse describes those who give while desiring what they share. Ibn Kathīr emphasizes that the value lies in this behavior, not the amount of effort.',
      'readingProgress': 'Reading Progress',
      'completed': 'completed',
      'featuredSurahs': '📚 Featured Surahs',
      'viewAll': 'View All',
      'read': 'Read',
      'recentActivity': '⏰ Recent Activity',
      'website': 'Visit Our Website',
      'websiteDesc': 'Visit hassana.eu for more resources',
      'supportTheApp': 'Support the Quran App',
      'hassanaEu': 'hassana.eu',

      // ========== QUICK ACTIONS ==========
      'readQuran': 'Read Quran',
      'prayerTimes': 'Prayer Times',
      'history': 'History',
      'stats': 'Statistics',
      'subscription': 'Subscription',
      'donate': 'Donate',
      'qibla': 'Qibla Compass',
      'support': 'Support & Donation',

      // ========== QURAN ==========
      'quran': 'Quran',
      'surah': 'Surah',
      'ayah': 'Ayah',
      'verses': 'verses',
      'noSurahsFound': 'No surahs found',
      'searchSurahs': 'Search surahs...',
      'favoriteAyahs': '⭐ Favorite Ayahs',
      'noFavorites': 'No favorite ayahs yet',
      'tapFavoriteIcon': 'Tap the ❤️ icon on any ayah to save it',
      'clearAllFavorites': 'Clear All Favorites',
      'clearAllFavoritesConfirm':
          'Are you sure you want to remove all favorite ayahs?',
      'cancel': 'Cancel',
      'clearAll': 'Clear All',
      'favoritesCleared': 'Favorites cleared',

      // ========== DUAS ==========
      'dua': 'Dua & Supplications',
      'duaSupplications': 'Dua & Supplications',
      'translationLabel': 'Translation:',
      'duaForFasting': 'Dua for Fasting',
      'duaForBreaking': 'Dua for Breaking Fast',
      'duaLaylatulQadr': 'Dua for Laylatul Qadr',
      'duaForGuidance': 'Dua for Guidance',

      // ========== PRAYER TIMES ==========
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'selectLocation': 'Select Location',
      'currentLocation': 'Current Location',
      'searchCity': '🔍 Search for a city...',
      'noPrayerTimes': 'No prayer times available',
      'nextPrayer': 'Next Prayer',
      'gettingLocation': 'Getting your location...',
      'citiesAvailable':
          'Search from {count}+ cities worldwide. Prayer times are calculated using the standard method.',
      'enableLocationSettings':
          'Enable location in Settings > Privacy > Location Services',
      'enableLocationAccurate': 'Enable location for accurate prayer times',
      'settings': 'Settings',

      // ========== QIBLA COMPASS ==========
      'qiblaDirection': 'Qibla Direction',
      'pointToQibla': 'Point your device towards Qibla',
      'distanceToQibla': 'Distance to Qibla',
      'qiblaAngle': 'Qibla Angle',
      'facingQibla': '🕋 Facing Qibla!',
      'almostThere': 'Almost there!',
      'rotateDevice': 'Rotate your device',
      'manualControl': '🖐️ Manual Control',
      'rotateCompass': '🖐️ Rotate Compass',
      'accuracy': 'Accuracy',
      'liveCompass': 'Live compass',
      'simulated': 'Simulated',
      'noSensor': 'No sensor',
      'qiblaLabel': '🕋 Qibla',
      'initializingCompass': 'Initializing compass...',
      'webMode': '🌐 Web mode: Use slider to rotate compass',
      'webChromeAllow':
          '🌐 Chrome: Click "Allow" when prompted for location. Use slider to rotate compass.',
      'permissionsRequired': 'Permissions Required',
      'permissionMessage':
          'This app needs sensor and location permissions to show accurate Qibla direction.',
      'useManualSlider': 'Use Manual Slider',
      'useFallback': 'Use Fallback',
      'retry': 'Retry',
      'manual': 'Manual',
      'sensor': 'Sensor',
      'km': 'km',
      'openSettings': 'Open Settings',

      // // ========== SUBSCRIPTION ==========
      // 'subscribe': 'Subscribe',
      // 'monthly': 'Monthly',
      // 'yearly': 'Yearly',
      // 'perMonth': '/mo',
      // 'perYear': '/yr',
      // 'freeTrial': 'Free Trial',
      // 'cancelAnytime': 'Cancel anytime',
      // 'basic': 'Basic',
      // 'premium': 'Premium',
      // 'family': 'Family',
      // 'basicDesc': 'Essential features for daily reading',
      // 'premiumDesc': 'All features unlocked for complete experience',
      // 'familyDesc': 'Share with up to 5 family members',
      // 'euro': '€',
      // 'premiumAccess': '🌟 Premium Access',
      // 'choosePlan': 'Choose your plan and unlock all features',
      // 'popular': 'POPULAR',
      // 'selectPlan': 'Select a plan to continue',
      // 'securePayment': 'Secure payment',
      // 'subscriptionStarted': 'Subscription started! (Demo)',

      // // ========== DONATION ==========
      // 'donation': 'Donation',
      // 'oneTime': 'One Time',
      // 'recurring': 'Recurring',
      // 'customAmount': 'Custom Amount',
      // 'donateNow': 'Donate Now',
      // 'thankYou': 'Thank You for Your Support!',
      // 'selectAmount': 'Select Amount',
      // 'custom': 'Custom',
      // 'donateOnWebsite': 'Donate {amount} on Website',
      // 'secureStripe': '100% secure • Powered by Stripe',
      // 'close': 'Close',
      // 'supportMessage':
      //     'Your support helps us continue improving the Quran App.',
      // 'thankYouDonation': 'Thank you for your generous donation of {amount}!',

      // ========== AUTHENTICATION ==========
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': 'Already have an account?',
      'orContinueWith': 'Or continue with',
      'google': 'Google',
      'apple': 'Apple',
      'loginSuccess': 'Login Successful',
      'signupSuccess': 'Account Created',
      'welcome': 'Welcome to Daily Quran',
      'welcomeDesc':
          'Read, learn, and understand the Quran with daily verses and translations.',
      'verifyEmail': 'Verify Your Email',
      'verifyYourEmail': 'Verify Your Email',
      'enterVerificationCode': 'Enter the 6-digit code sent to',
      'verificationCode': 'Verification Code',
      'verify': 'Verify',
      'resendCode': 'Resend Code',
      'backToLogin': 'Back to Login',
      'fullName': 'Full Name',
      'sendCode': 'Send Code',
      'resetPassword': 'Reset Password',
      'enterEmail':
          'Enter your email address and we\'ll send you a 6-digit reset code.',
      'enterCode': 'Enter Code',
      'enterCodeSent': 'Enter the 6-digit code sent to',
      'createNewPassword': 'Create a new password for your account',
      'newPassword': 'New Password',
      'passwordRequirements':
          'Password must be at least 8 characters with uppercase and number',
      'backToLogin2': 'Back to Login',
      'step': 'Step',
      'setNewPassword': 'Set New Password',
      'validEmailRequired': 'Please enter a valid email address',
      'resetCodeSent': 'Reset code sent to your email!',
      'enter6DigitCode': 'Please enter the 6-digit code',
      'codeVerified': 'Code verified! Set your new password.',
      'invalidCode': 'Invalid code',
      'resendNewCode': 'New code sent to your email!',
      'passwordResetSuccess': 'Password reset successful!',
      'failedResetPassword': 'Failed to reset password',
      'codeSentSuccess': 'Verification code sent to your email!',
      'newCodeSent': 'New code sent to your email!',
      'loginFailed': 'Login failed',
      'registrationFailed': 'Registration failed',
      'verificationFailed': 'Verification failed',
      'resendCodeFailed': 'Failed to resend code',
      'googleLoginFailed': 'Google login failed',
      'appleLoginFailed': 'Apple login failed',

      // ========== SETTINGS ==========
      'language': 'Language',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'switchToLight': 'Switch to light theme',
      'switchToDark': 'Switch to dark theme',
      'notifications': 'Notifications',
      'quranTranslation': 'Quran Translation',
      'audioRecitation': 'Audio Recitation',
      'about': 'About',
      'version': 'Version',
      'save': 'Save',
      'update': 'Update',
      'changePassword': 'Change Password',
      'logout': 'Logout',
      'confirmLogout': 'Are you sure you want to logout?',
      'editProfile': 'Edit Profile',
      'readingPreferences': 'Reading Preferences',
      'showTranslation': 'Show Translation',
      'showTranslationDesc': 'Display translation below verses',
      'showTafsir': 'Show Tafsir',
      'showTafsirDesc': 'Display explanation below translation',
      'theme': 'Theme',
      'account': 'Account',
      'deleteAccount': 'Delete Account',
      'deleteAccountConfirm':
          'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently removed.',
      'profileUpdated': 'Profile updated successfully',
      'passwordChanged': 'Password changed successfully',
      'accountDeleted': 'Account deleted successfully',
      'guestUser': 'Guest User',
      'notSignedIn': 'Not signed in',
      'skipNow': 'Skip Now',
      'createAccount': 'Create Account',
      'createAccountMessage':
          'Create an account to save your data and sync across devices',
      'createAccountStatsMessage':
          'Save your reading stats to the cloud and access them anywhere',
      'signUpNow': 'Sign Up Now',
      'verified': '✓ Verified',
      'notVerified': '⚠️ Not Verified',
      'nameCannotBeEmpty': 'Name cannot be empty',
      'failedUpdateProfile': 'Failed to update profile',
      'currentPassword': 'Current Password',
      'confirmNewPassword': 'Confirm New Password',
      'pleaseFillAllFields': 'Please fill all fields',
      'passwordsDoNotMatch': 'New passwords do not match',
      'passwordMinLength': 'Password must be at least 8 characters',
      'failedChangePassword': 'Failed to change password',
      'pleaseWait': 'Please wait...',

      // ========== WELCOME SCREEN ==========
      'welcomeTitle': 'Welcome Back!',
      'welcomeSubtitle': 'Today, someone in need will have a meal and water',
      'welcomeMessage':
          'Your daily subscription today provides a warm meal and clean water to someone in need.',
      'mealsProvided': 'Meals Provided',
      'waterAccess': 'Water Access',
      'continueToApp': 'Continue to App',
      'continuingAutomatically': 'Continuing automatically...',
      'todaySomeoneNeeds': 'Today, someone in need will have a meal and water',
      'gratitudeMessage1':
          'Thanks to you, a family will have food on their table today. 🌙',
      'gratitudeMessage2':
          'Your kindness reaches across the world. Today, someone will eat because of you. 🤲',
      'gratitudeMessage3':
          'Every day you subscribe, you change a life. Today is that day. 💚',
      'gratitudeMessage4':
          'Your generosity today means a child will go to bed with a full stomach. 🌟',

      // ========== STATISTICS ==========
      'statistics': '📊 Statistics',
      'overview': '📊 Overview',
      'analytics': '📈 Analytics',
      'historyTab': '📜 History',
      'versesRead': 'Verses Read',
      'readingStreak': 'Reading Streak',
      'timeSpent': 'Time Spent',
      'surahsRead': 'Surahs Read',
      'quranProgress': 'Quran Progress',
      'percentOfQuran': '% of Quran',
      'mostReadSurahs': '🏆 Most Read Surahs',
      'weeklyHeatmap': '🔥 Weekly Reading Heatmap',
      'hourlyDistribution': '⏰ Reading Time Distribution',
      'monthlyProgress': '📅 Monthly Progress',
      'dayStreak': 'Day Streak!',
      'keepGoing': 'Keep going! You\'re building a great habit.',
      'startToday': 'Start your streak today!',
      'clearAllData': '🗑️ Clear All Data',
      'clearAllDataDesc': 'Delete all reading history and statistics',
      'clear': 'Clear',
      'noHistory': 'No reading history yet',
      'startReadingHistory': 'Start reading to build your history',
      'refreshData': 'Refresh Data',
      'dataCleared': 'All data cleared successfully',
      'todayVerses': 'today',
      'startTodayStat': 'Start today',
      'sessions': 'sessions',
      'demoDataAdded': 'Demo data added!',
      'addDemoData': 'Add Demo Data',

      // ========== HISTORY ==========
      'ayahs': 'ayahs',
      'startReading': 'Start Reading',

      // ========== DAILY MESSAGES ==========
      'dailyMessage1':
          '🤲 Thank you. Today as well, your subscription helps support a family in need.',
      'dailyMessage2':
          '🌙 Every verse you read brings light to your heart and hope to others.',
      'dailyMessage3':
          '💚 Your daily habit is a gift to your soul and a blessing to those around you.',
      'dailyMessage4':
          '🌟 With each ayah, you grow closer to Allah and inspire others to do the same.',
      'dailyMessage5':
          '🕌 Your commitment to the Quran is a legacy for generations to come.',
      'dailyMessage6':
          '📖 Reading the Quran is not just an act of worship, but a conversation with the Divine.',
      'dailyMessage7':
          '✨ Every letter you recite is a light that illuminates your path.',
      'dailyMessage8':
          '🤝 Your subscription helps provide free access to the Quran for those who cannot afford it.',

      // ========== DAYS & MONTHS ==========
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'january': 'January',
      'february': 'February',
      'march': 'March',
      'april': 'April',
      'may': 'May',
      'june': 'June',
      'july': 'July',
      'august': 'August',
      'september': 'September',
      'october': 'October',
      'november': 'November',
      'december': 'December',

      // ========== COMPASS DIRECTIONS ==========
      'north': 'N',
      'south': 'S',
      'east': 'E',
      'west': 'W',

      // ========== ERRORS & MESSAGES ==========
      'networkError': 'Network error',
      'initializing': 'Initializing...',
      'permissionRequired': 'Permissions required',
      'locationPermissionDenied':
          'Location permission denied. Using selected city.',
      'sensorPermissionDenied':
          'Sensor permission denied. Using manual control.',
      'errorInitializing': 'Error initializing: {error}',
      'compassSensorError': 'Compass sensor error. Using manual slider.',
      'compassNotAvailable': 'Compass not available. Using manual slider.',

      // ========== WEBSITE ==========
      'openWebsite': 'Open Website',
      'forMoreResources': 'For more resources and information',
      'visitWebsite': 'Visit hassana.eu',
    },

    'French': {
      // ========== APP GENERAL ==========
      'appTitle': 'Coran Quotidien',
      'appTitleShort': 'Coran Quotidien',
      'appSubtitle': 'Votre habitude quotidienne du Coran',

      // ========== SPLASH & ONBOARDING ==========
      'yourDaily': 'VOTRE QUOTIDIEN',
      'quranHabit': 'HABITUDE DU CORAN',
      'skip': 'Passer',
      'next': 'Suivant',
      'getStarted': 'Commencer',

      // ========== ONBOARDING ==========
      'onboarding1': 'Versets quotidiens du Coran',
      'onboarding1Desc':
          'Commencez votre journée avec un verset du Coran avec traduction et Tafsir.',
      'onboarding2': 'Suivez votre progression',
      'onboarding2Desc':
          'Surveillez votre progression de lecture et restez constant dans votre habitude du Coran.',
      'onboarding3': 'Heures de prière & Dou\'a',
      'onboarding3Desc':
          "Ne manquez jamais une prière et trouvez des dou'as authentiques pour chaque occasion.",

      // ========== HOME SCREEN ==========
      'home': 'Accueil',
      'today': "Aujourd'hui",
      'todayDate': "Aujourd'hui",
      'ramadan': 'RAMADAN',
      'salam': 'Salam',
      'verseOfTheDay': '📖 Verset du Jour',
      'todayVerse': 'Sourate Al-Insān · verset 8',
      'todayVerseArabic':
          'وَيُطْعِمُونَ الْطَعَامَ عَلَى حَبِيهِ\nمِسْكِينًا وَيَتَيْمًا وَأَسِيرًا',
      'verseTranslation':
          '« Et ils offrent la nourriture, malgré son amour, au pauvre, à l\'orphelin et au captif. »',
      'dailyInspiration': '💚 Inspiration Quotidienne',
      'translation': 'Traduction',
      'translationCredit':
          'Traduction Muhammad Hamidullah, éd. révisée 2021 — licence vérifiée',
      'tafsir':
          "TAFSIR — APERÇU — Le verset décrit ceux qui donnent alors qu'ils désirent eux-mêmes ce qu'ils partagent. Ibn Kathīr souligne que la valeur du geste tient à ce comportement, non à la quantité d'effort.",
      'readingProgress': 'Progression de lecture',
      'completed': 'terminé',
      'featuredSurahs': '📚 Sourates en Vedette',
      'viewAll': 'Voir Tout',
      'read': 'Lire',
      'recentActivity': '⏰ Activité Récente',
      'website': 'Visitez notre site web',
      'websiteDesc': 'Visitez hassana.eu pour plus de ressources',
      'supportTheApp': 'Soutenez l\'application du Coran',
      'hassanaEu': 'hassana.eu',

      // ========== QUICK ACTIONS ==========
      'readQuran': 'Lire le Coran',
      'prayerTimes': 'Heures de prière',
      'history': 'Historique',
      'stats': 'Statistiques',
      'subscription': 'Abonnement',
      'donate': 'Faire un don',
      'qibla': 'Boussole Qibla',
      'support': 'Soutien & Don',

      // ========== QURAN ==========
      'quran': 'Coran',
      'surah': 'Sourate',
      'ayah': 'Verset',
      'verses': 'versets',
      'noSurahsFound': 'Aucune sourate trouvée',
      'searchSurahs': 'Rechercher des sourates...',
      'favoriteAyahs': '⭐ Versets Favoris',
      'noFavorites': 'Aucun verset favori',
      'tapFavoriteIcon':
          'Appuyez sur l\'icône ❤️ sur n\'importe quel verset pour le sauvegarder',
      'clearAllFavorites': 'Effacer tous les favoris',
      'clearAllFavoritesConfirm':
          'Êtes-vous sûr de vouloir supprimer tous les versets favoris?',
      'cancel': 'Annuler',
      'clearAll': 'Tout effacer',
      'favoritesCleared': 'Favoris effacés',

      // ========== DUAS ==========
      'dua': "Dou'a & Supplications",
      'duaSupplications': "Dou'a & Supplications",
      'translationLabel': 'Traduction:',
      'duaForFasting': "Dou'a pour le jeûne",
      'duaForBreaking': "Dou'a pour la rupture du jeûne",
      'duaLaylatulQadr': "Dou'a pour Laylatul Qadr",
      'duaForGuidance': "Dou'a pour la guidance",

      // ========== PRAYER TIMES ==========
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'selectLocation': 'Choisir un emplacement',
      'currentLocation': 'Emplacement actuel',
      'searchCity': '🔍 Rechercher une ville...',
      'noPrayerTimes': 'Aucune heure de prière disponible',
      'nextPrayer': 'Prochaine prière',
      'gettingLocation': 'Obtention de votre position...',
      'citiesAvailable':
          'Recherchez parmi {count}+ villes dans le monde. Les heures de prière sont calculées selon la méthode standard.',
      'enableLocationSettings':
          'Activez la localisation dans Paramètres > Confidentialité > Services de localisation',
      'enableLocationAccurate':
          'Activez la localisation pour des heures de prière précises',
      'settings': 'Paramètres',

      // ========== QIBLA COMPASS ==========
      'qiblaDirection': 'Direction de la Qibla',
      'pointToQibla': 'Orientez votre appareil vers la Qibla',
      'distanceToQibla': 'Distance vers la Qibla',
      'qiblaAngle': 'Angle de la Qibla',
      'facingQibla': '🕋 Vous faites face à la Qibla!',
      'almostThere': 'Presque!',
      'rotateDevice': 'Tournez votre appareil',
      'manualControl': '🖐️ Contrôle Manuel',
      'rotateCompass': '🖐️ Tourner la Boussole',
      'accuracy': 'Précision',
      'liveCompass': 'Boussole en direct',
      'simulated': 'Simulé',
      'noSensor': 'Aucun capteur',
      'qiblaLabel': '🕋 Qibla',
      'initializingCompass': 'Initialisation de la boussole...',
      'webMode':
          '🌐 Mode web: Utilisez le curseur pour faire pivoter la boussole',
      'webChromeAllow':
          '🌐 Chrome: Cliquez sur "Autoriser" lorsque vous êtes invité pour la localisation. Utilisez le curseur pour faire pivoter la boussole.',
      'permissionsRequired': 'Autorisations requises',
      'permissionMessage':
          'Cette application a besoin des autorisations de capteur et de localisation pour afficher la direction précise de la Qibla.',
      'useManualSlider': 'Utiliser le curseur manuel',
      'useFallback': 'Utiliser la solution de repli',
      'retry': 'Réessayer',
      'manual': 'Manuel',
      'sensor': 'Capteur',
      'km': 'km',
      'openSettings': 'Ouvrir les paramètres',

      // // ========== SUBSCRIPTION ==========
      // 'subscribe': "S'abonner",
      // 'monthly': 'Mensuel',
      // 'yearly': 'Annuel',
      // 'perMonth': '/mois',
      // 'perYear': '/an',
      // 'freeTrial': 'Essai gratuit',
      // 'cancelAnytime': 'Annulez à tout moment',
      // 'basic': 'Basique',
      // 'premium': 'Premium',
      // 'family': 'Famille',
      // 'basicDesc': 'Fonctionnalités essentielles pour la lecture quotidienne',
      // 'premiumDesc':
      //     'Toutes les fonctionnalités débloquées pour une expérience complète',
      // 'familyDesc': "Partagez avec jusqu'à 5 membres de la famille",
      // 'euro': '€',
      // 'premiumAccess': '🌟 Accès Premium',
      // 'choosePlan':
      //     'Choisissez votre plan et débloquez toutes les fonctionnalités',
      // 'popular': 'POPULAIRE',
      // 'selectPlan': 'Sélectionnez un plan pour continuer',
      // 'securePayment': 'Paiement sécurisé',
      // 'subscriptionStarted': 'Abonnement commencé! (Démo)',

      // // ========== DONATION ==========
      // 'donation': 'Don',
      // 'oneTime': 'Unique',
      // 'recurring': 'Récurrent',
      // 'customAmount': 'Montant personnalisé',
      // 'donateNow': 'Faire un don maintenant',
      // 'thankYou': 'Merci pour votre soutien!',
      // 'selectAmount': 'Sélectionnez le montant',
      // 'custom': 'Personnalisé',
      // 'donateOnWebsite': 'Faire un don de {amount} sur le site web',
      // 'secureStripe': '100% sécurisé • Propulsé par Stripe',
      // 'close': 'Fermer',
      // 'supportMessage':
      //     'Votre soutien nous aide à continuer d\'améliorer l\'application du Coran.',
      // 'thankYouDonation': 'Merci pour votre don généreux de {amount}!',

      // ========== AUTHENTICATION ==========
      'login': 'Se connecter',
      'signup': "S'inscrire",
      'email': 'E-mail',
      'password': 'Mot de passe',
      'confirmPassword': 'Confirmer le mot de passe',
      'forgotPassword': 'Mot de passe oublié?',
      'dontHaveAccount': "Vous n'avez pas de compte?",
      'alreadyHaveAccount': 'Vous avez déjà un compte?',
      'orContinueWith': 'Ou continuer avec',
      'google': 'Google',
      'apple': 'Apple',
      'loginSuccess': 'Connexion réussie',
      'signupSuccess': 'Compte créé',
      'welcome': 'Bienvenue sur Coran Quotidien',
      'welcomeDesc':
          'Lisez, apprenez et comprenez le Coran avec des versets quotidiens et des traductions.',
      'verifyEmail': "Vérifiez votre e-mail",
      'verifyYourEmail': "Vérifiez votre e-mail",
      'enterVerificationCode': 'Entrez le code à 6 chiffres envoyé à',
      'verificationCode': 'Code de vérification',
      'verify': 'Vérifier',
      'resendCode': 'Renvoyer le code',
      'backToLogin': 'Retour à la connexion',
      'fullName': 'Nom complet',
      'sendCode': 'Envoyer le code',
      'resetPassword': 'Réinitialiser le mot de passe',
      'enterEmail':
          "Entrez votre adresse e-mail et nous vous enverrons un code de réinitialisation à 6 chiffres.",
      'enterCode': 'Entrez le code',
      'enterCodeSent': 'Entrez le code à 6 chiffres envoyé à',
      'createNewPassword': 'Créez un nouveau mot de passe pour votre compte',
      'newPassword': 'Nouveau mot de passe',
      'passwordRequirements':
          'Le mot de passe doit contenir au moins 8 caractères avec une majuscule et un chiffre',
      'backToLogin2': 'Retour à la connexion',
      'step': 'Étape',
      'setNewPassword': 'Définir un nouveau mot de passe',
      'validEmailRequired': 'Veuillez entrer une adresse e-mail valide',
      'resetCodeSent': 'Code de réinitialisation envoyé à votre e-mail!',
      'enter6DigitCode': 'Veuillez entrer le code à 6 chiffres',
      'codeVerified': 'Code vérifié! Définissez votre nouveau mot de passe.',
      'invalidCode': 'Code invalide',
      'resendNewCode': 'Nouveau code envoyé à votre e-mail!',
      'passwordResetSuccess': 'Mot de passe réinitialisé avec succès!',
      'failedResetPassword': 'Échec de la réinitialisation du mot de passe',
      'codeSentSuccess': 'Code de vérification envoyé à votre e-mail!',
      'newCodeSent': 'Nouveau code envoyé à votre e-mail!',
      'loginFailed': 'Échec de la connexion',
      'registrationFailed': 'Échec de l\'inscription',
      'verificationFailed': 'Échec de la vérification',
      'resendCodeFailed': 'Échec du renvoi du code',
      'googleLoginFailed': 'Échec de la connexion Google',
      'appleLoginFailed': 'Échec de la connexion Apple',

      // ========== SETTINGS ==========
      'language': 'Langue',
      'darkMode': 'Mode sombre',
      'lightMode': 'Mode clair',
      'switchToLight': 'Passer au thème clair',
      'switchToDark': 'Passer au thème sombre',
      'notifications': 'Notifications',
      'quranTranslation': 'Traduction du Coran',
      'audioRecitation': 'Récitation audio',
      'about': 'À propos',
      'version': 'Version',
      'save': 'Enregistrer',
      'update': 'Mettre à jour',
      'changePassword': 'Changer le mot de passe',
      'logout': 'Se déconnecter',
      'confirmLogout': 'Êtes-vous sûr de vouloir vous déconnecter?',
      'editProfile': 'Modifier le profil',
      'readingPreferences': 'Préférences de lecture',
      'showTranslation': 'Afficher la traduction',
      'showTranslationDesc': 'Afficher la traduction sous les versets',
      'showTafsir': 'Afficher le Tafsir',
      'showTafsirDesc': "Afficher l'explication sous la traduction",
      'theme': 'Thème',
      'account': 'Compte',
      'deleteAccount': 'Supprimer le compte',
      'deleteAccountConfirm':
          'Êtes-vous sûr de vouloir supprimer votre compte? Cette action est irréversible. Toutes vos données seront définitivement supprimées.',
      'profileUpdated': 'Profil mis à jour avec succès',
      'passwordChanged': 'Mot de passe changé avec succès',
      'accountDeleted': 'Compte supprimé avec succès',
      'guestUser': 'Utilisateur invité',
      'notSignedIn': 'Non connecté',
      'skipNow': 'Ignorer maintenant',
      'createAccount': 'Créer un compte',
      'createAccountMessage':
          'Créez un compte pour enregistrer vos données et les synchroniser sur tous les appareils',
      'createAccountStatsMessage':
          'Enregistrez vos statistiques de lecture dans le cloud et accédez-y partout',
      'signUpNow': 'Inscrivez-vous maintenant',
      'verified': '✓ Vérifié',
      'notVerified': '⚠️ Non vérifié',
      'nameCannotBeEmpty': 'Le nom ne peut pas être vide',
      'failedUpdateProfile': 'Échec de la mise à jour du profil',
      'currentPassword': 'Mot de passe actuel',
      'confirmNewPassword': 'Confirmer le nouveau mot de passe',
      'pleaseFillAllFields': 'Veuillez remplir tous les champs',
      'passwordsDoNotMatch': 'Les nouveaux mots de passe ne correspondent pas',
      'passwordMinLength':
          'Le mot de passe doit contenir au moins 8 caractères',
      'failedChangePassword': 'Échec du changement de mot de passe',
      'pleaseWait': 'Veuillez patienter...',

      // ========== WELCOME SCREEN ==========
      'welcomeTitle': 'Bon retour!',
      'welcomeSubtitle':
          "Aujourd'hui, une personne dans le besoin aura un repas et de l'eau",
      'welcomeMessage':
          "Votre abonnement quotidien aujourd'hui fournit un repas chaud et de l'eau potable à quelqu'un dans le besoin.",
      'mealsProvided': 'Repas fournis',
      'waterAccess': "Accès à l'eau",
      'continueToApp': "Continuer vers l'application",
      'continuingAutomatically': 'Continuation automatique...',
      'todaySomeoneNeeds':
          "Aujourd'hui, une personne dans le besoin aura un repas et de l'eau",
      'gratitudeMessage1':
          'Grâce à vous, une famille aura de la nourriture sur sa table aujourd\'hui. 🌙',
      'gratitudeMessage2':
          'Votre gentillesse rayonne dans le monde. Aujourd\'hui, quelqu\'un mangera grâce à vous. 🤲',
      'gratitudeMessage3':
          'Chaque jour où vous vous abonnez, vous changez une vie. Aujourd\'hui est ce jour. 💚',
      'gratitudeMessage4':
          'Votre générosité aujourd\'hui signifie qu\'un enfant ira se coucher le ventre plein. 🌟',

      // ========== STATISTICS ==========
      'statistics': '📊 Statistiques',
      'overview': '📊 Aperçu',
      'analytics': '📈 Analytique',
      'historyTab': '📜 Historique',
      'versesRead': 'Versets lus',
      'readingStreak': 'Série de lecture',
      'timeSpent': 'Temps passé',
      'surahsRead': 'Sourates lues',
      'quranProgress': 'Progression du Coran',
      'percentOfQuran': '% du Coran',
      'mostReadSurahs': '🏆 Sourates les plus lues',
      'weeklyHeatmap': '🔥 Carte de chaleur hebdomadaire',
      'hourlyDistribution': '⏰ Répartition du temps de lecture',
      'monthlyProgress': '📅 Progression mensuelle',
      'dayStreak': 'Jour de série!',
      'keepGoing': 'Continuez! Vous construisez une excellente habitude.',
      'startToday': 'Commencez votre série aujourd\'hui!',
      'clearAllData': '🗑️ Effacer toutes les données',
      'clearAllDataDesc':
          'Supprimer tout l\'historique de lecture et les statistiques',
      'clear': 'Effacer',
      'noHistory': 'Aucun historique de lecture',
      'startReadingHistory':
          'Commencez à lire pour construire votre historique',
      'refreshData': 'Actualiser les données',
      'dataCleared': 'Toutes les données ont été effacées avec succès',
      'todayVerses': 'aujourd\'hui',
      'startTodayStat': 'Commencez aujourd\'hui',
      'sessions': 'sessions',
      'demoDataAdded': 'Données de démonstration ajoutées!',
      'addDemoData': 'Ajouter des données de démonstration',

      // ========== HISTORY ==========
      'ayahs': 'versets',
      'startReading': 'Commencer la lecture',

      // ========== DAILY MESSAGES ==========
      'dailyMessage1':
          "🤲 Merci. Aujourd'hui aussi, votre abonnement aide à soutenir une famille dans le besoin.",
      'dailyMessage2':
          '🌙 Chaque verset que vous lisez apporte de la lumière à votre cœur et de l\'espoir aux autres.',
      'dailyMessage3':
          '💚 Votre habitude quotidienne est un cadeau pour votre âme et une bénédiction pour ceux qui vous entourent.',
      'dailyMessage4':
          '🌟 Avec chaque ayah, vous vous rapprochez d\'Allah et inspirez les autres à faire de même.',
      'dailyMessage5':
          '🕌 Votre engagement envers le Coran est un héritage pour les générations à venir.',
      'dailyMessage6':
          "📖 Lire le Coran n'est pas seulement un acte d'adoration, mais une conversation avec le Divin.",
      'dailyMessage7':
          '✨ Chaque lettre que vous récitez est une lumière qui illumine votre chemin.',
      'dailyMessage8':
          '🤝 Votre abonnement aide à fournir un accès gratuit au Coran à ceux qui ne peuvent pas se le permettre.',

      // ========== DAYS & MONTHS ==========
      'monday': 'Lundi',
      'tuesday': 'Mardi',
      'wednesday': 'Mercredi',
      'thursday': 'Jeudi',
      'friday': 'Vendredi',
      'saturday': 'Samedi',
      'sunday': 'Dimanche',
      'january': 'Janvier',
      'february': 'Février',
      'march': 'Mars',
      'april': 'Avril',
      'may': 'Mai',
      'june': 'Juin',
      'july': 'Juillet',
      'august': 'Août',
      'september': 'Septembre',
      'october': 'Octobre',
      'november': 'Novembre',
      'december': 'Décembre',

      // ========== COMPASS DIRECTIONS ==========
      'north': 'N',
      'south': 'S',
      'east': 'E',
      'west': 'O',

      // ========== ERRORS & MESSAGES ==========
      'networkError': 'Erreur réseau',
      'initializing': 'Initialisation...',
      'permissionRequired': 'Autorisations requises',
      'locationPermissionDenied':
          'Autorisation de localisation refusée. Utilisation de la ville sélectionnée.',
      'sensorPermissionDenied':
          'Autorisation du capteur refusée. Utilisation du contrôle manuel.',
      'errorInitializing': 'Erreur lors de l\'initialisation: {error}',
      'compassSensorError':
          'Erreur du capteur de boussole. Utilisation du curseur manuel.',
      'compassNotAvailable':
          'Boussole non disponible. Utilisation du curseur manuel.',

      // ========== WEBSITE ==========
      'openWebsite': 'Ouvrir le site web',
      'forMoreResources': 'Pour plus de ressources et d\'informations',
      'visitWebsite': 'Visitez hassana.eu',
    },
  };

  // Get translation for a given language and key
  static String getText(String language, String key) {
    return _translations[language]?[key] ??
        _translations['English']?[key] ??
        key;
  }
}

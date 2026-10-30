// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Pockets Vault';

  @override
  String get addTransaction => 'Aggiungi movimento';

  @override
  String get saveTransaction => 'Salva movimento';

  @override
  String get editTransaction => 'Modifica movimento';

  @override
  String get amount => 'Importo';

  @override
  String get category => 'Categoria';

  @override
  String get selectCategory => 'Seleziona categoria';

  @override
  String get date => 'Data';

  @override
  String get note => 'Nota';

  @override
  String get income => 'Entrata';

  @override
  String get expense => 'Uscita';

  @override
  String get incomes => 'Entrate';

  @override
  String get expenses => 'Uscite';

  @override
  String get transactionSaved => 'Movimento salvato';

  @override
  String get recentTransactions => 'Movimenti recenti';

  @override
  String get noTransactions => 'Nessun movimento';

  @override
  String get total => 'Totale';

  @override
  String get month => 'Mese';

  @override
  String get transactions => 'Movimenti';

  @override
  String get stats => 'Statistiche';

  @override
  String get settings => 'Impostazioni';

  @override
  String get lfTransactions => 'Cerca movimenti';

  @override
  String get newCategory => 'Nuova categoria';

  @override
  String get nameCategory => 'Nome categoria';

  @override
  String get cancel => 'Annulla';

  @override
  String get add => 'Aggiungi';

  @override
  String get expensesDistribution => 'Distribuzione spese';

  @override
  String get noExpenses => 'Nessuna spesa';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get language => 'Lingua';

  @override
  String get data => 'Dati';

  @override
  String get cancelAll => 'Cancella tutti i dati';

  @override
  String get categoryRemoved => 'Categoria rimossa';

  @override
  String get balance => 'Saldo';

  @override
  String get removeTransactionQ => 'Eliminare movimento?';

  @override
  String get youSure => 'Questa azione non può essere annullata.';

  @override
  String get delete => 'Elimina';

  @override
  String get transactionDeleted => 'Movimento eliminato';

  @override
  String get confirm => 'Conferma';

  @override
  String get deleteAllQ =>
      'Sei sicuro di voler eliminare tutti i dati salvati?';

  @override
  String get salary => 'Stipendio';

  @override
  String get bonus => 'Bonus';

  @override
  String get gift => 'Regalo';

  @override
  String get food => 'Cibo';

  @override
  String get groceries => 'Supermercato';

  @override
  String get transport => 'Trasporti';

  @override
  String get rent => 'Affitto';

  @override
  String get bills => 'Bollette';

  @override
  String get shopping => 'Shopping';

  @override
  String get health => 'Salute';

  @override
  String get entertainment => 'Svago';

  @override
  String get travel => 'Viaggi';

  @override
  String get education => 'Studio';

  @override
  String get otherCategory => 'Altro';

  @override
  String get recurrents => 'Ricorrenti';

  @override
  String get security => 'Sicurezza';

  @override
  String get everyMonth => 'Ogni mese';

  @override
  String recurrenceEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ogni $count giorni',
      one: 'Ogni giorno',
    );
    return '$_temp0';
  }

  @override
  String recurrenceEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ogni $count settimane',
      one: 'Ogni settimana',
    );
    return '$_temp0';
  }

  @override
  String recurrenceEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ogni $count mesi',
      one: 'Ogni mese',
    );
    return '$_temp0';
  }

  @override
  String recurrenceEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ogni $count anni',
      one: 'Ogni anno',
    );
    return '$_temp0';
  }

  @override
  String get active => 'Attivo';

  @override
  String get modify => 'Modifica';

  @override
  String get pause => 'Metti in pausa';

  @override
  String get recurrent => 'Ricorrente';

  @override
  String get recurrentMsg => 'Attiva per ripeterlo automaticamente';

  @override
  String get color => 'Colore';

  @override
  String get day => 'Giorno';

  @override
  String get modifyRecurrent => 'Modifica ricorrenza';

  @override
  String get modifyCategory => 'Modifica categoria';

  @override
  String get noRecurrent => 'Nessuna transazione ricorrente';

  @override
  String get reactivate => 'Riattiva';

  @override
  String get reactivateMsg => 'Ricorrenza riattivata';

  @override
  String get reactivatePauseMsg => 'Ricorrenza messa in pausa';

  @override
  String get dayOfMonth => 'Giorno del mese';

  @override
  String get save => 'Salva';

  @override
  String get recurringCreationMsg => 'Ricorrenza creata  ';

  @override
  String get deleteMovement => 'Eliminare il movimento?';

  @override
  String get deleteMovementSure => 'Questa azione non può essere annullata';

  @override
  String get deletedMovement => 'Movimento eliminato';

  @override
  String get addExpenseToViewGraph =>
      'Aggiungi una spesa per vedere il grafico';

  @override
  String get selectYear => 'Seleziona anno';

  @override
  String get existingCategory => 'Categoria già esistente';

  @override
  String get saveCategory => 'Salva categoria';

  @override
  String get canceledAll => 'Tutti i dati sono stati cancellati';

  @override
  String get searchBar => 'Cerca movimento';

  @override
  String get paused => 'Pausa';

  @override
  String savedMore(Object value) {
    return 'Questo mese hai speso il $value% in meno rispetto al mese scorso';
  }

  @override
  String spentMore(Object value) {
    return 'Questo mese hai speso il $value% in più rispetto al mese scorso';
  }

  @override
  String get spentSameAsLastMonth =>
      'Questo mese stai spendendo come il mese scorso';

  @override
  String get period => 'Periodo';

  @override
  String get selectPeriod => 'Seleziona periodo';

  @override
  String get allCategories => 'Tutte le categorie';

  @override
  String get mostUsedCategories => 'Categorie più usate';

  @override
  String get otherCategories => 'Altre';

  @override
  String get deleteCategory => 'Elimina categoria';

  @override
  String get deleteCategoryConfirm =>
      'Sei sicuro di voler eliminare questa categoria?';

  @override
  String get createPin => 'Crea PIN';

  @override
  String get confirmPin => 'Conferma PIN';

  @override
  String get enterPin => 'Inserisci PIN';

  @override
  String get enableBiometrics => 'Attiva lo sblocco biometrico';

  @override
  String get enableBiometricsMessage =>
      'Usa Face ID o l’impronta per sbloccare Pockets Vault?';

  @override
  String get notNow => 'Non ora';

  @override
  String get enable => 'Attiva';

  @override
  String get biometricUnlock => 'Sblocco biometrico';

  @override
  String get biometricReason => 'Sblocca Pockets Vault';

  @override
  String get deleteDigit => 'Elimina cifra';

  @override
  String get clearPin => 'Cancella PIN';

  @override
  String get home => 'Home';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get mainCurrency => 'Valuta principale';

  @override
  String get updateRates => 'Aggiorna tassi';

  @override
  String get automaticLock => 'Blocco automatico';

  @override
  String get backupPortability => 'Backup e portabilità';

  @override
  String get encryptedBackupCaption =>
      'Cifratura AES-256, export CSV e ripristino locale';

  @override
  String get exportEncryptedBackup => 'Esporta backup cifrato';

  @override
  String get exportTransactionsCsv => 'Esporta movimenti CSV';

  @override
  String get importBackup => 'Importa backup';

  @override
  String get safeMergeOrReplace => 'Unione sicura o sostituzione completa';

  @override
  String get localSmartRules => 'Regole intelligenti locali';

  @override
  String get privateCategorization =>
      'Categorizzazione privata, senza inviare dati';

  @override
  String get noRules => 'Nessuna regola';

  @override
  String get noRulesHint =>
      'Puoi memorizzarne una mentre aggiungi un movimento.';

  @override
  String get availableToSpend => 'Disponibile da spendere';

  @override
  String get budgets => 'Budget';

  @override
  String get optionalMonthlyBudgets =>
      'Budget mensili facoltativi e modificabili in qualsiasi momento';

  @override
  String get noBudget => 'Nessun budget';

  @override
  String get forecast90Days => 'Previsione a 90 giorni';

  @override
  String get noForecastMovements => 'Nessun movimento ricorrente previsto.';

  @override
  String get savingsGoals => 'Obiettivi di risparmio';

  @override
  String get manage => 'Gestisci';

  @override
  String get createGoalHint => 'Crea un obiettivo e monitora i progressi.';

  @override
  String get newGoal => 'Nuovo obiettivo';

  @override
  String get noGoals => 'Nessun obiettivo';

  @override
  String get rememberCategory => 'Ricorda questa categoria';

  @override
  String get rememberCategoryHint =>
      'Suggeriscila per descrizioni simili, solo sul dispositivo.';

  @override
  String get addReceipt => 'Aggiungi ricevuta';

  @override
  String get receiptAttached => 'Ricevuta allegata';

  @override
  String get takePhoto => 'Scatta una foto';

  @override
  String get chooseLibrary => 'Scegli dalla libreria';

  @override
  String get repeatEvery => 'Ripeti ogni';

  @override
  String get endDate => 'Data di fine';

  @override
  String get none => 'Nessuna';

  @override
  String get undo => 'Annulla';

  @override
  String get recurrenceDeleted => 'Ricorrenza eliminata';

  @override
  String get availableThisMonth => 'Disponibile questo mese';

  @override
  String get availableAllTime => 'Disponibile complessivo';

  @override
  String get availableForPeriod => 'Disponibile nel periodo';

  @override
  String get availableFormula =>
      'Entrate − spese − risparmi accantonati − ricorrenze previste';

  @override
  String get reservedSavings => 'Accantonati';

  @override
  String get scheduledUpcoming => 'Transazioni in arrivo';

  @override
  String get categoryLimits => 'Limiti per categoria';

  @override
  String activeBudgets(Object count) {
    return '$count attivi';
  }

  @override
  String remainingBudget(Object amount) {
    return 'Restano $amount';
  }

  @override
  String budgetExceededBy(Object amount) {
    return 'Superato di $amount';
  }

  @override
  String get setOptionalLimit => 'Imposta un limite facoltativo';

  @override
  String budgetForCategory(Object category) {
    return 'Budget mensile · $category';
  }

  @override
  String amountInCurrency(Object currency) {
    return 'Importo in $currency';
  }

  @override
  String get enterPositiveAmount => 'Inserisci un importo maggiore di zero.';

  @override
  String get budgetDeleted => 'Budget eliminato';

  @override
  String get budgetPeriodHint =>
      'I limiti mensili sono proporzionati all’intervallo selezionato.';

  @override
  String get forecastRecurring => 'Previsione ricorrenze';

  @override
  String get forecastExplanation =>
      'Stima dal saldo attuale usando solo le ricorrenze programmate.';

  @override
  String get currentBalance => 'Saldo attuale';

  @override
  String forecastAfter(Object duration) {
    return 'Tra $duration';
  }

  @override
  String recurringIncluded(Object count) {
    return '$count movimenti ricorrenti inclusi nel calcolo.';
  }

  @override
  String get oneMonth => '1 mese';

  @override
  String monthsCount(Object count) {
    return '$count mesi';
  }

  @override
  String get oneYear => '1 anno';

  @override
  String yearsCount(Object count) {
    return '$count anni';
  }

  @override
  String get savingsReservedHint =>
      'Gli importi accantonati riducono il disponibile, ma restano parte del saldo.';

  @override
  String allocatedInSelection(Object amount) {
    return 'Accantonato nel periodo: $amount';
  }

  @override
  String get reserveFunds => 'Accantona';

  @override
  String get releaseFunds => 'Sblocca fondi';

  @override
  String get addSavings => 'Aggiungi risparmio';

  @override
  String get releaseSavings => 'Sblocca risparmio';

  @override
  String get goalName => 'Nome';

  @override
  String goalTarget(Object name) {
    return 'Obiettivo · $name';
  }

  @override
  String get deleteGoal => 'Eliminare l’obiettivo?';

  @override
  String get deleteGoalReleasesFunds =>
      'I fondi accantonati torneranno disponibili. La cronologia resta conservata e i movimenti non vengono modificati.';

  @override
  String get goalDeleted => 'Obiettivo eliminato';

  @override
  String maximumAmount(Object amount) {
    return 'Massimo $amount';
  }

  @override
  String get receiptOptional => 'Ricevuta opzionale';

  @override
  String get receiptPurpose =>
      'Legge importo, data, esercente e categoria direttamente sul dispositivo.';

  @override
  String get receiptStoredLocally =>
      'Scansione privata sul dispositivo, con revisione prima del salvataggio.';

  @override
  String get receiptLinked => 'Allegata a questo movimento';

  @override
  String get receiptPermissionDenied =>
      'Permesso non concesso. Abilita foto e fotocamera nelle Impostazioni.';

  @override
  String get cameraUnavailable =>
      'Fotocamera non disponibile su questo dispositivo.';

  @override
  String get libraryUnavailable =>
      'Libreria foto non disponibile su questo dispositivo.';

  @override
  String get receiptAttachFailed => 'Impossibile allegare la ricevuta.';

  @override
  String convertedToMainCurrency(Object amount) {
    return '≈ $amount nella valuta principale';
  }

  @override
  String get conversionOnSave => 'Il cambio verrà calcolato al salvataggio.';

  @override
  String get ecbRefreshNeeded => 'Conversione BCE · aggiornamento necessario';

  @override
  String ecbRatesDate(Object date) {
    return 'Tassi BCE del $date';
  }

  @override
  String get rateApp => 'Valuta l’app';

  @override
  String get shareApp => 'Condividi l’app';

  @override
  String get protectBackup => 'Proteggi il backup';

  @override
  String get unlockBackup => 'Sblocca il backup';

  @override
  String get continueAction => 'Continua';

  @override
  String get exportCanceled => 'Esportazione annullata.';

  @override
  String get backupReady => 'Backup pronto per essere salvato o condiviso.';

  @override
  String get csvReady => 'CSV pronto per essere salvato o condiviso.';

  @override
  String get importMode => 'Modalità di importazione';

  @override
  String get importModeExplanation =>
      'Unisci mantiene i dati attuali e aggiorna gli elementi con lo stesso identificativo. Sostituisci cancella prima tutti i dati finanziari locali.';

  @override
  String get merge => 'Unisci';

  @override
  String get replace => 'Sostituisci';

  @override
  String get backupRestored => 'Backup ripristinato correttamente.';

  @override
  String get minimumPassword => 'Usa almeno 8 caratteri.';

  @override
  String get passwordsDoNotMatch => 'Le password non coincidono.';

  @override
  String get minimumEightCharacters => 'Minimo 8 caratteri';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get changeCurrency => 'Cambia valuta';

  @override
  String recursEvery(Object frequency, Object interval) {
    return 'Ogni $interval $frequency';
  }

  @override
  String get savingsUpdateFailed =>
      'Impossibile aggiornare l’obiettivo di risparmio.';

  @override
  String get hideAmounts => 'Nascondi importi';

  @override
  String get showAmounts => 'Mostra importi';

  @override
  String get scanReceipt => 'Scansiona ricevuta';

  @override
  String get receiptScanHint =>
      'Fotografa o scegli una ricevuta per compilare automaticamente la spesa.';

  @override
  String get scanWithCamera => 'Scansiona con la fotocamera';

  @override
  String get scanFromLibrary => 'Scansiona una foto';

  @override
  String get cameraFlash => 'Flash';

  @override
  String get receiptScanReview => 'Controlla la scansione';

  @override
  String get receiptScanCheckData =>
      'Abbiamo trovato questi dati. Controllali e correggili prima di continuare.';

  @override
  String get receiptScanNoData =>
      'Non abbiamo trovato dati affidabili. Inseriscili manualmente o allega soltanto la foto.';

  @override
  String get receiptMerchant => 'Esercente';

  @override
  String get receiptScanPrivate =>
      'OCR e analisi avvengono interamente su questo dispositivo.';

  @override
  String get attachOnly => 'Solo allegato';

  @override
  String get useDetectedData => 'Usa i dati';

  @override
  String get receiptScanApplied =>
      'Dati della ricevuta applicati. Controlla e salva il movimento.';

  @override
  String get receiptScanning => 'Analisi della ricevuta…';

  @override
  String get dataTemporarilyUnavailable =>
      'Dati temporaneamente non disponibili.';

  @override
  String get retry => 'Riprova';

  @override
  String get yourMonth => 'Il tuo mese';

  @override
  String get byCategory => 'Per categoria';

  @override
  String get statsOverview => 'Panoramica';

  @override
  String get statsCategories => 'Categorie';

  @override
  String get statsComparisons => 'Confronti';

  @override
  String get statsTrend => 'Andamento cumulato';

  @override
  String get statsBreakdown => 'Dove spendi';

  @override
  String get statsWhatChanged => 'Cosa è cambiato';

  @override
  String get statsChangeDrivers => 'Da cosa dipende';

  @override
  String get statsPreviousMonth => 'Mese precedente';

  @override
  String get statsChooseMonth => 'Scegli un mese';

  @override
  String get statsYearAverage => 'Media dei mesi precedenti dell’anno';

  @override
  String get statsCompareWith => 'Confronta con';

  @override
  String get statsComparisonPeriod => 'Periodo del confronto';

  @override
  String get statsPrimaryMonth => 'Mese da analizzare';

  @override
  String get statsReferenceMonth => 'Mese di riferimento';

  @override
  String get statsElapsedDays => 'Allinea i giorni trascorsi';

  @override
  String get statsElapsedHint =>
      'Per il mese corrente confronta gli stessi giorni di ciascun mese di riferimento.';

  @override
  String statsThroughDay(int day) {
    return 'Giorni 1–$day di ogni mese';
  }

  @override
  String get statsWholeMonths => 'Interi mesi selezionati';

  @override
  String statsAverageBasis(int count) {
    return 'Media di $count mesi, inclusi quelli senza movimenti.';
  }

  @override
  String get statsNoEarlierMonths =>
      'Gennaio non ha mesi precedenti nello stesso anno. Scegli un altro confronto.';

  @override
  String get statsZeroReference =>
      'Percentuale non disponibile: il valore di riferimento è zero.';

  @override
  String get statsNet => 'Entrate − uscite';

  @override
  String get statsShowTransactions => 'Vedi i movimenti';

  @override
  String get statsDragHint => 'Trascina sul grafico per esplorare';

  @override
  String get statsForecastToday => 'Previsione ricorrenze da oggi';

  @override
  String get statsCompareHint => 'Scegli qui i mesi da confrontare.';

  @override
  String get statsRecordedOnly => 'Movimenti registrati';

  @override
  String get statsMonthTitle => 'Seleziona mese';

  @override
  String get statsCategoryChange => 'Variazione per categoria';

  @override
  String get statsCurrent => 'Mese selezionato';

  @override
  String get statsReference => 'Riferimento';

  @override
  String get statsHiddenChart =>
      'Grafico nascosto quando la privacy degli importi è attiva.';

  @override
  String get statsAllTime => 'Tutte le date registrate';

  @override
  String get statsComparisonUnavailable => 'Nessun periodo di riferimento';

  @override
  String statsTransactionCount(int count) {
    return '$count movimenti';
  }

  @override
  String statsPercentage(String value) {
    return '$value%';
  }

  @override
  String statsVersus(String period) {
    return 'Rispetto a $period';
  }

  @override
  String get statsAverageLabel => 'Media';

  @override
  String get statsMonthlyExpenses => 'Spese del mese';

  @override
  String get statsMonthlyIncome => 'Entrate del mese';

  @override
  String get statsPeriodExpenses => 'Spese del periodo';

  @override
  String get statsPeriodIncome => 'Entrate del periodo';

  @override
  String get statsTotalExpenses => 'Spese totali';

  @override
  String get statsTotalIncome => 'Entrate totali';

  @override
  String get statsPreviousPeriod => 'periodo precedente';

  @override
  String statsRangeCaption(Object period) {
    return 'Confronto: $period';
  }

  @override
  String statsSpentLess(Object amount) {
    return '$amount spesi in meno';
  }

  @override
  String statsSpentMore(Object amount) {
    return '$amount spesi in più';
  }

  @override
  String statsIncomeLess(Object amount) {
    return '$amount di entrate in meno';
  }

  @override
  String statsIncomeMore(Object amount) {
    return '$amount di entrate in più';
  }

  @override
  String statsMainVariation(Object category) {
    return '$category è la variazione principale';
  }

  @override
  String statsExplainsDrop(Object category) {
    return '$category spiega il calo';
  }

  @override
  String statsExplainsRise(Object category) {
    return '$category spiega l’aumento';
  }

  @override
  String get statsOpenCategoryHint =>
      'Apri la categoria per vedere i movimenti';

  @override
  String statsExpenseVersus(Object period) {
    return 'di spese rispetto a $period';
  }

  @override
  String statsIncomeVersus(Object period) {
    return 'di entrate rispetto a $period';
  }

  @override
  String get movementsHistory => 'Cronologia';

  @override
  String get swipeHint =>
      'Scorri a destra per modificare, a sinistra per eliminare';

  @override
  String movementsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movimenti',
      one: '1 movimento',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get repeat => 'Ripeti';

  @override
  String get done => 'Fatto';

  @override
  String get saved => 'Salvato';

  @override
  String get newCategoryShort => 'Nuova';

  @override
  String get addNote => 'Aggiungi nota';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsSupport => 'Supporta Pockets Vault';

  @override
  String get suggested => 'Suggeriti';

  @override
  String get filters => 'Filtri';

  @override
  String get filterType => 'Tipo';

  @override
  String get filterAll => 'Tutti';

  @override
  String get filterCategories => 'Categorie';

  @override
  String get filterCurrency => 'Valuta';

  @override
  String get filterReceipt => 'Ricevuta';

  @override
  String get filterWithReceipt => 'Con ricevuta';

  @override
  String get filterWithoutReceipt => 'Senza ricevuta';

  @override
  String get filterReset => 'Azzera';

  @override
  String filterShowMovements(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostra $count movimenti',
      one: 'Mostra 1 movimento',
      zero: 'Nessun movimento',
    );
    return '$_temp0';
  }

  @override
  String get filterNoResults => 'Nessun movimento con questi filtri.';

  @override
  String get filterClear => 'Azzera filtri';

  @override
  String filterCategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categorie',
      one: '1 categoria',
    );
    return '$_temp0';
  }

  @override
  String get notifications => 'Notifiche';

  @override
  String get notifyRecurring => 'Ricorrenze in arrivo';

  @override
  String get notifyBudget => 'Avviso budget';

  @override
  String get notifyReminder => 'Promemoria serale';

  @override
  String get notifyReminderCaption => 'Solo se oggi non hai registrato nulla';

  @override
  String get notifyHideAmounts => 'Nascondi importi nelle notifiche';

  @override
  String get notifySameDay => 'Il giorno stesso';

  @override
  String notifyDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni prima',
      one: '1 giorno prima',
    );
    return '$_temp0';
  }

  @override
  String notifyAtPercent(int percent) {
    return 'Al $percent%';
  }

  @override
  String get notifyPermissionDenied =>
      'Notifiche non consentite. Attivale nelle impostazioni del telefono.';

  @override
  String notifyRecurringTitleToday(String name) {
    return '$name oggi';
  }

  @override
  String notifyRecurringTitleTomorrow(String name) {
    return '$name domani';
  }

  @override
  String notifyRecurringTitleIn(String name, int days) {
    return '$name tra $days giorni';
  }

  @override
  String notifyRecurringExpenseBody(String amount) {
    return 'Uscita ricorrente di $amount.';
  }

  @override
  String notifyRecurringIncomeBody(String amount) {
    return 'Entrata ricorrente di $amount.';
  }

  @override
  String get notifyRecurringHiddenBody => 'Movimento ricorrente in arrivo.';

  @override
  String notifyBudgetTitle(String category, int percent) {
    return '$category al $percent% del budget';
  }

  @override
  String notifyBudgetOverTitle(String category) {
    return 'Budget $category superato';
  }

  @override
  String notifyBudgetBody(String spent, String limit) {
    return 'Spesi $spent su $limit questo mese.';
  }

  @override
  String get notifyBudgetHiddenBody => 'Apri l\'app per vedere i dettagli.';

  @override
  String get notifyReminderTitle => 'Hai speso qualcosa oggi?';

  @override
  String get notifyReminderBody => 'Registralo in pochi secondi.';

  @override
  String get notifyChannelName => 'Promemoria';

  @override
  String get notifyWhen => 'Quando avvisarti';

  @override
  String get notifyThreshold => 'Soglia';

  @override
  String get notifyTime => 'Orario';

  @override
  String get notifyRecurringCaption =>
      'Alle 9:00, prima di ogni movimento ricorrente';

  @override
  String get notifyBudgetCaption =>
      'Quando una categoria si avvicina al limite del mese';

  @override
  String get widgetMonthBalance => 'Saldo del mese';

  @override
  String get widgetReceipt => 'Ricevuta';

  @override
  String get quickActionExpense => 'Nuova uscita';

  @override
  String get quickActionIncome => 'Nuova entrata';

  @override
  String get quickActionScan => 'Scansiona ricevuta';

  @override
  String recapTitle(String year) {
    return 'Il tuo $year';
  }

  @override
  String recapEarnedIn(String year) {
    return 'Nel $year hai guadagnato';
  }

  @override
  String recapSpentIn(String year) {
    return 'Nel $year hai speso';
  }

  @override
  String get recapYouSpent => 'Hai speso';

  @override
  String get recapYouKept => 'Ti sono rimasti';

  @override
  String recapKeptPercent(int percent) {
    return 'Il $percent% di quello che hai guadagnato';
  }

  @override
  String get recapMonthByMonth => 'Mese per mese';

  @override
  String recapMonthsHeadline(String high, String low) {
    return '$high il mese più caro, $low il più leggero';
  }

  @override
  String get recapMonthlyAverage => 'Media al mese';

  @override
  String get recapWhereItWent => 'Dove sono andati';

  @override
  String recapTopCategory(String category, int percent) {
    return '$category si è presa il $percent%';
  }

  @override
  String get recapBiggest => 'La spesa più grande';

  @override
  String recapBiggestNote(int percent) {
    return 'Senza contare le ricorrenze. Vale il $percent% di un mese medio di spese.';
  }

  @override
  String get recapRhythm => 'Il tuo ritmo';

  @override
  String recapRhythmBody(String weekday, int count) {
    return 'movimenti registrati. $weekday è il giorno più attivo, con $count movimenti.';
  }

  @override
  String get recapRecurring => 'Le tue ricorrenze';

  @override
  String recapRecurringHeadline(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricorrenze, $amount nell\'anno',
      one: '1 ricorrenza, $amount nell\'anno',
    );
    return '$_temp0';
  }

  @override
  String recapRecurringShare(int percent) {
    return 'Il $percent% delle uscite dell\'anno.';
  }

  @override
  String recapTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count addebiti',
      one: '1 addebito',
    );
    return '$_temp0';
  }

  @override
  String get recapGoals => 'I tuoi obiettivi';

  @override
  String recapGoalsHeadline(int reached, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      reached,
      locale: localeName,
      other: '$reached raggiunti su $total',
      one: '1 raggiunto su $total',
    );
    return '$_temp0';
  }

  @override
  String get recapGoalReached => 'Raggiunto';

  @override
  String recapGoalOf(String saved, String target) {
    return '$saved di $target';
  }

  @override
  String recapBudgetKept(int kept, int months) {
    return 'Budget rispettato in $kept mesi su $months';
  }

  @override
  String get recapBudgetsOnly => 'I tuoi budget';

  @override
  String recapComparedTo(String year) {
    return 'Rispetto al $year';
  }

  @override
  String recapSpentLess(int percent) {
    return 'Hai speso il $percent% in meno';
  }

  @override
  String recapSpentMore(int percent) {
    return 'Hai speso il $percent% in più';
  }

  @override
  String recapSavingFromTo(int from, int to) {
    return 'Risparmio dal $from% al $to%';
  }

  @override
  String get recapFirstYear => 'Il tuo primo anno';

  @override
  String recapStartedIn(String month) {
    return 'Hai iniziato a $month e non ti sei più fermato';
  }

  @override
  String get recapWholeYear => 'Un anno intero di movimenti';

  @override
  String get recapCategoriesUsed => 'Categorie usate';

  @override
  String get recapSaved => 'Messo da parte';

  @override
  String recapNextYear(String year) {
    return 'L\'anno prossimo qui vedrai il confronto con il $year.';
  }

  @override
  String get recapShare => 'Condividi';

  @override
  String get recapShareTitle => 'Condividi il tuo anno';

  @override
  String get recapShareImage => 'Condividi immagine';

  @override
  String get recapCopyText => 'Copia testo';

  @override
  String get recapTextCopied => 'Testo copiato';

  @override
  String get recapHideAmounts => 'Nascondi importi';

  @override
  String get recapHideAmountsCaption => 'Solo percentuali, nessuna cifra';

  @override
  String get recapMyYear => 'IL MIO ANNO';

  @override
  String get recapSpentShort => 'Speso';

  @override
  String get recapTopCategoryShort => 'Prima categoria';

  @override
  String recapVsYear(String percent, String year) {
    return '$percent% vs $year';
  }

  @override
  String recapOfIncome(int percent) {
    return '$percent% delle entrate';
  }

  @override
  String recapShareText(String year, String spent, String saved) {
    return 'Il mio $year con Pockets Vault: $spent spesi, $saved messi da parte.';
  }

  @override
  String recapShareTextHidden(String year, int percent) {
    return 'Il mio $year con Pockets Vault: messo da parte il $percent% delle entrate.';
  }

  @override
  String recapShareTextPlain(String year, int count) {
    return 'Il mio $year con Pockets Vault: $count movimenti registrati.';
  }

  @override
  String recapBannerTitle(String year) {
    return 'Il tuo $year in Pockets Vault';
  }

  @override
  String recapBannerBody(int count) {
    return 'Rivivi l\'anno in $count schede';
  }

  @override
  String recapOpen(String year) {
    return 'Riepilogo $year';
  }

  @override
  String recapCardOf(int index, int total) {
    return 'Scheda $index di $total';
  }

  @override
  String get recapNoData => 'Nessun movimento in quest\'anno.';

  @override
  String get widgetAvailable => 'Disponibile';

  @override
  String get widgetIncomeSpent => 'delle entrate già spese';

  @override
  String get widgetNoIncome => 'nessuna entrata nel mese';
}

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
  String get deleteAllQ => 'Sei sicuro di voler eliminare tutti i dati salvati?';

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
  String get addExpenseToViewGraph => 'Aggiungi una spesa per vedere il grafico';

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
  String get spentSameAsLastMonth => 'Questo mese stai spendendo come il mese scorso';

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
  String get deleteCategoryConfirm => 'Sei sicuro di voler eliminare questa categoria?';

  @override
  String get createPin => 'Crea PIN';

  @override
  String get confirmPin => 'Conferma PIN';

  @override
  String get enterPin => 'Inserisci PIN';

  @override
  String get enableBiometrics => 'Attiva lo sblocco biometrico';

  @override
  String get enableBiometricsMessage => 'Usa Face ID o l’impronta per sbloccare Pockets Vault?';

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
  String get encryptedBackupCaption => 'Cifratura AES-256, export CSV e ripristino locale';

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
  String get privateCategorization => 'Categorizzazione privata, senza inviare dati';

  @override
  String get noRules => 'Nessuna regola';

  @override
  String get noRulesHint => 'Puoi memorizzarne una mentre aggiungi un movimento.';

  @override
  String get availableToSpend => 'Disponibile da spendere';

  @override
  String get budgets => 'Budget';

  @override
  String get optionalMonthlyBudgets => 'Budget mensili facoltativi e modificabili in qualsiasi momento';

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
  String get rememberCategoryHint => 'Suggeriscila per descrizioni simili, solo sul dispositivo.';

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
  String get availableFormula => 'Entrate − spese − risparmi accantonati − ricorrenze previste';

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
  String get budgetPeriodHint => 'I limiti mensili sono proporzionati all’intervallo selezionato.';

  @override
  String get forecastRecurring => 'Previsione ricorrenze';

  @override
  String get forecastExplanation => 'Stima dal saldo attuale usando solo le ricorrenze programmate.';

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
  String get savingsReservedHint => 'Gli importi accantonati riducono il disponibile, ma restano parte del saldo.';

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
  String get deleteGoalReleasesFunds => 'I fondi accantonati torneranno disponibili. La cronologia resta conservata e i movimenti non vengono modificati.';

  @override
  String get goalDeleted => 'Obiettivo eliminato';

  @override
  String maximumAmount(Object amount) {
    return 'Massimo $amount';
  }

  @override
  String get receiptOptional => 'Ricevuta opzionale';

  @override
  String get receiptPurpose => 'Legge importo, data, esercente e categoria direttamente sul dispositivo.';

  @override
  String get receiptStoredLocally => 'Scansione privata sul dispositivo, con revisione prima del salvataggio.';

  @override
  String get receiptLinked => 'Allegata a questo movimento';

  @override
  String get receiptPermissionDenied => 'Permesso non concesso. Abilita foto e fotocamera nelle Impostazioni.';

  @override
  String get cameraUnavailable => 'Fotocamera non disponibile su questo dispositivo.';

  @override
  String get libraryUnavailable => 'Libreria foto non disponibile su questo dispositivo.';

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
  String get importModeExplanation => 'Unisci mantiene i dati attuali e aggiorna gli elementi con lo stesso identificativo. Sostituisci cancella prima tutti i dati finanziari locali.';

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
  String get savingsUpdateFailed => 'Impossibile aggiornare l’obiettivo di risparmio.';

  @override
  String get hideAmounts => 'Nascondi importi';

  @override
  String get showAmounts => 'Mostra importi';

  @override
  String get scanReceipt => 'Scansiona ricevuta';

  @override
  String get receiptScanHint => 'Fotografa o scegli una ricevuta per compilare automaticamente la spesa.';

  @override
  String get scanWithCamera => 'Scansiona con la fotocamera';

  @override
  String get scanFromLibrary => 'Scansiona una foto';

  @override
  String get cameraFlash => 'Flash';

  @override
  String get receiptScanReview => 'Controlla la scansione';

  @override
  String get receiptScanCheckData => 'Abbiamo trovato questi dati. Controllali e correggili prima di continuare.';

  @override
  String get receiptScanNoData => 'Non abbiamo trovato dati affidabili. Inseriscili manualmente o allega soltanto la foto.';

  @override
  String get receiptMerchant => 'Esercente';

  @override
  String get receiptScanPrivate => 'OCR e analisi avvengono interamente su questo dispositivo.';

  @override
  String get attachOnly => 'Solo allegato';

  @override
  String get useDetectedData => 'Usa i dati';

  @override
  String get receiptScanApplied => 'Dati della ricevuta applicati. Controlla e salva il movimento.';

  @override
  String get receiptScanning => 'Analisi della ricevuta…';

  @override
  String get dataTemporarilyUnavailable => 'Dati temporaneamente non disponibili.';

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
  String get statsElapsedHint => 'Per il mese corrente confronta gli stessi giorni di ciascun mese di riferimento.';

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
  String get statsNoEarlierMonths => 'Gennaio non ha mesi precedenti nello stesso anno. Scegli un altro confronto.';

  @override
  String get statsZeroReference => 'Percentuale non disponibile: il valore di riferimento è zero.';

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
  String get statsHiddenChart => 'Grafico nascosto quando la privacy degli importi è attiva.';

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
  String get statsOpenCategoryHint => 'Apri la categoria per vedere i movimenti';

  @override
  String statsExpenseVersus(Object period) {
    return 'di spese rispetto a $period';
  }

  @override
  String statsIncomeVersus(Object period) {
    return 'di entrate rispetto a $period';
  }
}

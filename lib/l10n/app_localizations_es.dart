// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Pockets Vault';

  @override
  String get addTransaction => 'Agregar movimiento';

  @override
  String get saveTransaction => 'Guardar movimiento';

  @override
  String get editTransaction => 'Editar movimiento';

  @override
  String get amount => 'Importe';

  @override
  String get category => 'Categoría';

  @override
  String get selectCategory => 'Seleccionar categoría';

  @override
  String get date => 'Fecha';

  @override
  String get note => 'Nota';

  @override
  String get income => 'Ingreso';

  @override
  String get expense => 'Gasto';

  @override
  String get incomes => 'Ingresos';

  @override
  String get expenses => 'Gastos';

  @override
  String get transactionSaved => 'Movimiento guardado';

  @override
  String get recentTransactions => 'Movimientos recientes';

  @override
  String get noTransactions => 'Sin movimientos';

  @override
  String get total => 'Total';

  @override
  String get month => 'Mes';

  @override
  String get transactions => 'Movimientos';

  @override
  String get stats => 'Estadísticas';

  @override
  String get settings => 'Configuración';

  @override
  String get lfTransactions => 'Buscar movimientos';

  @override
  String get newCategory => 'Nueva categoría';

  @override
  String get nameCategory => 'Nombre de la categoría';

  @override
  String get cancel => 'Cancelar';

  @override
  String get add => 'Agregar';

  @override
  String get expensesDistribution => 'Distribución de gastos';

  @override
  String get noExpenses => 'Sin gastos';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get data => 'Datos';

  @override
  String get cancelAll => 'Eliminar todos los datos';

  @override
  String get categoryRemoved => 'Categoría eliminada';

  @override
  String get balance => 'Balance';

  @override
  String get removeTransactionQ => '¿Eliminar movimiento?';

  @override
  String get youSure => 'Esta acción no se puede deshacer.';

  @override
  String get delete => 'Eliminar';

  @override
  String get transactionDeleted => 'Movimiento eliminado';

  @override
  String get confirm => 'Confirmar';

  @override
  String get deleteAllQ => '¿Seguro que deseas eliminar todos los datos guardados?';

  @override
  String get salary => 'Salario';

  @override
  String get bonus => 'Bonificación';

  @override
  String get gift => 'Regalo';

  @override
  String get food => 'Comida';

  @override
  String get groceries => 'Supermercado';

  @override
  String get transport => 'Transporte';

  @override
  String get rent => 'Alquiler';

  @override
  String get bills => 'Facturas';

  @override
  String get shopping => 'Compras';

  @override
  String get health => 'Salud';

  @override
  String get entertainment => 'Entretenimiento';

  @override
  String get travel => 'Viajes';

  @override
  String get education => 'Educación';

  @override
  String get otherCategory => 'Otros';

  @override
  String get recurrents => 'Recurrentes';

  @override
  String get security => 'Seguridad';

  @override
  String get everyMonth => 'Cada mes';

  @override
  String get active => 'Activo';

  @override
  String get modify => 'Editar';

  @override
  String get pause => 'Pausar';

  @override
  String get recurrent => 'Recurrente';

  @override
  String get recurrentMsg => 'Activar para repetir cada mes';

  @override
  String get color => 'Color';

  @override
  String get day => 'Día';

  @override
  String get modifyRecurrent => 'Editar movimiento recurrente';

  @override
  String get modifyCategory => 'Editar categoría';

  @override
  String get noRecurrent => 'No hay movimientos recurrentes';

  @override
  String get reactivate => 'Reactivar';

  @override
  String get reactivateMsg => 'Movimiento recurrente reactivado';

  @override
  String get reactivatePauseMsg => 'Movimiento recurrente pausado';

  @override
  String get dayOfMonth => 'Día del mes';

  @override
  String get save => 'Guardar';

  @override
  String get recurringCreationMsg => 'Movimiento recurrente creado ';

  @override
  String get deleteMovement => '¿Eliminar movimiento?';

  @override
  String get deleteMovementSure => 'Esta acción no se puede deshacer';

  @override
  String get deletedMovement => 'Movimiento eliminado';

  @override
  String get addExpenseToViewGraph => 'Agrega un gasto para ver el gráfico';

  @override
  String get selectYear => 'Seleccionar año';

  @override
  String get existingCategory => 'La categoría ya existe';

  @override
  String get saveCategory => 'Guardar categoría';

  @override
  String get canceledAll => 'Todos los datos han sido eliminados';

  @override
  String get searchBar => 'Busca movimiento';

  @override
  String get paused => 'Pausado';

  @override
  String savedMore(Object value) {
    return 'Este mes has gastado un $value% menos que el mes pasado';
  }

  @override
  String spentMore(Object value) {
    return 'Este mes has gastado un $value% más que el mes pasado';
  }

  @override
  String get period => 'Período';

  @override
  String get selectPeriod => 'Seleccionar período';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get mostUsedCategories => 'Categorías más usadas';

  @override
  String get otherCategories => 'Otras';

  @override
  String get deleteCategory => 'Eliminar categoría';

  @override
  String get deleteCategoryConfirm => '¿Estás seguro de que deseas eliminar esta categoría?';

  @override
  String get createPin => 'Crear PIN';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get enterPin => 'Introducir PIN';

  @override
  String get enableBiometrics => 'Activar desbloqueo biométrico';

  @override
  String get enableBiometricsMessage => '¿Usar Face ID o la huella para desbloquear Pockets Vault?';

  @override
  String get notNow => 'Ahora no';

  @override
  String get enable => 'Activar';

  @override
  String get biometricUnlock => 'Desbloqueo biométrico';

  @override
  String get deleteDigit => 'Borrar dígito';

  @override
  String get clearPin => 'Borrar PIN';

  @override
  String get home => 'Inicio';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get mainCurrency => 'Moneda principal';

  @override
  String get updateRates => 'Actualizar tipos';

  @override
  String get automaticLock => 'Bloqueo automático';

  @override
  String get backupPortability => 'Copia y portabilidad';

  @override
  String get encryptedBackupCaption => 'Cifrado AES-256, exportación CSV y restauración local';

  @override
  String get exportEncryptedBackup => 'Exportar copia cifrada';

  @override
  String get exportTransactionsCsv => 'Exportar movimientos CSV';

  @override
  String get importBackup => 'Importar copia';

  @override
  String get safeMergeOrReplace => 'Fusión segura o sustitución completa';

  @override
  String get localSmartRules => 'Reglas inteligentes locales';

  @override
  String get privateCategorization => 'Categorización privada sin enviar datos';

  @override
  String get noRules => 'Sin reglas';

  @override
  String get noRulesHint => 'Puedes guardar una al añadir un movimiento.';

  @override
  String get availableToSpend => 'Disponible para gastar';

  @override
  String get budgets => 'Presupuestos';

  @override
  String get optionalMonthlyBudgets => 'Presupuestos mensuales opcionales y siempre editables';

  @override
  String get noBudget => 'Sin presupuesto';

  @override
  String get forecast90Days => 'Previsión a 90 días';

  @override
  String get noForecastMovements => 'No hay movimientos recurrentes previstos.';

  @override
  String get savingsGoals => 'Objetivos de ahorro';

  @override
  String get manage => 'Gestionar';

  @override
  String get createGoalHint => 'Crea un objetivo y controla tu progreso.';

  @override
  String get newGoal => 'Nuevo objetivo';

  @override
  String get noGoals => 'Sin objetivos';

  @override
  String get rememberCategory => 'Recordar esta categoría';

  @override
  String get rememberCategoryHint => 'Sugerirla para descripciones similares, solo en este dispositivo.';

  @override
  String get addReceipt => 'Añadir recibo';

  @override
  String get receiptAttached => 'Recibo adjunto';

  @override
  String get takePhoto => 'Hacer una foto';

  @override
  String get chooseLibrary => 'Elegir de la galería';

  @override
  String get repeatEvery => 'Repetir cada';

  @override
  String get endDate => 'Fecha de fin';

  @override
  String get none => 'Ninguna';

  @override
  String get undo => 'Deshacer';

  @override
  String get recurrenceDeleted => 'Recurrencia eliminada';

  @override
  String get availableThisMonth => 'Disponible este mes';

  @override
  String get availableAllTime => 'Disponible total';

  @override
  String get availableForPeriod => 'Disponible en el período';

  @override
  String get availableFormula => 'Ingresos − gastos − ahorro reservado − pagos recurrentes previstos';

  @override
  String get reservedSavings => 'Reservado';

  @override
  String get scheduledUpcoming => 'Próximas transacciones';

  @override
  String get categoryLimits => 'Límites por categoría';

  @override
  String activeBudgets(Object count) {
    return '$count activos';
  }

  @override
  String remainingBudget(Object amount) {
    return 'Quedan $amount';
  }

  @override
  String budgetExceededBy(Object amount) {
    return 'Superado en $amount';
  }

  @override
  String get setOptionalLimit => 'Establecer un límite opcional';

  @override
  String budgetForCategory(Object category) {
    return 'Presupuesto mensual · $category';
  }

  @override
  String amountInCurrency(Object currency) {
    return 'Importe en $currency';
  }

  @override
  String get enterPositiveAmount => 'Introduce un importe mayor que cero.';

  @override
  String get budgetDeleted => 'Presupuesto eliminado';

  @override
  String get budgetPeriodHint => 'Los límites mensuales se prorratean al intervalo seleccionado.';

  @override
  String get forecastRecurring => 'Previsión de recurrencias';

  @override
  String get forecastExplanation => 'Estimación desde el saldo actual usando solo movimientos recurrentes programados.';

  @override
  String get currentBalance => 'Saldo actual';

  @override
  String forecastAfter(Object duration) {
    return 'En $duration';
  }

  @override
  String recurringIncluded(Object count) {
    return '$count movimientos recurrentes incluidos en el cálculo.';
  }

  @override
  String get oneMonth => '1 mes';

  @override
  String monthsCount(Object count) {
    return '$count meses';
  }

  @override
  String get oneYear => '1 año';

  @override
  String yearsCount(Object count) {
    return '$count años';
  }

  @override
  String get savingsReservedHint => 'Los importes reservados reducen lo disponible para gastar, pero siguen formando parte del saldo.';

  @override
  String allocatedInSelection(Object amount) {
    return 'Reservado en este período: $amount';
  }

  @override
  String get reserveFunds => 'Reservar';

  @override
  String get releaseFunds => 'Liberar fondos';

  @override
  String get addSavings => 'Añadir ahorro';

  @override
  String get releaseSavings => 'Liberar ahorro';

  @override
  String get goalName => 'Nombre';

  @override
  String goalTarget(Object name) {
    return 'Objetivo · $name';
  }

  @override
  String get deleteGoal => '¿Eliminar este objetivo?';

  @override
  String get deleteGoalReleasesFunds => 'Los fondos reservados volverán a estar disponibles. El historial se conserva y los movimientos no se modifican.';

  @override
  String get goalDeleted => 'Objetivo eliminado';

  @override
  String maximumAmount(Object amount) {
    return 'Máximo $amount';
  }

  @override
  String get receiptOptional => 'Recibo opcional';

  @override
  String get receiptPurpose => 'Lee importe, fecha, comercio y categoría directamente en el dispositivo.';

  @override
  String get receiptStoredLocally => 'Escaneo privado en el dispositivo, con revisión antes de guardar.';

  @override
  String get receiptLinked => 'Adjunto a este movimiento';

  @override
  String get receiptPermissionDenied => 'Permiso denegado. Activa fotos y cámara en Ajustes.';

  @override
  String get cameraUnavailable => 'Cámara no disponible en este dispositivo.';

  @override
  String get libraryUnavailable => 'Galería no disponible en este dispositivo.';

  @override
  String get receiptAttachFailed => 'No se ha podido adjuntar el recibo.';

  @override
  String convertedToMainCurrency(Object amount) {
    return '≈ $amount en la moneda principal';
  }

  @override
  String get conversionOnSave => 'El tipo de cambio se calculará al guardar.';

  @override
  String get ecbRefreshNeeded => 'Conversión BCE · actualización necesaria';

  @override
  String ecbRatesDate(Object date) {
    return 'Tipos BCE del $date';
  }

  @override
  String get rateApp => 'Valorar la app';

  @override
  String get shareApp => 'Compartir la app';

  @override
  String get protectBackup => 'Proteger copia';

  @override
  String get unlockBackup => 'Desbloquear copia';

  @override
  String get continueAction => 'Continuar';

  @override
  String get exportCanceled => 'Exportación cancelada.';

  @override
  String get backupReady => 'Copia lista para guardar o compartir.';

  @override
  String get csvReady => 'CSV listo para guardar o compartir.';

  @override
  String get importMode => 'Modo de importación';

  @override
  String get importModeExplanation => 'Fusionar conserva los datos actuales y actualiza los elementos con el mismo identificador. Sustituir elimina primero todos los datos financieros locales.';

  @override
  String get merge => 'Fusionar';

  @override
  String get replace => 'Sustituir';

  @override
  String get backupRestored => 'Copia restaurada correctamente.';

  @override
  String get minimumPassword => 'Usa al menos 8 caracteres.';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get minimumEightCharacters => 'Mínimo 8 caracteres';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get changeCurrency => 'Cambiar moneda';

  @override
  String recursEvery(Object frequency, Object interval) {
    return 'Cada $interval $frequency';
  }

  @override
  String get savingsUpdateFailed => 'No se ha podido actualizar el objetivo de ahorro.';

  @override
  String get hideAmounts => 'Ocultar importes';

  @override
  String get showAmounts => 'Mostrar importes';

  @override
  String get scanReceipt => 'Escanear recibo';

  @override
  String get receiptScanHint => 'Haz o elige una foto del recibo para completar automáticamente el gasto.';

  @override
  String get scanWithCamera => 'Escanear con la cámara';

  @override
  String get scanFromLibrary => 'Escanear una foto';

  @override
  String get cameraFlash => 'Flash';

  @override
  String get receiptScanReview => 'Revisar escaneo';

  @override
  String get receiptScanCheckData => 'Hemos encontrado estos datos. Revísalos y corrígelos antes de continuar.';

  @override
  String get receiptScanNoData => 'No encontramos datos fiables. Introdúcelos manualmente o adjunta solo la foto.';

  @override
  String get receiptMerchant => 'Comercio';

  @override
  String get receiptScanPrivate => 'El OCR y el análisis se realizan íntegramente en este dispositivo.';

  @override
  String get attachOnly => 'Solo adjuntar';

  @override
  String get useDetectedData => 'Usar datos';

  @override
  String get receiptScanApplied => 'Datos del recibo aplicados. Revisa y guarda el movimiento.';

  @override
  String get receiptScanning => 'Analizando recibo…';

  @override
  String get dataTemporarilyUnavailable => 'Datos temporalmente no disponibles.';

  @override
  String get retry => 'Reintentar';

  @override
  String get yourMonth => 'Tu mes';

  @override
  String get byCategory => 'Por categoría';

  @override
  String get statsOverview => 'Resumen';

  @override
  String get statsCategories => 'Categorías';

  @override
  String get statsComparisons => 'Comparar';

  @override
  String get statsTrend => 'Evolución acumulada';

  @override
  String get statsBreakdown => 'Dónde gastas';

  @override
  String get statsWhatChanged => 'Qué ha cambiado';

  @override
  String get statsChangeDrivers => 'A qué se debe';

  @override
  String get statsPreviousMonth => 'Mes anterior';

  @override
  String get statsChooseMonth => 'Elegir un mes';

  @override
  String get statsYearAverage => 'Media de meses anteriores del año';

  @override
  String get statsCompareWith => 'Comparar con';

  @override
  String get statsComparisonPeriod => 'Periodo de comparación';

  @override
  String get statsPrimaryMonth => 'Mes que analizar';

  @override
  String get statsReferenceMonth => 'Mes de referencia';

  @override
  String get statsElapsedDays => 'Alinear días transcurridos';

  @override
  String get statsElapsedHint => 'Para el mes actual compara los mismos días de cada mes de referencia.';

  @override
  String statsThroughDay(int day) {
    return 'Días 1–$day de cada mes';
  }

  @override
  String get statsWholeMonths => 'Meses seleccionados enteros';

  @override
  String statsAverageBasis(int count) {
    return 'Media de $count meses, incluidos los que no tienen movimientos.';
  }

  @override
  String get statsNoEarlierMonths => 'Enero no tiene meses anteriores en el mismo año. Elige otra comparación.';

  @override
  String get statsZeroReference => 'Porcentaje no disponible: el importe de referencia es cero.';

  @override
  String get statsNet => 'Ingresos − gastos';

  @override
  String get statsShowTransactions => 'Ver movimientos';

  @override
  String get statsDragHint => 'Desliza sobre el gráfico para explorar';

  @override
  String get statsForecastToday => 'Previsión recurrente desde hoy';

  @override
  String get statsCompareHint => 'Elige aquí los meses que comparar.';

  @override
  String get statsRecordedOnly => 'Movimientos registrados';

  @override
  String get statsMonthTitle => 'Seleccionar mes';

  @override
  String get statsCategoryChange => 'Cambio por categoría';

  @override
  String get statsCurrent => 'Mes seleccionado';

  @override
  String get statsReference => 'Referencia';

  @override
  String get statsHiddenChart => 'Gráfico oculto mientras la privacidad de importes está activa.';

  @override
  String get statsAllTime => 'Todas las fechas registradas';

  @override
  String get statsComparisonUnavailable => 'Sin periodo de referencia';

  @override
  String statsTransactionCount(int count) {
    return '$count movimientos';
  }

  @override
  String statsPercentage(String value) {
    return '$value%';
  }

  @override
  String statsVersus(String period) {
    return 'Respecto a $period';
  }

  @override
  String get statsAverageLabel => 'Media';

  @override
  String get statsMonthlyExpenses => 'Gastos del mes';

  @override
  String get statsMonthlyIncome => 'Ingresos del mes';

  @override
  String get statsPeriodExpenses => 'Gastos del período';

  @override
  String get statsPeriodIncome => 'Ingresos del período';

  @override
  String get statsTotalExpenses => 'Gastos totales';

  @override
  String get statsTotalIncome => 'Ingresos totales';

  @override
  String get statsPreviousPeriod => 'período anterior';

  @override
  String statsRangeCaption(Object period) {
    return 'Comparación: $period';
  }

  @override
  String statsSpentLess(Object amount) {
    return '$amount menos de gastos';
  }

  @override
  String statsSpentMore(Object amount) {
    return '$amount más de gastos';
  }

  @override
  String statsIncomeLess(Object amount) {
    return '$amount menos de ingresos';
  }

  @override
  String statsIncomeMore(Object amount) {
    return '$amount más de ingresos';
  }

  @override
  String statsMainVariation(Object category) {
    return '$category es la variación principal';
  }

  @override
  String statsExplainsDrop(Object category) {
    return '$category explica la bajada';
  }

  @override
  String statsExplainsRise(Object category) {
    return '$category explica el aumento';
  }

  @override
  String get statsOpenCategoryHint => 'Abre la categoría para ver los movimientos';

  @override
  String statsExpenseVersus(Object period) {
    return 'de gastos respecto a $period';
  }

  @override
  String statsIncomeVersus(Object period) {
    return 'de ingresos respecto a $period';
  }
}

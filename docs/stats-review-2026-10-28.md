# Statistiche — implementazione e verifica

Aggiornamento del 28 ottobre 2026, sulla base grafica Vault con palette Essenziale già approvata. Nessuna funzione di acquisizione automatica e nessuna pubblicazione di siti o sugli store.

## Comportamento

- Tre viste: Panoramica, Categorie e Confronti. Le prime due leggono lo stesso `timeFilterProvider` usato da Home e Movimenti, nelle modalità Totale, Mese e Periodo. Il selettore in alto permette tutte e tre le modalità, con scelta di mese/anno e intervallo di date.
- In Confronti il selettore globale è nascosto. Il pulsante accanto a «Cosa è cambiato» controlla solo questa vista e non modifica il filtro di Home. All'apertura iniziale il confronto è mese corrente contro mese precedente.
- Il confronto può usare un altro mese/anno oppure la media da gennaio al mese precedente al mese analizzato. La media include i mesi senza movimenti; il denominatore viene dichiarato nell'interfaccia. Gennaio ha uno stato esplicito senza riferimento, senza divisione per zero.
- Per il mese corrente si possono allineare i giorni trascorsi: ogni riferimento termina al giorno corrispondente, limitato all'ultimo giorno effettivo del mese. Disattivando l'opzione si confrontano gli interi mesi selezionati. La modalità viene indicata vicino ai risultati.
- Uscite ed entrate sono selezionabili in tutte le viste. «Entrate − uscite» indica il saldo dei movimenti selezionati, distinto dal disponibile di Home, che include accantonamenti e ricorrenze in arrivo.
- Il grafico cumulato ha assi e lettura del valore/data trascinando il dito. Totale e periodi lunghi aggregano per mese o anno mantenendo distinti gli anni. Nel mese corrente la linea termina a oggi, o all'ultima data registrata se successiva.
- Categorie selezionabili dall'anello o dalle righe, con dettaglio dei movimenti. Scorrere verticalmente sull'anello non cambia selezione. Anche il dettaglio già aperto segue privacy e variazioni della valuta principale.
- Privacy condivisa con Home: nasconde importi, percentuali, assi e grafici quantitativi, senza lasciare un tooltip o un'animazione con valori precedenti. Le animazioni seguono l'impostazione di riduzione movimento del sistema.
- Le previsioni ricorrenti esistenti restano accessibili con un comando esplicitamente «da oggi» e conservano il loro orizzonte temporale indipendente. Non vengono presentate come dati storici del periodo selezionato.

## Allineamento grafico ai tre riferimenti approvati

- Marchio con portafoglio sottile, titolo, selettore compatto e tre tab sottolineati. La barra di navigazione assume il disegno del riferimento nella sezione Statistiche; le altre pagine conservano il disegno approvato precedente.
- Panoramica: importo principale, badge percentuale, linea cumulata indaco con area, riferimento grigio tratteggiato, etichette finali, indicatori di entrate e saldo, evidenza della variazione principale e categorie compatte. La selezione entrate/uscite è nel menu del titolo della scheda.
- Categorie: anello uniforme indaco/blu/ardesia, righe con importo e percentuale affiancati, dettaglio della categoria e confronto con il periodo precedente, pulsante per i movimenti. Le icone predefinite sono contornate; quelle delle categorie personalizzate mantengono il simbolo salvato.
- Confronti: selettore locale accanto al titolo, variazione in colore testo, badge positivo/negativo, barre con asse e valori, righe di categorie con coppie di barre e badge della differenza. Il selettore globale resta nascosto, come richiesto anche se presente nel mockup originale.
- Le informazioni della Panoramica e del dettaglio seguono il periodo condiviso. Un mese usa il precedente allineato agli stessi giorni e limitato alla lunghezza effettiva; un periodo personalizzato usa i giorni immediatamente precedenti di pari durata. Totale non inventa un riferimento storico. La scheda di evidenza apre la categoria nel periodo che l'ha generata.
- Le etichette sintetiche sopprimono solo decimali effettivamente nulli: non arrotondano i centesimi e rispettano le valute senza decimali. Gli assi usano etichette abbreviate; i dati e i dettagli restano precisi.

Le catture finali in `build/review/stats-*.png` mostrano l'app Flutter reale con dati sintetici ripartiti giornalmente: 940 € di spese, 2.800 € di entrate e 1.100 € di spese nel riferimento. Le etichette delle categorie provengono dalle categorie predefinite, senza rinominare dati salvati. Importi e didascalie sono calcolati dall'app, non sovrapposti alle immagini. Font, area di sicurezza e elementi del sistema operativo possono differire dai mockup iPhone.

## Compatibilità dei dati

Nessuna modifica a schema SQLite (versione 11), file del database, formato del backup, migrazioni, dipendenze o autorizzazioni native. I nuovi calcoli sono proiezioni in memoria dei movimenti già registrati nella valuta principale; non rigenerano ricorrenze, non riscrivono importi e non cambiano gli ID.

Le medie utilizzano aritmetica intera alle unità minime della valuta e distribuiscono i resti in modo deterministico: le variazioni per categoria conservano il totale arrotondato. Sono verificati anche valori oltre l'intervallo intero esatto dei `double` e valori con segno provenienti da archivi legacy.

Sono state corrette due incoerenze dei filtri esistenti necessarie alla sincronizzazione: selezione dell'anno nel selettore dei mesi di Movimenti e inclusione dell'intera giornata finale nei periodi. La sincronizzazione esterna del selettore evita inoltre di pubblicare i mesi intermedi attraversati dall'animazione. Il riepilogo dashboard rispetta il mese esplicitamente richiesto dalla query. I calendari di Home e Movimenti estendono i propri limiti per includere un periodo condiviso già selezionato, anche storico o futuro: riaprire quel periodo non causa un errore di validazione del calendario.

## Verifiche

- Suite completa: **157 test superati**, inclusi i test esistenti su database legacy/migrazioni, backup/ripristino, valute, ricorrenze, budget, obiettivi, ricevute e blocco dell'app.
- Nuovi test dei calcoli: periodo inclusivo, anni distinti, bisestili, aggregazioni lunghe, giorni di cambio ora, giorni vuoti, confronti personalizzati, allineamento dei giorni, media con mesi a zero, gennaio, riferimento zero, arrotondamenti, categorie scomparse, entrate e valori elevati. Aggiunti casi specifici per il riferimento della Panoramica: febbraio/gennaio, mesi più corti, intervalli personalizzati attraverso il cambio d’ora e aggregazioni mensili allineate per giorni trascorsi.
- Test dell'interfaccia: filtro condiviso, annullamento della selezione, selezione del periodo, mese/anno di confronto indipendenti, media, trascinamento, privacy immediata, dettaglio aperto durante un cambio valuta, archivio identico prima/dopo la consultazione, dati vuoti e accesso alle previsioni. Verificati inoltre centesimi nelle etichette sintetiche, rimozione della linea di riferimento su Totale e apertura dell’evidenza nel corretto periodo storico. Verificata la riapertura dei periodi trasferiti da Statistiche nei calendari di Home e Movimenti, compresi anni prima e dopo i precedenti limiti.
- Matrice responsive: italiano, inglese e spagnolo; chiaro e scuro; larghezza di 320 px e testo al 150%, incluse le opzioni del confronto.
- **5 test nativi Android superati**: dashboard, statistiche, asset nativi, transazioni ricorrenti e OCR. Il test delle statistiche usa il database reale in memoria e l'app completa, verifica il passaggio del filtro a Home, l'indipendenza dei confronti e uno snapshot finanziario invariato.
- Catture reali con `flutter drive`, su dati dimostrativi: panoramica, categorie, dettagli, confronto, selezione della media e privacy. Non sono immagini generate o dati personali.

La build release e l'analisi statica sono registrate nei log di verifica finali in `build/review/`. L'assenza di Xcode completo su questo Mac impedisce il collaudo iOS: le schermate sono dell'emulatore Android eseguito sul Mac. Nessun test su iPhone fisico viene dichiarato come eseguito.

## File principali

- `lib/features/stats/domain/stats_analysis.dart`: aggregazioni e confronti senza accesso in scrittura al database.
- `lib/features/stats/presentation/stats_page.dart`: tre viste e integrazione con stato condiviso.
- `lib/features/stats/widgets/stats_period_controls.dart`: selettori globale e locale.
- `lib/features/stats/widgets/stats_visuals.dart`: grafici, interazione e animazioni.
- `test/features/stats/`: test dei calcoli e dell'interfaccia.
- `integration_test/stats_design_integration_test.dart`: collaudo dell'app e catture.

Le modifiche al restyling di Home già presenti nel checkout sono state conservate; non sono state ripristinate o sostituite.

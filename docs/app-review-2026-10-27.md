# Verifica dell’app e proposte — 27 ottobre 2026

## Modifica realizzata

La scheda iniziale mostra **Transazioni in arrivo**, con due totali distinti:

- **+2.000,00 €** per la somma delle entrate ricorrenti previste.
- **−400,00 €** per la somma delle uscite ricorrenti previste.

Gli importi sono esempi. Ogni direzione compare soltanto quando ha un importo previsto; i movimenti non vengono elencati né compensati tra loro. Nel restyling approvato i due totali sono impilati e allineati a destra.

Il calcolo segue il mese o il periodo selezionato e considera tutte le occorrenze future delle ricorrenze attive. Esclude quelle terminate o fuori intervallo e le scadenze di oggi, che l’app genera già come movimenti effettivi. La vista Totale mantiene il comportamento esistente: nessuna previsione senza una data finale.

Le traduzioni italiana, inglese e spagnola sono aggiornate. Il comando per nascondere gli importi copre anche i nuovi totali e le loro etichette per i lettori di schermo.

Il valore **Disponibile** mantiene la formula esistente: entrate registrate − uscite registrate − uscite ricorrenti previste − accantonamenti. Le entrate future sono visibili ma non considerate già incassate. Un eventuale saldo previsto comprensivo delle entrate future merita un’etichetta dedicata, come proposto sotto.

## Restyling approvato e applicato

- Palette **Essenziale**: indaco, superfici neutre e colori dedicati ai temi chiaro e scuro.
- Struttura **Vault**: saldo in primo piano, metriche separate da divisori sottili, schede leggere, filtro temporale sottolineato e navigazione inferiore a capsula.
- Home con intestazione dell’app, selettore compatto del mese e riepilogo per categoria più compatto. Dati, calcoli, filtri e azioni usano i provider esistenti.
- Pulsanti flottanti mantenuti sulla destra: superficie dello scanner da 40 punti sopra il pulsante “+” da 56 punti, con area di tocco accessibile. L’icona della fotocamera è sostituita da una cornice di scansione con una linea centrale, disegnata come vettore Flutter.
- Spazio riservato per lasciare leggibili importi degli obiettivi, categorie e controlli vicini ai pulsanti. Layout adattivo con testo ingrandito.
- Nessuna nuova dipendenza e nessun cambiamento ai flussi di inserimento, scansione, gestione degli obiettivi o al calcolo del disponibile.

Schermate Android con dati di prova: [chiaro](../build/review/vault-essenziale-light.png), [scuro](../build/review/vault-essenziale-dark.png), [categorie](../build/review/vault-essenziale-categories.png).

## Controlli effettuati — verifica approfondita

- Analisi statica dell’intero progetto con `flutter analyze`.
- Suite completa di **109 test superati**: database e migrazioni, ricorrenze, conversioni, backup cifrato e ripristino, CSV, blocco automatico, ricevute, statistiche, budget e obiettivi. Include la home con dati, tre lingue, due temi, larghezza di 320 punti e testo al 150%, oltre al selettore compatto e ai pulsanti originali.
- Nuovi casi per entrate e uscite aggregate, ricorrenze settimanali, sospese e terminate, mesi passati e futuri, estremi del periodo e scadenze di oggi.
- Verifica della nuova scheda nelle tre lingue, con tema chiaro e scuro, larghezza di 320 punti, testo al 150% e importi elevati.
- Giro aggiuntivo dell’interfaccia con database temporaneo: apertura delle quattro sezioni, inserimento e salvataggio di una spesa, ricerca del movimento, pausa di una ricorrenza e aggiornamento del riepilogo iniziale.
- Riproduzione automatizzata delle due anomalie descritte sotto e controllo visivo della home con dati di prova.
- Matrice aggiuntiva di 25 casi: entrambe le direzioni, frequenze giornaliera/settimanale/mensile/annuale, intervalli multipli, febbraio bisestile, giorno 31, cambio d’anno, periodi di un solo giorno, inizio/fine inclusivi, importi elevati e somme uguali che restano separate.
- Quattro test aggiuntivi con database e provider reali: pausa/riattivazione, eliminazione/ripristino, modifica dell’importo in valuta estera, cambio valuta principale EUR/USD/JPY, cambio dei filtri e passaggio da scadenza futura a movimento effettivo senza duplicati.
- **Quattro test nativi Android** sull’emulatore API 35: accesso alla cartella documenti, riconoscimento OCR di uno scontrino generato localmente, avvio dell’app e navigazione tra le quattro sezioni con verifica dei totali, privacy e pausa/riattivazione, nuovo layout nei due temi e assenza di sovrapposizioni con i pulsanti.
- Acquisizione e controllo visivo di tre schermate reali tramite `flutter drive`, con fixture in memoria e temi chiaro/scuro.
- **Build Android debug e release completate.** Per la release è stata eseguita la rigenerazione ordinaria dei metadati dei plugin dopo i test nativi; non sono state modificate configurazioni di compilazione o dipendenze.
- Copertura dei calcoli rilevata prima del restyling: funzione `buildBudgetOverview` 50/51; intero provider budget 120/134; calcolatore delle ricorrenze 53/60. Questi file non sono stati modificati durante il restyling. La copertura misura il codice attraversato, non garantisce l’assenza di errori.

Resta da eseguire il collaudo su dispositivi fisici. La toolchain Xcode è incompleta, quindi build iOS, simulatore iOS e Face ID non sono stati verificati. Il test Android ha esercitato l’OCR nativo su un’immagine locale; la fotocamera fisica e i relativi permessi restano da provare su telefono.

Su indicazione dell’utente, le anomalie residue e le evoluzioni funzionali descritte sotto restano **in sospeso**. È stato applicato soltanto il restyling approvato, oltre alla modifica iniziale delle transazioni in arrivo.

## Anomalie preesistenti confermate, non modificate

### 1. Il cambio d’anno può lasciare i dati sull’anno precedente

**Riproduzione:** aprire il selettore dell’anno e scegliere un altro anno mantenendo lo stesso mese. L’etichetta cambia, ma il provider del filtro conserva l’anno precedente fino a un successivo cambio di mese.

**Causa:** il selettore aggiorna `selected` prima di chiamare `updateMonth`; quest’ultimo trova già la stessa selezione e termina senza notificare il filtro.

Il nuovo selettore compatto della home aggiorna correttamente mese e anno ed è coperto da test dedicati. La segnalazione resta aperta per la variante precedente usata nelle altre schermate.

**Riferimento:** [revolut_month_selector.dart](../lib/features/dashboard/widgets/revolut_month_selector.dart), selezione dell’anno e metodo `updateMonth`.

**Proposta:** aggiornare il filtro nello stesso passaggio della scelta dell’anno. Rendere inoltre selezionabili gli anni futuri e tradurre il titolo “Select year”. Attualmente la finestra propone soltanto l’anno corrente e quelli precedenti.

### 2. Nei grafici un periodo può escludere quasi tutto l’ultimo giorno

**Riproduzione:** inserire una spesa il 31 luglio alle 12:00 e selezionare 1–31 luglio. La home la comprende; alcune elaborazioni delle statistiche confrontano invece la data con il 31 luglio alle 00:00 e la escludono.

**Causa:** il riepilogo e i grafici usano confronti diretti con la data finale, mentre la scheda iniziale usa già l’intera giornata.

**Riferimenti:** [dashboard_provider.dart](../lib/features/dashboard/providers/dashboard_provider.dart), [category_donut_chart.dart](../lib/features/stats/widgets/category_donut_chart.dart) e [premium_fintech_chart.dart](../lib/features/stats/widgets/premium_fintech_chart.dart).

**Proposta:** usare ovunque la stessa funzione per gli intervalli temporali, includendo l’intera giornata finale. Correggerei questi due problemi prima di un intervento grafico più ampio.

## Proposte UX/UI — stato

| Priorità | Idea | Esperienza concreta |
| --- | --- | --- |
| 1 | **“Oggi” e “A fine mese”** | Affiancare disponibilità attuale e saldo previsto, con una piccola curva e una spiegazione del calcolo al tocco. Si capisce subito quanto è già disponibile e quanto dipende da incassi futuri. |
| 2 | **“Posso permettermelo?”** | Inserire una spesa ipotetica o spostare un cursore: saldo previsto, budget e obiettivi si aggiornano in anteprima. Si registra il movimento solo con un comando esplicito. È la funzione su cui punterei per distinguere l’app. |
| 3 | **Radar delle scadenze** | Una vista a 7/30 giorni che mostri gli incassi, gli addebiti e il punto di liquidità più basso. La home conserva i totali compatti; un tocco apre il dettaglio. |
| 4 | **Una grafica più riconoscibile — implementata** | Applicata la combinazione approvata: grafica Vault, colori Essenziale e pulsanti flottanti originali con la nuova icona dello scanner. |
| 5 | **Inserimento più rapido e informazioni utili** | Categoria e importo recenti a portata di pollice, campi incerti evidenziati dopo la scansione di una ricevuta e un solo suggerimento contestuale per volta: per esempio una categoria vicina al limite, con importo e periodo verificabili. |

La prima evoluzione che proporrei è una home centrata su **disponibilità attuale, previsione e simulazione di una spesa**, mantenendo movimenti e analisi dettagliate nelle rispettive sezioni.

# IALab1920
## Note di sviluppo
Per caricare tutti i file in contemporanea da terminale scrivere `./clips -f go.bat`

### Strategia 1
1. Considerare tutte le caselle conosciute inizialmente.
2. Qualora ci fossero delle caselle boat conosciute (k-cell) :
    * Se sono sottomarini viene aggiornato il conteggio interno delle navi abbattute aggiungendo il sottomarino in questione.
    * Se sono top/bottom o left/right si controlla, a seconda dell'orientamento, il numero N di navi presenti nella riga/colonna. Vengono segnate con guess le N-1 (tale che N-1 <= 3) caselle successive, sempre tenendo conto dell'orientamento della nave.
    * Se invece si tratta di parti middle si analizza se sono presenti più navi nella riga o nella colonna. Si seleziona il numero più alto, e vengono distribuite le guess in modo uniforme a sinistra/destra o sopra/sotto a seconda della scelta precedente (1 da una parte e una dall'altra).
    *Una volta finite le k-cell con navi si procedere al punto 3.
3. Qualora non ci fossero delle caselle boat conosciute:
    * Si scelgono le coordinate x e y tali che il numero di navi sulla rispettiva riga/colonna sia > 3. Dopo aver determinato i valori delle variabili, viene eseguita una fire con quelle coordinate. Se la fire trova una nave, si  ritorna al punto 2. Se non trova nessuna nave, si passa  alla coppia riga/colonna con valori > 3 successiva. Si continua finché non si finiscono le Fire o non si trova un'altra nave.

4. Qualora termineranno le guess a disposizione, ma sono presenti ancora delle k-cell non analizzate scoperte tramite la fire, allora viene eseguita una Unguess sulla casella intersezione riga/colonna con meno navi per permettere di continuare con la nave appena scoperta.
5. Al termine delle Fire si decide di concludere il gioco, per evitare di perdere ulteriori punti a causa di troppe Guess errate.

        


## Progetto
L’obiettivo del progetto è quello di sviluppare un sistema esperto che giochi ad una versione semplificata della famigerata Battaglia Navale.
Il gioco è nella versione “in-solitario”, per cui c’è un solo giocatore (il vostro sistema esperto) che deve indovinare la posizione di una flotta di navi distribuite su una griglia 10x10.
Come di consueto le navi da individuare sono le seguenti:
- 1 corazzata da 4 caselle
- 2 incrociatori da 3 caselle ciascuno
- 3 cacciatorpedinieri da 2 caselle ciascuno
- 4 sottomarini da 1 casella ciascuno
Le navi saranno, ovviamente, posizionate in verticale o in orizzantale e deve esserci almeno una cella libera (cioè con dell’acqua) tra due navi.
Per rendere più semplice il problema, il contenuto di alcune celle sarà noto fin dall’inizio. Inoltre, in corrispondenza di ciascuna riga e colonna sarà indicato il numero di celle che contengono navi.
Ad esempio, la seguente situazione rappresenta un possibile stato iniziale del problema.


Sapete quindi che in posizione [7, 1] c’è dell’acqua, in posizione [6, 5] c’è un sottomarino, in posizione [5, 10] c’è un pezzo di nave che probabilmente continuerà nelle celle subito sopra e subito sotto. Sapete inoltre, che nella prima riga due celle sono occupate da una nave, mentre nella prima colonna sono 5, ecc.
Il vostro sistema esperto avrà quattro possibili azioni: - fire x y
- guess x y
- unguess x y
- solve

L’azione fire è l’equivalente di un’azione percettiva e vi permette di vedere il contenuto della cella [x, y].
L’azione guess serve per indicare che il vostro sistema esperto ritiene ci sia una nave in posizione [x, y]. Questa azione è da considerarsi un’ipotesi, per cui è ritrattabile in un momento successivo, cioè il vostro sistema esperto potrebbe tornare sui suoi passi con il comando unguess.
Il comando solve è da usarsi solo quando il vostro sistema esperto ritiene di aver risolto il gioco, l’azione termina il gioco attivando il calcolo del punteggio secondo la seguente formula:

`(10∗fok+10∗gok+15∗sink)−(25∗fko+15∗gko+10∗safe)`

dove:
- fok è il numero di azioni fire che sono andate a segno
- gok è il numero di celle guessed corrette
- sink è il numero di navi totalemente affondate
- fko è il numero di azioni fire andate in acqua
- gko è il numero di celle guessed errate
- safe è il numero di celle che contengono una porzione di nave e che sono rimaste inviolate (né guessed né fired)

Per rendere le cose un po’ più interessanti, avete solamente 5 fire a disposizione. Inoltre, in un dato momento non possono esserci più di venti caselle marcate “guessed”.
Lo scopo del gioco è quindi marcare tutte le caselle che contengono una nave come guessed, o eventualmente averle colpite con fire.

## Relazione
La relazione deve evidenziare:
- come avete modellato la conoscenza, in particolare se avete dovuto creare fatti (ordinati o non- ordinati) per modellare ipotesi ecc.
- come avete modellato le regole di expertise. Sarebbe bene che provaste ad implementare diverse strategie di soluzione. Cioè diversi sistemi esperti più o meno capaci e li metteste a confronto.
- dovete fare prove con scenari alternativi, variando, oltre alla posizione delle navi, anche l’osservabilità iniziale (più o meno caselle note all’inizio).
- dovreste poter individuare i limiti della vostra soluzione: come si comporta se all’inizio non conosce nulla?

## Materiale a disposizione
Le regole del gioco (il funzionamento delle diverse azioni e il calcolo del punteggio) sono già state implementate e scaricabili dalla pagina moodle del corso. Vi rimando al video per maggiori dettagli. Non siete autorizzati a modificare l’ambiente, a meno che non vi siano bachi, vi chiedo però di avvisarmi nel caso.
È importante che ricordiate che l’ambiente può eseguire una sola azione per volta. Quindi, anche se avete pianificato una sequenza di azioni, dovete darle all’ambiente una per volta, vedere il video. NB Dopo 100 azioni il gioco termina automaticamente (viene in automatico aseguita l’azione solve).
Per la realizzazione di scenari alternativi vi metto a disposizione un editor di mappe che produce la codifica CLIPS necessaria per modellare il mondo dal punto di vista dell’ambiente.
NB L’editor di mappe è molto artigianale e non fa controlli sul numero di navi, sulla loro dimensione e sull’esistenza di spazi tra una nave e l’altra. Questi controlli dovrete farli voi nel momento in cui definite una mappa.
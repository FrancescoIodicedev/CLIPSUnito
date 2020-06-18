; ;  -----------------------------------------------------
; ;  --- Definizione del modulo e dei template Strategia 2---
; ;  -----------------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

(deftemplate v-cell
    (slot x)
    (slot y)
    (slot content (allowed-values water guess boat ))
)
(deftemplate boat
    (slot name)
    (slot num)
)
(deftemplate fired
    (slot x)
    (slot y)
)
(deftemplate fireOk
    (slot num)
)
;; decrementa il numero di celle con nave in una riga dopo aver effettuato una guess sicura
(defrule decrementRow (declare (salience 50))
    ?d <- (dRow ?r)
    ?nr <- (k-per-row (row ?r) (num ?numRow))
=>
    (modify ?nr (num (- ?numRow 1)))
    (retract ?d)
)


;; decrementa il numero di celle con nave in una colonna dopo aver effettuato una guess sicura
(defrule decrementCol (declare (salience 50))
    ?d <- (dCol ?c)
    ?nc <- (k-per-col (col ?c) (num ?numCol))
=>
    (modify ?nc (num (- ?numCol 1)))
    (retract ?d)
)

;; 0) Mettere W su righe e colonne con somma=0
(defrule waterCol (declare (salience 50))
    (k-per-col (col ?y) (num 0))
=>
    (assert (v-cell (x 0) (y ?y) (content water)))
    (assert (v-cell (x 1) (y ?y) (content water)))
    (assert (v-cell (x 2) (y ?y) (content water)))
    (assert (v-cell (x 3) (y ?y) (content water)))
    (assert (v-cell (x 4) (y ?y) (content water)))
    (assert (v-cell (x 5) (y ?y) (content water)))
    (assert (v-cell (x 6) (y ?y) (content water)))
    (assert (v-cell (x 7) (y ?y) (content water)))
    (assert (v-cell (x 8) (y ?y) (content water)))
    (assert (v-cell (x 9) (y ?y) (content water)))
)

(defrule waterRow (declare (salience 50))
    (k-per-row (row ?x) (num 0))
=>
    (assert (v-cell (x ?x) (y 0) (content water)))
    (assert (v-cell (x ?x) (y 1) (content water)))
    (assert (v-cell (x ?x) (y 2) (content water)))
    (assert (v-cell (x ?x) (y 3) (content water)))
    (assert (v-cell (x ?x) (y 4) (content water)))
    (assert (v-cell (x ?x) (y 5) (content water)))
    (assert (v-cell (x ?x) (y 6) (content water)))
    (assert (v-cell (x ?x) (y 7) (content water)))
    (assert (v-cell (x ?x) (y 8) (content water)))
    (assert (v-cell (x ?x) (y 9) (content water)))
)


;; Update del numero di fire corrette
(defrule updateFireOk (declare (salience 50))
    (moves (fires ?nf&:(< ?nf 5)))
    ?uf <- (updateFire)
    ?fok <- (fireOk (num ?num))
=> 
    (modify ?fok( num (+ ?num 1)))
    (retract ?uf)
)

;------------------ Guess sicure a seguito di una fire ------------------
;segno tutte le celle con sottomarini conosciute a priori
(defrule foundSub (declare (salience 40))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content sub ) )
    (not (v-cell (x ?x) (y ?y))) ; mi assicuro che la cella conosciuta non sia già stata visitata
    ?b <- (boat (name ?name & sottomarino) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 1 disponibili
    ?nr <- (k-per-row (row ?x) (num ?numRow))
    ?nc <- (k-per-col (col ?y) (num ?numCol))
=>
    (modify ?nr (num (- ?numRow 1)))
    (modify ?nc (num (- ?numCol 1)))
    (modify ?b (num (- ?nb 1)))
    (assert (v-cell (x ?x) (y ?y)(content boat)))
    ;; caselle intorno diventano acqua
    (assert (v-cell (x (+ ?x 1)) (y ?y)(content water)))
    (assert (v-cell (x (- ?x 1)) (y ?y)(content water)))
    (assert (v-cell (x ?x) (y (+ ?y 1))(content water)))
    (assert (v-cell (x ?x) (y (- ?y 1))(content water)))
    ;; caselle oblique intorno diventano acqua
    (assert (v-cell (x (+ ?x 1)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (+ ?y 1))(content water)))
    ;; Asserisce che la fire è andata a buon fine
    (assert (updateFire))
)


(defrule foundTop(declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content top ) )
    (not (v-cell (x ?x) (y ?y))) ; mi assicuro che la cella conosciuta non sia già stata visitata
    ?nr <- (k-per-row (row ?x) (num ?numRow))
    ?nc <- (k-per-col (col ?y) (num ?numCol))
=>
    (modify ?nc (num (- ?numCol 2)))	
    (modify ?nr (num (- ?numRow 1)))
    (bind ?x_1 (+ ?x 1))
    (assert (dRow ?x_1))
    (assert (v-cell (x ?x) (y ?y)(content boat)))
    (assert (v-cell (x (+ ?x 1)) (y ?y)(content boat)))
    (assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
    ;; caselle intorno diventano acqua
    (assert (v-cell (x (- ?x 1)) (y ?y)(content water)))
    (assert (v-cell (x ?x) (y (+ ?y 1))(content water)))
    (assert (v-cell (x ?x) (y (- ?y 1))(content water)))
    ;; caselle oblique intorno diventano acqua
    (assert (v-cell (x (+ ?x 1)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (+ ?y 1))(content water)))
    ;; caselle oblique della cella successiva
    (assert (v-cell (x (+ ?x 2)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 2)) (y (- ?y 1))(content water)))
    ;; Asserisce che la fire è andata a buon fine
    (assert (updateFire))
    (pop-focus)

)

(defrule foundBot(declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content bot ) )
    (not (v-cell (x ?x) (y ?y))) ; mi assicuro che la cella conosciuta non sia già stata visitata
    ?nr <- (k-per-row (row ?x) (num ?numRow))
    ?nc <- (k-per-col (col ?y) (num ?numCol))
=>
    (modify ?nc (num (- ?numCol 2)))	
    (modify ?nr (num (- ?numRow 1))) ; aggiorno i valori di k-per-row e k-per-col
    (bind ?x_1 (- ?x 1))
    (assert (dRow ?x_1))
    (assert (v-cell (x ?x) (y ?y)(content boat)))
    (assert (v-cell (x (- ?x 1)) (y ?y)(content boat)))
    (assert (exec (step ?s) (action guess) (x (- ?x 1)) (y ?y)))
    ;; caselle intorno diventano acqua
    (assert (v-cell (x (+ ?x 1)) (y ?y)(content water)))
    (assert (v-cell (x ?x) (y (+ ?y 1))(content water)))
    (assert (v-cell (x ?x) (y (- ?y 1))(content water)))
    ;; caselle oblique intorno diventano acqua
    (assert (v-cell (x (+ ?x 1)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (+ ?y 1))(content water)))
    ;; caselle oblique della cella successiva
    (assert (v-cell (x (- ?x 2)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (- ?x 2)) (y (- ?y 1))(content water)))
    ;; Asserisce che la fire è andata a buon fine
    (assert (updateFire))
    (pop-focus)
)

(defrule foundLeft(declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content left ) )
    (not (v-cell (x ?x) (y ?y))) ; mi assicuro che la cella conosciuta non sia già stata visitata
    ?nr <- (k-per-row (row ?x) (num ?numRow))
    ?nc <- (k-per-col (col ?y) (num ?numCol))
=>
    (modify ?nr (num (- ?numRow 2))) ; aggiorno i valori di k-per-row e k-per-col
    (modify ?nc (num (- ?numCol 1)))
    (bind ?y_1 (+ ?y 1))
    (assert (dCol ?y_1))
    (assert (v-cell (x ?x) (y ?y)(content boat)))
    (assert (v-cell (x ?x) (y (+ ?y 1))(content boat)))
    (assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
    ;; caselle intorno diventano acqua
    (assert (v-cell (x (- ?x 1)) (y ?y)(content water)))
    (assert (v-cell (x (+ ?x 1)) (y ?y)(content water)))
    (assert (v-cell (x ?x) (y (- ?y 1))(content water)))
    ;; caselle oblique intorno diventano acqua
    (assert (v-cell (x (+ ?x 1)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (+ ?y 1))(content water)))
    ;; caselle oblique della cella successiva
    (assert (v-cell (x (- ?x 1)) (y (+ ?y 2))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (+ ?y 2))(content water)))
    ;; Asserisce che la fire è andata a buon fine
    (assert (updateFire))
    (pop-focus)
)

(defrule foundRight(declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content right ))
    (not (v-cell (x ?x) (y ?y))) ; mi assicuro che la cella conosciuta non sia già stata visitata
    ?nr <- (k-per-row (row ?x) (num ?numRow))
    ?nc <- (k-per-col (col ?y) (num ?numCol))
=>
    (modify ?nr (num (- ?numRow 2))) ; aggiorno i valori di k-per-row e k-per-col
    (modify ?nc (num (- ?numCol 1)))
    (bind ?y_1 (- ?y 1))
    (assert (dCol ?y_1))
    (assert (v-cell (x ?x) (y ?y)(content boat)))
    (assert (v-cell (x ?x) (y (- ?y 1))(content boat)))
    (assert (exec (step ?s) (action guess) (x ?x) (y (- ?y 1))))
    ;; caselle intorno diventano acqua
    (assert (v-cell (x (- ?x 1)) (y ?y)(content water)))
    (assert (v-cell (x (+ ?x 1)) (y ?y)(content water)))
    (assert (v-cell (x ?x) (y (+ ?y 1))(content water)))
    ;; caselle oblique intorno diventano acqua
    (assert (v-cell (x (+ ?x 1)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (+ ?y 1))(content water)))
    ;; caselle oblique della cella successiva
    (assert (v-cell (x (- ?x 1)) (y (- ?y 2))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (- ?y 2))(content water)))
    ;; Asserisce che la fire è andata a buon fine
    (assert (updateFire))
    (pop-focus)    
)

(defrule foundMidLeftRight(declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content middle))
    (k-per-row (row ?x) (num ?numRow&:(> ?numRow 2)))
    (k-per-col (col ?y) (num ?numCol&:(< ?numCol ?numRow)))
    (not (v-cell (x ?x) (y ?y))) ; mi assicuro che la cella conosciuta non sia già stata visitata
    (not (v-cell (x ?x) (y ?y1)))
    (not (v-cell (x ?x) (y ?y2)))
    ?nr <- (k-per-row (row ?x) (num ?numRow))
    ?nc <- (k-per-col (col ?y) (num ?numCol))
=>
    (modify ?nr (num (- ?numRow 2))) ; aggiorno i valori di k-per-row e k-per-col
    (modify ?nc (num (- ?numCol 1)))
    (bind ?y_1 (- ?y 1))
    (bind ?y_2 (+ ?y 1))
    (assert (dCol ?y_1))
    (assert (dCol ?y_2))
    (assert (v-cell (x ?x) (y ?y)(content boat)))
    (assert (v-cell (x ?x) (y (+ ?y 1))(content boat)))
    (assert (v-cell (x ?x) (y (- ?y 1))(content boat)))
    (assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
    (assert (exec (step (+ ?s 1)) (action guess) (x ?x) (y (- ?y 1))))
    ;; caselle intorno diventano acqua
    (assert (v-cell (x (- ?x 1)) (y ?y)(content water)))
    (assert (v-cell (x (+ ?x 1)) (y ?y)(content water)))
    ;; caselle oblique intorno diventano acqua
    (assert (v-cell (x (+ ?x 1)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (+ ?y 1))(content water)))
    ;; caselle oblique della cella successiva
    (assert (v-cell (x (- ?x 1)) (y (- ?y 2))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (- ?y 2))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (+ ?y 2))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (+ ?y 2))(content water)))
    ;; Asserisce che la fire è andata a buon fine
    (assert (updateFire))
    (pop-focus)    
)


(defrule foundMidTopBottom(declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content middle))
    (k-per-col (col ?y) (num ?numCol&:(> ?numCol 2)))
    (k-per-row (row ?x) (num ?numRow&:(> ?numCol ?numRow)))
    (not (v-cell (x ?x) (y ?y))) ; mi assicuro che la cella conosciuta non sia già stata visitata
    (not (v-cell (x ?x1) (y ?y))) 
    (not (v-cell (x ?x2) (y ?y)))
    ?nr <- (k-per-row (row ?x) (num ?numRow))
    ?nc <- (k-per-col (col ?y) (num ?numCol))
=>
    (modify ?nc (num (- ?numCol 2)))	
    (modify ?nr (num (- ?numRow 1)))
    (bind ?x_1 (- ?x 1))
    (bind ?x_2 (+ ?x 1))
    (assert (dRow ?x_1))
    (assert (dRow ?x_2))
    (assert (v-cell (x ?x) (y ?y)(content boat)))
    (assert (v-cell (x ?x) (y (+ ?y 1))(content boat)))
    (assert (v-cell (x ?x) (y (- ?y 1))(content boat)))
    (assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
    (assert (exec (step (+ ?s 1)) (action guess) (x ?x) (y (- ?y 1))))

    ;; caselle intorno diventano acqua
    (assert (v-cell (x ?x) (y (+ ?y 1))(content water)))
    (assert (v-cell (x ?x) (y (- ?y 1))(content water)))
    ;; caselle oblique intorno diventano acqua
    (assert (v-cell (x (+ ?x 1)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (+ ?y 1))(content water)))
    ;; caselle oblique della cella successiva
    (assert (v-cell (x (- ?x 2)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (- ?x 2)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 2)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 2)) (y (- ?y 1))(content water)))
    ;; Asserisce che la fire è andata a buon fine
    (assert (updateFire))
    (pop-focus)    
)

;se trovo una mid ma non sono sicuro dell'orientamento
(defrule foundMid(declare (salience 5))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content middle))
    (not (v-cell (x ?x) (y ?y))) ; mi assicuro che la cella conosciuta non sia già stata visitata
    ?nr <- (k-per-row (row ?x) (num ?numRow))
    ?nc <- (k-per-col (col ?y) (num ?numCol&:(= ?numCol ?numRow)))
=>
    (modify ?nr (num (- ?numRow 1))) ; aggiorno i valori di k-per-row e k-per-col
    (modify ?nc (num (- ?numCol 1)))
    (assert (v-cell (x ?x) (y ?y)(content boat)))
    ;; caselle oblique intorno diventano acqua
    (assert (v-cell (x (+ ?x 1)) (y (+ ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (+ ?x 1)) (y (- ?y 1))(content water)))
    (assert (v-cell (x (- ?x 1)) (y (+ ?y 1))(content water)))
    ;; Asserisce che la fire è andata a buon fine
    (assert (updateFire))
)



; ;------------------ Fire con celle intersezione maggiore ------------------
(deffunction compareValMax (?value1 ?value2)
       (> ?value1 ?value2))

(defrule fireOnMax (declare (salience 0))
    (status (step ?s)(currently running))
    (moves (fires ?nf&:(> ?nf 0)))
    (not (k-cell (x ?a) (y ?b) (content ?b) ))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(compareValMax ?r ?numRow))))
    (not (k-per-col ( num ?c&:(compareValMax ?c ?numCol))))
    (not (v-cell (x ?x) (y ?y)))
    (not (fired (x ?x) (y ?y)))
=>
    (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
    (assert (fired (x ?x) (y ?y)))
    (printout t "---> FIRE row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

(defrule fireOn3Max (declare (salience -5))
    (status (step ?s)(currently running))
    (moves (fires ?nf&:(> ?nf 0)))
    (not (k-cell (x ?a) (y ?b) (content ?b) ))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(< ?numRow 3))))
    (not (k-per-col ( num ?c&:(< ?numCol 3))))
    (not (v-cell (x ?x) (y ?y)))
    (not (fired (x ?x) (y ?y)))
=>
    (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
    (assert (fired (x ?x) (y ?y)))
    (printout t "---> FIRE3 row " ?x   " - col: " ?y crlf)
    (pop-focus)
)


(defrule fireOn2Max (declare (salience -10))
    (status (step ?s)(currently running))
    (moves (fires ?nf&:(> ?nf 0)))
    (not (k-cell (x ?a) (y ?b) (content ?b) ))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(< ?numRow 2))))
    (not (k-per-col ( num ?c&:(< ?numCol 2))))
    (not (v-cell (x ?x) (y ?y)))
    (not (fired (x ?x) (y ?y)))
=>
    (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
    (assert (fired (x ?x) (y ?y)))
    (printout t "---> FIRE2 row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

(defrule fireOn1Max (declare (salience -15))
    (status (step ?s)(currently running))
    (moves (fires ?nf&:(> ?nf 0)))
    (not (k-cell (x ?a) (y ?b) (content ?b) ))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(< ?numRow 1))))
    (not (k-per-col ( num ?c&:(< ?numCol 1))))
    (not (v-cell (x ?x) (y ?y)))
    (not (fired (x ?x) (y ?y)))
=>
    (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
    (assert (fired (x ?x) (y ?y)))
    (printout t "---> FIRE1 row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

; ;------------------ Guess con celle intersezione maggiore ------------------
(defrule finishMaxGuess (declare (salience -20))
    (status (step ?s)(currently running))
    (fireOk (num ?numFok))
    (moves (fires 0) (guesses ?ng&:(> ?ng ?numFok)))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(compareValMax ?r ?numRow))))
    (not (k-per-col  ( num ?c&:(compareValMax ?c ?numCol))))
    (not (v-cell (x ?x) (y ?y)))
    (not (fired (x ?x) (y ?y)))
=>
    (assert (v-cell (x ?x) (y ?y)(content guess)))
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
    (printout t "---> GUESS2 post-fire row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

(defrule finish3Guess (declare (salience -25))
    (status (step ?s)(currently running))
    (fireOk (num ?numFok))
    (moves (fires 0) (guesses ?ng&:(> ?ng ?numFok)))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(< ?numRow 3))))
    (not (k-per-col ( num ?c&:(< ?numCol 3))))
    (not (v-cell (x ?x) (y ?y)))
    (not (fired (x ?x) (y ?y)))
=>
    (assert (v-cell (x ?x) (y ?y)(content guess)))
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
    (printout t "---> GUESS2 post-fire row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

;; finite le fire metto tutte le guess a disposizione nelle 
;; celle con #navi > 0 in riga/colonna
(defrule finish2Guess (declare (salience -30))
    (status (step ?s)(currently running))
    (fireOk (num ?numFok))
    (moves (fires 0) (guesses ?ng&:(> ?ng ?numFok)))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(< ?numRow 2))))
    (not (k-per-col ( num ?c&:(< ?numCol 2))))
    (not (v-cell (x ?x) (y ?y)))
    (not (fired (x ?x) (y ?y)))
=>
    (assert (v-cell (x ?x) (y ?y)(content guess)))
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
    (printout t "---> GUESS2 post-fire row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

(defrule finish1Guess (declare (salience -35))
    (status (step ?s)(currently running))
    (fireOk (num ?numFok))
    (moves (fires 0) (guesses ?ng&:(> ?ng ?numFok)))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(< ?numRow 1))))
    (not (k-per-col ( num ?c&:(< ?numCol 1))))
    (not (v-cell (x ?x) (y ?y)))
    (not (fired (x ?x) (y ?y)))
=>
    (assert (v-cell (x ?x) (y ?y)(content guess)))
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
    (printout t "---> GUESS2 post-fire row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

; ;------------------ Condizioni di chiusura ------------------

(defrule endGame (declare (salience -40))
    (status (step ?s)(currently running))
    (fireOk (num ?numFok))
    (moves (fires 0))
=>
    (assert (endgame))
    (printout t "Fine del Gioco"  crlf)
    (pop-focus)
)


; ;------------------ Fatti barche con conteggi ------------------
(deffacts startBoats
    (boat (name corazzata) (num 1))
    (boat (name incrociatore) (num 2))
    (boat (name cacciaT) (num 3))
    (boat (name sottomarino) (num 4))
)
(deffacts fireOkInit
    (fireOk (num 0))
)
;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

; TODO: CONTROLLARE CHE UNA VOLTA ANALIZZATA UNA K-CELL NON UNIFICHI AL PASSO DOPO 
; CON UN GUESS SUCCESSIVO

(deftemplate boat
    (slot name)
    (slot num)
)
(deftemplate kVisited
    (slot x)
    (slot y)
)
(deftemplate fired
    (slot row)
    (slot col)
)
(deftemplate guessed
    (slot x)
    (slot y)
)

;segno tutte le celle con sottomarini conosciute a priori
(defrule foundSub (declare (salience 30))
    (k-cell (x ?x) (y ?y) (content sub ) )
    (not (kVisited (x ?x) (y ?y))) ; mi assicuro che la cella conosciuta non sia già stata visitata
    ?b <- (boat (name ?name & sottomarino) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 1 disponibili
=>
    (modify ?b (num (- ?nb 1)))
    (assert (kVisited (x ?x) (y ?y)))
)


;------------------ Navi Verticali ------------------
; guess partendo da casella top con almeno 3 caselle sotto
(defrule guess3Top (declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 2)))
    (k-cell (x ?x) (y ?y) (content top) )
    (k-per-col (col ?y) (num ?num&:(> ?num 3)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & corazzata) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 4 disponibili
=>
    (assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
    (assert (exec (step (+ ?s 1)) (action guess) (x (+ ?x 2)) (y ?y)))
    (assert (exec (step (+ ?s 2)) (action guess) (x (+ ?x 3)) (y ?y)))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed (x (+ ?x 1)) (y ?y)))
    (assert (guessed (x (+ ?x 2)) (y ?y)))
    (assert (guessed (x (+ ?x 3)) (y ?y)))
    (modify ?b (num (- ?nb 1)))
    (pop-focus)
)

; guess partendo da casella bot con almeno 3 caselle sopra
(defrule guess3Bottom (declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 2)))
    (k-cell (x ?x) (y ?y) (content bot) )
    (k-per-col (col ?y) (num ?num&:(> ?num 3)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & corazzata) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 4 disponibili
=>
    (assert (exec (step ?s) (action guess) (x (- ?x 1)) (y ?y)))
    (assert (exec (step (+ ?s 1)) (action guess) (x (- ?x 2)) (y ?y)))
    (assert (exec (step (+ ?s 2)) (action guess) (x (- ?x 3)) (y ?y)))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed  (x (- ?x 1)) (y ?y)))
    (assert (guessed  (x (- ?x 2)) (y ?y)))
    (assert (guessed  (x (- ?x 3)) (y ?y)))
    (modify ?b (num (- ?nb 1)))
    (pop-focus)
)

; guess partendo da casella top con almeno 2 caselle sotto
(defrule guess2Top (declare (salience 10))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 1)))
    (k-cell (x ?x) (y ?y) (content top) )
    (k-per-col (col ?y) (num ?num&:(> ?num 2)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & incrociatore) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 3 disponibili
=>
    (assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
    (assert (exec (step (+ ?s 1)) (action guess) (x ?x) (y (+ ?y 2))))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed  (x ?x) (y (+ ?y 1))))
    (assert (guessed  (x ?x) (y (+ ?y 2))))
    (modify ?b (num (- ?nb 1)) )
    (pop-focus)
)

; guess partendo da casella bot con almeno 2 caselle sopra
(defrule guess2Bottom (declare (salience 10))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 1)))
    (k-cell (x ?x) (y ?y) (content bot) )
    (k-per-col (col ?y) (num ?num&:(> ?num 2)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & cacciaT) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 3 disponibili	
=>
    (assert (exec (step ?s) (action guess) (x (- ?x 1)) (y ?y)))
    (assert (exec (step (+ ?s 1)) (action guess) (x (- ?x 2)) (y ?y)))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed  (x (- ?x 1)) (y ?y)))
    (assert (guessed  (x (- ?x 2)) (y ?y)))
    (modify ?b (num (- ?nb 1)) )
    (pop-focus)
)

; guess partendo da casella top con almeno 1 caselle sotto
(defrule guess1Top (declare (salience 5))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content top) )
    (k-per-col (col ?y) (num ?num&:(> ?num 1)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & incrociatore) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 3 disponibili
=>
    (assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed (x (+ ?x 1)) (y ?y)))
    (modify ?b (num (- ?nb 1)) )
    (pop-focus)
)


(defrule guess1Bottom (declare (salience 5))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content bot ))
    (k-per-col (col ?y) (num ?num&:(> ?num 1)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & cacciaT) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 3 disponibili
=>
    (assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed  (x ?x) (y (+ ?y 1))))
    (modify ?b (num (- ?nb 1)) )
    (pop-focus)
)

;------------------ Navi Orizzontali ------------------

; guess partendo da casella right con almeno 3 caselle sinistra
(defrule guess3Left (declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 2)))
    (k-cell (x ?x) (y ?y) (content left) )
    (k-per-row (row ?x) (num ?num&:(> ?num 3)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & corazzata) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 4 disponibili
=>

    (assert (exec (step ?s) (action guess) (x ?x) (y (- ?y 1))))
    (assert (exec (step (+ ?s 1)) (action guess) (x ?x) (y (- ?y 2))))
    (assert (exec (step (+ ?s 2)) (action guess) (x ?x) (y (- ?y 3))))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed  (x ?x) (y (- ?y 1))))
    (assert (guessed  (x ?x) (y (- ?y 2))))
    (assert (guessed  (x ?x) (y (- ?y 3))))
    (modify ?b (num (- ?nb 1)))
    (pop-focus)
)

; guess partendo da casella left con almeno 3 caselle destra
(defrule guess3Right (declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 2)))
    (k-cell (x ?x) (y ?y) (content right) )
    (k-per-row (row ?x) (num ?num&:(> ?num 3)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & corazzata) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 4 disponibili
=>
    (assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
    (assert (exec (step (+ ?s 1)) (action guess) (x ?x) (y (+ ?y 2))))
    (assert (exec (step (+ ?s 2)) (action guess) (x ?x) (y (+ ?y 3))))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed  (x ?x) (y (+ ?y 1))))
    (assert (guessed  (x ?x) (y (+ ?y 2))))
    (assert (guessed  (x ?x) (y (+ ?y 3))))
    (modify ?b (num (- ?nb 1)))
    (pop-focus)
)

; guess partendo da casella right con almeno 2 caselle sinistra
(defrule guess2Left (declare (salience 10))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 1)))
    (k-cell (x ?x) (y ?y) (content left) )
    (k-per-row (row ?x) (num ?num&:(> ?num 2)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & incrociatore) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 3 disponibili
=>

    (assert (exec (step ?s) (action guess) (x ?x) (y (- ?y 1))))
    (assert (exec (step (+ ?s 1)) (action guess) (x ?x) (y (- ?y 2))))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed  (x ?x) (y (- ?y 1))))
    (assert (guessed  (x ?x) (y (- ?y 2))))
    (modify ?b (num (- ?nb 1)) )
    (pop-focus)
)

; guess partendo da casella left con almeno 2 caselle destra
(defrule guess2Right (declare (salience 10))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 1)))
    (k-cell (x ?x) (y ?y) (content right) )
    (k-per-row (row ?x) (num ?num&:(> ?num 2)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & cacciaT) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 3 disponibili	
=>	
    (assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
    (assert (exec (step (+ ?s 1)) (action guess) (x (+ ?x 2)) (y ?y)))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed (x (+ ?x 1)) (y ?y)))
    (assert (guessed (x (+ ?x 2)) (y ?y)))
    (modify ?b (num (- ?nb 1)) )
    (pop-focus)
)

; guess partendo da casella right con almeno 1 caselle sinistra
(defrule guess1Left (declare (salience 5))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content left) )
    (k-per-row (row ?x) (num ?num&:(> ?num 1)))	
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & incrociatore) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 3 disponibili
=>
    (assert (exec (step ?s) (action guess) (x (- ?x 1)) (y ?y)))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed  (x (- ?x 1)) (y ?y)))
    (modify ?b (num (- ?nb 1)) )
    (pop-focus)
)

; guess partendo da casella left con almeno 1 caselle destra
(defrule guess1Right (declare (salience 5))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content right ))
    (k-per-row (row ?x) (num ?num&:(> ?num 1)))
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & cacciaT) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 3 disponibili
=>
    (assert (exec (step ?s) (action guess) (x ?x) (y (- ?y 1))))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed  (x ?x) (y (- ?y 1))))
    (modify ?b (num (- ?nb 1)) )
    (pop-focus)
)

;------------------ Celle Conosciute Middle ------------------

(defrule guessLeftRight (declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content middle))
    (k-per-row (row ?x) (num ?numRow&:(> ?numRow 2)))
    (k-per-col (col ?y) (num ?numCol&:(< ?numCol ?numRow)))
    (< ?numCol ?numRow)
    (not (kVisited (x ?x) (y ?y)))
    ?b <- (boat (name ?name & cacciaT) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 3 disponibili
=>
    (assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
    (assert (exec (step (+ ?s 1)) (action guess) (x ?x) (y (- ?y 1))))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed (x ?x) (y (+ ?y 1))))
    (assert (guessed (x ?x) (y (- ?y 1))))
    (modify ?b (num (- ?nb 1)) )
    (pop-focus)
)


(defrule guessTopBottom (declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content middle))
    (k-per-col (col ?y) (num ?numCol&:(> ?numCol 2)))
    (k-per-row (row ?x) (num ?numRow&:(> ?numCol ?numRow)))
    (not (kVisited (x ?x) (y ?y))
    ?b <- (boat (name ?name & cacciaT) (num ?nb&:(> ?nb 0))) ; se ci sono ancora barche da 3 disponibili
=>
    (assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
    (assert (exec (step (+ ?s 1)) (action guess) (x (- ?x 1)) (y ?y)))
    (assert (kVisited (x ?x) (y ?y)))
    (assert (guessed (x (+ ?x 1)) (y ?y)))
    (assert (guessed (x (- ?x 1)) (y ?y)))	
    (modify ?b (num (- ?nb 1)) )
    (pop-focus)
)

se trovo una mid ma non sono sicuro dell'orientamento
(defrule guessMid(declare (salience 5))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-cell (x ?x) (y ?y) (content middle))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol&:(= ?numCol ?numRow)))
    (not (kVisited (x ?x) (y ?y))) ; mi assicuro che la cella conosciuta non sia già stata visitata
=>
    (assert (kVisited (x ?x) (y ?y)))
)

;------------------ Unguess delle celle se trovo navi ma finisco le guess -

(deffunction compareValMin (?value1 ?value2)
    (< 2 ?value2))

(defrule unguessOnFire 
    (status (step ?s)(currently running))
    (moves (guesses 0 ))
    (k-cell (x ?x) (y ?y) (content ?c))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(compareValMin ?r ?numRow))))
    (not (k-per-col ( num ?c&:(compareValMin ?c ?numCol))))
    ?gu <- (guessed (x ?x) (y ?y))
=>
    (assert (exec (step ?s) (action unguess) (x ?x) (y ?y)))
    (retract ?gu)
)

;------------------ Fire con celle intersezione maggiore ------------------

(deffunction compareValMax (?value1 ?value2)
    (> ?value1 ?value2))

(defrule fireOnMax (declare (salience -1))
    (status (step ?s)(currently running))
    (moves (fires ?nf&:(> ?nf 0)))
    (not (k-cell (x ?a) (y ?b) (content ?b) ))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(compareValMax ?r ?numRow))))
    (not (k-per-col ( num ?c&:(compareValMax ?c ?numCol))))
    (not (fired (row ?x) (col ?y)))
    (not (guessed (x ?x) (y ?y)))
    (not (kVisited (x ?x) (y ?y)))
=>
    (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
    (assert (fired (row ?x) (col ?y)))
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
    (not (fired (row ?x) (col ?y)))
    (not (guessed (x ?x) (y ?y)))
    (not (kVisited (x ?x) (y ?y)))
=>
    (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
    (assert (fired (row ?x) (col ?y)))
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
    (not (fired (row ?x) (col ?y)))
    (not (guessed (x ?x) (y ?y)))
    (not (kVisited (x ?x) (y ?y)))
=>
    (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
    (assert (fired (row ?x) (col ?y)))
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
    (not (fired (row ?x) (col ?y)))
    (not (guessed (x ?x) (y ?y)))
    (not (kVisited (x ?x) (y ?y)))
=>
    (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
    (assert (fired (row ?x) (col ?y)))
    (printout t "---> FIRE1 row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

;------------------ Condizioni di chiusura ------------------

(defrule endGame (declare (salience -20))
    (status (step ?s)(currently running))
    (moves (fires 0))
=>
    (assert (endgame))
    (printout t "Finite le FIRE"  crlf)
    (pop-focus)
)


;------------------ Fatti barche con conteggi ------------------
(deffacts startBoats
    (boat (name corazzata) (num 1))
    (boat (name incrociatore) (num 2))
    (boat (name cacciaT) (num 3))
    (boat (name sottomarino) (num 4))
)


;-----------------------------------------------------------------------


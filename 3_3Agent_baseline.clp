; ;  -----------------------------------------------------
; ;  --- Definizione del modulo e dei template Strategia 2---
; ;  -----------------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

(deftemplate v-cell
    (slot x)
    (slot y)
    (slot content (allowed-values water guess boat ))
)


; ;------------------ Fire con celle intersezione maggiore ------------------
(deffunction compareValMax (?value1 ?value2)
    (> ?value1 ?value2))


(defrule tryMaxGuess (declare (salience 30))
    (status (step ?s)(currently running))
    (moves  (guesses ?ng&:(> ?ng 0)))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(compareValMax ?r ?numRow))))
    (not (k-per-col  ( num ?c&:(compareValMax ?c ?numCol))))
    (not (v-cell (x ?x) (y ?y)))
    (not (k-cell (x ?x) (y ?Y)))
=>
    (assert (v-cell (x ?x) (y ?y)(content guess)))
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
    (printout t "---> GUESS Max  row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

(defrule try3Guess (declare (salience 25))
    (status (step ?s)(currently running))
    (moves  (guesses ?ng&:(> ?ng 0)))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(< ?numRow 3))))
    (not (k-per-col ( num ?c&:(< ?numCol 3))))
    (not (v-cell (x ?x) (y ?y)))
    (not (k-cell (x ?x) (y ?Y)))

=>
    (assert (v-cell (x ?x) (y ?y)(content guess)))
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
    (printout t "---> GUESS3  row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

;; finite le fire metto tutte le guess a disposizione nelle
;; celle con #navi > 0 in riga/colonna
(defrule try2Guess (declare (salience 20))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(< ?numRow 2))))
    (not (k-per-col ( num ?c&:(< ?numCol 2))))
    (not (v-cell (x ?x) (y ?y)))
    (not (k-cell (x ?x) (y ?Y)))

=>
    (assert (v-cell (x ?x) (y ?y)(content guess)))
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
       (printout t "---> GUESS2 row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

(defrule try1Guess (declare (salience 15))
    (status (step ?s)(currently running))
    (moves (guesses ?ng&:(> ?ng 0)))
    (k-per-row (row ?x) (num ?numRow))
    (k-per-col (col ?y) (num ?numCol))
    (not (k-per-row ( num ?r&:(< ?numRow 1))))
    (not (k-per-col ( num ?c&:(< ?numCol 1))))
    (not (v-cell (x ?x) (y ?y)))
    (not (k-cell (x ?x) (y ?Y)))
=>
    (assert (v-cell (x ?x) (y ?y)(content guess)))
    (assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
    (printout t "---> GUESS1 row " ?x   " - col: " ?y crlf)
    (pop-focus)
)

(defrule endGame (declare (salience -40))
    (status (step ?s)(currently running))
    (moves (guesses 0))
=>
    (assert (endgame))
    (printout t "Fine del Gioco"  crlf)
    (pop-focus)
)

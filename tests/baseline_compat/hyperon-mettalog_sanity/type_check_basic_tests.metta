;; declare foo's type
(: foo (-> Number Number))

;; (foo 1) has type, (foo "1") does not
!(assertEqualToResult (get-type (foo 1)) (Number))
!(assertEqualToResult (get-type (foo "1")) ())

;; evaluate triggers error
!(assertEqualToResult (foo "1") ((Error "1" BadType)))

;; match doesn't check types
!(assertEqualToResult (match &self (foo "1") Fine) ())

;; good function def is atom, bad function def is untyped
!(assertEqualToResult (get-type (= (foo $x) (+ $x 2))) (Atom))
!(assertEqualToResult (get-type (= (foo $x) (+ $x "2"))) ())

;; bad function def due to mismatched returns is untyped
(: bar (-> Number Bool))
!(assertEqualToResult (get-type (= (bar $x) (+ $x 2))) ())

;; declare types

(: Hammer Type)
(: Nail Type)
(: Object Type)
(: Paint Type)

(: myHammer Hammer)
(: myNail Nail)
(: myWall Object)
(: myPaint Paint)

(: hammered (-> Hammer Nail Object Object))
(: painted (-> Paint Object Object))
(: indirection (-> $t $t))

;; simple arg test

!(assertEqualToResult (get-type (hammered myHammer myNail myWall)) (Object))
!(assertEqualToResult (get-type (hammered myHammer myNail "notAnObject")) ())


;; nested arg test

!(assertEqualToResult (get-type (hammered myHammer myNail (painted myPaint myWall))) (Object))
!(assertEqualToResult (get-type (hammered myHammer myNail (painted "notPaint" myWall))) ())

!(assertEqualToResult (get-type (hammered myHammer myNail (indirection (painted myPaint myWall)))) (Object))
!(assertEqualToResult (get-type (hammered myHammer myNail (indirection (painted "notPaint" myWall)))) ())

!(assertEqualToResult (get-type (indirection (hammered myHammer myNail (indirection (painted myPaint myWall))))) (Object))
!(assertEqualToResult (get-type (indirection (hammered myHammer myNail (indirection (painted "notPaint" myWall))))) ())

;; function as arg, set types

(: iterN (-> Number Number (-> Number Number) Number))
(: add1 (-> Number Number))
(: toString (-> $t String))

!(assertEqualToResult (get-type (iterN 5 3 add1)) (Number))
!(assertEqualToResult (get-type (iterN 5 3 +)) ())
!(assertEqualToResult (get-type (iterN 5 3 toString)) ())

;; function as arg, implicit types

(: iterX (-> $x $x (-> $x $x) $x))

!(assertEqualToResult (get-type (iterX 5 3 add1)) (Number))
!(assertEqualToResult (get-type (iterX 5 3 +)) ())
!(assertEqualToResult (get-type (iterX 5 3 toString)) ())

!(assertEqualToResult (get-type (iterX "5" "3" toString)) (String))
!(assertEqualToResult (get-type (iterX "5" "3" indirection)) (String))
!(assertEqualToResult (get-type (iterX "5" "3" add1)) ())

!(assertEqualToResult (get-type (iterX (hammered myHammer myNail (painted myPaint myWall)) (indirection (hammered myHammer myNail (indirection (painted myPaint myWall)))) indirection)) (Object))
!(assertEqualToResult (get-type (iterX (hammered myHammer myNail (painted myPaint myWall)) (indirection (hammered myHammer myNail (indirection (painted myPaint myWall)))) add1)) ())
!(assertEqualToResult (get-type (iterX (hammered myHammer myNail (painted myPaint myWall)) (indirection (hammered myHammer myNail (indirection (painted myPaint myWall)))) toString)) ())

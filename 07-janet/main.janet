(defn is-splitter? [c] (= c (chr "^")))

(defn solve
  [lines]
  (def [hd & tl] lines)
  (def start (string/find "S" hd))
  (def beams (array/new-filled (length hd) 0))
  (put beams start 1)
  (var splits 0)
  (each line tl
    (loop [[i b] :pairs beams]
      (when (and (pos? b) (is-splitter? (line i)))
        (++ splits)
        (set (beams i) 0)
        (+= (beams (+ i 1)) b)
        (+= (beams (- i 1)) b))))
  [splits (sum (filter pos? beams))])


(def file "input.txt")
(def lines (with [f (file/open file)]
             (let [lines-iter (file/lines f )]
               (seq [line :in lines-iter] (string/trim line)))))
(def [p1 p2] (solve lines))
(print "Part one: " p1)
(print "Part two: " p2)

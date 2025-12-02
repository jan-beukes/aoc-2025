let read_entire_file path =
    let ch = open_in path in
    let s = really_input_string ch (in_channel_length ch) in
    close_in ch;
    s
let ( @% ) a b = (a mod b + b) mod b

let rec solve (dial, total) line =
    let turn = String.sub line 1 (String.length line - 1)
        |> int_of_string
        |> (if line.[0] = 'L' then (-) else (+)) dial in
    let clicks = (abs turn) / 100 + if turn < 0 && turn @% 100 != 0 then 1 else 0 in
    (turn @% 100, total + clicks)

let () =
    read_entire_file "input01.txt" |> String.trim |> String.split_on_char '\n'
    |> List.fold_left solve (50, 0) |> snd |> Printf.printf "%d\n"

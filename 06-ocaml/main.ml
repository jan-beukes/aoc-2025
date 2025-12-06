let rec transpose l = match l with
    | []
    | [] :: _ -> []
    | _ -> List.map List.hd l :: transpose (List.map List.tl l)

let list_of_string s = List.init (String.length s) (String.get s)

let is_digit c = match c with
    | '0'..'9' -> true
    | _ -> false

(* After transpose the numbers will be in order so accumulate them into list until a full list of
   spaces. Keep doing this until all problems are found *)
let rec extract_problems tlines acc = 
    let rec extract_numbers l acc = match l with
        | [] -> (acc, [])
        | h :: rest -> 
                if List.for_all ((=) ' ') h then
                    (acc, rest)
                else
                    let number = List.filter is_digit h
                        |> List.fold_left (fun a c -> 10 * a + (Char.code c - Char.code '0')) 0
                    in 
                    extract_numbers rest (number :: acc) 
    in
    match tlines with
        | [] -> acc
        | h :: rest ->
                let op = List.find (fun c -> c = '+' || c = '*') h in
                let (xs, next) = extract_numbers (h :: rest) [] in
                extract_problems next ((op, xs) :: acc)

let to_problems_part_two lines =
    let tlines = transpose @@ List.map list_of_string lines in
    extract_problems tlines []

let to_problems_part_one lines = 
    let split_lines = List.map (Str.split (Str.regexp "[ \t]+")) lines in
    let problems = List.rev split_lines |> transpose in
    let to_pair = fun p -> (String.get (List.hd p) 0, List.map int_of_string @@ List.tl p) in
    List.map to_pair problems

let solve lines =
    let calculate (op, xs) = match op with
        | '+' -> List.fold_left ( + ) 0 xs
        | '*' -> List.fold_left ( * ) 1 xs
        | c -> Printf.printf "Found unexpected '%c'\n" c; assert false
    in
    let p1 = List.map calculate (to_problems_part_one lines) |> List.fold_left ( + ) 0 in
    let p2 = List.map calculate (to_problems_part_two lines) |> List.fold_left ( + ) 0 in
    (p1, p2)

let read_lines file =
    let ic = open_in file in
    let try_read () =
        try Some (input_line ic) with End_of_file -> None in
    let rec loop acc = match try_read () with
        | Some s -> loop (s :: acc)
        | None -> close_in ic; List.rev acc in
    loop [] |> List.filter ((<>) String.empty)

let input_file = "input.txt"
let () =
    let lines = read_lines input_file in
    let (p1, p2) = solve lines in
    Printf.printf "Part one: %d\n" p1;
    Printf.printf "Part two: %d\n" p2

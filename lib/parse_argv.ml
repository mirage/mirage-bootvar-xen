open Astring

(* Split string into whitespace-separated substrings,
   taking into account quoting *)

let parse s =
  let skip_white s = String.Sub.drop
      ~max:Sys.max_string_length
      ~sat:Char.Ascii.is_white s in

  let split s =
    let rec inner in_quoted s so_far acc =
      let is_data = function
        | '\\' -> false
        | '"' -> false
        | c when Char.Ascii.is_white c -> in_quoted
        | _ -> true in

      let data,rem = String.Sub.span
          ~sat:is_data
          ~max:Sys.max_string_length s in

      match String.Sub.head rem with
      | Some c when Char.Ascii.is_white c ->
        let so_far = List.rev (data :: so_far) in
        inner in_quoted (skip_white rem) [] ((String.Sub.concat so_far)::acc)
      | Some '"' ->
        let so_far = data :: so_far in
        inner (not in_quoted) (String.Sub.tail rem) so_far acc
      | Some '\\' ->
        let rem = String.Sub.tail rem in
        begin match String.Sub.head rem with
          | Some c ->
            let so_far' = String.(sub (of_char c)) :: data :: so_far in
            inner in_quoted (String.Sub.tail rem) so_far' acc
          | None -> raise Exit
        end
      | Some c ->
        Printf.printf "Something went wrong in the argv parser: Matched '%c'" c;
        raise Exit
      | None ->
        let so_far = List.rev (data :: so_far) in
        List.map (String.Sub.to_string) (List.rev ((String.Sub.concat so_far) :: acc))
    in
    inner false s [] []
  in
  split (String.sub s |> skip_white) |> List.filter (fun s -> String.length s > 0)



let tests =
  [ "foo bar baz", ["foo"; "bar"; "baz"];
    "foo \"bar\" baz", ["foo"; "bar"; "baz"];
    "f\\\ oo b\\\"r baz", ["f oo"; "b\"r"; "baz"];
    "foo bar\"bie\"boo baz", ["foo"; "barbieboo"; "baz"];
    "  ", []
  ]
  
let _ =
  List.iter (fun (input, output) ->
      let result = parse input in
      if result <> output then begin
        Printf.printf "Got\n";
        List.iter (fun x -> Printf.printf "'%s'\n" x) result;
        Printf.printf "Expected\n";
        List.iter (fun x -> Printf.printf "'%s'\n" x) output;
      end;
      assert (result=output)) tests

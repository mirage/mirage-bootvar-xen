open OUnit

let test_parse () =
  ()

let _ =
  let verbose = ref false in
  Arg.parse [
    "-verbose", Arg.Unit (fun _ -> verbose := true), "Run in verbose mode";
  ] (fun x -> Printf.fprintf stderr "Ignoring argument: %s" x)
  "Test unix block driver";

  let suite = "parser" >::: [
    "test parse" >:: test_parse;
  ] in
  run_test_tt ~verbose:!verbose suite


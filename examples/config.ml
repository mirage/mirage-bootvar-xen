open Mirage

let main = foreign "Unikernel.Main" (console @-> job)

let () =
  add_to_ocamlfind_libraries [ "mirage-bootvar" ; "lwt" ; "re" ];
  add_to_opam_packages [ "mirage-bootvar-xen" ; "lwt" ; "re" ];

  register "unikernel" [
    main $ default_console
  ]

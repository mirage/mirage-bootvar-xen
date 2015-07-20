(*
 * Copyright (c) 2014-2015 Magnus Skjegstad <magnus@skjegstad.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)
open Lwt
open Re

type t = { cmd_line : string;
           parameters : (string * string) list }

exception Parameter_not_found of string

let get_cmd_line () =
  (* Originally based on mirage-skeleton/xen/static_website+ip code for reading
   * boot parameters, but we now read from xenstore for better ARM
   * compatibility.  *)
  OS.Xs.make () >>= fun client ->
  OS.Xs.(immediate client (fun x -> read x "vm")) >>= fun vm ->
  OS.Xs.(immediate client (fun x -> read x (vm^"/image/cmdline")))
  (*let cmd_line = OS.Start_info.((get ()).cmd_line) in -- currently only works on x86 *)

let create () = 
  get_cmd_line () >>= fun cmd_line ->
  let entries = Re_str.(split (regexp_string " ") cmd_line) in
  let parameters =
    List.map (fun x ->
        match Re_str.(split (regexp_string "=") x) with 
        | [a;b] -> (a,b)
        | _ -> raise (Failure "Malformed boot parameters")) entries
  in
  let t = 
    try 
      `Ok { cmd_line; parameters}
    with 
      Failure msg -> `Error msg
  in
  return t

let get_exn t parameter = 
  try
    List.assoc parameter t.parameters
  with
    Not_found -> raise (Parameter_not_found parameter)

let get t parameter =
  try
    Some (List.assoc parameter t.parameters)
  with
    Not_found -> None

let parameters x = x.parameters

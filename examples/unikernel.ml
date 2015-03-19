(*
 * Copyright (c) 2015 Magnus Skjegstad <magnus@skjegstad.com>
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


(* Unikernel that reads the boot parameter "hello" and exits. 
 *
 * Run with: 
 *
 * $ mirage configure --xen
 * $ make 
 * $ sudo xl create unikernel.xl -c 'extra="hello=world"'
 *)
open Lwt

module Main (C: V1_LWT.CONSOLE) = struct

    let start c  = 
        OS.Time.sleep 2.0 (* sleep long enough to see output in console *)
        >>= fun () ->
        Bootvar.create () >>= fun bootvars ->
        let t = match bootvars with
            | `Error msg -> raise (Failure msg)
            | `Ok t -> t
        in
        (try
            let hello = Bootvar.get_exn t "hello" in
            C.log_s c (Printf.sprintf "hello=%s\n" hello)
        with
            Bootvar.Parameter_not_found s -> C.log_s c (Printf.sprintf "Expected parameter %s not found" s))
        >>= fun () ->
        Lwt.return_unit

end


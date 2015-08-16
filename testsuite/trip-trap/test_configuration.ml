(* Test_configuration -- Test configuration parser

Author: Michael Grünewald
Date: Fri Aug  8 14:55:52 CEST 2014

Configuration (https://github.com/michipili/configuration)
This file is part of Configuration

Copyright © 2012–2015 Michael Grünewald

This file must be used under the terms of the CeCILL-B.
This source file is licensed as described in the file COPYING, which
you should have received as part of this distribution. The terms
are also available at
http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt *)
open Printf

(* A parser definition logging all events. *)
module Logger =
struct
  type t = unit

  let pos_to_lc pos =
    pos.Lexing.pos_lnum,
    pos.Lexing.pos_cnum - pos.Lexing.pos_bol

  let excerpt_to_string tag excerpt =
    let startpos = Configuration_Parser.startpos excerpt in
    let endpos = Configuration_Parser.endpos excerpt in
    let text = Configuration_Parser.text excerpt in
    let startline, startcol =
      pos_to_lc startpos
    in
    let endline, endcol =
      pos_to_lc endpos
    in
    sprintf "%03d:%03d-%03d:%03d %s(%S)"
      startline startcol
      endline endcol
      tag text

  let comment exc () =
    print_endline (excerpt_to_string "COMMENT" exc)

  let section path () =
    let process exc =
      print_endline (excerpt_to_string "PATH_ELT" exc)
    in
    List.iter process path

  let binding key value () =
    begin
      print_endline (excerpt_to_string "KEY" key);
      print_endline (excerpt_to_string "VALUE" value);
    end

  let parse_error errpos error () =
    let errline, errcol =
      pos_to_lc errpos
    in
    printf "%03d:%02d PARSE_ERROR(%S)\n"
      errline errcol
      (Configuration_Parser.error_to_string error)

end

module ConfigurationLogger =
  Configuration_Parser.Make(Logger)


let () = ConfigurationLogger.parse_file Sys.argv.(1) ()

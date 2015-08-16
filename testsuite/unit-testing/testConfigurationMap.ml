(* TestConfiguration -- Test configuration

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
open Broken

let configuration1 = "
maxusers = 25
message = \"I still cannot do much to help you, \\
           but I can demonstrate how configuration values \\
           can span over multiple lines!\"
"

let configuration2 = "maxusers = 10"

let configuration3 = "="

let concrete_string =
  let id_string = (fun (x : string) -> x) in {
    Configuration_Map.
    of_string = id_string;
    to_string = id_string;
  }

let concrete_int = {
  Configuration_Map.
  of_string = int_of_string;
  to_string = string_of_int;
}

let test_multiple_lines () =
  let conf = Configuration_Map.from_string configuration1 in
  let key = Configuration_Map.key concrete_string [] "message"
    "This is the default value of a message"
    "A message displayed to the user in various circonstances."
  in
  let expected = "\
    I still cannot do much to help you, \
    but I can demonstrate how configuration values \
    can span over multiple lines!"
  in
  assert_string "multiple-lines"
    (Configuration_Map.get conf) key expected

let test_override () =
  let conf =
    Configuration_Map.(override (from_string configuration1)
		     (from_string configuration2))
  in
  let key = Configuration_Map.key concrete_int [] "maxusers"
    13
    "The maximal number of users"
  in
  let expected = 10 in
  assert_int "override"
    (Configuration_Map.get conf) key expected

let test_illegal_character () =
  assert_exception "illegal_character"
    (Failure("Syntax error in configuration text on line 1."))
    Configuration_Map.from_string "="


let () =
  make_suite "Configuration" "Test the Configuration parser"
  |& test_multiple_lines ()
  |& test_override ()
  |& test_illegal_character()
  |> register

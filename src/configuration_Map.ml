(* Configuration_Map -- Generic configuration facility

   Author: Michael Grünewald
   Date: Wed Oct 24 07:48:50 CEST 2012

   Copyright © 2012–2015 Michael Grünewald

   This file must be used under the terms of the CeCILL-B.
   This source file is licensed as described in the file COPYING, which
   you should have received as part of this distribution. The terms
   are also available at
   http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt *)

open Printf

let path_to_string p k =
  String.concat "." (p @ [k])

(* Finite automatons recognising globbing patterns. *)
module Glob =
struct

  let rec list_match pattern text =
    match pattern, text with
    | [], [] -> true
    | '*' :: pattern_tl, [] -> list_match pattern_tl []
    | '*' :: pattern_tl, text_hd :: text_tl ->
        list_match pattern_tl text || list_match pattern text_tl
    | '?' :: pattern_tl, _ :: text_tl -> list_match pattern_tl text_tl
    | pattern_hd :: pattern_tl, text_hd :: text_tl ->
        (pattern_hd = text_hd) && list_match pattern_tl text_tl
    | _ -> false

  let string_chars s =
    let rec loop ax i =
      if i < 0 then
        ax
      else
        loop (s.[i] :: ax) (i-1)
    in
    loop [] (String.length s - 1)

  let string_match pattern text =
    list_match (string_chars pattern) (string_chars text)
end


(* We implement configuration sets as a functor parametrised by
   messages emitted on the occurence of various events. *)

module type MESSAGE =
sig
  val value_error : string list -> string ->
    Lexing.position -> string -> string -> unit
  val uncaught_exn : string list -> string ->
    Lexing.position -> string -> exn -> unit
  val default : string list -> string -> string -> unit
  val parse_error : Lexing.position -> string -> unit
end

module type S =
sig
  type t
  type 'a concrete = {
    of_string: string -> 'a;
    to_string: 'a -> string;
  }
  type 'a key = {
    concrete: 'a concrete;
    path: string list;
    name: string;
    default: 'a;
    description: string;
  }
  val key : ('a concrete) -> string list -> string -> 'a -> string -> 'a key
  val get : t -> 'a key -> 'a
  val value : 'a key -> string -> 'a
  type 'b editor
  val xmap : ('a -> 'b) -> ('b -> 'a -> 'a) -> 'b editor -> 'a editor
  val editor : 'a key -> ('a -> 'b -> 'b) -> 'b editor
  val apply : t -> 'b editor -> 'b -> 'b
  val empty : t
  val add : t -> (string list * string) -> string -> t
  val merge : t -> t -> t
  val override : t -> t -> t
  val from_file : string -> t
  val from_string : string -> t
  val from_alist : ((string list * string) * string) list -> t
end

(* We provide a simple implementation of the required associative
   structure based on alists.

   An implementation based on finite automatons could be interesting in
   the case where there is a large number of keys, because it would speed
   up the retrieval.

   It is not possible to use an hashtable because keys could be patterns. *)
module Make(M:MESSAGE) =
struct

  type t =
    (string * (string * Lexing.position)) list

  type 'a concrete = {
    of_string: string -> 'a;
    to_string: 'a -> string;
  }

  type 'a key = {
    concrete: 'a concrete;
    path: string list;
    name: string;
    default: 'a;
    description: string;
  }

  type 'b editor = {
    editor_path: string list;
    editor_name: string;
    editor_description: string;
    editor_f: t -> 'b -> 'b;
  }

  let xmap get set editor =
    let editor_f conf x =
      set (editor.editor_f conf (get x)) x
    in
    { editor with editor_f }

  let key c p k def des = {
    concrete = c;
    path = p;
    name = k;
    default = def;
    description = des;
  }

  let assoc key conf =
    let path_as_string =
      path_to_string key.path key.name
    in
    let string_match (glob, data) =
      Glob.string_match glob path_as_string
    in
    snd (List.find string_match conf)

  let use_default key =
    M.default key.path key.name (key.concrete.to_string key.default);
    key.default

  let positioned_value pos key text =
    try key.concrete.of_string text
    with
    | Failure(mesg) ->
        M.value_error key.path key.name pos text mesg;
        use_default key
    | exn ->
        M.uncaught_exn key.path key.name pos text exn;
        use_default key

  let value key text =
    positioned_value Lexing.dummy_pos key text

  let get a key =
    try
      let (text, pos) = assoc key a in
      positioned_value pos key text
    with
    | Not_found -> use_default key

  let editor key edit =
    let editor_f conf =
      edit (get conf key)
    in
    {
      editor_path = key.path;
      editor_name = key.name;
      editor_description = key.description;
      editor_f;
    }

  let apply conf editor =
    editor.editor_f conf

  let empty = []

  let add a (p,k) v =
    (path_to_string p k, (v, Lexing.dummy_pos)) :: a

  let merge a b =
    a @ b

  let rec override_loop a b ax =
    match a with
    | [] -> List.rev ax
    | (k,v)::t -> (
        if List.mem_assoc k b then
          override_loop t b ((k, List.assoc k b) :: ax)
        else
          override_loop t b ((k,v) :: ax)
      )

  let override a b =
    override_loop a b []


  (* Definition of our configuration parser *)
  module Parser_definition =
  struct
    type configuration = t

    type t = {
      path: string list;
      conf: configuration;
    }

    let comment _ state = state

    let section l state =
      { state with path = List.map Configuration_Parser.text l }

    let binding k v state =
      let path = path_to_string state.path (Configuration_Parser.text k) in
      let text = Configuration_Parser.text v in
      let pos = Configuration_Parser.startpos v in
      { state with conf = (path, (text, pos)) :: state.conf }

    let parse_error pos error state =
      (M.parse_error pos (Configuration_Parser.error_to_string error); state)
  end

  module Parser = Configuration_Parser.Make(Parser_definition)

  let from_anything f x =
    let p = {
      Parser_definition.
      path = [];
      conf = [];
    } in
    begin
      List.rev (f x p).Parser_definition.conf
    end

  let from_file =
    from_anything Parser.parse_file

  let from_string =
    from_anything Parser.parse_string

  let from_alist a =
    let loop c (k,v) = add c k v in
    List.fold_left loop empty a
end


module Quiet =
struct
  let value_error path name pos text mesg =
    ()

  let uncaught_exn path name pos text exn =
    ()

  let default path name value =
    ()

  let parse_error pos message =
    ()
end


module Verbose =
struct
  let value_error path name pos text mesg =
    eprintf "ConfigurationMap.value_error: '%s' for '%s' in %s'"
      text (path_to_string path name) pos.Lexing.pos_fname

  let uncaught_exn path name pos text exn =
    eprintf "ConfigurationMap.uncaught_exn: %s: %s\n"
      (path_to_string path name) (Printexc.to_string exn)

  let default path name value =
    eprintf "ConfigurationMap.default: %s: %s\n"
      (path_to_string path name) value

  let parse_error pos message =
    eprintf "ConfigurationMap.parse_error: \
             syntax error in configuration file '%s' on line %d."
      pos.Lexing.pos_fname pos.Lexing.pos_lnum
end


module Brittle =
struct

  type location =
    | Undefined
    | File of string * int

  let location pos =
    if pos.Lexing.pos_fname = "" then
      Undefined
    else
      File(pos.Lexing.pos_fname, pos.Lexing.pos_lnum)

  let failprintf fmt =
    ksprintf (fun s -> raise(Failure(s))) fmt

  let value_error path name pos text mesg =
    match location pos with
    | File(filename, line) ->
        failprintf "Bad %s value '%s' for '%s' in '%s'."
          mesg text (path_to_string path name) filename
    | Undefined ->
        failprintf "Bad %s value '%s' for '%s'."
          mesg text (path_to_string path name)

  let uncaught_exn path name pos text exn =
    eprintf "ConfigurationMap.uncaught_exn: %s: %s\n"
      (path_to_string path name) (Printexc.to_string exn)

  let default path name value =
    ()

  let parse_error pos message =
    match location pos with
    | File(filename, line) ->
        failprintf "Syntax error in configuration file '%s' on line %d."
          filename line
    | Undefined ->
        failprintf "Syntax error in configuration text on line %d."
          pos.Lexing.pos_lnum
end


module Internal =
  (Make(Brittle) : S)

include Internal

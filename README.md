# Configuration, analyse configuration files

The **Configuration** projects implements a library to analyse
configuration files written in some flavour of the popular INI-file
syntax.

[![Build Status](https://travis-ci.org/michipili/configuration.svg?branch=master)](https://travis-ci.org/michipili/configuration?branch=master)

It supports comments, quoted section names, quoted configuration
values and configuration values spreading over several lines.


## Configuration Parser

The module *Configuration_Parser* implements a functional
configuration parser.  This is actually a functor parametrised by a
parser definition defining the behaviour of the parser. The parser
definition has the following signature:

```ocaml
(** The input signature of the functor [Configuration_Parser.Make]. *)
module type Definition =
sig

  (** The type of functional parser state. *)
  type t

  (** Receive a comment. *)
  val comment : excerpt -> t -> t

  (** Receive a section specification. *)
  val section : excerpt list -> t -> t

  (** Receive a binding specificaton. *)
  val binding : excerpt -> excerpt -> t -> t

  (** Receive a parser error. *)
  val parse_error : pos -> error -> t -> t

end
```

A parser definition must define four events functionally editing a
parser state. The *excerpt* state used in the signature above is a
piece of text decorated with location information.


## Configuration Map

A *configuration map* holds configuration *values* associated to a
configuration *path*.  It is possible to read configuration maps from
files, strings, or directly from a list of bindings:

```ocaml
(** Read configuration values from a file. *)
val from_file : string -> t

(** Read configuration values from a string. *)
val from_string : string -> t

(** Read configuration values from an alist. *)
val from_alist : ((string list * string) * string) list -> t
```

Configuration maps can also be extended and combined together:

```ocaml
(** The empty configuration map. *)
val empty : t

(** Add a configuration binding. *)
val add : t -> (string list * string) -> string -> t

(** [merge a b] is a configuration map looking up values in [a] then
    in [b]. *)
val merge : t -> t -> t

(** [override a b] a configuration map whose keys are the same as
    [a] and the values are possibly overriden by those found in [b]. *)
val override : t -> t -> t
```

The *merge* and *override* operations make it easy to combine
site-wide and user-specific configurations and can be used to let the
site administrator enforce some specific values.

Retrieving individual values from a configuration map is accomplished
using configuration keys:

```ocaml
(** The type of configuration keys.  A configuration key can be used
    to retrieve a configuration value. *)
type 'a key = {
  concrete: 'a concrete;
  path: string list;
  name: string;
  default: 'a;
  description: string;
}

(** The type of configuration values concrete representations.
    A concrete representation should use the [parse_error] function below
    to advertise errors. *)
and 'a concrete = {
  of_string: string -> 'a;
  to_string: 'a -> string;
}

(** [key concrete path name default description] create a key
    out of its given parts. *)
val key : ('a concrete) -> string list -> string -> 'a -> string -> 'a key

(** Get the value associated with an key.  On error conditions, the
    default value from the key is returned. *)
val get : t -> 'a key -> 'a
```

Last, configuration maps support the definitions of *functional
editors* which ease the editing of program parameters given a
configuration map:

```ocaml
(** The abstract type of functional configuration editors,
    functionally editing a value of type ['b]. *)
type 'b editor

(** [editor key edit] create a functional configuration editor consuming
    keys described by [key] and functionally editing a value of type
    ['b] with [edit]. *)
val editor : 'a key -> ('a -> 'b -> 'b) -> 'b editor

(** Explicitely edit the given value with the provided editor. *)
val apply : t -> 'b editor -> 'b -> 'b
```

The *apply* function can easily be combined with *List.fold_right*.

The *xmap* function defines a natural isomorphism between editors of
two different functional values, which can be used in combination with
[lenses][lenses-home]:

```ocaml
(** [xmap get set editor] convert an editor functionally modifying a
    value of type ['b] in an editor functionally modifying a value of type
    ['a].  This can be used in conjunction with lenses to separately
    configure the different modules of an application. *)
val xmap : ('a -> 'b) -> ('b -> 'a -> 'a) -> 'b editor -> 'a editor
```


## Free software

It is written by Michael Grünewald and is distributed as a free
software: copying it  and redistributing it is
very much welcome under conditions of the [CeCILL-B][licence-url]
licence agreement, found in the [COPYING][licence-en] and
[COPYING-FR][licence-fr] files of the distribution.


## Setup guide

It is easy to install **Configuration** using **opam** and its *pinning*
feature.  In a shell visiting the repository, say

```console
% opam pin add configuration .
```

It is also possible to install **Configuration** manually.
The installation procedure is based on the portable build system
[BSD Owl Scripts][bsdowl-home] written for BSD Make.

1. Verify that prerequisites are installed:
   - GNU Autoconf
   - BSD Make
   - OCaml
   - [BSD Owl][bsdowl-install]
   - [Broken][broken-home]

2. Get the source, either by cloning the repository or by exploding a
   [distribution tarball](releases).

3. Optionally run `autoconf` to produce a configuration script. This
   is only required if the script is not already present.

4. Run `./configure`, you can choose the installation prefix with
   `--prefix`.

5. Run `make build`.

6. Optionally run `make test` to test your build.

7. Finally run `make install`.

Depending on how **BSD Make** is called on your system, you may need to
replace `make` by `bsdmake` or `bmake` in steps 5, 6, and 7.
The **GNU Make** program usually give up the ghost, croaking
`*** missing separator. Stop.` when you mistakingly use it instead of
**BSD Make**.

Step 7 requires that you can `su -` if you are not already `root`.


Michael Grünewald in Bonn, on August 15, 2015


  [licence-url]:        http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.html
  [licence-en]:         COPYING
  [licence-fr]:         COPYING-FR
  [bsdowl-home]:        https://github.com/michipili/bsdowl
  [bsdowl-install]:     https://github.com/michipili/bsdowl/wiki/Install
  [broken-home]:        https://github.com/michipili/broken
  [lenses-home]:        https://github.com/https://github.com/avsm/ocaml-lens

# Configuration, analyse configuration files

The **Configuration** projects implements a library to analyse
configuration files written in some flavour of the popular INI-file
syntax.

[![Build Status](https://travis-ci.org/michipili/configuration.svg?branch=master)](https://travis-ci.org/michipili/configuration?branch=master)

It supports comments, quoted section names, quoted configuration
values and configuration values spreading over several lines.


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

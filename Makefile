### Makefile -- Configuration

# Author: Michael Grünewald
# Date: Tue Nov  5 22:37:27 CET 2013

# Configuration (https://github.com/michipili/configuration)
# This file is part of Configuration
#
# Copyright © 2012–2015 Michael Grünewald
#
# This file must be used under the terms of the CeCILL-B.
# This source file is licensed as described in the file COPYING, which
# you should have received as part of this distribution. The terms
# are also available at
# http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt

PACKAGE=		configuration
VERSION=		0.4.1-current
OFFICER=		michipili@gmail.com

MODULE=			ocaml.lib:src
MODULE+=		ocaml.meta:meta
MODULE+=		ocaml.manual:manual

SUBDIR=			testsuite

EXTERNAL=		ocaml.findlib:broken

CONFIGURE=		meta/configuration.in
CONFIGURE+=		Makefile.config.in

.include "generic.project.mk"

### End of file `Makefile'

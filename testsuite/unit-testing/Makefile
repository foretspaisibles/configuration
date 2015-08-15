### Makefile -- Test suite

# Author: Michael Grünewald
# Date: Mon Apr 14 23:52:37 CEST 2014

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

PROGRAM=	unit_testing

SRCS+=		testConfigurationMap.ml
SRCS+=		main.ml

do-test: build
	${PROGRAM:tA}

do-install:
	${NOP}

.include "ocaml.prog.mk"

### End of file `Makefile'

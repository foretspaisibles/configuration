### Makefile -- Trip-trap test for the configuration parser

# Author: Michael Grünewald
# Date: Fri Aug  8 13:27:56 CEST 2014

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

PROGRAM=		test_configuration

TESTS+=			test-parser

ARGS.test-parser=	${.ALLSRC:M*.conf}
test-parser.got:	example.conf

.SUFFIXES: .expected .got


install:
	${NOP}

.for test in ${TESTS}
${test}.got: ${PROGRAM}
	${PROGRAM:tA} ${ARGS.${test}} > ${.TARGET}

CLEANFILES+=		${test}.got

test: do-${test}

.if !target(do-${test})
do-${test}: ${test}.expected ${test}.got
	diff -u ${.ALLSRC:M*.expected} ${.ALLSRC:M*.got}
.endif
.endfor

.include "ocaml.prog.mk"

### End of file `Makefile'

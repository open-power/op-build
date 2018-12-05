#!/bin/bash

T=$(mktemp -d)
A=$1
B=$2
R=0

pflash -i -F $A |grep -v '^Name' > $T/A.toc
pflash -i -F $B |grep -v '^Name' > $T/B.toc
diff -u $T/A.toc $T/B.toc
if [ $? != 0 ]; then R=1; fi

for p in $(pflash -i -F $A |awk '/^ID\=[0-9]+\w+(.*)/ { print $2};'); do
	pflash -F $A -P $p -r $T/$p.A >/dev/null
	pflash -F $B -P $p -r $T/$p.B >/dev/null
	diff -u $T/$p.A $T/$p.B
	if [ $? != 0 ]; then R=1; fi
done

if [ $R == 0 ]; then rm -rf $T; fi

exit $R

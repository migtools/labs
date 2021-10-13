#!/bin/sh
cd bookbag
oc start-build bookbag --follow --from-dir=../.. &&  oc process -f deploy-template.yaml | oc apply -f -;
cd ..
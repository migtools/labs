#!/bin/sh
cd bookbag
oc process -f build-template.yaml -p GIT_REPO="https://github.com/konveyor/labs.git" | oc apply -f -
oc start-build bookbag --follow --from-dir=../.. &&  oc process -f deploy-template.yaml | oc apply -f -;
cd ..
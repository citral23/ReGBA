#!/bin/bash
rm -rf .multi_opk
cp -r data .multi_opk

for TARGET in gcw0 lepus rg99 rs90
do CONFIG=$TARGET make opk && cp regba.$TARGET .multi_opk && CONFIG=$TARGET make clean
done

mksquashfs .multi_opk regba_multi.opk -all-root -noappend -no-exports -no-xattrs -no-progress >/dev/null

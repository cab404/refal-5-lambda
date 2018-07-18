#!/bin/bash

( cd src && RELEASE=1 ./make.sh )

pushd distrib
rm -rf bin scripts compiler doc docs lexgen srlib srmake editors
cp -R ../build/{compiler,lexgen,srmake,srlib-{rich,slim}-prefix} .
mkdir bin
cp ../src/scripts/srefc.bat bin
cp ../src/scripts/srefc.sh bin/srefc
cp ../src/scripts/srmake.bat bin
cp ../src/scripts/srmake.sh bin/srmake
mkdir scripts
cp ../scripts/* scripts
mkdir srlib
cp -R ../srlib/scratch srlib/scratch
mkdir srlib/rich
cp ../srlib/rich/*.{rasl,froms} srlib/rich
mkdir srlib/slim
cp ../srlib/slim/*.{rasl,froms} srlib/slim
mkdir srlib/common
cp -R ../srlib/common/* srlib/common
mkdir doc
cp -R ../doc/examples doc/examples
cp ../doc/*.pdf doc
cp ../doc/*.jpg doc
mkdir doc/OptPattern
cp ../doc/OptPattern/*.pdf doc/OptPattern
cp ../doc/OptPattern/*.md doc/OptPattern
mkdir doc/historical
cp ../doc/historical/*.txt doc/historical
cp ../doc/historical/*.pdf doc/historical
cp ../doc/historical/*.jpg doc/historical
cp ../doc/historical/*.doc doc/historical
mkdir doc/historical/Drogunov
cp ../doc/historical/Drogunov/*.pdf doc/historical/Drogunov
mkdir docs
cp ..\docs\*.md docs
cp ..\docs\*.ref docs
cp ..\docs\*.yml docs
cp ../LICENSE .
cp ../README.md .
cp ../README.en.md .
mkdir editors
cp -R ../editors/* editors
./bootstrap.sh
popd

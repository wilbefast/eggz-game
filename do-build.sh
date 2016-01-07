#! /bin/bash

rm -rf build/0.9.2/

cd ./src/

love-release -lmw --osx-maintainer-name wilbefast -x fudge/.git/ -x unrequited/.git/ -n eggz -r ../build/ . 


rm -f eggz-win32.zip
rm -f eggz-win64.zip
rm -f eggz-macosx-x64.zip

cd ..
cd build/0.9.2/


# Zip love version
mkdir eggz-love
cp eggz.love eggz-love
cp manual.pdf eggz-love
zip -r eggz-love.zip eggz-love/
rm -rf eggz-love
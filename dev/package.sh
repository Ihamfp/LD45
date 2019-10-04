#!/bin/sh
cd ~/Dropbox/Lua/LD42

echo "STRIPPING USELESS FILES"
rsync -a --delete --exclude "*.git" --exclude "dev" --exclude "release" --exclude "*.ase" --exclude "*.tsx" --exclude "*.tmx" --exclude "*.dropbox" --exclude "*.can" ./ release/

echo "PACKAGING MAC, WIN"
cd ~/Dropbox/Lua/LD42/release/
love-release -M -W
# cp release/* ../
# rm -r release

echo "PACKAGING APPIMAGE"
cd ~/Dropbox/Lua/LD42/release/
name="$(find release -name \*.love -printf '%f\n')"
name="${name%.*}"
cp "release/$name.love" ~/Dropbox/Lua/LD42/dev/love-x86_64/game.love
appimagetool-x86_64.AppImage ~/Dropbox/Lua/LD42/dev/love-x86_64/. "release/$name-lin64.AppImage"
chmod +x "release/$name-lin64.AppImage"


# echo "PACKAGING WEB"
# cd ~/Dropbox/Lua/LD39
# mkdir -p release/web
# cd ~/Programmation/love.js/release-compatibility
# python2 ../emscripten/tools/file_packager.py game.data --preload ~/Dropbox/Lua/LD39/release/source@/ --js-output=game.js
# cp -r ./* ~/Dropbox/Lua/LD39/release/web/

#cd ~/Dropbox/Lua/LD39
#for f in *.love *win64.zip web *win32.zip *macosx.zip *.deb; do
#	echo SENDING TO SERVER $f
#	rsync -rzvh --progress release/$f perceval:"/var/www/html/ld/39/."
#done

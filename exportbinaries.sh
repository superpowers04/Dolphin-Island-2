godotexec="godot216"
echo "This script requires godot to be named \`${godotexec}\` in one of your PATH folders to work"
#Modify the below to change what the godot executable is


${godotexec} -path "${PWD}/src" -export "Linux X11" "${PWD}/bin/DIedit32"
${godotexec} -path "${PWD}/src" -export "Windows Desktop" "${PWD}/bin/DIedit.exe"
${godotexec} -path "${PWD}/src" -export "Mac OSX" "${PWD}/bin/Di2Macfat.zip"
${godotexec} -path "${PWD}/src" -export "Android" "${PWD}/bin/DI2.apk"
echo "Done"
read
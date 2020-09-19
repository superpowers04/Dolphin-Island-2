#!/bin/bash
godotexec="godot216"
echo "This script requires godot to be named \`${godotexec}\` in one of your PATH folders to work"
#Modify the below to change what the godot executable is

# Debug exports
${godotexec} -path "${PWD}/src" -export-debug "Linux X11" "${PWD}/bin/debug/DIedit32"
${godotexec} -path "${PWD}/src" -export-debug "Windows Desktop" "${PWD}/bin/debug/DIedit.exe"
${godotexec} -path "${PWD}/src" -export-debug "Mac OSX" "${PWD}/bin/debug/Di2Macfat.zip"
${godotexec} -path "${PWD}/src" -export-debug "Android" "${PWD}/bin/debug/DI2.apk"


# Normal Exports

${godotexec} -path "${PWD}/src" -export "Linux X11" "${PWD}/bin/DIedit32"
${godotexec} -path "${PWD}/src" -export "Windows Desktop" "${PWD}/bin/DIedit.exe"
${godotexec} -path "${PWD}/src" -export "Mac OSX" "${PWD}/bin/Di2Macfat.zip"
${godotexec} -path "${PWD}/src" -export "Android" "${PWD}/bin/DI2.apk"
echo "Done"
read

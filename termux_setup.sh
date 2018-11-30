#!/data/data/com.termux/files/usr/bin/env bash
apt update
apt install termux-tools termux-api make luarocks lua clang libllvm zip unzip liblua-dev liblua
luarocks install moonscript
luarocks install busted
termux-fix-shebang $(which moon)
termux-fix-shebang $(which moonc)
termux-fix-shebang $(which busted)
termux-setup-storage
# termux-open-url 'https://play.google.com/store/apps/details?id=org.love2d.android'

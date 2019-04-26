## Linux (native) SDL builds

Dependencies:

  * SDL
  * SDL_ttf
  * freetype
  * build essentials
  * lua5.2 and liblua5.2 - Only necessary if compiling with lua, which some mods like stats through skills use. Versions 5.1, 5.2 and 5.3 are supported.
  * libsdl2-mixer-dev - Used if compiling with sound support.

Install:

    sudo apt-get install libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-mixer-dev libfreetype6-dev build-essential lua5.2 liblua5.2-dev

## Cross-compile to Windows from Linux

To cross-compile to Windows from Linux, you will need MXE. The main difference between the native build process and this one, is the use of the CROSS flag for make. The other make flags are still applicable.

  * `CROSS=` - should be the full path to MXE g++ without the *g++* part at the end

Dependencies:

  * [MXE](http://mxe.cc)
  * [MXE Requirements](http://mxe.cc/#requirements)

Install:

    sudo apt-get install autoconf automake autopoint bash bison bzip2 cmake flex gettext git g++ gperf intltool libffi-dev libgdk-pixbuf2.0-dev libtool libltdl-dev libssl-dev libxml-parser-perl make openssl p7zip-full patch perl pkg-config python ruby scons sed unzip wget xz-utils g++-multilib libc6-dev-i386 libtool-bin
    mkdir -p ~/src/mxe
    git clone https://github.com/mxe/mxe.git ~/src/mxe
    cd ~/src/mxe
    make MXE_TARGETS='x86_64-w64-mingw32.static i686-w64-mingw32.static' sdl2 sdl2_ttf sdl2_image sdl2_mixer gettext lua ncurses

If you are not on a Debian derivative (Linux Mint, Ubuntu, etc), you will have to use a different command than apt-get to install [the MXE requirements](http://mxe.cc/#requirements). Building all these packages from MXE might take a while even on a fast computer. Be patient. If you are not planning on building for both 32-bit and 64-bit, you might want to adjust your MXE_TARGETS.

### Building (SDL)

Run:

    PLATFORM="i686-w64-mingw32.static"
    make CROSS="~/src/mxe/usr/bin/${PLATFORM}-" TILES=1 SOUND=1 LUA=1 RELEASE=1 LOCALIZE=1

Change PLATFORM to x86_64-w64-mingw32.static for a 64-bit Windows build.

To create nice zip file with all the required resources for a trouble free copy on Windows use the bindist target like this:

    PLATFORM="i686-w64-mingw32.static"
    make CROSS="~/src/mxe/usr/bin/${PLATFORM}-" TILES=1 SOUND=1 LUA=1 RELEASE=1 LOCALIZE=1 bindist

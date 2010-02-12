# Copyright (c) 2009-2010 Satoshi Nakamoto
# Distributed under the MIT/X11 software license, see the accompanying
# file license.txt or http://www.opensource.org/licenses/mit-license.php.


ifneq "$(BUILD)" "debug"
ifneq "$(BUILD)" "release"
BUILD=debug
endif
endif
ifeq "$(BUILD)" "debug"
D=d
DEBUGFLAGS=-g -D__WXDEBUG__
endif



INCLUDEPATHS=-I"/boost" -I"/db/build_unix" -I"/openssl/include" -I"/wxwidgets/lib/vc_lib/mswd" -I"/wxwidgets/include"
LIBPATHS=-L"/boost/stage/lib" -L"/db/build_unix" -L"/openssl/out" -L"/wxwidgets/lib/gcc_lib"
LIBS= \
 -l libboost_system-mgw34-mt-d -l libboost_filesystem-mgw34-mt-d \
 -l db_cxx \
 -l eay32 \
 -l wxmsw28$(D)_richtext -l wxmsw28$(D)_html -l wxmsw28$(D)_core -l wxmsw28$(D)_adv -l wxbase28$(D) -l wxtiff$(D) -l wxjpeg$(D) -l wxpng$(D) -l wxzlib$(D) -l wxregex$(D) -l wxexpat$(D) \
 -l kernel32 -l user32 -l gdi32 -l comdlg32 -l winspool -l winmm -l shell32 -l comctl32 -l ole32 -l oleaut32 -l uuid -l rpcrt4 -l advapi32 -l ws2_32 -l shlwapi
WXDEFS=-DWIN32 -D__WXMSW__ -D_WINDOWS -DNOPCH
CFLAGS=-mthreads -O0 -w -Wno-invalid-offsetof -Wformat $(DEBUGFLAGS) $(WXDEFS) $(INCLUDEPATHS)
HEADERS=headers.h strlcpy.h serialize.h uint256.h util.h key.h bignum.h base58.h script.h db.h net.h irc.h main.h market.h rpc.h uibase.h ui.h



all: bitcoin.exe


headers.h.gch: headers.h            $(HEADERS)
	g++ -c $(CFLAGS) -o $@ $<

obj/util.o: util.cpp                $(HEADERS)
	g++ -c $(CFLAGS) -o $@ $<

obj/script.o: script.cpp            $(HEADERS)
	g++ -c $(CFLAGS) -o $@ $<

obj/db.o: db.cpp                    $(HEADERS)
	g++ -c $(CFLAGS) -o $@ $<

obj/net.o: net.cpp                  $(HEADERS)
	g++ -c $(CFLAGS) -o $@ $<

obj/main.o: main.cpp                $(HEADERS) sha.h
	g++ -c $(CFLAGS) -o $@ $<

obj/market.o: market.cpp            $(HEADERS)
	g++ -c $(CFLAGS) -o $@ $<

obj/ui.o: ui.cpp                    $(HEADERS)
	g++ -c $(CFLAGS) -o $@ $<

obj/uibase.o: uibase.cpp            uibase.h
	g++ -c $(CFLAGS) -o $@ $<

obj/sha.o: sha.cpp                  sha.h
	g++ -c $(CFLAGS) -O3 -o $@ $<

obj/irc.o: irc.cpp                  $(HEADERS)
	g++ -c $(CFLAGS) -o $@ $<

obj/rpc.o: rpc.cpp                  $(HEADERS)
	g++ -c $(CFLAGS) -o $@ $<

obj/ui_res.o: ui.rc  rc/bitcoin.ico rc/check.ico rc/send16.bmp rc/send16mask.bmp rc/send16masknoshadow.bmp rc/send20.bmp rc/send20mask.bmp rc/addressbook16.bmp rc/addressbook16mask.bmp rc/addressbook20.bmp rc/addressbook20mask.bmp
	windres $(WXDEFS) $(INCLUDEPATHS) -o $@ -i $<



OBJS=obj/util.o obj/script.o obj/db.o obj/net.o obj/main.o obj/market.o \
        obj/ui.o obj/uibase.o obj/sha.o obj/irc.o obj/rpc.o \
        obj/ui_res.o

bitcoin.exe: headers.h.gch $(OBJS)
	-kill /f bitcoin.exe
	g++ $(CFLAGS) -mwindows -Wl,--subsystem,windows -o $@ $(LIBPATHS) $(OBJS) $(LIBS)

clean:
	-del /Q obj\*
	-del /Q headers.h.gch

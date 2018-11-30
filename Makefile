# zipfile name
lovefile = $(notdir $(CURDIR)).love

# Get moonc from the current path
moonc = $(shell which moonc | head -n 1)
# If moonc isnt in the current path set to local luarocks moonc.
ifeq ($(moonc),)  # is $(moonc) empty?
	moonc = "$(HOME)/.luarocks/bin/moonc"
endif

# Are we using termux on android?
ifeq ($(findstring "com.termux", "$(PATH)"), "com.termux")
	runcommand = run_android
else
	runcommand = run_linux
endif

# moon source files
moonfiles = $(wildcard *.moon)
# lua source files compiled from moonfiles
compiled_moonfiles = $(moonfiles:.moon=.lua)

all: moonpathecho $(compiled_moonfiles) zip $(runcommand)

moonpathecho:
	@echo "Using $(moonc)"

$(compiled_moonfiles): $(moonfiles)

%.lua: %.moon
	@$(moonc) -o $@ $<

zip:
	@zip -r $(lovefile) *.lua *.ttf shine

run_android:
	cp $(lovefile) ~/storage/downloads/$(lovefile)
	am start -d "file:///sdcard/Download/$(lovefile)" --user 0 -t "application/*" -n org.love2d.android/org.love2d.android.GameActivity

run_linux:
	love $(lovefile)

.PHONY: clean
clean:
	-rm -f $(compiled_moonfiles) $(lovefile)

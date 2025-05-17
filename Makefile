GODOT_PATH := godot
MOD_DIRECTORY := ${HOME}/.local/share/godot/app_userdata/SV Mod Loader/mods

all: example-mod-blue-player

example-mod-blue-player:
	cd example-mods/blue-player; $(GODOT_PATH) --headless --export-pack Mod build/blue-player.pck

install-example-mods: install-example-mod-blue-player

install-example-mod-blue-player: mod-directory
	cp --update=all example-mods/blue-player/build/blue-player.pck "${MOD_DIRECTORY}/blue-player.pck"

clean: clean-example-mod-blue-player

clean-example-mod-blue-player:
	rm -f example-mods/blue-player/build/blue-player.pck

mod-directory:
	mkdir -p ${MOD_DIRECTORY}

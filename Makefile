GODOT_PATH := godot
MOD_DIRECTORY := ${HOME}/.local/share/godot/app_userdata/SV Mod Loader Example Game/mods



all: linux

linux:
	mkdir -p build/linux; $(GODOT_PATH) --headless --export-release Linux "build/linux/SV Mod Loader Example Game.x86_64"



example-mods: example-mod-blue-player example-mod-yellow-player example-mod-red-background example-mod-2x-bullet-speed

example-mod-blue-player:
	cd example-mods/blue-player; $(GODOT_PATH) --headless --export-pack Mod build/blue-player.pck

example-mod-yellow-player:
	cd example-mods/yellow-player; $(GODOT_PATH) --headless --export-pack Mod build/yellow-player.pck

example-mod-red-background:
	cd example-mods/red-background; $(GODOT_PATH) --headless --export-pack Mod build/red-background.pck

example-mod-2x-bullet-speed:
	cd example-mods/2x-bullet-speed; $(GODOT_PATH) --headless --export-pack Mod build/2x-bullet-speed.pck



clean-example-mods: clean-example-mod-blue-player clean-example-mod-yellow-player clean-example-mod-red-background clean-example-mod-2x-bullet-speed

clean-example-mod-blue-player:
	rm -f example-mods/blue-player/build/blue-player.pck

clean-example-mod-yellow-player:
	rm -f example-mods/yellow-player/build/yellow-player.pck

clean-example-mod-red-background:
	rm -f example-mods/red-background/build/red-background.pck

clean-example-mod-2x-bullet-speed:
	rm -f example-mods/2x-bullet-speed/build/2x-bullet-speed.pck



install-example-mods: install-example-mod-blue-player install-example-mod-yellow-player install-example-mod-red-background install-example-mod-2x-bullet-speed

install-example-mod-blue-player: mod-directory
	cp --update=all example-mods/blue-player/build/blue-player.pck "${MOD_DIRECTORY}/blue-player.pck"

install-example-mod-yellow-player: mod-directory
	cp --update=all example-mods/yellow-player/build/yellow-player.pck "${MOD_DIRECTORY}/yellow-player.pck"

install-example-mod-red-background: mod-directory
	cp --update=all example-mods/red-background/build/red-background.pck "${MOD_DIRECTORY}/red-background.pck"

install-example-mod-2x-bullet-speed: mod-directory
	cp --update=all example-mods/2x-bullet-speed/build/2x-bullet-speed.pck "${MOD_DIRECTORY}/2x-bullet-speed.pck"



uninstall-example-mods: uninstall-example-mod-blue-player uninstall-example-mod-yellow-player uninstall-example-mod-red-background uninstall-example-mod-2x-bullet-speed

uninstall-example-mod-blue-player:
	rm -f "${MOD_DIRECTORY}/blue-player.pck"

uninstall-example-mod-yellow-player:
	rm -f "${MOD_DIRECTORY}/yellow-player.pck"

uninstall-example-mod-red-background:
	rm -f "${MOD_DIRECTORY}/red-background.pck"

uninstall-example-mod-2x-bullet-speed:
	rm -f "${MOD_DIRECTORY}/2x-bullet-speed.pck"



mod-directory:
	mkdir -p ${MOD_DIRECTORY}

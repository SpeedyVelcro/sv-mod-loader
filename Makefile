GODOT_PATH := godot
MOD_DIRECTORY := ${HOME}/.local/share/godot/app_userdata/SV Mod Loader/mods



all: example-mod-blue-player example-mod-yellow-player



example-mod-blue-player:
	cd example-mods/blue-player; $(GODOT_PATH) --headless --export-pack Mod build/blue-player.pck

example-mod-yellow-player:
	cd example-mods/yello-player; $(GODOT_PATH) --headless --export-pack Mod build/yellow-player.pck



clean: clean-example-mod-blue-player clean-example-mod-blue-player

clean-example-mod-blue-player:
	rm -f example-mods/blue-player/build/blue-player.pck

clean-example-mod-yellow-player:
	rm -f example-mods/yellow-player/build/yellow-player.pck



install-example-mods: install-example-mod-blue-player install-example-mod-yellow-player

install-example-mod-blue-player: mod-directory
	cp --update=all example-mods/blue-player/build/blue-player.pck "${MOD_DIRECTORY}/blue-player.pck"

install-example-mod-yellow-player: mod-directory
	cp --update=all example-mods/yellow-player/build/yellow-player.pck "${MOD_DIRECTORY}/yellow-player.pck"



uninstall-example-mods: uninstall-example-mod-blue-player uninstall-example-mod-yellow-player

uninstall-example-mod-blue-player:
	rm -f "${MOD_DIRECTORY}/blue-player.pck"

uninstall-example-mod-yellow-player:
	rm -f "${MOD_DIRECTORY}/yellow-player.pck"



mod-directory:
	mkdir -p ${MOD_DIRECTORY}

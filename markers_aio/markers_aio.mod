return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`markers_aio` encountered an error loading the Darktide Mod Framework.")

		new_mod("markers_aio", {
			mod_script       = "markers_aio/scripts/mods/markers_aio/markers_aio",
			mod_data         = "markers_aio/scripts/mods/markers_aio/markers_aio_data",
			mod_localization = "markers_aio/scripts/mods/markers_aio/markers_aio_localization",
		})
	end,
	packages = {},
}

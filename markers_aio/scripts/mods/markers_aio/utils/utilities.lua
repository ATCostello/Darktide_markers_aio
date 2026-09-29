local mod = get_mod("markers_aio")

mod.get_archetype_symbol = function(archetype)
	local archetype_symbol = ""
	if archetype.name == "veteran" then
		archetype_symbol = ""
	elseif archetype.name == "zealot" then
		archetype_symbol = ""
	elseif archetype.name == "psyker" then
		archetype_symbol = ""
	elseif archetype.name == "ogryn" then
		archetype_symbol = ""
	elseif archetype.name == "adamant" then
		archetype_symbol = ""
	elseif archetype.name == "broker" then
		archetype_symbol = ""
	elseif archetype.name == "cryptic" then
		archetype_symbol = ""
	end

	return archetype_symbol
end

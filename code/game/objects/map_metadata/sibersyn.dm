
/obj/map_metadata/sibersyn
	ID = MAP_SIBERSYN
	title = "Battle of the Bridges"
	lobby_icon_state = "ww1"
	no_winner ="The battle ends in stalemate."
	caribbean_blocking_area_types = list(/area/caribbean/no_mans_land/invisible_wall/tundra)
	respawn_delay = 600
	faction_organization = list(
		RUSSIAN,
		CIVILIAN)

	roundend_condition_sides = list(
		list(RUSSIAN) = /area/caribbean/pirates/land/inside/objective,
		list(CIVILIAN) = /area/caribbean/russian/land/inside/command,
		)
	age = "1919"
	ordinal_age = 5
	faction_distribution_coeffs = list(RUSSIAN = 0.5, CIVILIAN = 0.5)
	battle_name = "Battle of the Bridges."
	mission_start_message = "<font size=4>All factions have <b>7 minutes</b> to prepare before the ceasefire ends!<br>The <b>Soviets</b> will win if they capture the <i>White Army's</i> command post <b>in 40 minutes</b>. <br>The <b>White Army</b> will win if they capture the <i>Soviets'</i> command post<b> in 40 minutes. <br>If no command post is captured within 40 minutes the battle will end in a stalemate</font>"
	faction1 = RUSSIAN
	faction2 = CIVILIAN
	valid_weather_types = list(WEATHER_NONE, WEATHER_WET, WEATHER_EXTREME)
	songs = list(
		"Argonnerwaldlied:1" = 'sound/music/argonnerwaldlied.ogg')
	gamemode = "Siege"

obj/map_metadata/sibersyn/job_enabled_specialcheck(var/datum/job/J)
	..()
	if (istype(J, /datum/job/civilian/fantasy))
		. = FALSE
	if (istype(J, /datum/job/russian))
		if (J.is_rcw == TRUE)
			. = TRUE
		else
			. = FALSE
	else
		if (J.is_rcw == TRUE)
			. = TRUE
		else
			. = FALSE

/obj/map_metadata/sibersyn/faction1_can_cross_blocks()
	return (processes.ticker.playtime_elapsed >= 4200 || admin_ended_all_grace_periods)

/obj/map_metadata/sibersyn/faction2_can_cross_blocks()
	return (processes.ticker.playtime_elapsed >= 4200 || admin_ended_all_grace_periods)


/obj/map_metadata/sibersyn/roundend_condition_def2name(define)
	..()
	switch (define)
		if (RUSSIAN)
			return "White"
		if (CIVILIAN)
			return "Soviet"
/obj/map_metadata/sibersyn/roundend_condition_def2army(define)
	..()
	switch (define)
		if (RUSSIAN)
			return "Whites"
		if (CIVILIAN)
			return "Soviets"

/obj/map_metadata/sibersyn/army2name(army)
	..()
	switch (army)
		if ("Whites")
			return "White"
		if ("Soviets")
			return "Soviet"


/obj/map_metadata/sibersyn/cross_message(faction)
	if (faction == CIVILIAN)
		return "<font size = 4>The Red Army may now cross the invisible wall!</font>"
	else if (faction == RUSSIAN)
		return "<font size = 4>The White Army may now cross the invisible wall!</font>"
	else
		return ""

/obj/map_metadata/sibersyn/reverse_cross_message(faction)
	if (faction == CIVILIAN)
		return "<font size = 4>The Red Army may no longer cross the invisible wall!</font>"
	else if (faction == RUSSIAN)
		return "<font size = 4>The White Army may no longer cross the invisible wall!</font>"
	else
		return ""

/obj/map_metadata/berlin/short_win_time(faction)
	if (!(alive_n_of_side(faction1)) || !(alive_n_of_side(faction2)))
		return 600
	else
		return 3000 // 5 minutes

/obj/map_metadata/berlin/long_win_time(faction)
	if (!(alive_n_of_side(faction1)) || !(alive_n_of_side(faction2)))
		return 600
	else
		return 3000 // 5 minutes


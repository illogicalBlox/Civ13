/mob/living/human/proc/get_unarmed_attack(var/mob/living/human/target, var/hit_zone)
	for (var/datum/unarmed_attack/u_attack in species.unarmed_attacks)
		if (u_attack.is_usable(src, target, hit_zone))
			if (pulling_punches)
				var/datum/unarmed_attack/soft_variant = u_attack.get_sparring_variant()
				if (soft_variant)
					return soft_variant
			return u_attack
	return null

/mob/living/human/attack_hand(mob/living/human/M as mob)
	if (map && map.ID == MAP_FOOTBALL)
		return
	var/mob/living/human/H = M
	if (istype(H))
		var/obj/item/organ/external/temp = H.organs_by_name["r_hand"]
		if (H.hand)
			temp = H.organs_by_name["l_hand"]
		if (!temp || !temp.is_usable())
			H << "<span class = 'red'>You can't use your hand.</span>"
			return
	var/tgt = H.targeted_organ
	if (H.targeted_organ == "random")
		tgt = pick("l_foot","r_foot","l_leg","r_leg","chest","groin","l_arm","r_arm","l_hand","r_hand","eyes","mouth","head")
	// Should this all be in Touch()?
	if (istype(H))
		if (H != src && check_shields(0, null, H, tgt, H.name))
			H.do_attack_animation(src)
			return FALSE
	if (H.mind && H.mind.martial_art && H.mind.martial_art.id != H.mind.default_martial_art.id)
		switch(H.a_intent)
			if(I_HARM)
				H.mind.martial_art.harm_act(H, src)
			if(I_HELP)
				H.mind.martial_art.help_act(H, src)
			if(I_GRAB)
				H.mind.martial_art.grab_act(H, src)
			if(I_DISARM)
				H.mind.martial_art.disarm_act(H, src)
	else
		switch(M.a_intent)
			if (I_HELP)
				if (H != src && istype(H) && health < config.health_threshold_crit && health > config.health_threshold_dead && !on_fire)
					if (!H.check_has_mouth())
						H << "<span class='danger'>You don't have a mouth, you cannot perform CPR!</span>"
						return
					if (!check_has_mouth())
						H << "<span class='danger'>They don't have a mouth, you cannot perform CPR!</span>"
						return
					if ((H.head && (H.head.body_parts_covered & FACE)) || (H.wear_mask && (H.wear_mask.body_parts_covered & FACE)))
						H << "<span class='notice'>Remove your mask!</span>"
						return FALSE
					if ((head && (head.body_parts_covered & FACE)) || (wear_mask && (wear_mask.body_parts_covered & FACE)))
						H << "<span class='notice'>Remove [src]'s mask!</span>"
						return FALSE

					if (!cpr_time)
						return FALSE

					cpr_time = FALSE
					spawn(30)
						cpr_time = TRUE

					H.visible_message("<span class='danger'>\The [H] is trying perform CPR on \the [src]!</span>")

					if (!do_after(H, 30, src))
						return

					adjustOxyLoss(-(min(getOxyLoss(), 5)))
					updatehealth()
					H.visible_message("<span class='danger'>\The [H] performs CPR on \the [src]!</span>")
					if (stat != DEAD)
						src << "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>"
					H << "<span class='warning'>Repeat at least every 7 seconds.</span>"
					if(is_asystole())
						if(prob(5/H.getStatCoeff("medical")))
							var/obj/item/organ/external/chest = get_organ("chest")
							if(chest)
								chest.fracture()

						var/obj/item/organ/heart/heart = internal_organs_by_name["heart"]
						if(heart)
							heart.external_pump = list(world.time, 0.4 + 0.1*H.getStatCoeff("medical") + rand(-0.1,0.1))

						if(stat != DEAD && prob(10 + 5 * H.getStatCoeff("medical")))
							resuscitate()

					if(!H.check_has_mouth())
						to_chat(H, "<span class='warning'>You don't have a mouth, you cannot do mouth-to-mouth resuscitation!</span>")
						return
					if(!check_has_mouth())
						to_chat(H, "<span class='warning'>They don't have a mouth, you cannot do mouth-to-mouth resuscitation!</span>")
						return
					if((H.head && (H.head.body_parts_covered & FACE)) || (H.wear_mask && (H.wear_mask.body_parts_covered & FACE)))
						to_chat(H, "<span class='warning'>You need to remove your mouth covering for mouth-to-mouth resuscitation!</span>")
						return 0
					if((head && (head.body_parts_covered & FACE)) || (wear_mask && (wear_mask.body_parts_covered & FACE)))
						to_chat(H, "<span class='warning'>You need to remove \the [src]'s mouth covering for mouth-to-mouth resuscitation!</span>")
						return 0
					if (!H.internal_organs_by_name["lungs"])
						to_chat(H, "<span class='danger'>You need lungs for mouth-to-mouth resuscitation!</span>")
						return
					var/obj/item/organ/lungs/L = internal_organs_by_name["lungs"]
					if(L)
						to_chat(src, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
				help_shake_act(M)
				return TRUE

			if (I_GRAB)
				if (anchored)
					return FALSE
				var/f1 = FALSE
				var/f2 = FALSE
				for (var/obj/structure/vehicleparts/frame/FR1 in get_turf(src))
					f1 = TRUE
				for (var/obj/structure/vehicleparts/frame/FR2 in get_turf(tgt))
					f2 = TRUE
				if (f1 != f2)
					return FALSE
				if (M == src)
					var/obj/item/organ/external/organ = get_organ(tgt)
					if(!organ || !(organ.status & ORGAN_BLEEDING))
						return FALSE

					if(organ.applied_pressure)
						var/message = "<span class='warning'>[ismob(organ.applied_pressure)? "Someone" : "\A [organ.applied_pressure]"] is already applying pressure to [src == src? "your [organ.name]" : "[src]'s [organ.name]"].</span>"
						M << "[message]"
						return FALSE
					apply_pressure(src, tgt)
					return
				for (var/obj/structure/noose/N in get_turf(src))
					if (N.hanging == src)
						return
				for (var/obj/item/weapon/grab/G in grabbed_by)
					if (G.assailant == M)
						M << "<span class='notice'>You already grabbed [src].</span>"
						return
				if (w_uniform)
					w_uniform.add_fingerprint(M)

				var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)
				if (buckled)
					M << "<span class='notice'>You cannot grab [src], \he is buckled in!</span>"
				if (!G)	//the grab will delete itself in New if affecting is anchored
					return
				M.put_in_active_hand(G)
				G.synch()
				LAssailant = M

				H.do_attack_animation(src)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
				visible_message("<span class='warning'>[M] has grabbed [src] passively!</span>")
				return TRUE
			if (I_HARM)
				var/tgtm = M.targeted_organ
				if (M.targeted_organ == "random")
					tgtm = pick("l_foot","r_foot","l_leg","r_leg","chest","groin","l_arm","r_arm","l_hand","r_hand","eyes","mouth","head")
				if (tgtm == "mouth" && wear_mask && istype(wear_mask, /obj/item/weapon/grenade))
					var/obj/item/weapon/grenade/G = wear_mask
					if (!G.active)
						visible_message("<span class='danger'>\The [M] pulls the pin from \the [src]'s [G.name]!</span>")
						G.activate(M)
						update_inv_wear_mask()
					else
						M << "<span class='warning'>\The [G] is already primed! Run!</span>"
					return

				if (!istype(H))
					attack_generic(H,rand(1,3),"punched")
					return
				if (src != M)
					if(attempt_dodge())//Trying to dodge it before they even have the chance to miss us.
						return 1

				var/rand_damage = rand(1, 5)
				var/block = FALSE
				var/accurate = FALSE
				var/hit_zone = tgt
				var/obj/item/organ/external/affecting = get_organ(hit_zone)

				if (!affecting || affecting.is_stump())
					M << "<span class='danger'>They are missing that limb!</span>"
					return TRUE

				switch(a_intent)
					if (I_HELP)
						// We didn't see this coming, so we get the full blow
						rand_damage = 5
						accurate = TRUE
					if (I_HARM, I_GRAB)
						// We're in a fighting stance, there's a chance we block
						if (canmove && src!=H && prob(20))
							block = TRUE

				if (M.grabbed_by.len)
					// Someone got a good grip on them, they won't be able to do much damage
					rand_damage = max(1, rand_damage - 2)

				if (grabbed_by.len || buckled || !canmove || src==H)
					accurate = TRUE // certain circumstances make it impossible for us to evade punches
					rand_damage = 5

				// Process evasion and blocking
				var/miss_type = FALSE
				var/attack_message
				if (!accurate)
					/* ~Hubblenaut
						This place is kind of convoluted and will need some explaining.
						ran_zone() will pick out of 11 zones, thus the chance for hitting
						our target where we want to hit them is circa 9.1%.

						Now since we want to statistically hit our target organ a bit more
						often than other organs, we add a base chance of 20% for hitting it.

						This leaves us with the following chances:

						If aiming for chest:
							27.3% chance you hit your target organ
							70.5% chance you hit a random other organ
							2.2% chance you miss

						If aiming for something else:
							23.2% chance you hit your target organ
							56.8% chance you hit a random other organ
							15.0% chance you miss

						Note: We don't use get_zone_with_miss_chance() here since the chances
							were made for projectiles.
						TODO: proc for melee combat miss chances depending on organ?
					*/
					if (prob(80))
						hit_zone = ran_zone(hit_zone)
					if (prob(15) && hit_zone != "chest") // Missed!
						if (!lying)
							attack_message = "[H] attempted to strike [src], but missed!"
							adaptStat("dexterity", 1)
						else
							attack_message = "[H] attempted to strike [src], but \he rolled out of the way!"
							adaptStat("dexterity", 1)
							set_dir(pick(cardinal))
						miss_type = TRUE

				if (!miss_type && block)
					attack_message = "[H] went for [src]'s [affecting.name] but was blocked!"
					miss_type = 2
					adaptStat("dexterity", 1)
				var/hitcheck = rand(0, 9)
				if (istype(affecting, /obj/item/organ/external/head) && prob(hitcheck * (hit_zone == "mouth" ? 5 : TRUE))) //MUCH higher chance to knock out teeth if you aim for mouth
					var/obj/item/organ/external/head/U = affecting
					if (U.knock_out_teeth(get_dir(H, src), round(rand(28, 38) * ((hitcheck*2)/100))))
						visible_message("<span class='danger'>Some of [src]'s teeth sail off in an arc!</span>", \
											"<span class='userdanger'>Some of [src]'s teeth sail off in an arc!</span>")

				// See what attack they use
				var/datum/unarmed_attack/attack = H.get_unarmed_attack(src, hit_zone)
				if (!attack)
					return FALSE

				H.do_attack_animation(src)
				if (!attack_message)
					attack.show_attack(H, src, hit_zone, rand_damage)
				else
					H.visible_message("<span class='danger'>[attack_message]</span>")

				playsound(loc, ((miss_type) ? (miss_type == TRUE ? attack.miss_sound : 'sound/weapons/thudswoosh.ogg') : attack.attack_sound), 25, TRUE, -1)
				H.attack_log += text("\[[time_stamp()]\] <font color='red'>[miss_type ? (miss_type == TRUE ? "Missed" : "Blocked") : "[pick(attack.attack_verb)]"] [name] ([ckey])</font>")
				attack_log += text("\[[time_stamp()]\] <font color='orange'>[miss_type ? (miss_type == TRUE ? "Was missed by" : "Has blocked") : "Has Been [pick(attack.attack_verb)]"] by [H.name] ([H.ckey])</font>")
				msg_admin_attack("[key_name(H)] [miss_type ? (miss_type == TRUE ? "has missed" : "was blocked by") : "has [pick(attack.attack_verb)]"] [key_name(src)]")

				if (miss_type)
					return FALSE

				var/real_damage = rand_damage
				real_damage += attack.get_unarmed_damage(H)
				real_damage *= damage_multiplier
				rand_damage *= damage_multiplier

				real_damage = max(1, real_damage)

				// Apply stat effects
				real_damage *= H.getStatCoeff("strength")
				real_damage /= getStatCoeff("strength")
				if (tactic == "charge")
					real_damage *= 1.1
				var/armor = run_armor_check(affecting, "melee")
				// Apply additional unarmed effects.
				attack.apply_effects(H, src, armor, rand_damage, hit_zone)

				// Finally, apply damage to target
				apply_damage(real_damage, (attack.deal_halloss ? HALLOSS : BRUTE), affecting, armor, sharp=attack.sharp, edge=attack.edge, toxic=H.lizard)

			if (I_DISARM)
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [name] ([ckey])</font>")
				attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [M.name] ([M.ckey])</font>")

				msg_admin_attack("[key_name(M)] disarmed [name] ([ckey])")
				M.do_attack_animation(src)

				if (w_uniform)
					w_uniform.add_fingerprint(M)
				var/tgtm = M.targeted_organ
				if (M.targeted_organ == "random")
					tgtm = pick("l_foot","r_foot","l_leg","r_leg","chest","groin","l_arm","r_arm","l_hand","r_hand","eyes","mouth","head")
				var/obj/item/organ/external/affecting = get_organ(ran_zone(tgtm))

				var/list/holding = list(get_active_hand() = 40, get_inactive_hand = 20)

				//See if they have any guns that might go off
				for (var/obj/item/weapon/gun/W in holding)
					if (W && prob(holding[W]))
						var/list/turfs = list()
						for (var/turf/T in view())
							turfs += T
						if (turfs.len)
							var/turf/target = pick(turfs)
							visible_message("<span class='danger'>[src]'s [W] goes off during the struggle!</span>")
							return W.afterattack(target,src)

				var/randn = rand(1, 100)
				if (!(species.flags & NO_SLIP) && randn <= 25)
					var/armor_check = run_armor_check(affecting, "melee")
					apply_effect(3, WEAKEN, armor_check)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
					if (armor_check < 2)
						visible_message("<span class='danger'>[M] has pushed [src]!</span>")
					else
						visible_message("<span class='warning'>[M] attempted to push [src]!</span>")
					return

				if (randn <= 60)
					//See about breaking grips or pulls
					if (break_all_grabs(M))
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
						return

					//Actually disarm them
					for (var/obj/item/I in holding)
						if (I)
							drop_from_inventory(I)
							visible_message("<span class='danger'>[M] has disarmed [src]!</span>")
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
							return

				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
				visible_message("<span class = 'red'><b>[M] attempted to disarm [src]!</b></span>")
	return
/mob/living/human/proc/resuscitate()
	if(!is_asystole())
		return
	var/obj/item/organ/heart/heart = internal_organs_by_name["heart"]
	if(istype(heart) && !(heart.status & ORGAN_DEAD))
		var/active_breaths = 0
		var/obj/item/organ/lungs/L = internal_organs_by_name["lungs"]
		if(L)
			active_breaths = L.active_breathing
		if(active_breaths)
			visible_message("\The [src] jerks and gasps for breath!")
		else
			visible_message("\The [src] twitches a bit as \his heart restarts!")
		shock_stage = min(shock_stage, 100) // 120 is the point at which the heart stops.
		if(getOxyLoss() >= 75)
			setOxyLoss(75)
		heart.pulse = PULSE_NORM
		heart.handle_pulse()
		return TRUE

/mob/living/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return

/mob/living/human/attack_generic(var/mob/user, var/damage, var/attack_message)

	if (!damage || !istype(user))
		return

	user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [name] ([ckey])</font>")
	attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [user.name] ([user.ckey])</font>")
	visible_message("<span class='danger'>[user] has [attack_message] [src]!</span>")
	user.do_attack_animation(src)

	var/dam_zone = pick(organs_by_name)
	var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
	var/armor_block = run_armor_check(affecting, "melee")
	apply_damage(damage, BRUTE, affecting, armor_block)
	updatehealth()
	return TRUE

//Used to attack a joint through grabbing
/mob/living/human/proc/grab_joint(var/mob/living/user, var/def_zone)
	var/has_grab = FALSE
	for (var/obj/item/weapon/grab/G in list(user.l_hand, user.r_hand))
		if (G.affecting == src && G.state == GRAB_NECK)
			has_grab = TRUE
			break

	if (!has_grab)
		return FALSE
	var/tgt = user.targeted_organ
	if (user.targeted_organ == "random")
		tgt = pick("l_foot","r_foot","l_leg","r_leg","chest","groin","l_arm","r_arm","l_hand","r_hand","eyes","mouth","head")
	if (!def_zone) def_zone = tgt
	if (def_zone == "random")
		def_zone = pick("l_foot","r_foot","l_leg","r_leg","chest","groin","l_arm","r_arm","l_hand","r_hand","eyes","mouth","head")
	var/target_zone = check_zone(def_zone)
	if (!target_zone)
		return FALSE
	var/obj/item/organ/external/organ = get_organ(check_zone(target_zone))
	if (!organ || organ.is_dislocated() || organ.dislocated == -1)
		return FALSE

	user.visible_message("<span class='warning'>[user] begins to dislocate [src]'s [organ.joint]!</span>")
	if (do_after(user, 100, progress = FALSE))
		organ.dislocate(1)
		visible_message("<span class='danger'>[src]'s [organ.joint] [pick("gives way","caves in","crumbles","collapses")]!</span>")
		return TRUE
	return FALSE

//Breaks all grips and pulls that the mob currently has.
/mob/living/human/proc/break_all_grabs(mob/living/human/user)
	var/success = FALSE
	if (pulling)
		visible_message("<span class='danger'>[user] has broken [src]'s grip on [pulling]!</span>")
		success = TRUE
		stop_pulling()

	if (istype(l_hand, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/lgrab = l_hand
		if (lgrab.affecting)
			visible_message("<span class='danger'>[user] has broken [src]'s grip on [lgrab.affecting]!</span>")
			success = TRUE
		spawn(1)
			qdel(lgrab)
	if (istype(r_hand, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/rgrab = r_hand
		if (rgrab.affecting)
			visible_message("<span class='danger'>[user] has broken [src]'s grip on [rgrab.affecting]!</span>")
			success = TRUE
		spawn(1)
			qdel(rgrab)
	return success


/*
	We want to ensure that a mob may only apply pressure to one organ of one mob at any given time. Currently this is done mostly implicitly through
	the behaviour of do_after() and the fact that applying pressure to someone else requires a grab:

	If you are applying pressure to yourself and attempt to grab someone else, you'll change what you are holding in your active hand which will stop do_mob()
	If you are applying pressure to another and attempt to apply pressure to yourself, you'll have to switch to an empty hand which will also stop do_mob()
	Changing targeted zones should also stop do_mob(), preventing you from applying pressure to more than one body part at once.
*/
/mob/living/human/proc/apply_pressure(mob/living/user, var/target_zone)
	var/obj/item/organ/external/organ = get_organ(target_zone)
	if(!organ || !(organ.status & ORGAN_BLEEDING))
		return 0

	if(organ.applied_pressure)
		var/message = "<span class='warning'>[ismob(organ.applied_pressure)? "Someone" : "\A [organ.applied_pressure]"] is already applying pressure to [user == src? "your [organ.name]" : "[src]'s [organ.name]"].</span>"
		user << "[message]"
		return 0

	if(user == src)
		user.visible_message("\The [user] starts applying pressure to \his [organ.name]!", "You start applying pressure to your [organ.name]!")
	else
		user.visible_message("\The [user] starts applying pressure to [src]'s [organ.name]!", "You start applying pressure to [src]'s [organ.name]!")
	spawn(0)
		organ.applied_pressure = user
		check_pressure(user,target_zone)
	return 1

/mob/living/human/proc/check_pressure(mob/living/user, var/target_zone)
	var/obj/item/organ/external/organ = get_organ(target_zone)
	if(!organ || !(organ.status & ORGAN_BLEEDING))
		return FALSE
	//apply pressure as long as they keep a hand empty
	if (!has_empty_hand(FALSE))
		organ.applied_pressure = null

		if(user == src)
			user.visible_message("\The [user] stops applying pressure to \his [organ.name]!", "You stop applying pressure to your [organ.name]!")
		else
			user.visible_message("\The [user] stops applying pressure to [src]'s [organ.name]!", "You stop applying pressure to [src]'s [organ.name]!")
		return FALSE
	else

		spawn(10)
			check_pressure(user, target_zone)
			return TRUE
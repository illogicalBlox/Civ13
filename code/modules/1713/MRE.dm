//Food items that are eaten normally and don't leave anything behind.
/obj/item/weapon/reagent_containers/food/snacks/MRE
	name = "MRE"
	desc = "horrible food"
	nutriment_desc = list("horrible food" = 1)
	nutriment_amt = 5
	var/open = FALSE
	var/opens = TRUE
	var/base_state = ""
	trash = null
	flammable = TRUE
	decay = 1200*6000
	non_vegetarian = TRUE
/obj/item/weapon/reagent_containers/food/snacks/MRE/attack(mob/M as mob, mob/user as mob, def_zone)
	if (!open && opens && M == user)
		user << "<span class = 'warning'>Open it first.</span>"
		return FALSE
	return ..(M, user, def_zone)

/obj/item/weapon/reagent_containers/food/snacks/MRE/attack_self(var/mob/living/human/H)
	if (!istype(H))
		return
	if (!open && opens)
		playsound(get_turf(src), 'sound/effects/rip_pack.ogg', 100)
		visible_message("<span class = 'notice'>[H] opens [src].</span>")
		icon_state = "[base_state]_open"
		open = TRUE
	return

// generic MRE

/obj/item/weapon/reagent_containers/food/snacks/MRE/generic
	base_state = "mre_food"
	icon_state = "mre_food"
	name = "MRE"
	opens = FALSE
	trash = /obj/item/weapon/generic_MRE_trash

/obj/item/weapon/generic_MRE_trash
	icon = 'icons/obj/food/food.dmi'
	icon_state = "mre_food_trash"
	name = "MRE trash"
	desc = "The remains of some MRE."
	w_class = 1

/obj/item/weapon/reagent_containers/food/snacks/MRE/generic/german
	name = "German MRE: Sauerkraut"
	desc = "A pickled cabbage MRE."
	nutriment_desc = list("pickled cabbage" = 1)

/obj/item/weapon/reagent_containers/food/snacks/MRE/generic/british
	name = "British MRE: Canned Meat"
	desc = "A canned meat MRE."
	nutriment_desc = list("canned meat" = 1)

/obj/item/weapon/reagent_containers/food/snacks/MRE/generic/french
	name = "French MRE: Cheese"
	desc = "A cheese MRE."
	nutriment_desc = list("cheese" = 1)

/obj/item/weapon/reagent_containers/food/snacks/MRE/generic/pirates
	name = "Soviet MRE: Cabbage"
	desc = "A cabbage MRE."
	nutriment_desc = list("overcooked cabbage" = 1)

/obj/item/weapon/reagent_containers/food/snacks/MRE/generic/italian
	name = "Italian MRE: Spaghetti"
	desc = "Mama mia!"
	nutriment_desc = list("spaghett" = 1, "tomat" = 1, "spicia meatball")

/obj/item/weapon/reagent_containers/food/snacks/MRE/generic/american
	name = "American MRE: Canned Meat"
	desc = "A package of canned meat and vegetables."
	nutriment_desc = list("canned meat" = 1, "canned vegetables" = 1)

/obj/item/weapon/reagent_containers/food/snacks/MRE/generic/japanese
	name = "Japanese MRE: Noodles"
	desc = "A package of precooked noodles and dry meat."
	nutriment_desc = list("noodles" = 1, "vegetables" = 1, "dried meat")

/obj/item/weapon/reagent_containers/food/snacks/MRE/generic/russian
	name = "Russian MRE: Potatoes"
	desc = "A package of precooked potatoes."
	nutriment_desc = list("potatoes" = 1,)
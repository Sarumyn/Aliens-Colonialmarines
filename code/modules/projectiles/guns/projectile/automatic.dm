/obj/item/weapon/gun/projectile/automatic
	origin_tech = "combat=4;materials=2"
	w_class = 3
	var/alarmed = 0
	var/select = 1
	can_suppress = 1
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode, /datum/action/item_action/wield)

/obj/item/weapon/gun/projectile/automatic/proto
	name = "\improper NanoTrasen Saber SMG"
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm

/obj/item/weapon/gun/projectile/automatic/update_icon(ammobased_iconstate = TRUE)
	..()
	if(ammobased_iconstate)
		cut_overlays()
		if(!select)
			add_overlay("[initial(icon_state)]semi")
		if(select == 1)
			add_overlay("[initial(icon_state)]burst")
		icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"

/obj/item/weapon/gun/projectile/automatic/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if(istype(AM, mag_type))
			if(magazine)
				user << "<span class='notice'>You perform a tactical reload on \the [src], replacing the magazine.</span>"
				magazine.dropped()
				magazine.forceMove(get_turf(src.loc))
				magazine.update_icon()
				magazine = null
			else
				user << "<span class='notice'>You insert the magazine into \the [src].</span>"
			user.remove_from_mob(AM)
			magazine = AM
			magazine.loc = src
			chamber_round()
			A.update_icon()
			update_icon()
			return 1

/obj/item/weapon/gun/projectile/automatic/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/toggle_firemode)
		burst_select()
	..()

/obj/item/weapon/gun/projectile/automatic/proc/burst_select()
	var/mob/living/carbon/human/user = usr
	select = !select
	if(!select)
		burst_size = 1
		fire_delay = 0
		user << "<span class='notice'>You switch to semi-automatic.</span>"
	else
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		user << "<span class='notice'>You switch to [burst_size]-rnd burst.</span>"

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/weapon/gun/projectile/automatic/can_shoot()
	return get_ammo()

/obj/item/weapon/gun/projectile/automatic/proc/empty_alarm()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(src.loc, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A bullpup three-round burst .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	fire_delay = 2
	burst_size = 3
	attachment_x_offsets = list("barrel" = 31, "optics" = 7, "underbarrel" = 25, "stock" = 0, "paint" = 0)
	attachment_y_offsets = list("barrel" = 1, "optics" = 4, "underbarrel" = 0, "stock" = 0, "paint" = 0)

/obj/item/weapon/gun/projectile/automatic/c20r/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/c20r/afterattack()
	..()
	empty_alarm()
	return

/obj/item/weapon/gun/projectile/automatic/c20r/update_icon()
	..()
	icon_state = "c20r[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"

/obj/item/weapon/gun/projectile/automatic/wt550
	name = "security auto rifle"
	desc = "An outdated personal defence weapon. Uses 4.6x30mm rounds and is designated the WT-550 Automatic Rifle."
	icon_state = "wt550"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_delay = 2
	can_suppress = 0
	burst_size = 0
	actions_types = list()

/obj/item/weapon/gun/projectile/automatic/wt550/update_icon()
	..()
	icon_state = "wt550[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""]"

/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "\improper 'Type U3' Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "mini-uzi"
	origin_tech = "combat=4;materials=2;syndicate=4"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	burst_size = 2

/obj/item/weapon/gun/projectile/automatic/c90
	name = "\improper C-90gl Carbine"
	desc = "A three-round burst 5.56 toploading carbine, designated 'C-90gl'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon_state = "m90"
	item_state = "m90"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	can_suppress = 0
	var/obj/item/weapon/gun/projectile/revolver/grenadelauncher/underbarrel
	burst_size = 3
	fire_delay = 2

/obj/item/weapon/gun/projectile/automatic/c90/New()
	..()
	underbarrel = new /obj/item/weapon/gun/projectile/revolver/grenadelauncher(src)
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/c90/afterattack(atom/target, mob/living/user, flag, params)
	if(select == 2)
		underbarrel.afterattack(target, user, flag, params)
	else
		..()
		return
/obj/item/weapon/gun/projectile/automatic/c90/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing))
		if(istype(A, underbarrel.magazine.ammo_type))
			underbarrel.attack_self()
			underbarrel.attackby(A, user, params)
	else
		..()
/obj/item/weapon/gun/projectile/automatic/c90/update_icon()
	..()
	cut_overlays()
	switch(select)
		if(0)
			add_overlay("[initial(icon_state)]semi")
		if(1)
			add_overlay("[initial(icon_state)]burst")
		if(2)
			add_overlay("[initial(icon_state)]gren")
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"
	return
/obj/item/weapon/gun/projectile/automatic/c90/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select = 1
			burst_size = initial(burst_size)
			fire_delay = initial(fire_delay)
			user << "<span class='notice'>You switch to [burst_size]-rnd burst.</span>"
		if(1)
			select = 2
			user << "<span class='notice'>You switch to grenades.</span>"
		if(2)
			select = 0
			burst_size = 1
			fire_delay = 0
			user << "<span class='notice'>You switch to semi-auto.</span>"
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/tommygun
	name = "\improper Thompson SMG"
	desc = "Based on the classic 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = 5
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	can_suppress = 0
	burst_size = 4
	fire_delay = 1

/obj/item/weapon/gun/projectile/automatic/ar
	name = "\improper NT-ARG 'Boarder'"
	desc = "A robust assault rile used by Nanotrasen fighting forces."
	icon_state = "arg"
	item_state = "arg"
	slot_flags = 0
	origin_tech = "combat=6;engineering=4"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	can_suppress = 0
	burst_size = 3
	fire_delay = 1



// Bulldog shotgun //

/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog
	name = "\improper 'Bulldog' Shotgun"
	desc = "A semi-auto, mag-fed shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = 3
	origin_tech = "combat=6;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/Gunshot.ogg'
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	actions_types = list()

/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/proc/update_magazine()
	if(magazine)
		src.overlays = 0
		add_overlay("[magazine.icon_state]")
		return

/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/update_icon()
	src.overlays = 0
	update_magazine()
	icon_state = "bulldog[chambered ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/afterattack()
	..()
	empty_alarm()
	return



// L6 SAW //

/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified 7.62 light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = 5
	slot_flags = 0
	origin_tech = "combat=6;engineering=3;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m762
	weapon_weight = WEAPON_MEDIUM
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	var/cover_open = 0
	can_suppress = 0
	burst_size = 3
	fire_delay = 1

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user)
	cover_open = !cover_open
	user << "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>"
	update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? Ceiling(get_ammo(0)/12.5)*25 : "-empty"][suppressed ? "-suppressed" : ""]"
	item_state = "l6[cover_open ? "openmag" : "closedmag"]"


/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		user << "<span class='warning'>[src]'s cover is open! Close it before firing!</span>"
	else
		..()
		update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !magazine))
		..()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		user << "<span class='notice'>You remove the magazine from [src].</span>"


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	if(!cover_open)
		user << "<span class='warning'>[src]'s cover is closed! You can't insert a new mag.</span>"
		return
	..()


/obj/item/weapon/gun/projectile/automatic/m41a
	name = "M41A pulse rifle MK2"
	desc = "The Armat M41A Pulse Rifle MK2 is an American-made pulse-action assault rifle chambered for 10x24mm Caseless ammunition."
	icon_state = "m41a"
	item_state = "m41a"
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/m41a
	fire_delay = 5
	attachments_flags = BARREL|OPTICS|UNDERBARREL|STOCK|PAINT
	attachments_onnew = list(/obj/item/gun_attachment/underbarrel/nadelauncher, /obj/item/gun_attachment/stock/m41a)
	attachment_x_offsets = list("barrel" = 31, "optics" = 10, "underbarrel" = 27, "stock" = 2, "paint" = 0)//TO BE SET
	attachment_y_offsets = list("barrel" = 2, "optics" = 5, "underbarrel" = -2, "stock" = 2, "paint" = 0)//TO BE SET

/obj/item/weapon/gun/projectile/automatic/m41a/update_icon(ammobased_iconstate = FALSE)
	icon_state = "m41a[magazine ? "" : "-0"]"
	item_state = "m41a[magazine ? "" : "-0"][wielded ? "-w" : ""]"
	..()

/obj/item/weapon/gun/projectile/automatic/m39
	name = "M39 submachine gun"
	desc = "The M39 is an American-made submachine gun used primarily by the United States Colonial Marine Corps as their standard issue SMG."
	icon_state = "m39"
	item_state = "m39"
	weapon_weight = WEAPON_LIGHT
	mag_type = /obj/item/ammo_box/magazine/m39
	attachments_onnew = list(/obj/item/gun_attachment/stock/m39)
	attachments_flags = BARREL|OPTICS|UNDERBARREL|STOCK|PAINT
	attachment_x_offsets = list("barrel" = 29, "optics" = 10, "underbarrel" = 24, "stock" = 8, "paint" = 0)//TO BE SET
	attachment_y_offsets = list("barrel" = 2, "optics" = 2, "underbarrel" = -2, "stock" = 0, "paint" = 0)//TO BE SET

/obj/item/weapon/gun/projectile/automatic/m39/update_icon(ammobased_iconstate = FALSE)
	icon_state = "m39[magazine ? "" : "-0"]"
	item_state = "m39[magazine ? "" : "-0"][wielded ? "-w" : ""]"
	..()

/obj/item/weapon/gun/projectile/automatic/nsg23
	name = "NSG 23 assault rifle"
	desc = "The NSG 23 Assault Rifle is a three-round burst assault rifle used primarily by the United States Colonial Marine Corps and Weyland-Yutani PMCs."
	icon_state = "nsg23"
	item_state = "nsg23"
	weapon_weight = WEAPON_LIGHT
	mag_type = /obj/item/ammo_box/magazine/nsg23
	attachment_x_offsets = list("barrel" = 30, "optics" = 11, "underbarrel" = 20, "stock" = 0, "paint" = 0)//TO BE SET
	attachment_y_offsets = list("barrel" = 3, "optics" = 5, "underbarrel" = -1, "stock" = 2, "paint" = 0)//TO BE SET

/obj/item/weapon/gun/projectile/automatic/nsg23/update_icon(ammobased_iconstate = FALSE)
	icon_state = "nsg23[magazine ? "" : "-0"]"
	item_state = "nsg23[magazine ? "" : "-0"][wielded ? "-w" : ""]"
	..()
// SNIPER //

/obj/item/weapon/gun/projectile/automatic/sniper_rifle
	name = "sniper rifle"
	desc = "The kind of gun that will leave you crying for mummy before you even realise your leg's missing."
	icon_state = "sniper"
	item_state = "sniper"
	var/base_state = "sniper"//fuck this whole icon bullshit,i'll rewrite you somewhen.
	recoil = 2
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	fire_delay = 40
	burst_size = 1
	origin_tech = "combat=7"
	w_class = 4
	slot_flags = SLOT_BACK
	actions_types = list(/datum/action/item_action/wield)
	attachments_onnew = list(/obj/item/gun_attachment/optics/sniper)

/obj/item/weapon/gun/projectile/automatic/sniper_rifle/New()
	..()
	spread = 0
	base_spread = 0//it's a sniper rifle,it's supposed to be accurate

/obj/item/weapon/gun/projectile/automatic/sniper_rifle/update_icon(ammobased_iconstate = FALSE)
	if(magazine)
		icon_state = "[base_state]"
	else
		icon_state = "[base_state]-0"
	..()


/obj/item/weapon/gun/projectile/automatic/sniper_rifle/syndicate
	name = "syndicate sniper rifle"
	desc = "Syndicate flavoured sniper rifle, it packs quite a punch, a punch to your face"
	origin_tech = "combat=7;syndicate=6"

/obj/item/weapon/gun/projectile/automatic/sniper_rifle/wy102
	name = "WY102"
	desc = "A weapon designed for great ranges, often used for long range fire support and assassination."
	icon_state = "wy102"
	base_state = "wy102"

// Laser rifle (rechargeable magazine) //

/obj/item/weapon/gun/projectile/automatic/laser
	name = "laser rifle"
	desc = "Though sometimes mocked for the relatively weak firepower of their energy weapons, the logistic miracle of rechargable ammunition has given Nanotrasen a decisive edge over many a foe."
	icon_state = "oldrifle"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/recharge
	fire_delay = 2
	can_suppress = 0
	burst_size = 0
	actions_types = list()
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/weapon/gun/projectile/automatic/laser/process_chamber(eject_casing = 0, empty_chamber = 1)
	..() //we changed the default value of the first argument


/obj/item/weapon/gun/projectile/automatic/laser/update_icon()
	..()
	icon_state = "oldrifle[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""]"
	return

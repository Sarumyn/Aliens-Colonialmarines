

//The ammo/gun is stored in a back slot item
/obj/item/weapon/minigunpack
	name = "backpack power source"
	desc = "The massive external power source for the laser gatling gun"
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "holstered"
	item_state = "backpack"
	slot_flags = SLOT_BACK
	w_class = 5
	var/obj/item/weapon/gun/projectile/minigun/gun = /obj/item/weapon/gun/projectile/minigun
	var/armed = 0 //whether the gun is attached, 0 is attached, 1 is the gun is wielded.
	var/overheat = 0
	var/overheat_max = 40
	var/heat_diffusion = 1

/obj/item/weapon/minigunpack/New()
	gun = new gun(src)
	if(overheat_max)
		START_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/minigunpack/Destroy()
	if(overheat_max)
		STOP_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/minigunpack/process()
	if(overheat_max)
		overheat = max(0, overheat - heat_diffusion)

/obj/item/weapon/minigunpack/attack_hand(mob/living/carbon/user)
	if(loc == user)
		if(!armed)
			if(user.get_item_by_slot(slot_back) == src)
				armed = 1
				if(!user.put_in_hands(gun))
					armed = 0
					user << "<span class='warning'>You need a free hand to hold the gun!</span>"
					return
				update_icon()
				gun.forceMove(user)
				user.update_inv_back()
		else
			user << "<span class='warning'>You are already holding the gun!</span>"
	else
		..()

/obj/item/weapon/minigunpack/attackby(obj/item/weapon/W, mob/user, params)
	if(W == gun) //Don't need armed check, because if you have the gun assume its armed.
		user.unEquip(gun,1)
	else
		..()

/obj/item/weapon/minigunpack/dropped(mob/user)
	if(armed)
		user.unEquip(gun,1)
	..()

/obj/item/weapon/minigunpack/MouseDrop(atom/over_object)
	if(armed)
		return
	if(iscarbon(usr))
		var/mob/M = usr

		if(!over_object)
			return

		if(!M.restrained() && !M.stat)

			if(istype(over_object, /obj/screen/inventory/hand))
				var/obj/screen/inventory/hand/H = over_object
				if(!M.unEquip(src))
					return
				switch(H.slot_id)
					if(slot_r_hand)
						M.put_in_r_hand(src)
					if(slot_l_hand)
						M.put_in_l_hand(src)


/obj/item/weapon/minigunpack/update_icon()
	if(armed)
		icon_state = "notholstered"
	else
		icon_state = "holstered"

/obj/item/weapon/minigunpack/proc/attach_gun(mob/user)
	if(ispath(gun))
		gun = new gun(src)
	if(gun.loc == user)
		user.unEquip(gun)
	gun.forceMove(src)
	armed = 0
	if(user)
		user << "<span class='notice'>You attach the [gun.name] to the [name].</span>"
	else
		visible_message("<span class='warning'>The [gun.name] snaps back onto the [name]!</span>")
	update_icon()
	user.update_inv_back()

/obj/item/weapon/minigunpack/smartgun
	name = "m56 breastplate"
	desc = "The holder for the M56 processor and ammo."
	icon_state = "m56-holstered"
	item_state = "m56-holstered"
	gun = /obj/item/weapon/gun/projectile/minigun/smartgun
	actions_types = list(/datum/action/item_action/reload_smartgun)
	overheat_max = 0
	var/obj/item/ammo_box/smartgun/box = new /obj/item/ammo_box/smartgun

/obj/item/weapon/minigunpack/smartgun/ui_action_click(mob/user)
	if(!gun || ispath(gun) || !gun.magazine)
		return//just how
	user.visible_message("[user] begins to reload \the [gun]...", "You begin to reload \the [gun]...")
	gun.semicd = TRUE
	if(do_after(user, 30, target = src))
		user.visible_message("[user] reloads \the [gun]!", "You reload \the [gun]!")
		gun.magazine.attackby(box, user, silent = 1)
		gun.chamber_round()
		gun.semicd = FALSE
	else
		user << "<span class='warning'>You fail to reload \the [gun], don't move while reloading!</span>"
		gun.semicd = FALSE

/obj/item/weapon/minigunpack/smartgun/update_icon()
	..()
	if(!armed)
		icon_state = "m56-holstered"
		item_state = "m56-holstered"
	else
		icon_state = "m56-notholstered"
		item_state = "m56-notholstered"

/obj/item/weapon/minigunpack/smartgun/examine(mob/user)
	..()
	user << "Has [box.stored_ammo.len] round\s remaining."

/obj/item/weapon/gun/projectile/minigun
	name = "laser gatling gun"
	desc = "An advanced laser cannon with an incredible rate of fire. Requires a bulky backpack power source to use."
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "minigun_spin"
	item_state = "minigun"
	origin_tech = "combat=6;powerstorage=5;magnets=4"
	flags = CONDUCT | HANDSLOW
	slowdown = 1
	slot_flags = null
	w_class = 5
	materials = list()
	burst_size = 3
	automatic = 0
	fire_delay = 1
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'sound/weapons/Laser.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/minigun
	var/obj/item/weapon/minigunpack/ammo_pack

/obj/item/weapon/gun/projectile/minigun/attack_self(mob/living/user)
	return

/obj/item/weapon/gun/projectile/minigun/dropped(mob/user)
	..()
	if(ammo_pack)
		ammo_pack.attach_gun(user)
	else
		qdel(src)

/obj/item/weapon/gun/projectile/minigun/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	if(ammo_pack)
		if(!ammo_pack.overheat_max)//overheat system disabled
			return ..()
		if(ammo_pack.overheat < ammo_pack.overheat_max)
			ammo_pack.overheat += burst_size
			..()
		else
			user << "The gun's heat sensor locked the trigger to prevent lens damage."

/obj/item/weapon/gun/projectile/minigun/afterattack(atom/target, mob/living/user, flag, params)
	if(!ammo_pack || ammo_pack.loc != user)
		user << "You need the backpack power source to fire the gun!"
	..()

/obj/item/weapon/gun/projectile/minigun/New()
	..()
	if(!ammo_pack)
		if(istype(loc,/obj/item/weapon/minigunpack)) //We should spawn inside a ammo pack so let's use that one.
			ammo_pack = loc
		else
			qdel(src)//No pack, no gun

/obj/item/weapon/gun/projectile/minigun/attack_hand(mob/user)
	return //to fix an ugly bug with gun duplication when you attack it with your other empty hand

/obj/item/weapon/gun/projectile/minigun/smartgun
	name = "M56 smartgun"
	desc = "The marine's best friend, the M56 has an electronic device able to stop friendly fire."
	icon_state = "m56"
	item_state = "m56-w"
	slowdown = 0//fuck slowdown
	fire_sound = "gunshot"
	burst_size = 1
	fire_delay = 1
	automatic = 1
	flags = CONDUCT | NODROP
	mag_type = /obj/item/ammo_box/magazine/internal/smartgun
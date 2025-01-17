//-------------------------------------------------------
//SNIPER RIFLES
//Keyword rifles. They are subtype of rifles, but still contained here as a specialist weapon.

//Because this parent type did not exist
//Note that this means that snipers will have a slowdown of 3, due to the scope
/obj/item/weapon/gun/rifle/sniper
	aim_slowdown = 1
	gun_skill_category = GUN_SKILL_SPEC
	wield_delay = 1 SECONDS

//Pow! Headshot

/obj/item/weapon/gun/rifle/sniper/M42A
	name = "\improper M42A scoped rifle"
	desc = "A heavy sniper rifle manufactured by Armat Systems. It has a scope system and fires armor penetrating rounds out of a 15-round magazine.\nIt has an integrated Target Marker and a Laser Targeting system.\n'Peace Through Superior Firepower'"
	icon_state = "m42a"
	item_state = "m42a"
	max_shells = 15 //codex
	caliber = "10x28mm"
	fire_sound = 'sound/weapons/guns/fire/sniper.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_reload.ogg'
	current_mag = /obj/item/ammo_magazine/sniper
	force = 12
	wield_delay = 12 //Ends up being 1.6 seconds due to scope
	zoomdevicename = "scope"
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	var/targetmarker_on = FALSE
	var/targetmarker_primed = FALSE
	var/mob/living/carbon/laser_target = null
	var/image/LT = null
	var/obj/item/binoculars/tactical/integrated_laze = null
	attachable_allowed = list(
						/obj/item/attachable/bipod,
						/obj/item/attachable/lasersight,
						)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	starting_attachment_types = list(/obj/item/attachable/scope/m42a, /obj/item/attachable/sniperbarrel)

	fire_delay = 2.5 SECONDS
	burst_amount = 1
	accuracy_mult = 1.50
	recoil = 2


/obj/item/weapon/gun/rifle/sniper/M42A/Initialize()
	. = ..()
	LT = image("icon" = 'icons/obj/items/projectiles.dmi',"icon_state" = "sniper_laser", "layer" =-LASER_LAYER)
	integrated_laze = new(src)

/obj/item/weapon/gun/rifle/sniper/M42A/Fire(atom/target, mob/living/user, params, reflex = 0, dual_wield)
	if(!able_to_fire(user))
		return
	if(gun_on_cooldown(user))
		return
	if(targetmarker_primed)
		if(!iscarbon(target))
			return
		if(laser_target)
			deactivate_laser_target()
		if(target.apply_laser())
			activate_laser_target(target, user)
		return
	if(!QDELETED(laser_target))
		target = laser_target
	return ..()


/obj/item/weapon/gun/rifle/sniper/M42A/InterceptClickOn(mob/user, params, atom/object)
	var/list/pa = params2list(params)
	if(!pa.Find("ctrl"))
		return FALSE
	integrated_laze.acquire_target(object, user)
	return TRUE


/atom/proc/apply_laser()
	return FALSE

/mob/living/carbon/human/apply_laser()
	overlays_standing[LASER_LAYER] = image("icon" = 'icons/obj/items/projectiles.dmi',"icon_state" = "sniper_laser", "layer" =-LASER_LAYER)
	apply_overlay(LASER_LAYER)
	return TRUE

/mob/living/carbon/xenomorph/apply_laser()
	overlays_standing[X_LASER_LAYER] = image("icon" = 'icons/obj/items/projectiles.dmi',"icon_state" = "sniper_laser", "layer" =-X_LASER_LAYER)
	apply_overlay(X_LASER_LAYER)
	return TRUE

/mob/living/carbon/monkey/apply_laser()
	overlays_standing[M_LASER_LAYER] = image("icon" = 'icons/obj/items/projectiles.dmi',"icon_state" = "sniper_laser", "layer" =-M_LASER_LAYER)
	apply_overlay(M_LASER_LAYER)
	return TRUE

/mob/living/carbon/proc/remove_laser()
	return FALSE

/mob/living/carbon/human/remove_laser()
	remove_overlay(LASER_LAYER)
	return TRUE

/mob/living/carbon/xenomorph/remove_laser()
	remove_overlay(X_LASER_LAYER)
	return TRUE

/mob/living/carbon/monkey/remove_laser()
	remove_overlay(M_LASER_LAYER)
	return TRUE


/obj/item/weapon/gun/rifle/sniper/M42A/unique_action(mob/user)
	if(!targetmarker_primed && !targetmarker_on)
		return laser_on(user)
	else
		return laser_off(user)


/obj/item/weapon/gun/rifle/sniper/M42A/Destroy()
	laser_off()
	QDEL_NULL(integrated_laze)
	. = ..()

/obj/item/weapon/gun/rifle/sniper/M42A/dropped()
	laser_off()
	. = ..()

/obj/item/weapon/gun/rifle/sniper/M42A/process()
	if(!zoom)
		laser_off()
		return
	var/mob/living/user = loc
	if(!istype(user))
		laser_off()
		return
	if(!laser_target)
		laser_off(user)
		playsound(user,'sound/machines/click.ogg', 25, 1)
		return
	if(!can_see(user, laser_target, length=24))
		laser_off()
		to_chat(user, "<span class='danger'>You lose sight of your target!</span>")
		playsound(user,'sound/machines/click.ogg', 25, 1)

/obj/item/weapon/gun/rifle/sniper/M42A/zoom(mob/living/user, tileoffset = 11, viewsize = 12) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	. = ..()
	if(!zoom && (targetmarker_on || targetmarker_primed) )
		laser_off(user)

/atom/proc/sniper_target(atom/A)
	return FALSE

/obj/item/weapon/gun/rifle/sniper/M42A/sniper_target(atom/A)
	if(!laser_target)
		return FALSE
	if(A == laser_target)
		return laser_target
	else
		return TRUE

/obj/item/weapon/gun/rifle/sniper/M42A/proc/activate_laser_target(atom/target, mob/living/user)
	laser_target = target
	to_chat(user, "<span class='danger'>You focus your target marker on [target]!</span>")
	targetmarker_primed = FALSE
	targetmarker_on = TRUE
	RegisterSignal(src, COMSIG_PROJ_SCANTURF, .proc/scan_turf_for_target)
	START_PROCESSING(SSobj, src)
	accuracy_mult += 0.50 //We get a big accuracy bonus vs the lasered target


/obj/item/weapon/gun/rifle/sniper/M42A/proc/deactivate_laser_target()
	UnregisterSignal(src, COMSIG_PROJ_SCANTURF)
	laser_target.remove_laser()
	laser_target = null


/obj/item/weapon/gun/rifle/sniper/M42A/proc/scan_turf_for_target(datum/source, turf/target_turf)
	if(QDELETED(laser_target) || !isturf(laser_target.loc))
		return NONE
	if(get_turf(laser_target) == target_turf)
		return COMPONENT_PROJ_SCANTURF_TARGETFOUND
	return COMPONENT_PROJ_SCANTURF_TURFCLEAR


/obj/item/weapon/gun/rifle/sniper/M42A/proc/laser_on(mob/user)
	if(!zoom) //Can only use and prime the laser targeter when zoomed.
		to_chat(user, "<span class='warning'>You must be zoomed in to use your target marker!</span>")
		return TRUE
	targetmarker_primed = TRUE //We prime the target laser
	if(user?.client)
		user.client.click_intercept = src
		to_chat(user, "<span class='notice'><b>You activate your target marker and take careful aim.</b></span>")
		playsound(user,'sound/machines/click.ogg', 25, 1)
	return TRUE


/obj/item/weapon/gun/rifle/sniper/M42A/proc/laser_off(mob/user)
	if(targetmarker_on)
		if(laser_target)
			deactivate_laser_target()
		accuracy_mult -= 0.50 //We lose a big accuracy bonus vs the now unlasered target
		STOP_PROCESSING(SSobj, src)
		targetmarker_on = FALSE
	targetmarker_primed = FALSE
	if(user?.client)
		user.client.click_intercept = null
		to_chat(user, "<span class='notice'><b>You deactivate your target marker.</b></span>")
		playsound(user,'sound/machines/click.ogg', 25, 1)
	return TRUE


/obj/item/weapon/gun/rifle/sniper/M42A/jungle
	name = "\improper M42A marksman rifle"
	icon_state = "m_m42a"
	item_state = "m_m42a"


/obj/item/weapon/gun/rifle/sniper/elite
	name = "\improper M42C anti-tank sniper rifle"
	desc = "A high end mag-rail heavy sniper rifle from Nanotrasen chambered in the heaviest ammo available, 10x99mm Caseless."
	icon_state = "m42c"
	item_state = "m42c"
	max_shells = 6 //codex
	caliber = "10x99mm"
	fire_sound = 'sound/weapons/guns/fire/sniper_heavy.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_heavy_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_heavy_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/sniper_heavy_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/sniper/elite
	force = 17
	zoomdevicename = "scope"
	attachable_allowed = list()
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15)
	starting_attachment_types = list(/obj/item/attachable/scope/pmc, /obj/item/attachable/sniperbarrel)

	fire_delay = 2.5 SECONDS
	accuracy_mult = 1.50
	scatter = 15
	recoil = 5


/obj/item/weapon/gun/rifle/sniper/elite/simulate_recoil(total_recoil = 0, mob/user)
	. = ..()
	if(.)
		var/mob/living/carbon/human/PMC_sniper = user
		if(PMC_sniper.lying == 0 && !istype(PMC_sniper.wear_suit,/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC) && !istype(PMC_sniper.wear_suit,/obj/item/clothing/suit/storage/marine/veteran))
			PMC_sniper.visible_message("<span class='warning'>[PMC_sniper] is blown backwards from the recoil of the [src]!</span>","<span class='highdanger'>You are knocked prone by the blowback!</span>")
			step(PMC_sniper,turn(PMC_sniper.dir,180))
			PMC_sniper.knock_down(5)

//SVD //Based on the Dragunov sniper rifle.

/obj/item/weapon/gun/rifle/sniper/svd
	name = "\improper SVD Dragunov-033 sniper rifle"
	desc = "A sniper variant of the MAR-40 rifle, with a new stock, barrel, and scope. It doesn't have the punch of modern sniper rifles, but it's finely crafted in 2133 by someone probably illiterate. Fires 7.62x54mmR rounds."
	icon_state = "svd"
	item_state = "svd"
	max_shells = 10 //codex
	caliber = "7.62x54mm Rimmed" //codex
	fire_sound = 'sound/weapons/guns/fire/svd.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/svd_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/svd_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/svd_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/sniper/svd
	type_of_casings = "cartridge"
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope/slavic)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 13, "rail_y" = 19, "under_x" = 24, "under_y" = 13, "stock_x" = 20, "stock_y" = 14)
	starting_attachment_types = list(/obj/item/attachable/scope/slavic, /obj/item/attachable/slavicbarrel, /obj/item/attachable/stock/slavic)

	fire_delay = 1.2 SECONDS
	burst_amount = 2
	accuracy_mult = 0.85
	scatter = 15
	recoil = 2



//M4RA marksman rifle

/obj/item/weapon/gun/rifle/m4ra
	name = "\improper M4RA battle rifle"
	desc = "The M4RA battle rifle is a designated marksman rifle in service with the TGMC. Only fielded in small numbers, and sporting a bullpup configuration, the M4RA battle rifle is perfect for reconnaissance and fire support teams.\nIt is equipped with rail scope and takes 10x24mm A19 high velocity magazines."
	icon_state = "m4ra"
	item_state = "m4ra"
	max_shells = 15 //codex
	caliber = "10x24mm caseless" //codex
	fire_sound = 'sound/weapons/guns/fire/m4ra.ogg'
	unload_sound = 'sound/weapons/guns/interact/m4ra_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m4ra_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m4ra_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m4ra
	force = 16
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/bipod,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/attached_gun/grenade
						)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_SPEC
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)
	starting_attachment_types = list(/obj/item/attachable/scope/m4ra, /obj/item/attachable/stock/rifle/marksman)

	fire_delay = 0.4 SECONDS
	burst_amount = 2
	burst_delay = 0.1 SECONDS
	burst_accuracy_mult = 0.9
	accuracy_mult = 1.05
	scatter = 15
	recoil = 2

//-------------------------------------------------------
//SMARTGUN

//Come get some.
/obj/item/weapon/gun/smartgun
	name = "\improper M56B smartgun"
	desc = "The actual firearm in the 4-piece M56B Smartgun System. Essentially a heavy, mobile machinegun.\nReloading is a cumbersome process requiring a powerpack. Click the powerpack icon in the top left to reload.\nYou may toggle firing restrictions by using a special action."
	icon_state = "m56"
	item_state = "m56"
	max_shells = 100 //codex
	caliber = "10x28mm Caseless" //codex
	fire_sound = "gun_smartgun"
	load_method = POWERPACK //codex
	current_mag = /obj/item/ammo_magazine/internal/smartgun
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	wield_delay = 1.6 SECONDS
	aim_slowdown = 1.5
	var/datum/ammo/ammo_secondary = /datum/ammo/bullet/smartgun/lethal//Toggled ammo type
	var/shells_fired_max = 50 //Smartgun only; once you fire # of shells, it will attempt to reload automatically. If you start the reload, the counter resets.
	var/shells_fired_now = 0 //The actual counter used. shells_fired_max is what it is compared to.
	var/restriction_toggled = TRUE //Begin with the safety on.
	gun_skill_category = GUN_SKILL_SMARTGUN
	attachable_allowed = list(
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/burstfire_assembly,
						/obj/item/attachable/bipod)

	flags_gun_features = GUN_INTERNAL_MAG|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/flashlight)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 16,"rail_x" = 11, "rail_y" = 18, "under_x" = 22, "under_y" = 14, "stock_x" = 22, "stock_y" = 14)

	fire_delay = 0.4 SECONDS
	burst_amount = 3
	accuracy_mult = 1.15
	damage_falloff_mult = 0.5


/obj/item/weapon/gun/smartgun/Initialize()
	. = ..()
	ammo_secondary = GLOB.ammo_list[ammo_secondary]


/obj/item/weapon/gun/smartgun/examine_ammo_count(mob/user)
	to_chat(user, "[current_mag?.current_rounds ? "Ammo counter shows [current_mag.current_rounds] round\s remaining." : "It's dry."]")
	to_chat(user, "The restriction system is [restriction_toggled ? "<B>on</b>" : "<B>off</b>"].")

/obj/item/weapon/gun/smartgun/unique_action(mob/living/carbon/user)
	var/obj/item/smartgun_powerpack/power_pack = user.back
	if(!istype(power_pack))
		return FALSE
	return power_pack.attack_self(user)

/obj/item/weapon/gun/smartgun/able_to_fire(mob/living/user)
	. = ..()
	if(.)
		if(!ishuman(user))
			return FALSE
		var/mob/living/carbon/human/H = user
		if(!istype(H.wear_suit,/obj/item/clothing/suit/storage/marine/smartgunner) || !istype(H.back,/obj/item/smartgun_powerpack))
			click_empty(H)
			return FALSE

/obj/item/weapon/gun/smartgun/load_into_chamber(mob/user)
	return ready_in_chamber()

/obj/item/weapon/gun/smartgun/reload_into_chamber(mob/living/carbon/user)
	var/obj/item/smartgun_powerpack/power_pack = user.back
	if(!istype(power_pack))
		return current_mag.current_rounds
	if(shells_fired_now >= shells_fired_max && power_pack.rounds_remaining > 0) // If shells fired exceeds shells needed to reload, and we have ammo.
		addtimer(CALLBACK(src, .proc/auto_reload, user, power_pack), 0.5 SECONDS)
	else
		shells_fired_now++

	return current_mag.current_rounds

/obj/item/weapon/gun/smartgun/delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund) current_mag.current_rounds++
	return 1

/obj/item/weapon/gun/smartgun/toggle_gun_safety()
	var/obj/item/weapon/gun/smartgun/G = get_active_firearm(usr)
	if(!istype(G))
		return //Right kind of gun is not in hands, abort.
	src = G
	to_chat(usr, "[icon2html(src, usr)] You [restriction_toggled? "<B>disable</b>" : "<B>enable</b>"] the [src]'s fire restriction. You will [restriction_toggled ? "harm anyone in your way" : "target through IFF"].")
	playsound(loc,'sound/machines/click.ogg', 25, 1)
	var/A = ammo
	ammo = ammo_secondary
	ammo_secondary = A
	restriction_toggled = !restriction_toggled

/obj/item/weapon/gun/smartgun/proc/auto_reload(mob/smart_gunner, obj/item/smartgun_powerpack/power_pack)
	if(power_pack?.loc == smart_gunner)
		power_pack.attack_self(smart_gunner, TRUE)

/obj/item/weapon/gun/smartgun/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/smartgun/get_ammo_count()
	if(!current_mag)
		return 0
	else
		return current_mag.current_rounds


/obj/item/weapon/gun/smartgun/dirty
	name = "\improper M56D 'dirty' smartgun"
	desc = "The actual firearm in the 4-piece M56D Smartgun System. If you have this, you're about to bring some serious pain to anyone in your way.\nYou may toggle firing restrictions by using a special action."
	current_mag = /obj/item/ammo_magazine/internal/smartgun/dirty
	ammo_secondary = /datum/ammo/bullet/smartgun/dirty/lethal
	attachable_allowed = list() //Cannot be upgraded.
	flags_gun_features = GUN_INTERNAL_MAG|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER

	fire_delay = 0.3 SECONDS
	accuracy_mult = 1.1


//-------------------------------------------------------
//GRENADE LAUNCHER

/obj/item/weapon/gun/launcher/m92
	name = "\improper M92 grenade launcher"
	desc = "A heavy, 6-shot grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
	icon_state = "m92"
	item_state = "m92"
	max_shells = 6 //codex
	caliber = "40mm grenades" //codex
	load_method = SINGLE_CASING //codex
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 10
	force = 5.0
	wield_delay = 8
	fire_sound = 'sound/weapons/guns/fire/m92_attachable.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m92_cocked.ogg'
	var/list/grenades = list()
	var/max_grenades = 6
	aim_slowdown = 1
	attachable_allowed = list(
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_SPEC
	var/datum/effect_system/smoke_spread/smoke
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 2 SECONDS


/obj/item/weapon/gun/launcher/m92/Initialize()
	. = ..()
	for(var/i in 1 to 6)
		grenades += new /obj/item/explosive/grenade/frag(src)


/obj/item/weapon/gun/launcher/m92/examine_ammo_count(mob/user)
	if(!length(grenades) || (get_dist(user, src) > 2 && user != loc))
		return
	to_chat(user, "<span class='notice'> It is loaded with <b>[length(grenades)] / [max_grenades]</b> grenades.</span>")


/obj/item/weapon/gun/launcher/m92/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/explosive/grenade))
		if(length(grenades) >= max_grenades)
			to_chat(user, "<span class='warning'>The grenade launcher cannot hold more grenades!</span>")
			return

		if(!user.transferItemToLoc(I, src))
			return

		grenades += I
		playsound(user, 'sound/weapons/guns/interact/shotgun_shell_insert.ogg', 25, 1)
		to_chat(user, "<span class='notice'>You put [I] in the grenade launcher.</span>")
		to_chat(user, "<span class='info'>Now storing: [grenades.len] / [max_grenades] grenades.</span>")

	else if(istype(I, /obj/item/attachable) && check_inactive_hand(user))
		attach_to_gun(user, I)


/obj/item/weapon/gun/launcher/m92/afterattack(atom/target, mob/user, flag)
	if(user.action_busy)
		return
	if(!able_to_fire(user))
		return
	if(gun_on_cooldown(user))
		return
	if(user.mind?.cm_skills && user.mind.cm_skills.spec_weapons < 0 && !do_after(user, 0.8 SECONDS, TRUE, src))
		return
	if(get_dist(target,user) <= 2)
		to_chat(user, "<span class='warning'>The grenade launcher beeps a warning noise. You are too close!</span>")
		return
	if(!length(grenades))
		to_chat(user, "<span class='warning'>The grenade launcher is empty.</span>")
		return
	fire_grenade(target,user)
	var/obj/screen/ammo/A = user.hud_used.ammo
	A.update_hud(user)


//Doesn't use most of any of these. Listed for reference.
/obj/item/weapon/gun/launcher/m92/load_into_chamber()
	return


/obj/item/weapon/gun/launcher/m92/reload_into_chamber()
	return


/obj/item/weapon/gun/launcher/m92/unload(mob/user)
	if(length(grenades))
		var/obj/item/explosive/grenade/nade = grenades[length(grenades)] //Grab the last one.
		if(user)
			user.put_in_hands(nade)
			playsound(user, unload_sound, 25, 1)
		else
			nade.loc = get_turf(src)
		grenades -= nade
	else
		to_chat(user, "<span class='warning'>It's empty!</span>")
	return TRUE


/obj/item/weapon/gun/launcher/m92/proc/fire_grenade(atom/target, mob/user)
	playsound(user.loc, cocked_sound, 25, 1)
	last_fired = world.time
	visible_message("<span class='danger'>[user] fired a grenade!</span>")
	to_chat(user, "<span class='warning'>You fire the grenade launcher!</span>")
	var/obj/item/explosive/grenade/F = grenades[1]
	grenades -= F
	F.loc = user.loc
	F.throw_range = 20
	if(F?.loc) //Apparently it can get deleted before the next thing takes place, so it runtimes.
		log_explosion("[key_name(user)] fired a grenade [F] from [src] at [AREACOORD(user.loc)].")
		log_combat(user, src, "fired a grenade [F] from [src]")
		F.det_time = min(10, F.det_time)
		F.launched = TRUE
		F.activate()
		F.throwforce += F.launchforce //Throws with signifcantly more force than a standard marine can.
		F.throw_at(target, 20, 3, user)
		playsound(F.loc, fire_sound, 50, 1)

/obj/item/weapon/gun/launcher/m92/get_ammo_type()
	if(length(grenades) == 0)
		return list("empty", "empty")
	else
		var/obj/item/explosive/grenade/F = grenades[1]
		return list(F.hud_state, F.hud_state_empty)

/obj/item/weapon/gun/launcher/m92/get_ammo_count()
	return length(grenades)


/obj/item/weapon/gun/launcher/m81
	name = "\improper M81 grenade launcher"
	desc = "A lightweight, single-shot grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
	icon_state = "m81"
	item_state = "m81"
	max_shells = 1 //codex
	caliber = "40mm grenades" //codex
	load_method = SINGLE_CASING //codex
	materials = list(/datum/material/metal = 7000)
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 10
	force = 5.0
	wield_delay = 0.2 SECONDS
	fire_sound = 'sound/weapons/armbomb.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m92_cocked.ogg'
	aim_slowdown = 1
	gun_skill_category = GUN_SKILL_SPEC
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	attachable_allowed = list()
	var/grenade
	var/grenade_type_allowed = /obj/item/explosive/grenade
	var/riot_version
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 1.05 SECONDS


/obj/item/weapon/gun/launcher/m81/Initialize(mapload, spawn_empty)
	. = ..()
	if(!spawn_empty)
		if(riot_version)
			grenade = new /obj/item/explosive/grenade/chem_grenade/teargas(src)
		else
			grenade = new /obj/item/explosive/grenade/frag(src)


/obj/item/weapon/gun/launcher/m81/examine_ammo_count(mob/user)
	if(!grenade || (get_dist(user, src) > 2 && user != loc))
		return
	to_chat(user, "<span class='notice'> It is loaded with a grenade.</span>")


/obj/item/weapon/gun/launcher/m81/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/explosive/grenade))
		if(!istype(I, grenade_type_allowed))
			to_chat(user, "<span class='warning'>[src] can't use this type of grenade!</span>")
			return

		if(grenade)
			to_chat(user, "<span class='warning'>The grenade launcher cannot hold more grenades!</span>")
			return

		if(!user.transferItemToLoc(I, src))
			return

		grenade = I
		to_chat(user, "<span class='notice'>You put [I] in the grenade launcher.</span>")

	else if(istype(I, /obj/item/attachable) && check_inactive_hand(user))
		attach_to_gun(user, I)


/obj/item/weapon/gun/launcher/m81/afterattack(atom/target, mob/user, flag)
	if(!able_to_fire(user))
		return
	if(gun_on_cooldown(user))
		return
	if(get_dist(target,user) <= 2)
		to_chat(user, "<span class='warning'>The grenade launcher beeps a warning noise. You are too close!</span>")
		return
	if(!grenade)
		to_chat(user, "<span class='warning'>The grenade launcher is empty.</span>")
		return
	fire_grenade(target,user)
	playsound(user.loc, cocked_sound, 25, 1)


//Doesn't use most of any of these. Listed for reference.
/obj/item/weapon/gun/launcher/m81/load_into_chamber()
	return


/obj/item/weapon/gun/launcher/m81/reload_into_chamber()
	return


/obj/item/weapon/gun/launcher/m81/unload(mob/user)
	if(grenade)
		var/obj/item/explosive/grenade/nade = grenade
		if(user)
			user.put_in_hands(nade)
			playsound(user, unload_sound, 25, 1)
		else
			nade.loc = get_turf(src)
		grenade = null
	else
		to_chat(user, "<span class='warning'>It's empty!</span>")
	return TRUE


/obj/item/weapon/gun/launcher/m81/proc/fire_grenade(atom/target, mob/user)
	set waitfor = 0
	last_fired = world.time
	user.visible_message("<span class='danger'>[user] fired a grenade!</span>", \
						"<span class='warning'>You fire the grenade launcher!</span>")
	var/obj/item/explosive/grenade/F = grenade
	grenade = null
	F.loc = user.loc
	F.throw_range = 20
	F.throw_at(target, 20, 2, user)
	if(F && F.loc) //Apparently it can get deleted before the next thing takes place, so it runtimes.
		log_explosion("[key_name(user)] fired a grenade [F] from \a [src] at [AREACOORD(user.loc)].")
		message_admins("[ADMIN_TPMONTY(user)] fired a grenade [F] from \a [src].")
		F.icon_state = initial(F.icon_state) + "_active"
		F.active = 1
		F.updateicon()
		playsound(F.loc, fire_sound, 50, 1)
		sleep(10)
		if(F?.loc)
			F.prime()


/obj/item/weapon/gun/launcher/m81/riot
	name = "\improper M81 riot grenade launcher"
	desc = "A lightweight, single-shot grenade launcher to launch tear gas grenades. Used by the TerraGov Marine Corps Military Police during riots."
	grenade_type_allowed = /obj/item/explosive/grenade/chem_grenade
	riot_version = TRUE
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_POLICE|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	req_access = list(ACCESS_MARINE_BRIG)

//-------------------------------------------------------
//M5 RPG

/obj/item/weapon/gun/launcher/rocket
	name = "\improper M5 RPG"
	desc = "The M5 RPG is the primary anti-armor weapon of the TGMC. Used to take out light-tanks and enemy structures, the M5 RPG is a dangerous weapon with a variety of combat uses."
	icon_state = "m5"
	item_state = "m5"
	max_shells = 1 //codex
	caliber = "84mm rockets" //codex
	load_method = SINGLE_CASING //codex
	materials = list(/datum/material/metal = 10000)
	current_mag = /obj/item/ammo_magazine/rocket
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	wield_delay = 12
	wield_penalty = 1.6 SECONDS
	aim_slowdown = 1.75
	attachable_allowed = list(
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_SPEC
	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	var/datum/effect_system/smoke_spread/smoke

	fire_delay = 1 SECONDS
	recoil = 3


/obj/item/weapon/gun/launcher/rocket/Initialize(mapload, spawn_empty)
	. = ..()
	smoke = new(src, FALSE)

/obj/item/weapon/gun/launcher/rocket/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/weapon/gun/launcher/rocket/Fire(atom/target, mob/living/user, params, reflex = 0, dual_wield)
	if(!able_to_fire(user) || user.action_busy)
		return

	if(gun_on_cooldown(user))
		return

	var/delay = 3
	if(has_attachment(/obj/item/attachable/scope/mini))
		delay += 3

	if(user.mind?.cm_skills && user.mind.cm_skills.spec_weapons < 0)
		delay += 6

	if(!do_after(user, delay, TRUE, src, BUSY_ICON_DANGER)) //slight wind up
		return

	playsound(loc,'sound/weapons/guns/fire/launcher.ogg', 50, 1)
	. = ..()


	//loaded_rocket.current_rounds = max(loaded_rocket.current_rounds - 1, 0)

	if(current_mag && !current_mag.current_rounds)
		current_mag.loc = get_turf(src)
		current_mag.update_icon()
		current_mag = null

	log_combat(usr, usr, "fired the [src].")
	log_explosion("[usr] fired the [src] at [AREACOORD(loc)].")


/obj/item/weapon/gun/launcher/rocket/examine_ammo_count(mob/user)
	if(current_mag?.current_rounds)
		to_chat(user, "It's ready to rocket.")
	else
		to_chat(user, "It's empty.")


/obj/item/weapon/gun/launcher/rocket/load_into_chamber(mob/user)
	return ready_in_chamber()


//No such thing
/obj/item/weapon/gun/launcher/rocket/reload_into_chamber(mob/user)
	return TRUE


/obj/item/weapon/gun/launcher/rocket/delete_bullet(obj/item/projectile/projectile_to_fire, refund = FALSE)
	qdel(projectile_to_fire)
	if(refund)
		current_mag.current_rounds++
	return TRUE


/obj/item/weapon/gun/launcher/rocket/replace_magazine(mob/user, obj/item/ammo_magazine/magazine)
	user.transferItemToLoc(magazine, src) //Click!
	current_mag = magazine
	ammo = GLOB.ammo_list[current_mag.default_ammo]
	user.visible_message("<span class='notice'>[user] loads [magazine] into [src]!</span>",
	"<span class='notice'>You load [magazine] into [src]!</span>", null, 3)
	if(reload_sound)
		playsound(user, reload_sound, 25, 1, 5)
	update_icon()


/obj/item/weapon/gun/launcher/rocket/unload(mob/user)
	if(!user)
		return FALSE
	if(!current_mag || current_mag.loc != src)
		to_chat(user, "<span class='warning'>[src] is already empty!</span>")
		return TRUE
	to_chat(user, "<span class='notice'>You begin unloading [src].</span>")
	if(!do_after(user, current_mag.reload_delay * 0.5, TRUE, src, BUSY_ICON_GENERIC))
		to_chat(user, "<span class='warning'>Your unloading was interrupted!</span>")
		return TRUE
	if(!user) //If we want to drop it on the ground or there's no user.
		current_mag.loc = get_turf(src) //Drop it on the ground.
	else
		user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1, 5)
	user.visible_message("<span class='notice'>[user] unloads [current_mag] from [src].</span>",
	"<span class='notice'>You unload [current_mag] from [src].</span>", null, 4)
	current_mag.update_icon()
	current_mag = null

	return TRUE


//Adding in the rocket backblast. The tile behind the specialist gets blasted hard enough to down and slightly wound anyone
/obj/item/weapon/gun/launcher/rocket/apply_gun_modifiers(obj/item/projectile/projectile_to_fire, atom/target)
	. = ..()
	var/turf/blast_source = get_turf(src)
	var/thrown_dir = REVERSE_DIR(get_dir(blast_source, target))
	var/turf/backblast_loc = get_step(blast_source, thrown_dir)
	smoke.set_up(0, backblast_loc)
	smoke.start()
	for(var/mob/living/carbon/victim in backblast_loc)
		if(victim.lying || victim.stat == DEAD) //Have to be standing up to get the fun stuff
			continue
		victim.adjustBruteLoss(15) //The shockwave hurts, quite a bit. It can knock unarmored targets unconscious in real life
		victim.knock_down(3) //For good measure
		victim.emote("pain")
		victim.throw_at(get_step(backblast_loc, thrown_dir), 1, 2)


/obj/item/weapon/gun/launcher/rocket/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/launcher/rocket/get_ammo_count()
	if(!current_mag)
		return 0
	else
		return current_mag.current_rounds

//-------------------------------------------------------
//M5 RPG'S MEAN FUCKING COUSIN

/obj/item/weapon/gun/launcher/rocket/m57a4
	name = "\improper M57-A4 'Lightning Bolt' quad thermobaric launcher"
	desc = "The M57-A4 'Lightning Bolt' is posssibly the most destructive man-portable weapon ever made. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles. Enough said."
	icon_state = "m57a4"
	item_state = "m57a4"
	max_shells = 4 //codex
	caliber = "84mm rockets" //codex
	load_method = MAGAZINE //codex
	current_mag = /obj/item/ammo_magazine/rocket/m57a4
	aim_slowdown = 2.75
	attachable_allowed = list()
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER

	fire_delay = 0.6 SECONDS
	burst_delay = 0.4 SECONDS
	burst_amount = 4
	accuracy_mult = 0.8

//-------------------------------------------------------
//SCOUT SHOTGUN

/obj/item/weapon/gun/shotgun/merc/scout
	name = "\improper ZX-76 assault shotgun"
	desc = "The MIC ZX-76 Assault Shotgun, a double barreled semi-automatic combat shotgun with a twin shot mode. Has a 9 round internal magazine."
	icon_state = "zx-76"
	item_state = "zx-76"
	max_shells = 10 //codex
	caliber = "12 gauge shotgun shells" //codex
	load_method = SINGLE_CASING //codex
	fire_sound = 'sound/weapons/guns/fire/shotgun_light.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/scout
	gun_skill_category = GUN_SKILL_SPEC
	aim_slowdown = 0.75
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/extended_barrel,
						/obj/item/attachable/compensator,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/attached_gun/grenade)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 8, "rail_y" = 18, "under_x" = 24, "under_y" = 12, "stock_x" = 13, "stock_y" = 15)
	starting_attachment_types = list(/obj/item/attachable/stock/scout)

	fire_delay = 2 SECONDS
	burst_delay = 0.01 SECONDS //basically instantaneous two shots
	burst_accuracy_mult = 0.7
	accuracy_mult = 1

//-------------------------------------------------------
//This gun is very powerful, but also has a kick.

/obj/item/weapon/gun/minigun
	name = "\improper MIC-A7 Vindicator Minigun"
	desc = "It's a damn minigun! The ultimate in man-portable firepower, spraying countless high velocity armor piercing rounds with a rotary action, this thing will no doubt pack a punch."
	icon_state = "minigun"
	item_state = "minigun"
	max_shells = 500 //codex
	caliber = "7.62x51mm" //codex
	load_method = MAGAZINE //codex
	fire_sound = 'sound/weapons/guns/fire/minigun.ogg'
	unload_sound = 'sound/weapons/guns/interact/minigun_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/minigun
	type_of_casings = "cartridge"
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	wield_delay = 15
	gun_skill_category = GUN_SKILL_SPEC
	aim_slowdown = 1
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	attachable_allowed = list(
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 24, "under_y" = 14, "stock_x" = 24, "stock_y" = 12)

	fire_delay = 3
	burst_amount = 8
	recoil = 2
	recoil_unwielded = 4
	damage_falloff_mult = 0.5


obj/item/weapon/gun/minigun/Fire(atom/target, mob/living/user, params, reflex = FALSE, dual_wield)
	if(gun_firemode == GUN_FIREMODE_BURSTFIRE)
		if(user.action_busy)
			return
		playsound(get_turf(src), 'sound/weapons/guns/fire/tank_minigun_start.ogg', 30)
		if(!do_after(user, 0.5 SECONDS, TRUE, src, BUSY_ICON_DANGER))
			return
	return ..()


/obj/item/weapon/gun/minigun/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/minigun/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	else
		return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds

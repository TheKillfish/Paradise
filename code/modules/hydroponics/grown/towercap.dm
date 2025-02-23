/// Minimum required mole value of oxygen to ignite a bonfire.
#define MIN_OXY_IGNITE 7

/obj/item/seeds/tower
	name = "pack of tower-cap mycelium"
	desc = "This mycelium grows into tower-cap mushrooms."
	icon_state = "mycelium-tower"
	species = "towercap"
	plantname = "Tower Caps"
	product = /obj/item/grown/log
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 5
	potency = 50
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	icon_dead = "towercap-dead"
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	mutatelist = list(/obj/item/seeds/tower/steel)
	reagents_add = list("plantmatter" = 0.225)

/obj/item/seeds/tower/steel
	name = "pack of steel-cap mycelium"
	desc = "This mycelium grows into steel logs."
	icon_state = "mycelium-steelcap"
	species = "steelcap"
	plantname = "Steel Caps"
	product = /obj/item/grown/log/steel
	mutatelist = list()
	reagents_add = list("iron" = 0.5)
	rarity = 20

/obj/item/grown/log
	seed = /obj/item/seeds/tower
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon_state = "logs"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 3
	origin_tech = "materials=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	var/plank_type = /obj/item/stack/sheet/wood
	var/plank_name = "wooden planks"
	var/static/list/accepted = typecacheof(list(/obj/item/food/grown/tobacco,
	/obj/item/food/grown/tea,
	/obj/item/food/grown/ambrosia/vulgaris,
	/obj/item/food/grown/ambrosia/deus,
	/obj/item/food/grown/wheat))

/obj/item/grown/log/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(W.sharp)
		if(in_inventory)
			to_chat(user, "<span class='warning'>You need to place [src] on a flat surface to make [plank_name].</span>")
			return
		user.show_message("<span class='notice'>You make [plank_name] out of \the [src]!</span>", 1)
		var/seed_modifier = 0
		if(seed)
			seed_modifier = round(seed.potency / 25)
		new plank_type(user.loc, 1 + seed_modifier)
		to_chat(user, "<span class='notice'>You add the newly-formed [plank_name] to the stack.</span>")
		qdel(src)

	if(CheckAccepted(W))
		var/obj/item/food/grown/leaf = W
		if(leaf.dry)
			user.show_message("<span class='notice'>You wrap \the [W] around the log, turning it into a torch!</span>")
			var/obj/item/flashlight/flare/torch/T = new /obj/item/flashlight/flare/torch(user.loc)
			user.unequip(leaf)
			usr.put_in_active_hand(T)
			qdel(leaf)
			qdel(src)
			return
		else
			to_chat(usr, "<span class ='warning'>You must dry this first!</span>")
	else
		return ..()

/obj/item/grown/log/proc/CheckAccepted(obj/item/I)
	return is_type_in_typecache(I, accepted)

/obj/item/grown/log/tree
	seed = null
	name = "wood log"
	desc = "TIMMMMM-BERRRRRRRRRRR!"

/obj/item/grown/log/steel
	seed = /obj/item/seeds/tower/steel
	name = "steel-cap log"
	desc = "It's made of metal."
	icon_state = "steellogs"
	plank_type = /obj/item/stack/rods
	plank_name = "rods"

/obj/item/grown/log/steel/CheckAccepted(obj/item/I)
	return FALSE

/*
 * Punji sticks
 */
/obj/structure/punji_sticks
	name = "punji sticks"
	desc = "Don't step on this."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "punji"
	resistance_flags = FLAMMABLE
	max_integrity = 30
	anchored = TRUE

/obj/structure/punji_sticks/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 20, 30, 100, 6 SECONDS, CALTROP_BYPASS_SHOES)

/obj/structure/punji_sticks/spikes
	name = "wooden spikes"
	icon_state = "woodspike"

/////////BONFIRES//////////

/obj/structure/bonfire
	name = "bonfire"
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "bonfire"
	density = FALSE
	anchored = TRUE
	buckle_lying = FALSE
	var/burning = FALSE
	var/lighter // Who lit the fucking thing
	var/fire_stack_strength = 5

/obj/structure/bonfire/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/bonfire/dense
	density = TRUE

/// haha empty define
/obj/structure/bonfire/lit

/obj/structure/bonfire/lit/dense
	density = TRUE

/obj/structure/bonfire/lit/Initialize(mapload)
	. = ..()
	StartBurning()

/obj/structure/bonfire/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/rods) && !can_buckle)
		var/obj/item/stack/rods/R = W
		R.use(1)
		can_buckle = TRUE
		buckle_requires_restraints = TRUE
		to_chat(user, "<span class='italics'>You add a rod to [src].</span>")
		var/image/U = image(icon='icons/obj/hydroponics/equipment.dmi',icon_state="bonfire_rod",pixel_y=16)
		underlays += U
	if(W.get_heat())
		lighter = user.ckey
		user.create_log(MISC_LOG, "lit a bonfire", src)
		StartBurning(user)

/obj/structure/bonfire/attack_hand(mob/user)
	if(burning)
		to_chat(user, "<span class='warning'>You need to extinguish [src] before removing the logs!</span>")
		return
	if(!has_buckled_mobs() && do_after(user, 50, target = src))
		for(var/I in 1 to 5)
			var/obj/item/grown/log/L = new /obj/item/grown/log(loc)
			L.scatter_atom()
		qdel(src)
		return
	..()


/// Check if we're standing in an oxygenless environment
/obj/structure/bonfire/proc/CheckOxygen()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T.get_readonly_air()
	if(G.oxygen() > MIN_OXY_IGNITE)
		return 1
	return 0

/obj/structure/bonfire/proc/StartBurning(mob/user)
	if(burning)
		return
	if(!CheckOxygen())
		to_chat(user, "<span class='warning'>You can't seem to ignite [src] in this environment!</span>")
		return

	icon_state = "bonfire_on_fire"
	burning = TRUE
	set_light(6, l_color = "#ED9200")
	Burn()
	START_PROCESSING(SSobj, src)

/obj/structure/bonfire/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	StartBurning()

/obj/structure/bonfire/proc/on_atom_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	if(burning)
		Burn()
		if(ishuman(entered))
			var/mob/living/carbon/human/H = entered
			add_attack_logs(src, H, "Burned by a bonfire (Lit by [lighter])", ATKLOG_ALMOSTALL)

/obj/structure/bonfire/proc/Burn()
	var/turf/current_location = get_turf(src)
	current_location.hotspot_expose(1000, 10)
	for(var/A in current_location)
		if(A == src)
			continue
		if(isobj(A))
			var/obj/O = A
			O.fire_act(1000, 500)
		else if(isliving(A))
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength)
			L.IgniteMob()

/obj/structure/bonfire/process()
	if(!CheckOxygen())
		extinguish()
		return
	Burn()

/obj/structure/bonfire/extinguish()
	if(burning)
		icon_state = "bonfire"
		burning = 0
		set_light(0)
		STOP_PROCESSING(SSobj, src)

/obj/structure/bonfire/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(..())
		M.pixel_y += 13

/obj/structure/bonfire/unbuckle_mob(mob/living/buckled_mob, force = FALSE)
	if(..())
		buckled_mob.pixel_y -= 13

#undef MIN_OXY_IGNITE

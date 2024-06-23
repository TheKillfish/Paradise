/obj/item/organ/internal/cyberimp/leg
	name = "leg-mounted implant"
	desc = "A generic leg implant. You really shouldn't be seeing this, notify an admin!"
	parent_organ = "r_leg"
	slot = "r_leg_device"
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/organ/internal/cyberimp/leg/update_icon_state()
	if(parent_organ == "r_leg")
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/leg/examine(mob/user)
	. = ..()
	. += "<span class='info'>[src] is assembled in the [parent_organ == "r_leg" ? "right" : "left"] leg configuration. You can use a screwdriver to reassemble it.</span>"

/obj/item/organ/internal/cyberimp/leg/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(parent_organ == "r_leg")
		parent_organ = "l_leg"
	else
		parent_organ = "r_leg"
	slot = parent_organ + "_device"
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [parent_organ == "r_leg" ? "right" : "left"] leg.</span>")
	update_icon(UPDATE_ICON_STATE)

/obj/item/organ/internal/cyberimp/leg/emag_act()
	return FALSE

/obj/item/organ/internal/cyberimp/leg/emp_act(severity)
	if(!owner || emp_proof)
		return

/obj/item/organ/internal/cyberimp/leg/balancer
	name = "Leap balancer"
	desc = "A collection of synthetic muscle and gyroscopes intended to improve one's ability to leap onto tall structures."
	origin_tech = "materials=4;combat=2;biotech=4"

/obj/item/organ/internal/cyberimp/leg/balancer/insert(mob/living/carbon/M, special = FALSE)
	..()
	if(HAS_TRAIT(M, TRAIT_WEAK_TABLE_LEAP))
		REMOVE_TRAIT(M, TRAIT_WEAK_TABLE_LEAP, "second balancer added")
		ADD_TRAIT(M, TRAIT_MID_TABLE_LEAP, "second balancer added")
	else
		ADD_TRAIT(M, TRAIT_WEAK_TABLE_LEAP, "first balancer added")

/obj/item/organ/internal/cyberimp/leg/balancer/remove(mob/living/carbon/M, special = FALSE)
	if(HAS_TRAIT(M, TRAIT_MID_TABLE_LEAP))
		REMOVE_TRAIT(M, TRAIT_MID_TABLE_LEAP, "second balancer removed")
		ADD_TRAIT(M, TRAIT_WEAK_TABLE_LEAP, "second balancer removed")
	else
		REMOVE_TRAIT(M, TRAIT_WEAK_TABLE_LEAP, "first balancer removed")

/obj/item/organ/internal/cyberimp/leg/balancer/emp_act(severity)
	if(emp_proof)
		return
	if(owner)
		if(HAS_TRAIT(owner, TRAIT_MID_TABLE_LEAP))
			to_chat(owner, "<span class='danger'>You feel both of your legs turn to jelly as you fall to the ground!</span>")
			owner.KnockDown(5 SECONDS)
			return
		else if(HAS_TRAIT(owner, TRAIT_WEAK_TABLE_LEAP))
			to_chat(owner, "<span_class='danger'>You stumble a bit as you feel one of your legs turn to jelly!</span>")
			owner.Slowed(5 SECONDS)

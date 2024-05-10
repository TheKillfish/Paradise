/obj/item/organ/internal/cyberimp/leg
	name = "leg-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
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
	if(emp_proof)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, "<span class='warning'>[src] is hit by EMP!</span>")
	..()

/obj/item/organ/internal/cyberimp/leg/balancer
	name = "Leap balancer"
	desc = "A collection of synthetic muscle and gyroscopes intended to improve one's ability to leap onto tall structures."
	origin_tech = "materials=4;combat=2;biotech=4"

/obj/item/organ/internal/cyberimp/leg/balancer/insert(mob/living/carbon/M, special = FALSE)
	..()
	if(HAS_TRAIT(M, TRAIT_WEAK_TABLE_LEAP))
		ADD_TRAIT(M, TRAIT_MID_TABLE_LEAP, "second balancer")
	else
		ADD_TRAIT(M, TRAIT_WEAK_TABLE_LEAP, "first balancer")

/obj/item/organ/internal/cyberimp/leg/balancer/remove(mob/living/carbon/M, special = FALSE)
	if(HAS_TRAIT(M, TRAIT_MID_TABLE_LEAP))
		REMOVE_TRAIT(M, TRAIT_MID_TABLE_LEAP, "second balancer")
	else
		REMOVE_TRAIT(M, TRAIT_WEAK_TABLE_LEAP, "first balancer")

/obj/item/organ/internal/cyberimp/leg/balancer/emp_act(severity)
	if(emp_proof)
		return
	if(owner)
		to_chat(owner, "<span class='danger'>You feel your legs turn to jelly and can't move!</span>")
		owner.KnockDown(5 SECONDS)
		owner.Stun(5 SECONDS)

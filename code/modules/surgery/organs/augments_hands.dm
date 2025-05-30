/obj/item/organ/internal/cyberimp/hand
	name = "leg-mounted implant"
	desc = "A generic leg implant. You really shouldn't be seeing this, notify an admin!"
	parent_organ = "r_hand"
	slot = "r_hand_device"
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/organ/internal/cyberimp/hand/update_icon_state()
	if(parent_organ == "r_hand")
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/hand/examine(mob/user)
	. = ..()
	. += "<span class='info'>[src] is assembled in the [parent_organ == "r_hand" ? "right" : "left"] hand configuration. You can use a screwdriver to reassemble it.</span>"

/obj/item/organ/internal/cyberimp/hand/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(parent_organ == "r_hand")
		parent_organ = "l_hand"
	else
		parent_organ = "r_hand"
	slot = parent_organ + "_device"
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [parent_organ == "r_hand" ? "right" : "left"] hand.</span>")
	update_icon(UPDATE_ICON_STATE)

/obj/item/organ/internal/cyberimp/hand/emag_act()
	return FALSE

/obj/item/organ/internal/cyberimp/hand/emp_act(severity)
	if(!owner || emp_proof)
		return

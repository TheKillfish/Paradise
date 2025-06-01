// Handscanners
// What differs these implants from other implants that may or may not have scanners/analyzers included is that these only need you to alt-click on a valid target to scan.
// This means true hands-free scanning!

/obj/item/organ/internal/cyberimp/handscanner
	name = "generic handscanner implant"
	desc = "A generic handscanner implant, awaiting scanner software and additional hardware to become something. You really shouldn't be seeing this, notify an admin!"
	parent_organ = "r_hand"
	slot = "r_hand_device"
	icon_state = "toolkit_generic"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/organ_action/toggle)

	var/list/items_list = list()

	var/obj/item/holder = null

	var/enabled_handscanner = TRUE // Determines if your help intent on the installed hand will do a scan or not

/obj/item/organ/internal/cyberimp/handscanner/New()
	..()
	if(ispath(holder))
		holder = new holder(src)

	update_icon(UPDATE_ICON_STATE)
	slot = parent_organ + "_device"
	items_list = contents.Copy()

/obj/item/organ/internal/cyberimp/handscanner/update_icon_state()
	if(parent_organ == "r_hand")
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/handscanner/examine(mob/user)
	. = ..()
	. += "<span class='info'>[src] is assembled in the [parent_organ == "r_hand" ? "right" : "left"] hand configuration. You can use a screwdriver to reassemble it.</span>"

/obj/item/organ/internal/cyberimp/handscanner/screwdriver_act(mob/user, obj/item/I)
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

/obj/item/organ/internal/cyberimp/handscanner/ui_action_click()
	if(crit_fail)
		to_chat(owner, "<span class='warning'>The implant doesn't respond. It seems to be broken...</span>")
		return

	var/arm_slot = (parent_organ == "r_hand" ? ITEM_SLOT_RIGHT_HAND : ITEM_SLOT_LEFT_HAND)
	if(istype(owner.get_item_by_slot(arm_slot), /obj/item/card/emag) && emag_act(owner))
		return

	if(enabled_handscanner)
		enabled_handscanner = FALSE
		to_chat(owner, "<span class='notice'>You turn [src] off.</span>")
	else
		enabled_handscanner = TRUE
		to_chat(owner, "<span class='notice'>You turn [src] on.</span>")

/obj/item/organ/internal/cyberimp/handscanner/insert(mob/living/carbon/M, special, dont_remove_slot)
	. = ..()
	RegisterSignal(M, COMSIG_CLICK_ALT, PROC_REF(perform_scan_action))

/obj/item/organ/internal/cyberimp/handscanner/remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(M, COMSIG_CLICK_ALT)
	. = ..()

/obj/item/organ/internal/cyberimp/handscanner/proc/perform_scan_action(mob/user, atom/target)
	SIGNAL_HANDLER

	var/active_hand = "r_hand"
	switch(user.hand)
		if(HAND_BOOL_LEFT)
			active_hand = "l_hand"
		if(HAND_BOOL_RIGHT)
			active_hand = "r_hand"

	if(parent_organ == active_hand)
		if(user.a_intent == INTENT_HELP && enabled_handscanner)
			desired_scan_action(user, target)

/obj/item/organ/internal/cyberimp/handscanner/proc/desired_scan_action(mob/user, mob/living/carbon/target)
	return

/obj/item/organ/internal/cyberimp/handscanner/emag_act()
	return FALSE

/obj/item/organ/internal/cyberimp/handscanner/emp_act(severity)
	if(emp_proof)
		return

	..()

/obj/item/organ/internal/cyberimp/handscanner/health_analyzer
	name = "health handscanner"
	desc = "A health analyzer in handscanner form. Handy for having a gander at health handsfree!"

/obj/item/organ/internal/cyberimp/handscanner/health_analyzer/desired_scan_action(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		user.visible_message("<span class='notice'>[user] waves [user.p_their()] [parent_organ == "r_hand" ? "right" : "left"] hand over [target].</span>",
		"<span class='notice'>You wave your [parent_organ == "r_hand" ? "right" : "left"] hand over [target], scanning them.</span>")
		healthscan(user, target, 1, TRUE) // Advanced healthscan, since these handscanners will be on the pricier side of Research

/obj/item/organ/internal/cyberimp/handscanner/machine_analyzer
	name = "robotics handscanner"
	desc = "A machine analyzer in handscanner form. Handy for having a gander at the state of a machine handsfree!"

/obj/item/organ/internal/cyberimp/handscanner/machine_analyzer/desired_scan_action(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		user.visible_message("<span class='notice'>[user] waves [user.p_their()] [parent_organ == "r_hand" ? "right" : "left"] hand over [target].</span>",
		"<span class='notice'>You wave your [parent_organ == "r_hand" ? "right" : "left"] hand over [target], scanning them.</span>")
		robot_healthscan(user, target)

// Handscanner todo list:
// - /obj/item/reagent_scanner
// - /obj/item/slime_scanner
// - /obj/item/plant_analyzer
// - /obj/item/mail_scanner
// - /obj/item/detective_scanner
// - /obj/item/eftpos based thing for Syndies to steal money and/or ID information

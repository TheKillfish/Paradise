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

	var/message = TRUE
	var/range = 1 // How far away your clicked target can be
	var/enabled_handscanner = TRUE // Determines if your help intent on the installed hand will do a scan or not
	var/printer_compatible = FALSE // If true, you can target photocopiers to print readouts of whatever it is you need a printout of

/obj/item/organ/internal/cyberimp/handscanner/New()
	..()
	update_icon(UPDATE_ICON_STATE)
	slot = parent_organ + "_device"

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
		to_chat(owner, "<span class='warning'>The implant doesn't respond...</span>")
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
	RegisterSignal(M, COMSIG_CLICK_CTRL_SHIFT, PROC_REF(perform_scan_action))

/obj/item/organ/internal/cyberimp/handscanner/remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(M, COMSIG_CLICK_CTRL_SHIFT)
	. = ..()

/obj/item/organ/internal/cyberimp/handscanner/proc/perform_scan_action(mob/user, atom/target)
	SIGNAL_HANDLER

	if(crit_fail)
		return

	var/active_hand = "r_hand"
	switch(user.hand)
		if(HAND_BOOL_LEFT)
			active_hand = "l_hand"
		if(HAND_BOOL_RIGHT)
			active_hand = "r_hand"

	if(parent_organ == active_hand)
		if(enabled_handscanner)
			if(printer_compatible && istype(target, /obj/machinery/photocopier))
				print_action(user, target)
			else
				if(message)
					user.visible_message("<span class='notice'>[user] waves [user.p_their()] [parent_organ == "r_hand" ? "right" : "left"] hand over [target].</span>",
					"<span class='notice'>You wave your [parent_organ == "r_hand" ? "right" : "left"] hand over [target], scanning them.</span>")
				desired_scan_action(user, target)

/obj/item/organ/internal/cyberimp/handscanner/proc/desired_scan_action(mob/user, atom/target)
	if(get_dist(user, target) > range)
		return

	if(user.stat || user.incapacitated())
		return

/obj/item/organ/internal/cyberimp/handscanner/proc/print_action(mob/user, atom/target)
	return

/obj/item/organ/internal/cyberimp/handscanner/emag_act()
	return FALSE

/obj/item/organ/internal/cyberimp/handscanner/emp_act(severity)
	if(emp_proof)
		return
	crit_fail = TRUE
	enabled_handscanner = FALSE
	to_chat(owner, "<span class='warning'>[src] gives off a low buzz, indicating it has been shut down!</span>")
	addtimer(CALLBACK(src, PROC_REF(emp_disable_end)), 30 SECONDS)
	..()

/obj/item/organ/internal/cyberimp/handscanner/proc/emp_disable_end()
	crit_fail = TRUE
	to_chat(owner, "<span class='warning'>[src] quietly beeps, indicating it is functional again!</span>")
	playsound(owner, 'sound/machines/twobeep.ogg', 10, TRUE)

/obj/item/organ/internal/cyberimp/handscanner/health_analyzer
	name = "health handscanner"
	desc = "A health analyzer in handscanner form. Provides a readout of most organic creatures with just a swipe of your hand!"

/obj/item/organ/internal/cyberimp/handscanner/health_analyzer/desired_scan_action(mob/user, atom/target)
	. = ..()

	if(ishuman(target))
		var/mob/living/carbon/carb_targ = target
		healthscan(user, carb_targ, 1, TRUE) // Advanced healthscan, since these handscanners will be on the pricier side of Research

/obj/item/organ/internal/cyberimp/handscanner/machine_analyzer
	name = "robotics handscanner"
	desc = "A machine analyzer in handscanner form. Provides diagnostics details on cyborgs and robotic chassis' with just a swipe of your hand!"

/obj/item/organ/internal/cyberimp/handscanner/machine_analyzer/desired_scan_action(mob/user, atom/target)
	. = ..()

	if(ishuman(target))
		var/mob/living/carbon/carb_targ = target
		robot_healthscan(user, carb_targ)

/obj/item/organ/internal/cyberimp/handscanner/reagent_scanner
	name = "reagent handscanner"
	desc = "A reagent scanner in handscanner form. Capable of scanning for blood and chemicals, but incapable of printing anything."

/obj/item/organ/internal/cyberimp/handscanner/reagent_scanner/desired_scan_action(mob/user, atom/target)
	. = ..()

	if(isobj(target))
		var/obj/obj_targ = target
		if(!isnull(obj_targ.reagents))
			var/dat = ""
			var/blood_type = ""
			if(length(obj_targ.reagents.reagent_list) > 0)
				var/one_percent = obj_targ.reagents.total_volume / 100
				for(var/datum/reagent/R in obj_targ.reagents.reagent_list)
					if(R.id != "blood")
						dat += "<br>[TAB]<span class='notice'>[R] [R.volume / one_percent]%</span>"
					else
						blood_type = R.data["blood_type"]
						dat += "<br>[TAB]<span class='notice'>[blood_type ? "[blood_type]" : ""] [R.data["species"]] [R.name] [R.volume / one_percent]%</span>"
			if(dat)
				to_chat(user, "<span class='notice'>Chemicals found: [dat]</span>")
			else
				to_chat(user, "<span class='notice'>No active chemical agents found in [obj_targ].</span>")
		else
			to_chat(user, "<span class='notice'>No significant chemical agents found in [obj_targ].</span>")
		return

/obj/item/organ/internal/cyberimp/handscanner/slime_scanner
	name = "slime handscanner"
	desc = "A slime scanner in handscanner form. Capable of providing detailed readouts on a desired slime with just a swipe of your hand, just don't swipe too close."

/obj/item/organ/internal/cyberimp/handscanner/slime_scanner/desired_scan_action(mob/user, atom/target)
	. = ..()

	if(!isslime(target))
		to_chat(user, "<span class='warning'>This handscanner can only scan slimes!</span>")
		return
	else
		var/mob/living/live_targ = target
		slime_scan(live_targ, user)

/obj/item/organ/internal/cyberimp/handscanner/plant_analyzer
	name = "plant handscanner"
	desc = "A plant analyzer in handscanner form. Capable of performing the many functions of a plant analyzer, all behind a simple hand swipe."

/obj/item/organ/internal/cyberimp/handscanner/plant_analyzer/desired_scan_action(mob/user, atom/target)
	. = ..()

	if(istype(target, /obj/item))
		var/found_unsorted_seeds = FALSE
		var/depth = 0
		for(var/obj/item/unsorted_seeds/unsorted in target)
			found_unsorted_seeds = TRUE
			if(!use_tool(target, user, 0.5 SECONDS))
				break
			depth++
			unsorted.sort(depth)

		if(found_unsorted_seeds)
			return

	if(istype(target, /obj/item/grown))
		var/obj/item/grown/grown_targ = target
		grown_targ.send_plant_details(user)
		return

	if(istype(target, /obj/item/food/grown))
		var/obj/item/food/grown/grownfood_targ = target
		grownfood_targ.send_plant_details(user)
		return

	var/obj/item/unsorted_seeds/unsortseeds_targ = target
	if(istype(target, /obj/item/unsorted_seeds))
		to_chat(user, "<span class='notice'>This is \a <span class='name'>[unsortseeds_targ].</span></span>")
		var/text = unsortseeds_targ.get_analyzer_text()
		if(text)
			to_chat(user, "<span class='notice'>[text]</span>")
		return

	if(istype(target, /obj/item/seeds))
		var/obj/item/unsorted_seeds/seeds_targ = target
		to_chat(user, "<span class='notice'>This is \a <span class='name'>[seeds_targ].</span></span>")
		var/text = seeds_targ.get_analyzer_text()
		if(text)
			to_chat(user, "<span class='notice'>[text]</span>")
		return

	if(istype(target, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/hydrotray_targ = target
		hydrotray_targ.send_plant_details(user)

/obj/item/organ/internal/cyberimp/handscanner/mail_scanner
	name = "mail handscanner"
	desc = "A mail scanner in handscanner form. Simply swipe your hand over mail, then swipe whoever it's addressed to, and boom! Cargonia becomes a bit richer."
	var/obj/item/envelope/saved

/obj/item/organ/internal/cyberimp/handscanner/mail_scanner/desired_scan_action(mob/user, atom/target)
	. = ..()

	if(istype(target, /obj/item/envelope))
		var/obj/item/envelope/envelope = target
		if(envelope.has_been_scanned)
			to_chat(user, "<span class='warning'>This letter has already been logged to the active database!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 25, TRUE)
			return

		to_chat(user, "<span class='notice'>You add [envelope] to the active database.</span>")
		playsound(loc, 'sound/mail/mailscanned.ogg', 25, TRUE)
		saved = target
		SSblackbox.record_feedback("amount", "successful_mail_scan", 1)
		return
	if(isliving(target))
		var/mob/living/live_targ = target
		if(!saved)
			to_chat(user, "<span class='warning'>Error: You have not logged mail to the mail scanner!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 25, TRUE)
			return

		if(live_targ.stat == DEAD)
			to_chat(user, "<span class='warning'>Consent Verification failed: You can't deliver mail to a corpse!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 25, TRUE)
			return

		if(live_targ.real_name != saved.recipient)
			to_chat(user, "<span class='warning'>'Identity Verification failed: Target is not an authorized recipient of this package!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 25, TRUE)
			return

		if(!live_targ.client)
			to_chat(user, "<span class='warning'>Consent Verification failed: The scanner will not accept confirmation of orders from SSD people!</span>")
			playsound(loc, 'sound/mail/maildenied.ogg', 25, TRUE)
			return

		saved.has_been_scanned = TRUE
		saved = null
		to_chat(user, "<span class='notice'>Successful delivery acknowledged! [MAIL_DELIVERY_BONUS] credits added to Supply account!</span>")
		playsound(loc, 'sound/mail/mailapproved.ogg', 25, TRUE)
		GLOB.station_money_database.credit_account(SSeconomy.cargo_account, MAIL_DELIVERY_BONUS, "Mail Delivery Compensation", "Nanotrasen Mail and Interstellar Logistics", supress_log = FALSE)
		SSblackbox.record_feedback("amount", "successful_mail_delivery", 1)

/obj/item/organ/internal/cyberimp/handscanner/detective_scanner
	name = "forensic handscanner"
	desc = "A forensic scanner in handscanner form. While capable of processing and storing hefty amounts of information, it lacks search functions and requires interfacing with a photocopier to produce print-outs."
	actions_types = list(/datum/action/item_action/organ_action/toggle, /datum/action/item_action/clear_records)
	message = FALSE
	var/scanning = FALSE
	var/list/log = list()
	var/obj/item/paper/printout_log // Tracks for printing logs

/obj/item/organ/internal/cyberimp/handscanner/detective_scanner/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/clear_records)
		clear_scan_logs()
	else
		. = ..()

/obj/item/organ/internal/cyberimp/handscanner/detective_scanner/proc/clear_scan_logs()
	if(length(log) && !scanning)
		to_chat(usr, "<span class='notice'>You wipe the log buffer of your handscanner.</span>")
		log = list()
	else
		to_chat(usr, "<span class='warning'>The handscanner has no logs or is in use.</span>")

/obj/item/organ/internal/cyberimp/handscanner/detective_scanner/desired_scan_action(mob/user, atom/target)
	. = ..()
	perform_forensic_scan(user, target)

/obj/item/organ/internal/cyberimp/handscanner/detective_scanner/proc/perform_forensic_scan(mob/user, atom/target)
	if(!scanning)
		if(loc != user)
			return

		scanning = TRUE

		user.visible_message("<span class='notice'>[user] holds [user.p_their()] [parent_organ == "r_hand" ? "right" : "left"] hand over [target].</span>",
		"<span class='notice'>You hold [parent_organ == "r_hand" ? "right" : "left"] hand over [target], scanning them. The handscanner is now analysing the results...</span>")

		// GATHER INFORMATION

		//Make our lists
		var/list/fingerprints = list()
		var/list/blood = list()
		var/list/fibers = list()
		var/list/reagents = list()

		var/target_name = target.name

		// Start gathering

		if(length(target.blood_DNA))
			blood = target.blood_DNA.Copy()

		if(length(target.suit_fibers))
			fibers = target.suit_fibers.Copy()

		if(ishuman(target))

			var/mob/living/carbon/human/H = target
			if(istype(H.dna, /datum/dna) && !H.gloves)
				fingerprints += md5(H.dna.uni_identity)

		else if(!ismob(target))

			if(length(target.fingerprints))
				fingerprints = target.fingerprints.Copy()

			// Only get reagents from non-mobs.
			if(target.reagents && length(target.reagents.reagent_list))

				for(var/datum/reagent/R in target.reagents.reagent_list)
					reagents[R.name] = R.volume

					// Get blood data from the blood reagent.
					if(istype(R, /datum/reagent/blood))

						if(R.data["blood_DNA"] && R.data["blood_type"])
							var/blood_DNA = R.data["blood_DNA"]
							var/blood_type = R.data["blood_type"]
							blood[blood_DNA] = blood_type


		// We gathered everything. Slowly display the results to the holder of the scanner.
		var/found_something = FALSE
		add_log("<B>[station_time_timestamp()][get_timestamp()] - [target_name]</B>", FALSE)

		// Fingerprints
		if(length(fingerprints))
			sleep(30)
			add_log("<span class='notice'><B>Prints:</B></span>")
			for(var/finger in fingerprints)
				add_log("[finger]")
			found_something = TRUE

		// Blood
		if(length(blood))
			sleep(30)
			add_log("<span class='notice'><B>Blood:</B></span>")
			found_something = TRUE
			for(var/B in blood)
				add_log("Type: <font color='red'>[blood[B]]</font> DNA: <font color='red'>[B]</font>")

		//Fibers
		if(length(fibers))
			sleep(30)
			add_log("<span class='notice'><B>Fibers:</B></span>")
			for(var/fiber in fibers)
				add_log("[fiber]")
			found_something = TRUE

		//Reagents
		if(length(reagents))
			sleep(30)
			add_log("<span class='notice'><B>Reagents:</B></span>")
			for(var/R in reagents)
				add_log("Reagent: <font color='red'>[R]</font> Volume: <font color='red'>[reagents[R]]</font>")
			found_something = TRUE

		// Get a new user
		var/mob/holder = null
		if(ismob(loc))
			holder = loc

		if(!found_something)
			add_log("<I># No forensic traces found #</I>", FALSE) // Don't display this to the holder user
			if(holder)
				to_chat(holder, "<span class='notice'>Unable to locate any fingerprints, materials, fibers, or blood on [target]!</span>")
		else
			if(holder)
				to_chat(holder, "<span class='notice'>You finish scanning [target].</span>")

		add_log("---------------------------------------------------------", FALSE)
		scanning = FALSE

/obj/item/organ/internal/cyberimp/handscanner/detective_scanner/proc/add_log(msg)
	if(scanning)
		to_chat(usr, msg)
		log += "&nbsp;&nbsp;[msg]"
	else
		CRASH("[src] \ref[src] is adding a log when it was never put in scanning mode!")

/obj/item/organ/internal/cyberimp/handscanner/detective_scanner/print_action(mob/user, atom/target)
	var/obj/machinery/photocopier/copier = target
	if(length(log) && !scanning)
		scanning = TRUE

		user.visible_message("<span class='notice'>[user] holds [user.p_their()] [parent_organ == "r_hand" ? "right" : "left"] hand over [target].</span>",
		"<span class='notice'>You hold [parent_organ == "r_hand" ? "right" : "left"] hand over [target], sending the stored data for printing and clearing the buffer.</span>")

		printout_log.name = "paper- 'Scanner Report'"
		printout_log.info = "<center><font size='6'><B>Scanner Report</B></font></center><HR><BR>"
		printout_log.info += jointext(log, "<BR>")
		printout_log.info += "<HR><B>Notes:</B><BR>"
		printout_log.info_links = printout_log.info
		log = list() // Clear the logs
		copier.papercopy(printout_log)

	else
		to_chat(usr, "<span class='warning'>The handscanner has no logs or is in use.</span>")

// Handscanner todo list:
// - /obj/item/eftpos based thing for Syndies to steal money and/or ID information

/obj/item/organ/internal/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	gender = PLURAL
	organ_tag = "kidneys"
	parent_organ = "groin"
	slot = "kidneys"

/obj/item/organ/internal/kidneys/on_life()
	// Coffee is really bad for you with busted kidneys.
	// This should probably be expanded in some way, but fucked if I know
	// what else kidneys can process in our reagent list.
	var/datum/reagent/coffee = locate(/datum/reagent/consumable/drink/coffee) in owner.reagents.reagent_list
	if(coffee)
		if(is_bruised())
			owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)
		else if(is_broken())
			owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)

/obj/item/organ/internal/kidneys/cybernetic
	name = "cybernetic kidneys"
	icon_state = "kidneys-c"
	desc = "An electronic device designed to mimic the functions of human kidneys. It has no benefits over a pair of organic kidneys, but is easy to produce."
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT

/obj/item/organ/internal/kidneys/cybernetic/upgraded
	name = "upgraded cybernetic kidneys"
	desc = "A more advanced pair of cybernetic kidneys. They have improved filtration capabilities, allowing toxins in the body to be filtered out."
	origin_tech = "biotech=5"

/obj/item/organ/internal/kidneys/cybernetic/upgraded/on_life()
	..()

	if(owner.getToxLoss())
		owner.adjustToxLoss(-0.2 * PROCESS_ACCURACY)

//Procedures in this file: Robotic surgery steps, organ removal, replacement. MMI insertion, synthetic organ repair.
//////////////////////////////////////////////////////////////////
//						ROBOTIC SURGERY							//
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//	generic robotic surgery step datum
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/
	can_infect = 0
	core_skill = SKILL_DEVICES

/decl/surgery_step/robotics/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!istype(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (affected == null)
		return 0
	if (affected.status & ORGAN_CUT_AWAY)
		return 0
	if (!BP_IS_ROBOTIC(affected) || BP_IS_CRYSTAL(affected))
		return 0
	return 1

/decl/surgery_step/robotics/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	. = ..()

	//Compensating for anatomy skill req in base proc
	. += 10

	if(!user.skill_check(SKILL_DEVICES, SKILL_ADEPT))
		. -= 20

	if(user.skill_check(SKILL_ELECTRICAL, SKILL_BASIC))
		. += 10

	if(user.skill_check(SKILL_DEVICES, SKILL_PROF))
		. += 20

//////////////////////////////////////////////////////////////////
//	 unscrew robotic limb hatch surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/unscrew_hatch
	name = "Unscrew maintenance hatch"
	allowed_tools = list(
		/obj/item/weapon/screwdriver = 100,
		/obj/item/weapon/material/coin = 50,
		/obj/item/weapon/material/kitchen/utensil/knife = 50
	)

	min_duration = 90
	max_duration = 110

/decl/surgery_step/robotics/unscrew_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.hatch_state == HATCH_CLOSED && target_zone != BP_MOUTH

/decl/surgery_step/robotics/unscrew_hatch/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
	"You start to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/decl/surgery_step/robotics/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You have opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>",)
	affected.hatch_state = HATCH_UNSCREWED

/decl/surgery_step/robotics/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>\The [user]'s [tool.name] slips, failing to unscrew \the [target]'s [affected.name].</span>", \
	"<span class='warning'>Your [tool.name] slips, failing to unscrew [target]'s [affected.name].</span>")

//////////////////////////////////////////////////////////////////
//	 screw robotic limb hatch surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/screw_hatch
	name = "Secure maintenance hatch"
	allowed_tools = list(
		/obj/item/weapon/screwdriver = 100,
		/obj/item/weapon/material/coin = 50,
		/obj/item/weapon/material/kitchen/utensil/knife = 50
	)

	min_duration = 90
	max_duration = 110

/decl/surgery_step/robotics/screw_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.hatch_state == HATCH_UNSCREWED && target_zone != BP_MOUTH

/decl/surgery_step/robotics/screw_hatch/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to screw down the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
	"You start to screw down the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/decl/surgery_step/robotics/screw_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has screwed down the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You have screwed down the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>",)
	affected.hatch_state = HATCH_CLOSED

/decl/surgery_step/robotics/screw_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to screw down [target]'s [affected.name].</span>", \
	"<span class='warning'>Your [tool] slips, failing to screw down [target]'s [affected.name].</span>")

//////////////////////////////////////////////////////////////////
//	open robotic limb surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/open_hatch
	name = "Open maintenance hatch"
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 100,
		/obj/item/weapon/material/kitchen/utensil = 50
	)

	min_duration = 30
	max_duration = 40

/decl/surgery_step/robotics/open_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.hatch_state == HATCH_UNSCREWED

/decl/surgery_step/robotics/open_hatch/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].",
	"You start to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/decl/surgery_step/robotics/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] opens the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	 "<span class='notice'>You open the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>")
	affected.hatch_state = HATCH_OPENED

/decl/surgery_step/robotics/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to open the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool] slips, failing to open the hatch on [target]'s [affected.name].</span>")

//////////////////////////////////////////////////////////////////
//	close robotic limb surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/close_hatch
	name = "Close maintenance hatch"
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 100,
		/obj/item/weapon/material/kitchen/utensil = 50
	)

	min_duration = 70
	max_duration = 100

/decl/surgery_step/robotics/close_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.hatch_state == HATCH_OPENED && target_zone != BP_MOUTH

/decl/surgery_step/robotics/close_hatch/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to close the hatch on [target]'s [affected.name] with \the [tool]." , \
	"You begin to close the hatch on [target]'s [affected.name] with \the [tool].")
	..()

/decl/surgery_step/robotics/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] closes the hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You close the hatch on [target]'s [affected.name] with \the [tool].</span>")
	affected.hatch_state = HATCH_UNSCREWED
	affected.germ_level = 0

/decl/surgery_step/robotics/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")

//////////////////////////////////////////////////////////////////
//	robotic limb brute damage repair surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/repair_brute
	name = "Repair damage to prosthetic"
	allowed_tools = list(
		/obj/item/weapon/weldingtool = 100,
		/obj/item/weapon/gun/energy/plasmacutter = 50,
		/obj/item/psychic_power/psiblade/master = 100
	)

	min_duration = 50
	max_duration = 60

/decl/surgery_step/robotics/repair_brute/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	. = ..()
	if(user.skill_check(SKILL_CONSTRUCTION, SKILL_BASIC))
		. += 10

/decl/surgery_step/robotics/repair_brute/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(isWelder(tool))
		var/obj/item/weapon/weldingtool/welder = tool
		if(!welder.isOn() || !welder.remove_fuel(1,user))
			return FALSE
	if(!affected)
		return FALSE
	else if(BP_IS_BRITTLE(affected))
		to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] is too brittle to be repaired normally."))
		return FALSE
	return TRUE

/decl/surgery_step/robotics/repair_brute/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected && affected.hatch_state == HATCH_OPENED && ((affected.status & ORGAN_DISFIGURED) || affected.brute_dam > 0) && target_zone != BP_MOUTH

/decl/surgery_step/robotics/repair_brute/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to patch damage to [target]'s [affected.name]'s support structure with \the [tool]." , \
	"You begin to patch damage to [target]'s [affected.name]'s support structure with \the [tool].")
	..()

/decl/surgery_step/robotics/repair_brute/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] finishes patching damage to [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You finish patching damage to [target]'s [affected.name] with \the [tool].</span>")
	affected.heal_damage(rand(30,50),0,1,1)
	affected.status &= ~ORGAN_DISFIGURED

/decl/surgery_step/robotics/repair_brute/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>")
	target.apply_damage(rand(5,10), BURN, affected)

//////////////////////////////////////////////////////////////////
//	robotic limb brittleness repair surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/repair_brittle
	name = "Reinforce prosthetic"
	allowed_tools = list(/obj/item/stack/nanopaste = 100)
	min_duration = 50
	max_duration = 60

/decl/surgery_step/robotics/repair_brittle/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	. = ..()
	if(user.skill_check(SKILL_ELECTRICAL, SKILL_BASIC))
		. += 10

/decl/surgery_step/robotics/repair_brittle/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected && BP_IS_BRITTLE(affected) && affected.hatch_state == HATCH_OPENED && target_zone != BP_MOUTH

/decl/surgery_step/robotics/repair_brittle/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to repair the brittle metal inside \the [target]'s [affected.name]." , \
	"You begin to repair the brittle metal inside \the [target]'s [affected.name].")
	..()

/decl/surgery_step/robotics/repair_brittle/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] finishes repairing the brittle interior of \the [target]'s [affected.name].</span>", \
	"<span class='notice'>You finish repairing the brittle interior of \the [target]'s [affected.name].</span>")
	affected.status &= ~ORGAN_BRITTLE

/decl/surgery_step/robotics/repair_brittle/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user] causes some of \the [target]'s [affected.name] to crumble!</span>",
	"<span class='warning'>You cause some of \the [target]'s [affected.name] to crumble!</span>")
	target.apply_damage(rand(5,10), BRUTE, affected)

//////////////////////////////////////////////////////////////////
//	robotic limb burn damage repair surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/repair_burn
	name = "Repair burns on prosthetic"
	allowed_tools = list(
		/obj/item/stack/cable_coil = 100
	)

	min_duration = 50
	max_duration = 60

/decl/surgery_step/robotics/repair_burn/success_chance(mob/living/user, mob/living/carbon/human/target, obj/item/tool)
	. = ..()

	if(user.skill_check(SKILL_ELECTRICAL, SKILL_BASIC))
		. += 10

/decl/surgery_step/robotics/repair_burn/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected)
		if(BP_IS_BRITTLE(affected))
			to_chat(user, SPAN_WARNING("\The [target]'s [affected.name] is too brittle for this kind of repair."))
		else
			var/obj/item/stack/cable_coil/C = tool
			if(istype(C))
				if(C.get_amount() < 3)
					to_chat(user, SPAN_WARNING("You need three or more cable pieces to repair this damage."))
				else
					C.use(3)
					return TRUE
	return FALSE

/decl/surgery_step/robotics/repair_burn/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected && affected.hatch_state == HATCH_OPENED && ((affected.status & ORGAN_DISFIGURED) || affected.burn_dam > 0) && target_zone != BP_MOUTH

/decl/surgery_step/robotics/repair_burn/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to splice new cabling into [target]'s [affected.name]." , \
	"You begin to splice new cabling into [target]'s [affected.name].")
	..()

/decl/surgery_step/robotics/repair_burn/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] finishes splicing cable into [target]'s [affected.name].</span>", \
	"<span class='notice'>You finishes splicing new cable into [target]'s [affected.name].</span>")
	affected.heal_damage(0,rand(30,50),1,1)
	affected.status &= ~ORGAN_DISFIGURED

/decl/surgery_step/robotics/repair_burn/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user] causes a short circuit in [target]'s [affected.name]!</span>",
	"<span class='warning'>You cause a short circuit in [target]'s [affected.name]!</span>")
	target.apply_damage(rand(5,10), BURN, affected)

//////////////////////////////////////////////////////////////////
//	 artificial organ repair surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/fix_organ_robotic //For artificial organs
	name = "Repair prosthetic organ"
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,		\
	/obj/item/weapon/bonegel = 30, 		\
	/obj/item/weapon/screwdriver = 70,	\
	)

	min_duration = 70
	max_duration = 90

/decl/surgery_step/robotics/fix_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected) return

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(BP_IS_ROBOTIC(I) && !BP_IS_CRYSTAL(I) && I.damage > 0)
			if(I.surface_accessible)
				return TRUE
			if(affected.how_open() >= (affected.encased ? SURGERY_ENCASED : SURGERY_RETRACTED) || affected.hatch_state == HATCH_OPENED)
				return TRUE

/decl/surgery_step/robotics/fix_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/organ/I in affected.internal_organs)
		if(I && I.damage > 0)
			if(BP_IS_ROBOTIC(I))
				user.visible_message("[user] starts mending the damage to [target]'s [I.name]'s mechanisms.", \
				"You start mending the damage to [target]'s [I.name]'s mechanisms." )
	..()

/decl/surgery_step/robotics/fix_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/organ/I in affected.internal_organs)

		if(I && I.damage > 0)
			if(BP_IS_ROBOTIC(I))
				user.visible_message("<span class='notice'>[user] repairs [target]'s [I.name] with [tool].</span>", \
				"<span class='notice'>You repair [target]'s [I.name] with [tool].</span>" )
				I.damage = 0

/decl/surgery_step/robotics/fix_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>")

	target.adjustToxLoss(5)
	affected.createwound(CUT, 5)

	for(var/internal in affected.internal_organs)
		var/obj/item/organ/internal/I = internal
		if(I)
			I.take_internal_damage(rand(3,5))

//////////////////////////////////////////////////////////////////
//	robotic organ detachment surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/detatch_organ_robotic
	name = "Decouple prosthetic organ"
	allowed_tools = list(
	/obj/item/device/multitool = 100
	)

	min_duration = 90
	max_duration = 110

/decl/surgery_step/robotics/detatch_organ_robotic/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/list/attached_organs = list()
	for(var/organ in target.internal_organs_by_name)
		var/obj/item/organ/I = target.internal_organs_by_name[organ]
		if(I && !(I.status & ORGAN_CUT_AWAY) && !BP_IS_CRYSTAL(I) && I.parent_organ == target_zone)
			attached_organs |= organ
	var/organ_to_remove = input(user, "Which organ do you want to prepare for removal?") as null|anything in attached_organs
	if(organ_to_remove)
		target.op_stage.current_organ = organ_to_remove
		return TRUE
	else
		target.op_stage.current_organ = null
	return FALSE

/decl/surgery_step/robotics/detatch_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(.)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.hatch_state == HATCH_OPENED

/decl/surgery_step/robotics/detatch_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to decouple [target]'s [target.op_stage.current_organ] with \the [tool].", \
	"You start to decouple [target]'s [target.op_stage.current_organ] with \the [tool]." )
	..()

/decl/surgery_step/robotics/detatch_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has decoupled [target]'s [target.op_stage.current_organ] with \the [tool].</span>" , \
	"<span class='notice'>You have decoupled [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/obj/item/organ/internal/I = target.internal_organs_by_name[target.op_stage.current_organ]
	if(I && istype(I))
		I.cut_away(user)

/decl/surgery_step/robotics/detatch_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, disconnecting \the [tool].</span>", \
	"<span class='warning'>Your hand slips, disconnecting \the [tool].</span>")

//////////////////////////////////////////////////////////////////
//	robotic organ transplant finalization surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/attach_organ_robotic
	name = "Reattach prosthetic organ"
	allowed_tools = list(
		/obj/item/weapon/screwdriver = 100,
	)

	min_duration = 100
	max_duration = 120

/decl/surgery_step/robotics/attach_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected || !BP_IS_ROBOTIC(affected) || BP_IS_CRYSTAL(affected))
		return 0
	if(affected.hatch_state != HATCH_OPENED)
		return 0

	target.op_stage.current_organ = null

	var/list/removable_organs = list()
	for(var/obj/item/organ/I in affected.implants)
		if ((I.status & ORGAN_CUT_AWAY) && BP_IS_ROBOTIC(I) && !BP_IS_CRYSTAL(I) && (I.parent_organ == target_zone))
			removable_organs |= I.organ_tag

	var/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in removable_organs
	if(!organ_to_replace)
		return 0

	var/obj/item/organ/internal/augment/A = organ_to_replace
	if(istype(A))
		if(!(A.augment_flags & AUGMENTATION_MECHANIC))
			to_chat(user, SPAN_WARNING("\the [A] cannot function within a robotic limb"))

	target.op_stage.current_organ = organ_to_replace
	return ..()

/decl/surgery_step/robotics/attach_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins reattaching [target]'s [target.op_stage.current_organ] with \the [tool].", \
	"You start reattaching [target]'s [target.op_stage.current_organ] with \the [tool].")
	..()

/decl/surgery_step/robotics/attach_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>" , \
	"<span class='notice'>You have reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	for (var/obj/item/organ/I in affected.implants)
		if (I.organ_tag == target.op_stage.current_organ)
			I.status &= ~ORGAN_CUT_AWAY
			affected.implants -= I
			I.replaced(target, affected)
			break

/decl/surgery_step/robotics/attach_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, disconnecting \the [tool].</span>", \
	"<span class='warning'>Your hand slips, disconnecting \the [tool].</span>")

//////////////////////////////////////////////////////////////////
//	mmi installation surgery step
//////////////////////////////////////////////////////////////////
/decl/surgery_step/robotics/install_mmi
	name = "Install MMI"
	allowed_tools = list(
		/obj/item/device/mmi = 100
	)
	min_duration = 60
	max_duration = 80

/decl/surgery_step/robotics/install_mmi/pre_surgery_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/device/mmi/M = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected && istype(M))
		if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
			to_chat(user, SPAN_WARNING("That brain is not usable."))
		else if(BP_IS_CRYSTAL(affected))
			to_chat(user, SPAN_WARNING("The crystalline interior of \the [affected] is incompatible with \the [M]."))
		else if(!target.isSynthetic())
			to_chat(user, SPAN_WARNING("You cannot install a computer brain into a meat body."))
		else if(!target.should_have_organ(BP_BRAIN))
			to_chat(user, SPAN_WARNING("You're pretty sure [target.species.name_plural] don't normally have a brain."))
		else if(target.internal_organs[BP_BRAIN])
			to_chat(user, SPAN_WARNING("Your subject already has a brain."))
		else 
			return TRUE
	return FALSE

/decl/surgery_step/robotics/install_mmi/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && affected.hatch_state == HATCH_OPENED && target_zone != BP_HEAD

/decl/surgery_step/robotics/install_mmi/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts installing \the [tool] into [target]'s [affected.name].", \
	"You start installing \the [tool] into [target]'s [affected.name].")
	..()

/decl/surgery_step/robotics/install_mmi/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!user.unEquip(tool))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has installed \the [tool] into [target]'s [affected.name].</span>", \
	"<span class='notice'>You have installed \the [tool] into [target]'s [affected.name].</span>")

	var/obj/item/device/mmi/M = tool
	var/obj/item/organ/internal/mmi_holder/holder = new(target, 1)
	target.internal_organs_by_name[BP_BRAIN] = holder
	tool.forceMove(holder)
	holder.stored_mmi = tool
	holder.update_from_mmi()

	if(M.brainmob && M.brainmob.mind)
		M.brainmob.mind.transfer_to(target)

/decl/surgery_step/robotics/install_mmi/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips.</span>", \
	"<span class='warning'>Your hand slips.</span>")

/decl/surgery_step/internal/remove_organ/robotic
	name = "Remove robotic component"
	robotic_surgery = TRUE
	can_infect = 0
	core_skill = SKILL_DEVICES

/decl/surgery_step/internal/replace_organ/robotic
	name = "Replace robotic component"
	robotic_surgery = TRUE
	can_infect = 0
	core_skill = SKILL_DEVICES

/**
 * Unit test to check that held items are dropped correctly when we are dismembered.
 *
 * Also tests for edge cases such as undroppable items.
 */
/datum/unit_test/dismemberment/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	var/obj/item/testing_item = allocate(/obj/item/analyzer)
	testing_item.name = "testing item"

	// Standard situation: We're holding a normal item and get dismembered.
	test_item(dummy, testing_item, status_text = "in a normal situation")
	TEST_ASSERT_EQUAL(dummy.num_hands, 2, "Dummy has the wrong number of hands after being dismembers and fullhealed, test aborted")

	// Abnormal situation: We're holding an undroppable item and get dismembered.
	ADD_TRAIT(testing_item, TRAIT_NODROP, TRAIT_GENERIC)
	test_item(dummy, testing_item, status_text = "after applying TRAIT_NODROP to the testing item")
	TEST_ASSERT_EQUAL(dummy.num_hands, 2, "Dummy has the wrong number of hands after fullhealing at the end of the test")


/datum/unit_test/dismemberment/proc/test_item(mob/living/carbon/human/dummy, obj/item/testing_item, status_text = "")
	//Check both to make sure being the active hand doesn't make a difference.
	dummy.put_in_l_hand(testing_item)
	check_dismember(dummy, BODY_ZONE_L_ARM, status_text)

	dummy.put_in_r_hand(testing_item)
	check_dismember(dummy, BODY_ZONE_R_ARM, status_text)

	dummy.fully_heal(HEAL_ALL)

/datum/unit_test/dismemberment/proc/check_dismember(mob/living/carbon/human/dummy, which_arm, status_text)
	var/obj/item/bodypart/dismembered_limb = dummy.get_bodypart(which_arm)
	var/obj/item/held_item = dummy.get_item_for_held_index(dismembered_limb.held_index)

	dismembered_limb.dismember()
	TEST_ASSERT_NULL(dismembered_limb.owner, "Dummy didn't actually get dismembered when dismember was called [status_text].")
	TEST_ASSERT(held_item in dummy.loc, "Dummy did not drop [held_item] when [dismembered_limb] was dismembered [status_text].")
	qdel(dismembered_limb)

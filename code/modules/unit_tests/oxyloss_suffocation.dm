/// Test getting over a certain threshold of oxy damage results in KO
/datum/unit_test/oxyloss_suffocation

/datum/unit_test/oxyloss_suffocation/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	dummy.setOxyLoss(150)
	TEST_ASSERT(HAS_TRAIT(dummy, TRAIT_KNOCKEDOUT), "Dummy should have been knocked out from taking oxy damage.")
	dummy.setOxyLoss(0)
	TEST_ASSERT(!HAS_TRAIT(dummy, TRAIT_KNOCKEDOUT), "Dummy should have woken up from KO when healing to 0 oxy damage.")

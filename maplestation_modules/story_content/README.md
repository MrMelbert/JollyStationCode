## THIS FOLDER IS FOR STORY CONTENT

This is a folder for holding content relating to story and events on MapleStation. This is to differentiate it from the rest of the modular code, as it can be deleted when made unused.

All individual pieces of story-only content are to be stored in their own folders.

### LIST OF PLACES WE TOUCH MAIN CODE:

- FILE - PROC/TYPE - RELATED STORY
- code\game\objects\effects\contraband.dm - proc/randomise(base_type) - Modular posters in general
- code\modules\admin\admin_verbs.dm - admin_verbs_fun - Adds the Warfare GUI to the admin panel
- code\modules\meteors\meteor_types.dm - obj/effect/meteor - Changes meteor spinning and achievement
- code\modules\meteors\meteor_types.dm - obj/effect/meteor/Initialize(mapload, turf/target) - Changes meteor spinning and fixes the destination code
- code\modules\meteors\meteor_types.dm - obj/effect/meteor/examine(mob/user) - Changes meteor achievement

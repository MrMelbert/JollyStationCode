import { createLanguagePerk, Species } from "./base";

const Slimeperson: Species = {
  description: "WIP Slimeperson description!",
  features: {
    good: [{
      icon: "user-injured",
      name: "Major Pain Resilience",
      description: "Being made entirely of slime, slimepeople are very \
        resistant to pain. They recieve 50% less pain overall.",
    }, {
      icon: "fire",
      name: "Fire Resistance",
      description: "Slimepeople are very resistant to burn damage \
        and high temperatures.",
    }, {
      icon: "utensils",
      name: "Jelly Regeneration",
      description: "Toxic chemicals and food will regenerate a slimeperson's \
        blood levels to much higher than normal.",
    }, {
      icon: "users",
      name: "Slime Powers",
      description: "Slimepeople can come in a variety of types. Some can \
        split into multiple slime clones, regenerate lost limbs, link with \
        other people's minds, or accept slime cores for powers.",
    }, {
      icon: "user-friends",
      name: "Friend of Slimes",
      description: "Slimepeople are friendly with wild slimes.",
    },  createLanguagePerk("Slime")],
    neutral: [{
      icon: "syringe",
      name: "Toxins Lover",
      description: "Toxins damage dealt to slimepeople are reversed - \
        healing toxins will hurt them, and causing toxins will heal them. \
        Be careful around toxin purging chemicals!",
    }],
    bad: [{
      icon: "temperature-low",
      name: "Extreme Cold Vulnerability",
      description: "Slimepeople are extremely vulnerable to cold temperatures.",
    }, {
      icon: "tint",
      name: "Slime Jelly",
      description: "Slimepeople's blood consists of extremely \
        toxic Slime Jelly, making medical treatment extremely difficult.",
    }, {
      icon: "pump-medical",
      name: "Importance of Jelly",
      description: "Being low on blood is much more dangerous, causing you to \
        lose limbs and take heavy damage.",
    }],
  },
  lore: [
    "WIP Slimepeople lore!",
  ],
};

export default Slimeperson;

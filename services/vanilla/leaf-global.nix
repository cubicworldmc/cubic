{ }:
{
  config-version = "3.0";
  async = {
    async-chunk-send.enable = true;
    async-mob-spawning.enable = true;
    async-pathfinding = {
      enable = true;
    };
    async-playerdata-save.enable = true;
  };
  performance = {
    check-survival-before-growth.cactus-check-survival = true;
    dab = {
      enabled = true;
      start-distance = 8;
      max-tick-freq = 20;
      blacklisted-entities = [
        "villager"
        "axolotl"
        "hoglin"
        "zombified_piglin"
        "goat"
        "armor_stand"
      ];
    };
    entity-goal.start-tick-chance = {
      nearest-attackable-target = 20;
      follow-parent = 20;
      avoid-entity = 20;
      temptation = 20;
      enderman-look-for-player = 20;
    };
    fast-biome-manager-seed-obfuscation.enabled = true;
    faster-random-generator = {
      enabled = true;
      enable-for-worldgen = true;
      warn-for-slime-chunk = false;
      use-legacy-random-for-slime-chunk = false;
    };
    cache-biome = {
      enabled = true;
      mob-spawning = true;
      advancements = true;
    };
    optimized-powered-rails = true;
    reduce-packets = {
      reduce-entity-move-packets = true;
      reduce-entity-motion-packets = true;
      disable-useless-particles = true;
    };
    sleeping-block-entity = true;
  };
  fixes = {
    vanilla-bug-fix = {
      mc-270656 = true;
      mc-301114 = true;
      mc-301114-max-entries = 10240;
      mc-152094 = true;
    };
  };
  gameplay-mechanisms = {
    knockback = {
      snowball-knockback-players = true;
      egg-knockback-players = true;
    };
    use-spigot-item-merging-mechanism = true;
    use-vanilla-hopper = true;
  };
  network = {
    async-switch-state = true;
    chat-message-signature = false;
  };
  misc = {
    lag-compensation = {
      enabled = true;
      enable-for-water = true;
      enable-for-lava = true;
    };
    region-format = {
      format-name = "B_LINEAR";
    };
    secure-seed = {
      enabled = true;
    };
  };
}

{ }:
{
  _version = 1;
  gameplay-mechanics = {
    enable-book-writing = true;
  };
  log-to-console = {
    chat = {
      empty-message-warning = false;
      expired-message-warning = false;
      not-secure-marker = true;
    };
    ignored-advancements = true;
    invalid-legacy-text-component = true;
    invalid-statistics = true;
    legacy-material-initialization = false;
    null-id-disconnections = true;
    player-login-locations = true;
    plugin-library-loader = {
      downloads = true;
      library-loaded = true;
      start-load-libraries-for-plugin = true;
    };
    set-block-in-far-chunk = true;
    unrecognized-recipes = false;
  };
  misc = {
    keepalive = {
      send-multiple = false;
    };
    last-tick-time-in-tps-command = {
      add-oversleep = false;
      enabled = false;
    };
    premium-account-slow-login-timeout = -1;
    verify-chat-order = false;
  };
  small-optimizations = {
    reduced-intervals = {
      increase-time-statistics = 1;
      update-entity-line-of-sight = 4;
    };
  };
}

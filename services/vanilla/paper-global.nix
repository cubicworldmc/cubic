{ ... }: {
  _version = 31;
  proxies.velocity = {
    enabled = true;
    secret = "@forwardingSecret@";
  };
}

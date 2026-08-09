{ ... }: {
  proxies.velocity = {
    enabled = true;
    secret = "@forwardingSecret@";
  };
}

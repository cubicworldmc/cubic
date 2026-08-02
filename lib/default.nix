isTest: {
  secretPath = secret: if isTest then ../secrets/test/${secret} else ../secrets/prod/${secret};
  inherit isTest;
  isProd = !isTest;
}

{...}: {
  imports = [
    ../../users/eddy
  ];

  godtamnix = {
    suites = {
      development = {
        enable = true;
        awsEnable = true;
        digitaloceanEnable = true;
        dockerEnable = true;
        kubernetesEnable = true;
        nixEnable = true;
        rustEnable = true;
        sqlEnable = true;
        # aiEnable intentionally NOT set — eddy uses pi directly, not opencode
      };
    };
  };

  home.stateVersion = "25.11";
}

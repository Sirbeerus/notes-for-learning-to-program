{ lib
, ... }:
{
  /* URL of the site, must be set to the url of the domain the site will be deployed.
     Should not end with a '/'.
  */
  siteUrl = "https://sirbeerus.github.io/abundant-solutions-dev";

  /* Theme specific settings
     it is possible to override any of the used themes configuration in this set.
  */
  theme = {
    title = "abundant-solutions-dev";
    body = "Welcome to my functional site! An exercise in futility. Join us on discord?";
    links = [
      { text = "Cardano Developers"; url = "https://developers.cardano.org/"; }
      { text = "Discord"; url = "https://discord.gg/YSnJrN9wwe"; }
      { text = "Vending Machine"; url = "https://www.wildtangz.com/vending-machine/"; }
    ];
  };
}

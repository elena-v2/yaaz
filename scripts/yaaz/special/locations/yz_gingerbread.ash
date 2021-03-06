import "util/base/yz_maximize.ash";

void gingerbread_progress()
{
  if (!to_boolean(get_property("gingerbreadCityAvailable") == "true")) return;

  task(wrap("Gingerbread City", COLOR_LOCATION) + " is not automated, but you have it. Do this yourself if interested during the run.");
}

boolean can_gingerbread()
{
  if (!to_boolean(get_property("gingerbreadCityAvailable"))) return false;

  return to_boolean(setting("do_gingerbread", "false"));
}

void gingerbread()
{
  if (!can_gingerbread()) return;

  if (!svn_exists("veracity0-gingerbread"))
  {
    if (!to_boolean(setting("gingerbread_warning", "false")))
    {
      save_daily_setting("gingerbread_warning", "true");
      error("This Gingerbread script relies on Veracity's Gingerbread City script.");
      error("Install that and try again if you'd like to automate the Gingerbread City.");
    }
    return;
  }

  if (!can_interact())
  {
    warning("The Gingerbread script is built solely with Aftercore in mind.");
    warning("doing it at other times may not produce optimal results (we optimize solely for sprinkles)");
    warning("If you want to do it manually, hit ESC now, otherwise we'll continue.");
    wait(10);
  }

  maximize("sprinkles");
  visit_url("inv_equip.php?which=2&action=customoutfit&outfitname=Gingerbread City");
  cli_execute("call Gingerbread City.ash");
}



void main()
{
  gingerbread();
}

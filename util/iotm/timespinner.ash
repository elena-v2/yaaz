import "util/base/settings.ash";
import "util/base/print.ash";

int time_minutes()
{
  if (item_amount($item[time-spinner]) == 0)
    return 0;

  // hopefully mafia will track this as some point. Until then ...
  string time = visit_url("inv_use.php?pwd=&which=3&whichitem=9104");
  matcher minutematcher = create_matcher("You have (\\d+) minute[s]? left today", time);
  if(minutematcher.find())
  {
     return to_int(minutematcher.group(1));
  }
  visit_url("main.php");
  return 0;
}

boolean can_spin_time()
{
  if (item_amount($item[time-spinner]) == 0)
    return false;
  if (time_minutes() == 0)
    return false;
  return true;
}

boolean time_prank(string player, string msg)
{
  if (!can_spin_time())
    false;
  string url = "choice.php?pwd&whichchoice=1198&option=1&pl="+url_encode(player)+"&th="+url_encode(msg);

  visit_url("inv_use.php?pwd=&which=3&whichitem=9104");
  visit_url("choice.php?pwd&whichchoice=1195&option=5");
  string ret = visit_url(url);
  string oops = "someone else hiding in their timestream already";

  if (contains_text(ret, oops))
  {
    log("Trying to send " + wrap("Time Prank", COLOR_ITEM) + " to " + wrap(player, COLOR_MONSTER) + ", but someone beat you to it.");
    visit_url("choice.php?pwd&whichchoice=1198&option=2");
    return false;
  }
  return true;
}

boolean timespinner_future()
{
  if (time_minutes() < 2)
    return false;

  if (setting("visited_future") == "true")
    return false;

  string future = setting("far_future");
  if (future == "")
  {
    if (setting("spinner_notice") != "true")
    {
      save_daily_setting("spinner_notice", "true");
      warning("You have the " + wrap($item[time-spinner]) + " but I don't know how to visit the far future.");
      warning("If you set the property 'dg_far_future', I'll try to visit the future for you and replciate things.");
      warning("I recommend Ezandora's FarFuture script");
      wait(3);
    }
    return false;
  }

  if (time_minutes() < 2)
    return false;

  string replicate = "food";

  if (hippy_stone_broken())
    replicate = "drink";

  log("Using the " + wrap($item[time-spinner]) + " to visit the far future. Going to try to replicate some " + replicate + ".");
  save_daily_setting("visited_future", "true");
  return cli_execute(future + " " + replicate);
}

void timespinner()
{
  timespinner_future();
}

void main()
{
  timespinner();
}

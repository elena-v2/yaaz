import "util/base/yz_inventory.ash";

void buy_things()
{

  if (quest_status("questL13Final") < 5)
  {
    stock_item($item[boris's key]);
    stock_item($item[jarlsberg's key]);
    stock_item($item[sneaky pete's key]);
  }
  // in order to catburgle the orcish blueprints
  if (knoll_available()) stock_item($item[frilly skirt]);

  stock_item($item[anti-anti-antidote], 3);

  if (to_int(get_property("lastIslandUnlock")) == my_ascensions())
  {
    stock_item($item[the big book of pirate insults]);
    if ((item_amount($item[dictionary]) + item_amount($item[abridged dictionary])) == 0)
    {
      stock_item($item[abridged dictionary]);
    }
  }

  if (can_adventure_with_familiar($familiar[trick-or-treating tot]))
  {
    stock_item($item[li'l unicorn costume]);
    stock_item($item[li'l candy corn costume]);

  }


  // spend BACON on things for future use:
  if (!to_boolean(setting("bought_viral_video", "false"))
      && item_amount($item[BACON]) > 20
      && item_amount($item[viral video]) < 2)
  {
    log("Picking up a " + wrap($item[viral video]) + " for use later.");
    save_daily_setting("bought_viral_video", "true");
    cli_execute("acquire viral video");
  }

  if (!to_boolean(setting("bought_print_screen", "false"))
      && item_amount($item[BACON]) > 111
      && item_amount($item[print screen button]) < 2)
  {
    log("Picking up a " + wrap($item[print screen button]) + " for use later.");
    save_daily_setting("bought_print_screen", "true");
    cli_execute("acquire print screen button");
  }

  if (to_int(get_property("lastGoofballBuy")) < my_ascensions()
      && quest_status("questL03Rat") == FINISHED)
  {
    // once per ascension
    log("Getting a " + wrap($item[bottle of goofballs]) + ". They're free!");
    visit_url('tavern.php?action=buygoofballs');
  }
}

import "util/yz_main.ash";
string TRAPPER_URL="place.php?whichplace=mclargehuge&action=trappercabin";

boolean do_ninja_peak();

void L08_Q_trapper_progress()
{
  if (quest_status("questL08Trapper") == 1)
  {
    item ore_wanted = to_item(get_property("trapperOre"));
    if (ore_wanted != $item[none])
    {
      int ore = item_amount(ore_wanted);
      progress(ore, 3, wrap(ore_wanted) + " for the trapper");

      int cheese = item_amount($item[goat cheese]);
      progress(cheese, 3, wrap($item[goat cheese]) + " for the trapper");
    }
  }

  if (quest_status("questL08Trapper") == 2)
  {
    if (do_ninja_peak())
    {
      int gear = 0;
      foreach x in $items[ninja carabiner,
                          ninja rope,
                          ninja crampons]
      {
        if (have(x)) gear++;
      }

      string carabiner = UNCHECKED;
      string rope = UNCHECKED;
      string crampons = UNCHECKED;

      if (have($item[ninja carabiner])) carabiner = CHECKED;
      if (have($item[ninja rope])) rope = CHECKED;
      if (have($item[ninja crampons])) crampons = CHECKED;

      progress(gear, 3, "ninja gear (" + carabiner + " carabiner, " + rope + " rope, " + crampons + " crampons)");
    } else {
      if (!have_outfit_simple("eXtreme Cold-Weather Gear"))
      {
        task("Get the " + wrap("eXtreme Cold-Weather Gear", COLOR_ITEM));
      } else {
        int extremity = to_int(get_property("currentExtremity"));
        progress(extremity, 3, "eXtremity to reach the peak");
      }
    }
  }

  if (quest_status("questL08Trapper") == 3
      || quest_status("questL08Trapper") == 4)
  {
    progress($location[mist-shrouded peak].turns_spent, 3, "yetis killed");
  }
}

void L08_Q_trapper_cleanup()
{

}

void visit_trapper()
{
  log("Visiting the Trapper.");
  visit_url(TRAPPER_URL);
}

boolean kill_yetis()
{

  if (quest_status("questL08Trapper") == FINISHED) return false;

  if ($location[mist-shrouded peak].turns_spent < 3
      && dangerous($location[mist-shrouded peak]))
  {
    log("Avoiding the " + wrap($location[mist-shrouded peak]) + " until a bit later.");
    return false;
  }
  else if (dangerous($monster[groar]))
  {
    log("Going to try to kill " + wrap($monster[groar]) + " a bit later.");
    return false;
  }

  log("Off to kill " + wrap($monster[Groar]) + ".");
  string max = "cold res, 0.1 meat, 0.1 mainstat";
  boolean b = yz_adventure($location[mist-shrouded peak], max);
  return true;
}

boolean get_cheese()
{
  item cheese = $item[goat cheese];
  location goatlet = $location[the goatlet];

  if (item_amount(cheese) >= 3) return false;

  if (maybe_pull(cheese, 3) > 0) return true;

  yz_adventure(goatlet, "items");
  return true;
}

boolean jump_peak()
{
  string outfit = "";
  if (to_int(get_property("currentExtremity")) >= 3)
  {
    outfit = "eXtreme Cold-Weather Gear";
  }
  maximize("cold res", outfit);

  if (numeric_modifier("cold resistance") < 5)
  {
    log("You should have enough cold resistance available to you, but I can't find it. Skipping peak for now.");
    return false;
  }
  log("Climbing the " + wrap($location[the icy peak]) + ".");
  string peak = "place.php?whichplace=mclargehuge&action=cloudypeak";

  visit_url(peak);
  return true;
}

boolean peak_extreme()
{
  if (dangerous($location[the extreme slope]))
  {
    log("Skipping " + wrap($location[the extreme slope]) + " for now because it's dangerous.");
    return false;
  }

  if (!have_outfit_simple("eXtreme Cold-Weather Gear"))
  {
    log("Trying to get the " + wrap("eXtreme Cold-Weather Gear", COLOR_ITEM) + ".");
    yz_adventure($location[the extreme slope], "items");
    return true;
  }

  if (!have_outfit("eXtreme Cold-Weather Gear"))
  {
    log("Skipping " + wrap($location[the extreme slope]) + " for now because we can't wear the eXtreme Cold-Weather Gear.");
    return false;
  }

  if (to_int(get_property("currentExtremity")) < 3)
  {
    maximize("-combat", "eXtreme Cold-Weather Gear");
    yz_adventure($location[the extreme slope]);
    return true;
  }

  return jump_peak();
}

boolean peak_ninja()
{
  maybe_pull($item[ninja carabiner]);
  maybe_pull($item[ninja crampons]);
  maybe_pull($item[ninja rope]);

  if (ninja_snowman_items() == 3) return jump_peak();

  if (to_monster(get_property("_sourceTerminalDigitizeMonster")) == $monster[ninja snowman assassin])
  {
    log("The " + wrap($monster[ninja snowman assassin]) + " has been digitized, so going to wait for them to show before continuing the peak.");
    return false;
  }

  maximize("combat");
  if (numeric_modifier("combat rate") <= 0)
  {
    warning("By my guess, you should have a positive combat modifier right now, but you don't seem to.");
    warning("We won't find any Ninja Snowman Assassins at this rate, so I'm bailing out.");
    warning("If you can modify your rate you may be able to just rerun this script, otherwise this may be a bug.");
    abort();
  }
  yz_adventure($location[lair of the ninja snowmen]);
  return true;
}

boolean do_ninja_peak()
{
  if (have_outfit_simple("eXtreme Cold-Weather Gear")) {
    // We've already sunk that effort, carry on with that path and don't flip-flop
    return false;
  }

  int cold = numeric_modifier("cold resistance");
  if (have_skill($skill[elemental saucesphere]) && have_effect($effect[elemental saucesphere]) == 0)
    cold += 2;
  if (have_skill($skill[scarysauce]) && have_effect($effect[scarysauce]) == 0)
    cold += 2;
  if (have_skill($skill[astral shell]) && have_effect($effect[astral shell]) == 0)
    cold += 1;
  if (item_amount($item[cold powder]) > 0 && have_effect($effect[insulated trousers]) == 0)
    cold += 1;

  boolean combat = (have_skill($skill[Musk of the Moose])
                    || have_skill($skill[Carlweather's Cantata of Confrontation])
                    || have($item[musk turtle])
                    || have($item[reodorant])
                    || can_adventure_with_familiar($familiar[jumpsuited hound dog])
                    || have($item[portable cassette player]));

  if (cold >= 5 && combat) return true;
  return false;

}

boolean get_to_peak()
{
  if (do_ninja_peak()) return peak_ninja();

  return peak_extreme();
}

boolean trapper_items()
{
  // if we don't expect to do well in these area, skip for now.
  if (dangerous($location[the goatlet])) return false;

  item ore = to_item(get_property("trapperOre"));
  maybe_pull($item[goat cheese], 3);

  if (get_cheese()) return true;

  int goat_qty = item_amount($item[goat cheese]);

  if (item_amount(ore) < 3)
  {
    if (can_deck("mine"))
    {
      cheat_deck("mine", "get some ore for the trapper.");
      return true;
    }

    maybe_pull(ore, 3);

    if (item_amount($item[disassembled clover]) > 0)
    {
      if (yz_clover($location[Itznotyerzitz Mine])) return true;
    }

    warning("No good ways remain to get the " + wrap(ore) + " without mining.");
    warning("I don't want to do that, so waiting until tomorrow for some clover.");
    warning("Mine manually if you want to go about this a different way.");
    wait(5);
    return false;
  }

  if (goat_qty < 3)
  {
    warning("You should have three " + wrap($item[goat cheese]) + " at this point, but you don't.");
    return false;
  }

  log("Three " + wrap($item[goat cheese]) + " and three " + wrap(ore) + " found.");
  log("Returning these to the trapper.");
  visit_trapper();
  return true;

}

boolean L08_Q_trapper()
{
  if (my_level() < 8)
    return false;

  switch (quest_status("questL08Trapper"))
  {
    default:
      warning("There's something else we should do with the trapper, it's just not coded yet.");
      wait(10);
      return false;
    case FINISHED:
      return false;
    case UNSTARTED:
      log("Trapper quest isn't started yet. Talking to the council.");
      council();
      break;
    case STARTED:
      log("Talking to the trapper to see what ore he wants.");
      visit_trapper();
      log("Trapper wants " + wrap(to_item(get_property("trapperOre"))) + ".");
      return true;
    case 1:
      if (trapper_items()) return true;
      break;
    case 2:
      if (get_to_peak()) return true;
      break;
    case 3:
    case 4:
      return kill_yetis();
    case 5:
      log("Returning " + wrap($item[groar's fur]) + " to the Trapper.");
      visit_trapper();
      return true;
  }

  return false;
}

void main()
{
  while (L08_Q_trapper());
}

import "util/print.ash";
import "util/util.ash";
import "util/iotm/clanvip.ash";

boolean is_spleen_item(item it);
boolean is_booze_item(item it);
boolean is_food_item(item it);
int spleen_remaining();
int fullness_remaining();
int inebriety_remaining();
float adv_per_consumption(item it);


float adv_per_consumption(item it)
{
  if (it.levelreq > my_level())
    return 0;

  if (is_spleen_item(it))
  {
    if (it.spleen > spleen_remaining())
      return 0;
    return average_range(it.adventures) / to_float(it.spleen);
  }

  if (is_food_item(it))
  {
    if (it.fullness > fullness_remaining())
      return 0;
    return average_range(it.adventures) / to_float(it.fullness);
  }

  if (is_booze_item(it))
  {
    if (it.inebriety > inebriety_remaining())
      return 0;
    return average_range(it.adventures) / to_float(it.inebriety);
  }

  return 0;
}

int spleen_remaining()
{
  return spleen_limit() - my_spleen_use();
}

int fullness_remaining()
{
  return fullness_limit() - my_fullness();
}

int inebriety_remaining()
{
  return inebriety_limit() - my_inebriety();
}

boolean is_spleen_item(item it)
{
  if (it.spleen > 0)
    return true;
  return false;
}

boolean is_food_item(item it)
{
  if (it.fullness > 0)
    return true;
  return false;
}

boolean is_booze_item(item it)
{
  if (it.inebriety > 0)
    return true;
  return false;
}

int consume_cost(item it)
{
  if (is_spleen_item(it))
    return it.spleen;
  if (is_booze_item(it))
    return it.inebriety;
  if (is_food_item(it))
    return it.fullness;
  error("Trying to get consumption cost of " + wrap(it) + " but I don't know what that is.");
  return 100;
}

boolean can_chew(item it)
{
  if (item_amount(it) == 0)
    return false;
  if (!is_spleen_item(it))
    return false;
  if (consume_cost(it) > spleen_remaining())
    return false;
  return true;
}

boolean can_eat(item it)
{
  if (item_amount(it) == 0)
    return false;
  if (!is_food_item(it))
    return false;
  if (consume_cost(it) > fullness_remaining())
    return false;
  return true;
}

boolean can_drink(item it)
{
  if (item_amount(it) == 0 && !is_vip_item(it))
    return false;
  if (!is_booze_item(it))
    return false;
  if (consume_cost(it) > inebriety_remaining())
    return false;
  return true;
}

boolean try_chew(item it)
{
  if (!can_chew(it))
    return false;
  log("Chewing a " + wrap(it) + ". Expected adventures: " + to_string(adv_per_consumption(it)));
  return chew(1, it);
}

boolean try_eat(item it)
{
  if (!can_eat(it))
    return false;
  log("Eating a " + wrap(it) + ". Expected adventures: " + to_string(adv_per_consumption(it)));
  return eat(1, it);
}

boolean try_drink(item it)
{
  if (!can_drink(it))
    return false;
  if (have_skill($skill[the ode to booze]) && mp_cost($skill[the ode to booze]) < my_mp())
  {
    if (have_effect($effect[ode to booze]) == 0)
    {
      log("Casting " + wrap($skill[the ode to booze]) + " for better booze action.");
      use_skill(1, $skill[the ode to booze]);
    }
  }
  log("Drinking a " + wrap(it) + ". Expected adventures: " + to_string(adv_per_consumption(it)));
  if (is_vip_item(it))
  {
    if (!can_vip_drink(it))
      return false;
    cli_execute("drink 1 " + it);
    return true;
  } else {
    return drink(1, it);
  }
  return false;
}

item[int] consume_list()
{
  item[int] noms;
  int[item] inventory = get_inventory();
  int count = 0;
  foreach it in inventory
  {
    float avg = adv_per_consumption(it);

    if (avg == 0)
      continue;

    noms[count] = it;
    count+=1;
  }
  sort noms by -adv_per_consumption(value);
  return noms;
}

void max_consumption()
{
  // use up all of our space.

}

void drink_irresponibly()
{
  // overdrink.

  // doing this in this here vs max_consumption.
  // This way if max_consumption() makes enough turns to then
  // generate more speen items, they can be used. Here this will
  // only fire if we're truly near end-of-day and have the room:
  if (spleen_remaining() >= 5 && hippy_stone_broken() && my_meat() > 1000)
  {
    log("Chewing a " + $item[hatorade] + " for extra pvp.");
    cli_execute("chew hatorade");
  }

}

boolean try_consume(item it)
{
  if (is_spleen_item(it))
    return try_chew(it);
  if (is_food_item(it))
    return try_eat(it);
  if (is_booze_item(it))
    return try_drink(it);
  error("Trying to consume " + wrap(it) + " but I don't know what it is.");
  return false;
}

boolean consume_best()
{
  item[int] noms = consume_list();
  foreach nom, it in noms
  {
    print("Considering consuming " + wrap(it) + " which would give us " + adv_per_consumption(it) + " adventures.");
//    if (try_consume(nom))
//      return true;
  }
  return false;
}

void consume()
{
  int adv_min = to_int(setting("adventure_floor", "10"));

  if (get_counters("fortune cookie", 0, 500) == "")
  {
    if (get_counters("Semirare window begin", 0, 500) == "" || get_counters("Semirare window begin", 0, 10) != "")
    {
      // we don't know our next semi-rare and:
      // we don't even know a window for it to appear...
      // -or-
      // the window is upon us, so we should find out what the actual number is...
      if (can_vip_drink($item[lucky lindy]))
      {
        try_drink($item[lucky lindy]);
      }
    }
  }

  if (closet_amount($item[hacked gibson]) == 0 && item_amount($item[hacked gibson]) > 0)
  {
    log("Putting one " + wrap($item[hacked gibson]) + " in the closet for use at the end of the day.");
    put_closet(1, $item[hacked gibson]);
  }

  while (my_adventures() < adv_min)
  {
    if (!consume_best())
      break;
  }

}

void main()
{
  consume();
}

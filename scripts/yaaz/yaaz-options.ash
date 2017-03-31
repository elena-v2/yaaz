import "util/base/util.ash";
import "util/base/settings.ash";

string pref_line(string pref, string def, string comment)
{
  return "<tr><td>" + SETTING_PREFIX + "_" + pref + "</td><td>" + setting(pref, def) + "</td><td>" + comment + "</td></tr>";
}


print_html("Options with <b>" + SCRIPT + "</b> can be set by changing various settings.");
print("Set an option by changing the variable like the following in the gCLI:");
print("");
print("set " + SETTING_PREFIX + "_war_side=hippy");
print("");
print("Settings:");
string table = "<table border=2 width=500px><tr><th>Option</th><th>Current</th><th>Notes</th></tr>";

table += pref_line("100familiar", "", "Familiar to use for 100% run, versus trying to find the right familiar for a given task.");
table += pref_line("adventure_floor", "10", "Adventures left to start consuming food/booze");
table += pref_line("war_side", "fratboy", "Fight Island War as fratboy or hippy.");
table += pref_line("do_heart", "true", "Do heart-y thing like using up your Smile of Mr. Accessory. Set to false to not be a heart while playing.");
table += pref_line("do_collectors", "true", "Give things to certain well-known collectors, particularly devs of KoLMafia. Set to false to not give to these collectors.");
table += pref_line("manuel_always_show_progress", "false", "If true, Monster Manuel progress will always be shown. Otherwise, once you have all location facts, that progress display is skipped.");
table += pref_line("use_avatar_potions", "true", "Use avatar potions when you have them to stay constantly dressed up.");
table += pref_line("aggressive_optimize", "false", "If true, skip all side actions that aren't solely about ascending (ex: Evoke Eldritch Horror, Portscan, etc).");


table += "</table>";
print_html(table);

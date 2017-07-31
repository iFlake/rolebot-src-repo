import "dart:async";

import "package:rolebot/config.dart";
import "package:rolebot/bot.dart";
import "package:rolebot/tr.dart";
import "package:rolebot/processor.dart";

void main()
{
    print("Starting role changing bot...");

    print("Initializing TypeRacer API...");;
    TypeRacerAPI typeRacerAPI = new TypeRacerAPI();
    print("OK");

    print("Initializing Discord bot...");
    Bot bot = new Bot(typeRacerAPI);
    print("OK");
    
    print("Initializing processor...");

    new Timer(SystemConfig.initDuration, ()
    {
        Processor processor    = new Processor(bot);
        bot.processor          = processor;
        print("OK");

        print("Role changing bot started.");
        print("");
        print("Configuration: ");
        print(" -  Token:  ${DiscordConfig.token}");
        print(" -  Prefix: ${DiscordConfig.prefix}");
        print(" -  Administrative role: ${DiscordConfig.adminRole}");
        print("");
    });
}

import "dart:async";
import "package:meta/meta.dart";

import "package:dartcord/dartcord.dart";

import "./config.dart";
import "./tr.dart";
import "./rank.dart";
import "./processor.dart";
import "./user.dart" as AppUser;
import "./auxmember.dart";

class Bot
{
    @protected final Client client;
    final TypeRacerAPI typeRacerAPI;
    Processor processor;

    Bot(TypeRacerAPI typeRacerAPI)
    :   client = new Client(DiscordConfig.token)
            ..start(),
        typeRacerAPI = typeRacerAPI
    {
        client.onMessageCreate.listen(handleMessage);
    }
    

    bool userExists(String userID) =>
        client.guilds[DiscordConfig.server].members.containsKey(userID);
    
    Future sendUpdateWPMMessage(String userID, Rank lastRank, Rank newRank) async
    {
        Member member = client.guilds[DiscordConfig.server].members[userID];

        if (lastRank == null)
        {
            await member.sendMessage("You have been assigned the rank **${newRank}**");
        }
        else
        {
            await member.sendMessage("Congratulations, your rank has been updated!");
            await member.sendMessage("**Last rank**: ${lastRank} (${lastRank.wpm} WPM) | **New rank**: ${newRank} (${newRank.wpm} WPM)");
            await member.sendMessage("**Change**: ${newRank.wpm - lastRank.wpm}");
        }
    }

    void updateRole(String userID, String roleID)
    {
        client.guilds[DiscordConfig.server].members[userID].roles
            ..remove(Roles.transcended)
            ..remove(Roles.ascended)
            ..remove(Roles.illuminati)
            ..remove(Roles.keyboardGrandmaster)
            ..remove(Roles.keyboardMaster)
            ..remove(Roles.jediTypist)
            ..remove(Roles.eliteTypist)
            ..remove(Roles.professional)
            ..remove(Roles.advanced)
            ..remove(Roles.intermediate)
            ..add(roleID);

        updateRoles(client, client.guilds[DiscordConfig.server], client.guilds[DiscordConfig.server].members[userID]);
    }
    
    @protected Future handleMessage(MessageCreateEvent event) async
    {
        if (event.message.content.length > 1)
        {
            if (event.message.content.substring(0, DiscordConfig.prefix.length) == DiscordConfig.prefix)
            {
                int space            = event.message.content.indexOf(" ");

                String command       = "";
                String parameters    = "";

                if (event.message.content.length == space - 1)
                    return; //failsafe to avoid crashing when a command has been posted with a trailing space

                if (space == -1)
                {
                    command    = event.message.content;
                }
                else
                {
                    command       = event.message.content.substring(DiscordConfig.prefix.length, space);
                    parameters    = event.message.content.substring(space + 1);
                }

                switch (command)
                {
                    case "addme":
                        Message message = await event.message.channel.createMessage("Please wait...");

                        if (processor.discordUserExists(event.message.author.id))
                            await message.edit("<@${event.message.author.id}> Your request has been rejected because you are already connected to a TypeRacer username. Please contact an administrator if you wish to change it.");
                        else if (processor.trUserExists(parameters))
                            await message.edit("<@${event.message.author.id}> Your request has been rejected because someone has already connected their Discord account to this TypeRacer username. Please contact an administrator if someone is using your account without permission.");
                        else
                        {
                            typeRacerAPI.importUserName(parameters);
                            processor.addUser(new AppUser.User(discordID: event.message.author.id, trUserName: parameters));

                            await message.edit("<@${event.message.author.id}> You have been added to the users list and will shortly be given your role. This process may take up to a minute so please wait patiently.");
                        }

                        break;
                    
                    case "deluser":
                        if (event.message.member.roles.indexOf(DiscordConfig.adminRole) == -1)
                        {
                            await event.message.channel.createMessage("You are not an administrator and are therefore not allowed to delete a user.");
                        }
                        else
                        {
                            Message message = await event.message.channel.createMessage("Please wait...");

                            processor.delUser(parameters);

                            await message.edit("Deleted user `${parameters}`.");
                        }

                        break;
                }
            }
        }
    }
}

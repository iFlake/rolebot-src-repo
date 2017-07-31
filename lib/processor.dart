import "dart:async";
import "dart:convert";
import "dart:io";

import "./config.dart";
import "./bot.dart";
import "./user.dart";
import "./rank.dart";

class Processor
{
    final Bot bot;
    final List<User> users;

    Processor(Bot bot)
    :   bot      = bot,
        users    = []
    {
        loadUsers().then((Timer timer) => new Timer.periodic(ProcessorConfig.masterInterval, (Timer timer) => process()));
        loadUsers().then((Timer timer) => new Timer.periodic(ProcessorConfig.saveInterval, (Timer timer) => saveUsers()));
    }

    Future loadUsers() async
    {
        List<Map<String, dynamic>> userList = JSON.decode(await new File("./data/users.json").readAsString());

        for (Map<String, dynamic> rawUser in userList)
            users.add(new User(discordID: rawUser["discordid"], trUserName: rawUser["trusername"], rank: rawUser["savedwpm"] == null ? null : new Rank(rawUser["savedwpm"])));
    }

    Future saveUsers() async
    {
        if (SystemConfig.debugging == true)
            print("Saving users");

        dynamic jsonObject = [];

        for (User user in users)
        {
            dynamic jsonNode          = {};

            jsonNode["discordid"]     = user.discordID;
            jsonNode["trusername"]    = user.trUserName;
            jsonNode["savedwpm"]      = user.rank == null ? null : user.rank.wpm;

            jsonObject.add(jsonNode);
        }

        await new File("./data/users.json").writeAsString(JSON.encode(jsonObject));

        if (SystemConfig.debugging == true)
            print("Users saved");
    }

    void addUser(User user)
    {        
        if (SystemConfig.debugging == true)
            print("Adding user ${user.discordID}: ${user.trUserName}");

        List<User> usersToRemove = [];

        for (User listUser in users)
            if (listUser.discordID == user.discordID)
            {
                usersToRemove.add(listUser);
                if (SystemConfig.debugging == true)
                    print("Removing user ${listUser.discordID}: ${listUser.trUserName}");
            }

        for (User listUser in usersToRemove)
            users.remove(listUser);

        users.add(user);

        if (SystemConfig.debugging == true)
            print("Added user ${user}, index: ${users.indexOf(user)}");
    }

    void delUser(String trUserName)
    {
        if (SystemConfig.debugging == true)
            print("Deleting user ${trUserName}");
        
        List<User> usersToRemove = [];

        for (User listUser in users)
            if (listUser.trUserName == trUserName)
            {
                usersToRemove.add(listUser);
                if (SystemConfig.debugging == true)
                    print("Removing user ${listUser.discordID}: ${listUser.trUserName}");
            }
        
        for (User listUser in usersToRemove)
            users.remove(listUser);
    }

    bool trUserExists(String trUserName)
    {
        for (User user in users)
            if (user.trUserName == trUserName)
                return true;
        
        return false;
    }

    bool discordUserExists(String discordID)
    {
        for (User user in users)
            if (user.discordID == discordID)
                return true;
        
        return false;
    }

    Future process([int iterator = 0]) async
    {
        if (SystemConfig.debugging == true && iterator == 0)
            print("User list: ${users}");

        if (SystemConfig.debugging == true)
            print("Processing iteration ${iterator}");

        if (iterator > users.length / 5) return;

        processBatch(iterator * 5);
        new Timer(ProcessorConfig.interval, () => process(iterator + 1));
    }

    Future processBatch(int batchStart, [int iterator = 0]) async
    {
        if (SystemConfig.debugging == true)
            print("Processing batch from ${batchStart} with iterator ${iterator}");

        if (iterator - batchStart >= ProcessorConfig.batchSize)
            return;
        
        int currentID       = batchStart + iterator;

        if (currentID >= users.length)
            return;

        
        if (SystemConfig.debugging == true)
            print("Batch eligible to process, current ID: ${currentID}");

        User currentUser    = users[currentID];

        if (bot.userExists(currentUser.discordID) == false)
        {
            users.removeAt(currentID);

            if (SystemConfig.debugging == true)
                print("Removing index ${currentID}, doesn't exist in Discord");
        }
        else
        {
            if (SystemConfig.debugging == true)
                print("Importing username: ${currentUser.trUserName}");

            await bot.typeRacerAPI.importUserName(currentUser.trUserName);

            
            if (SystemConfig.debugging == true)
                print("Retrieving username: ${currentUser.trUserName}");

            dynamic rawUser = await bot.typeRacerAPI.getUser(currentUser.trUserName);

            if (SystemConfig.debugging == true)
                print("Batch in approval");

            if (rawUser == null)
            {
                users.removeAt(currentID);
                
                if (SystemConfig.debugging == true)
                    print("Removing index ${currentID}, doesn't exist in TR");
            }
            else
            {
                if (SystemConfig.debugging == true)
                    print("Batch approved");

                int lastTen        = num.parse(rawUser["account"]["wpm_last10"]).toInt();
                int bestLastTen    = num.parse(rawUser["account"]["wpm_bestlast10"]).toInt();

                Rank userRank = new Rank(bestLastTen == 0 ?
                lastTen :
                bestLastTen);
                
                if (SystemConfig.debugging == true)
                    print("User ${currentUser.trUserName}:${currentUser.discordID} last wpm: ${currentUser.rank == null ? null : currentUser.rank.wpm} current wpm: ${userRank.wpm}");

                if (userRank != currentUser.rank)
                    await updateWPM(currentUser, userRank);
            }
        }
        
        processBatch(batchStart, iterator + 1);
    }

    Future updateWPM(User user, Rank userRank) async
    {
        if (SystemConfig.debugging == true)
            print("Updating WPM of ${user.trUserName}:${user.discordID}");

        Rank oldRank       = user.rank;
        user.rank          = userRank;
        
        bot.sendUpdateWPMMessage(user.discordID, oldRank, userRank);
        bot.updateRole(user.discordID, userRank.type);
    }
}

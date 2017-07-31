import "./rank.dart";

class User
{
    final String discordID;
    final String trUserName;
    Rank rank;

    User({String discordID, String trUserName, Rank rank})
    :   discordID      = discordID,
        trUserName     = trUserName,
        rank           = rank;
}

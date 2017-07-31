class DiscordConfig
{
    static const String token         = "Your bot's token here";
    static const String server        = "The guild's ID";
    static const String prefix        = "The command prefix";
    static const String adminRole     = "The ID of the role that is allowed to use administrative commands";
}

class Roles
{
    static const String transcended            = "Role ID";
    static const String ascended               = "Role ID";
    static const String illuminati             = "Role ID";
    static const String keyboardGrandmaster    = "Role ID";
    static const String keyboardMaster         = "Role ID";
    static const String jediTypist             = "Role ID";
    static const String eliteTypist            = "Role ID";
    static const String professional           = "Role ID";
    static const String advanced               = "Role ID";
    static const String intermediate           = "Role ID";
    static const String trainee                = "Role ID";
}

class TypeRacerConfig
{
    static const String uri    = "www.typeracerdata.com";
    static const int port      = 80;
}

class ProcessorConfig
{
    static const Duration masterInterval    = const Duration(minutes: 1);
    static const Duration interval          = const Duration(seconds: 5);
    static const Duration saveInterval      = const Duration(seconds: 30);
    static const int batchSize              = 10;
}

class SystemConfig
{
    static const Duration initDuration    = const Duration(seconds: 2);
    static const bool debugging           = false;
}

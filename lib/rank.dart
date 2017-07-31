import "./config.dart";

class Rank
{
    String type;
    final int wpm;


    Rank(int wpm)
    :   wpm    = wpm
    {
        if (wpm >= 171)
            type = Roles.transcended;
        else if (wpm >= 151 && wpm <= 170)
            type = Roles.ascended;
        else if (wpm >= 141 && wpm <= 150)
            type = Roles.illuminati;
        else if (wpm >= 131 && wpm <= 140)
            type = Roles.keyboardGrandmaster;
        else if (wpm >= 121 && wpm <= 130)
            type = Roles.keyboardMaster;
        else if (wpm >= 111 && wpm <= 120)
            type = Roles.jediTypist;
        else if (wpm >= 91 && wpm <= 110)
            type = Roles.eliteTypist;
        else if (wpm >= 71 && wpm <= 90)
            type = Roles.professional;
        else if (wpm >= 51 && wpm <= 70)
            type = Roles.advanced;
        else
            type = Roles.trainee;
    }


    String toString()
    {
        switch (type)
        {
            case Roles.transcended:
                return "Transcended";
                break;
            
            case Roles.ascended:
                return "Ascended";
                break;
            
            case Roles.illuminati:
                return "Illuminati";
                break;
            
            case Roles.keyboardGrandmaster:
                return "Keyboard grandmaster";
                break;
            
            case Roles.keyboardMaster:
                return "Keyboard master";
                break;
            
            case Roles.jediTypist:
                return "Jedi typist";
                break;
            
            case Roles.eliteTypist:
                return "Elite typist";
                break;
            
            case Roles.professional:
                return "Professional";
                break;
            
            case Roles.advanced:
                return "Advanced";
                break;
            
            case Roles.trainee:
                return "Trainee";
                break;
            
            default:
                return "Unknown";
                break;
        }
    }

    bool operator ==(Rank other) =>
        type == other.type;
}

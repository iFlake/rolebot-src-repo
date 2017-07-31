import "dart:io";
import "dart:convert";
import "dart:async";


import "./config.dart";

class TypeRacerAPI
{
    TypeRacerAPI();

    Future<Null> importUserName(String userName) async =>
        await new HttpClient().get(TypeRacerConfig.uri, TypeRacerConfig.port, "/import?username=${Uri.encodeComponent(userName)}");

    Future<dynamic> getUser(String userName) async
    {
        if (SystemConfig.debugging == true)
            print("Querying on /api?username=${Uri.encodeComponent(userName)}");
        
        HttpClientRequest request = await new HttpClient().get(TypeRacerConfig.uri, TypeRacerConfig.port, "/api?username=${Uri.encodeComponent(userName)}");

        if (SystemConfig.debugging == true)
            print("Waiting for request to close on user: ${userName}");

        HttpClientResponse response = await request.close();

        if (SystemConfig.debugging == true)
            print("Request closed on ${userName}");

        Stream responseStream = response.transform(UTF8.decoder);

        String responseText = "";

        await for (String character in responseStream)
            responseText = "${responseText}${character}";

        if (responseText == "")
        {
            if (SystemConfig.debugging == true)
                print("Empty response, returning null");

            return null;
        }

        dynamic responseObject = JSON.decode(responseText);
        
        if (SystemConfig.debugging == true)
            print("Got user: ${userName}");

        return responseObject;
    }
}

import "dart:async";

import "package:dartcord/dartcord.dart";
import "package:w_transport/w_transport.dart" as w_transport;
import 'package:http_parser/http_parser.dart' as http_parser;

import "./config.dart";

Future updateRoles(Client client, Guild guild, Member member) async
{
    RestClient restClient = new RestClient(client);
    restClient.send("PATCH", DiscordEndpoints.guildMember(guild.id, member.id), body: { "roles": member.roles });
}


/* Everything below this line is borrowed from Dartcord and modified very slightly -- very hacky but it's important

MIT License

Copyright (c) 2017 Jackson Rakena.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */


/// An HTTP error.
class HttpError implements Exception {
  w_transport.Response _r;

  /// The HTTP status code.
  int statusCode;

  /// Discord's error code, if provided.
  int code;

  /// Discord's message, if provided.
  String message;

  /// The response body decoded, if it is JSON.
  Map<String, dynamic> json;

  /// The raw response body.
  w_transport.HttpBody body;

  /// Constructs a new [HttpError].
  HttpError._new(this._r) {
    if (_r.headers['content-type'] == "application/json") {
      this.code = _r.body.asJson()['code'];
      this.message = _r.body.asJson()['message'];
    }
    this.body = _r.body;
    this.statusCode = _r.status;
  }

  /// Returns a string representation of this object.
  @override
  String toString() => this.statusCode.toString() + ": " + _r.statusText;
}

class DiscordEndpoints {
  static const String getGatewayWithShards = "/gateway/bot";
  static const String getGatewayNoShards = "/gateway";
  static String user(String id) => "/users/" + id;
  static String invite(String id) => "/invites/" + id;
  static String channel(String id) => "/channels/$id";
  static String guild(String id) => "/guilds/$id";
  static String guildRoles(String id) => guild(id) + "/roles";
  static String guildRole(String guildId, String roleId) => guildRoles(guildId) + "/$roleId";
  static String guildBans(String id) => guild(id) + "/bans";
  static String guildBan(String guildId, String userId) => guildBans(guildId) + "/$userId";
  static String guildMembers(String guildId) => guild(guildId) + "/members";
  static String guildMember(String guildId, String userId) => guildMembers(guildId) + "/$userId";
  static String currentUserGuilds() => user("@me") + "/guilds";
  static String currentUserChannels() => user("@me") + "/channels";
  static String guildChannels(String id) => guild(id) + "/channels";
  static String currentUserGuild(String guildId) => currentUserGuilds() + "/$guildId";
  static String pruneGuild(String guildId) => guild(guildId) + "/prune";
  static String channelMessages(String channelId) => channel(channelId) + "/messages";
  static String channelMessage(String channelId, String messageId) => channelMessages(channelId) + "/" + messageId;
  static String channelTyping(String id) => DiscordEndpoints.channel(id) + "/typing";
  static String auditLogs(String id) => guild(id) + "/audit-logs";
  static String guildWebhooks(String guildId) => guild(guildId) + '/webhooks';
  static String channelWebhooks(String channelId) => channel(channelId) + '/webhooks';
  static String webhooks() => "/webhooks";
  static String webhook(String id, String token) => webhooks() + "/$id/$token";
}

class CDNEndpoints {
  static String userAvatar(String userId, String avatarFileName, [String format = 'jpg']) => "${Constants.host}/users/${userId}/avatars/${avatarFileName}.${format}";
}

class OAuth2Endpoints {
  static const String oAuth2Base = "/oauth2";
  static const String getCurrentApplication = oAuth2Base + "/applications/@me";
  static String authorize(String clientId, [String scope='bot']) => '/oauth2/authorize?client_id=$clientId&scope=$scope';

  static String authorizeWithPermissions(String clientId, String permissions,
      [String scope = 'bot']) =>
      authorize(clientId, scope) + "&permissions=$permissions";
}

class OpCodes {
  static const int dispatch = 0;
  static const int heartbeat = 1;
  static const int identify = 2;
  static const int statusUpdate = 3;
  static const int voiceStateUpdate = 4;
  static const int voiceGuildPing = 5;
  static const int resume = 6;
  static const int reconnect = 7;
  static const int requestGuildMembers = 8;
  static const int invalidSession = 9;
  static const int hello = 10;
  static const int heartbeatAck = 11;
  static const int guildSync = 12;
}

class VoiceOpCodes {
  static const int identify = 0;
  static const int selectProtocol = 1;
  static const int ready = 2;
  static const int heartbeat = 3;
  static const int sessionDescription = 4;
  static const int speaking = 5;
}

/// The client constants.
class Constants {
  static const String host = "discordapp.com";
  static const String baseUri = "/api/v6";
  static const String clientVersion = "0.1.1";
  static const String library = "dartcord";
  static const String repo = "https://github.com/jacksonrakena/dartcord";

  /// The gateway OP codes.
  static const Map<String, int> opCodes = const <String, int>{
    "DISPATCH": 0,
    "HEARTBEAT": 1,
    "IDENTIFY": 2,
    "STATUS_UPDATE": 3,
    "VOICE_STATE_UPDATE": 4,
    "VOICE_GUILD_PING": 5,
    "RESUME": 6,
    "RECONNECT": 7,
    "REQUEST_GUILD_MEMBERS": 8,
    "INVALID_SESSION": 9,
    "HELLO": 10,
    "HEARTBEAT_ACK": 11,
    "GUILD_SYNC": 12
  };

  /// The gateway OP codes for voice.
  static const Map<String, int> voiceOpCodes = const <String, int>{
    "IDENTIFY": 0,
    "SELECT_PROTOCOL": 1,
    "READY": 2,
    "HEARTBEAT": 3,
    "SESSION_DESCRIPTION": 4,
    "SPEAKING": 5
  };

  /// The permission bits.
  static const Map<String, int> permissions = const <String, int>{
    "CREATE_INSTANT_INVITE": 1 << 0,
    "KICK_MEMBERS": 1 << 1,
    "BAN_MEMBERS": 1 << 2,
    "ADMINISTRATOR": 1 << 3,
    "MANAGE_CHANNELS": 1 << 4,
    "MANAGE_GUILD": 1 << 5,
    "READ_MESSAGES": 1 << 10,
    "SEND_MESSAGES": 1 << 11,
    "SEND_TTS_MESSAGES": 1 << 12,
    "MANAGE_MESSAGES": 1 << 13,
    "EMBED_LINKS": 1 << 14,
    "ATTACH_FILES": 1 << 15,
    "READ_MESSAGE_HISTORY": 1 << 16,
    "MENTION_EVERYONE": 1 << 17,
    "EXTERNAL_EMOJIS": 1 << 18,
    "CONNECT": 1 << 20,
    "SPEAK": 1 << 21,
    "MUTE_MEMBERS": 1 << 22,
    "DEAFEN_MEMBERS": 1 << 23,
    "MOVE_MEMBERS": 1 << 24,
    "USE_VAD": 1 << 25,
    "CHANGE_NICKNAME": 1 << 26,
    "MANAGE_NICKNAMES": 1 << 27,
    "MANAGE_ROLES_OR_PERMISSIONS": 1 << 28,
    "MANAGE_WEBHOOKS": 1 << 29,
    "MANAGE_EMOJIS": 1 << 30
  };
}


class HttpRequest {
  RestClient http;
  Uri uri;
  String method;
  Map<String, String> headers;
  dynamic body;
  Function execute;
  StreamController<w_transport.Response> streamController;
  Stream<w_transport.Response> stream;

  HttpRequest(this.http, this.uri, this.method, this.headers, this.body) {
    this.streamController = new StreamController<w_transport.Response>();
    this.stream = streamController.stream;

    this.execute = () async {
      try {
        if (this.body != null) {
          w_transport.JsonRequest r = new w_transport.JsonRequest()
            ..body = this.body;
          return await r.send(this.method,
              uri: this.uri, headers: this.headers);
        } else {
          return await w_transport.Http
              .send(this.method, this.uri, headers: this.headers);
        }
      } on w_transport.RequestException catch (err) {
        return err.response;
      }
    };
  }
}

class Bucket {
  String url;
  int ratelimitRemaining = 1;
  DateTime ratelimitReset;
  Duration timeDifference;
  List<HttpRequest> requests = <HttpRequest>[];
  bool waiting = false;

  Bucket(this.url);

  Stream<w_transport.Response> push(HttpRequest request) {
    this.requests.add(request);
    this.handle();
    return request.stream;
  }

  void handle() {
    if (this.waiting || this.requests.length == 0) return;
    this.waiting = true;

    this.execute(this.requests[0]);
  }

  void execute(HttpRequest request) {
    if (this.ratelimitRemaining == null || this.ratelimitRemaining > 0) {
      request.execute().then((w_transport.Response r) {
        this.ratelimitRemaining = r.headers['x-ratelimit-remaining'] != null
            ? int.parse(r.headers['x-ratelimit-remaining'])
            : null;
        this.ratelimitReset = r.headers['x-ratelimit-reset'] != null
            ? new DateTime.fromMillisecondsSinceEpoch(
                int.parse(r.headers['x-ratelimit-reset']) * 1000,
                isUtc: true)
            : null;
        try {
          this.timeDifference = new DateTime.now()
              .toUtc()
              .difference(http_parser.parseHttpDate(r.headers['date']).toUtc());
        } catch (err) {
          this.timeDifference = new Duration();
        }

        if (r.status == 429) {
          new Timer(
              new Duration(milliseconds: r.body.asJson()['retry_after'] + 500),
              () => this.execute(request));
        } else {
          this.waiting = false;
          this.requests.remove(request);
          request.streamController.add(r);
          request.streamController.close();
          this.handle();
        }
      });
    } else {
      final Duration waitTime =
          this.ratelimitReset.difference(new DateTime.now().toUtc()) +
              this.timeDifference +
              new Duration(milliseconds: 1000);
      if (waitTime.isNegative) {
        this.ratelimitRemaining = 1;
        this.execute(request);
      } else {
        new Timer(waitTime, () {
          this.ratelimitRemaining = 1;
          this.execute(request);
        });
      }
    }
  }
}

/// Represents a Discord REST adapter.
class RestClient {
  /// The [Client] instance.
  Client client;
  /// The request buckets.
  Map<String, Bucket> buckets = <String, Bucket>{};
  /// The default headers.
  Map<String, String> headers;

  /// Default constructor.
  RestClient([this.client]) {
    this.headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bot ${DiscordConfig.token}',
      'User-Agent':
      '${Constants.library} (${Constants.repo}, ${Constants.clientVersion})'
    };
  }

  /// Sends a REST request using [method] to [path].
  Future<w_transport.Response> send(String method, String path,
      {dynamic body,
      Map<String, String> queryParams,
      bool beforeReady: false,
      Map<String, String> headers: const {}}) async {
    if (!this.client.ready && !beforeReady) throw new ClientNotReadyError();

    Uri uri =
        new Uri.https(Constants.host, Constants.baseUri + path, queryParams);

    if (buckets[uri.toString()] == null)
      buckets[uri.toString()] = new Bucket(uri.toString());

    await for (w_transport.Response r in buckets[uri.toString()].push(
        new HttpRequest(this, uri, method,
            new Map.from(this.headers)..addAll(headers), body))) {
      if (r.status.toString().startsWith("2")) {
        return r;
      } else {
        throw new HttpError._new(r);
      }
    }
    return null;
  }

  Future<w_transport.Response> get(String path, {dynamic body,
    Map<String, String> queryParams,
    bool beforeReady: false,
    Map<String, String> headers: const {}}) {
    return this.send('GET', path, body: body,
        queryParams: queryParams,
        beforeReady: beforeReady,
        headers: headers);
  }
}

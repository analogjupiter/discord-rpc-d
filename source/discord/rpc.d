module discord.rpc;

import core.stdc.inttypes : int8_t, int64_t;
import discord.register;

extern (C):

struct DiscordRichPresence
{
    /++ max 128 bytes +/
    const(char)* state;

    /++ max 128 bytes +/
    const(char)* details;

    int64_t startTimestamp;

    int64_t endTimestamp;

    /++ max 32 bytes +/
    const(char)* largeImageKey;

    /++ max 128 bytes +/
    const(char)* largeImageText;

    /++ max 32 bytes +/
    const(char)* smallImageKey;

    /++ max 128 bytes +/
    const(char)* smallImageText;

    /++ max 128 bytes +/
    const(char)* partyId;

    int partySize;

    int partyMax;

    /++ max 128 bytes +/
    const(char)* matchSecret;

    /++ max 128 bytes +/
    const(char)* joinSecret;

    /++ max 128 bytes +/
    const(char)* spectateSecret;

    int8_t instance;
}

struct DiscordUser
{
    const(char)* userId;
    const(char)* username;
    const(char)* discriminator;
    const(char)* avatar;
}

struct DiscordEventHandlers
{
    private
    {
        alias ReadyCallback = extern (C) void function(const(DiscordUser)* request);
        alias DisconnectedCallback = extern (C) void function(int errorCode, const(char)* message);
        alias ErroredCallback = extern (C) void function(int errorCode, const(char)* message);
        alias JoinGameCallback = extern (C) void function(const(char)* joinSecret);
        alias SpectateGameCallback = extern (C) void function(const(char)* spectateSecret);
        alias JoinRequestCallback = extern (C) void function(const(DiscordUser)* request);
    }

    ReadyCallback ready;
    DisconnectedCallback disconnected;
    ErroredCallback errored;
    JoinGameCallback joinGame;
    SpectateGameCallback spectateGame;
    JoinRequestCallback joinRequest;
}

enum DISCORD_REPLY_NO = 0;
enum DISCORD_REPLY_YES = 1;
enum DISCORD_REPLY_IGNORE = 2;

mixin(DISCORD_EXPORT!("void Discord_Initialize(
    const(char)* applicationId,
    DiscordEventHandlers* handlers,
    int autoRegister,
    const(char)* optionalSteamId)")
);

mixin(DISCORD_EXPORT!("void Discord_Shutdown()"));

/++ checks for incoming messages, dispatches callbacks +/
mixin(DISCORD_EXPORT!("void Discord_RunCallbacks()"));

version (DISCORD_DISABLE_IO_THREAD)
{
    pragma(msg, "[i]\tDISCORD_DISABLE_IO_THREAD");

    /++ If you disable the lib starting its own io thread, you'll need to call this from your own +/
    mixin(DISCORD_EXPORT!("void Discord_UpdateConnection()"));
}

mixin(DISCORD_EXPORT!("void Discord_UpdatePresence(const(DiscordRichPresence)* presence)"));

mixin(DISCORD_EXPORT!("void Discord_ClearPresence()"));

mixin(DISCORD_EXPORT!("void Discord_Respond(const(char)* userid, int reply)"));

mixin(DISCORD_EXPORT!("void Discord_UpdateHandlers(DiscordEventHandlers* handlers)"));

import core.stdc.stdint;
import core.stdc.stdio;
import core.stdc.string;
import core.stdc.time;

import discord.rpc;


immutable const(char)* APPLICATION_ID = "345229890980937739";
__gshared int FrustrationLevel = 0;
__gshared int64_t StartTime;
__gshared int SendPresence = 1;

__gshared int prompt(char* line, size_t size)
{
    int res;
    char* nl;
    printf("\n> ");
    fflush(stdout);
    res = fgets(line, cast(int)(size), stdin) ? 1 : 0;
    line[size - 1] = 0;
    nl = strchr(line, '\n');
    if (nl) {
        *nl = 0;
    }
    return res;
}

__gshared void updateDiscordPresence()
{
    if (SendPresence) {
        __gshared char[256] buffer;
        DiscordRichPresence discordPresence;
        memset(&discordPresence, 0, discordPresence.sizeof);
        discordPresence.state = "West of House";
        sprintf(buffer.ptr, "Frustration level: %d", FrustrationLevel);
        discordPresence.details = buffer.ptr;
        discordPresence.startTimestamp = StartTime;
        discordPresence.endTimestamp = time(null) + 5 * 60;
        discordPresence.largeImageKey = "canary-large";
        discordPresence.smallImageKey = "ptb-small";
        discordPresence.partyId = "party1234";
        discordPresence.partySize = 1;
        discordPresence.partyMax = 6;
        discordPresence.matchSecret = "xyzzy";
        discordPresence.joinSecret = "join";
        discordPresence.spectateSecret = "look";
        discordPresence.instance = 0;
        Discord_UpdatePresence(&discordPresence);
    }
    else {
        Discord_ClearPresence();
    }
}


extern (C) {
    __gshared void handleDiscordReady(const(DiscordUser)* connectedUser)
    {
        printf("\nDiscord: connected to user %s#%s - %s\n",
            connectedUser.username,
            connectedUser.discriminator,
            connectedUser.userId);
    }

    __gshared void handleDiscordDisconnected(int errcode, const(char)* message)
    {
        printf("\nDiscord: disconnected (%d: %s)\n", errcode, message);
    }

    __gshared void handleDiscordError(int errcode, const(char)* message)
    {
        printf("\nDiscord: error (%d: %s)\n", errcode, message);
    }

    __gshared void handleDiscordJoin(const(char)* secret)
    {
        printf("\nDiscord: join (%s)\n", secret);
    }

    __gshared void handleDiscordSpectate(const(char)* secret)
    {
        printf("\nDiscord: spectate (%s)\n", secret);
    }

    __gshared void handleDiscordJoinRequest(const(DiscordUser)* request)
    {
        int response = -1;
        char[4] yn;
        printf("\nDiscord: join request from %s#%s - %s\n",
            request.username,
            request.discriminator,
            request.userId);
        do {
            printf("Accept? (y/n)");
            if (!prompt(yn.ptr, yn.sizeof)) {
                break;
            }

            if (!yn[0]) {
                continue;
            }

            if (yn[0] == 'y') {
                response = DISCORD_REPLY_YES;
                break;
            }

            if (yn[0] == 'n') {
                response = DISCORD_REPLY_NO;
                break;
            }
        } while (1);
        if (response != -1) {
            Discord_Respond(request.userId, response);
        }
    }
}

__gshared void discordInit()
{
    DiscordEventHandlers handlers;
    memset(&handlers, 0, handlers.sizeof);
    handlers.ready = &handleDiscordReady;
    handlers.disconnected = &handleDiscordDisconnected;
    handlers.errored = &handleDiscordError;
    handlers.joinGame = &handleDiscordJoin;
    handlers.spectateGame = &handleDiscordSpectate;
    handlers.joinRequest = &handleDiscordJoinRequest;
    Discord_Initialize(APPLICATION_ID, &handlers, 1, null);
}

__gshared void gameLoop()
{
    char[512] line;
    char* space;

    StartTime = time(null);

    printf("You are standing in an open field west of a white house.\n");
    while (prompt(line.ptr, line.sizeof)) {
        if (line[0]) {
            if (line[0] == 'q') {
                break;
            }

            if (line[0] == 't') {
                printf("Shutting off Discord.\n");
                Discord_Shutdown();
                continue;
            }

            if (line[0] == 'c') {
                if (SendPresence) {
                    printf("Clearing presence information.\n");
                    SendPresence = 0;
                }
                else {
                    printf("Restoring presence information.\n");
                    SendPresence = 1;
                }
                updateDiscordPresence();
                continue;
            }

            if (line[0] == 'y') {
                printf("Reinit Discord.\n");
                discordInit();
                continue;
            }

            if (time(null) & 1) {
                printf("I don't understand that.\n");
            }
            else {
                space = strchr(line.ptr, ' ');
                if (space) {
                    *space = 0;
                }
                printf("I don't know the word \"%s\".\n", line.ptr);
            }

            ++FrustrationLevel;

            updateDiscordPresence();
        }

version(DISCORD_DISABLE_IO_THREAD)
{
        Discord_UpdateConnection();
}
        Discord_RunCallbacks();
    }
}

int main()
{
    discordInit();

    gameLoop();

    Discord_Shutdown();
    return 0;
}

# Discord RPC D

A static binding to 🎮 Discord RPC.

Please note that *Discord RPC* is licensed under the terms of the [MIT license](LICENSE.LIBRARY.txt).


## Usage

First, get a copy of *Discord RPC*.

In order to link against `libdiscord-rpc`, add it to your `dub.json`.
```json
"libs": [ "discord-rpc" ]
```

Now you can use *Discord RPC* in your code:
```d
import discord.rpc;

void main()
{
    DiscordEventHandlers handlers;
    // ...

    Discord_Initialize(APPLICATION_ID, &handlers, 1, null);
}
```


## Links

- **Discord RPC - SDK**<br/>https://github.com/discordapp/discord-rpc
- **Pre-built binaries for *Discord RPC***<br/>https://github.com/discordapp/discord-rpc/releases

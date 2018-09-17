module discord.register;

extern (C):

package template DISCORD_EXPORT(string f)
{
    version (Windows)
    {
        enum pre = "export extern (C) ";
    }
    else
    {
        enum pre = "extern (C) ";
    }

    const(char[]) DISCORD_EXPORT = pre ~ f ~ ";";
}

mixin(DISCORD_EXPORT!("void Discord_Register(const(char)* applicationId, const(char)* command)"));

mixin(DISCORD_EXPORT!("void Discord_RegisterSteamGame(const(char)* applicationId, const(char)* steamId)"));

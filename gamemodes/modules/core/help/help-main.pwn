/**
 *           __             __
 *          |  \           |  |
 *      ____| $$  ______  _| $$_     ______
 *     /      $$ |      \|   $$ \   |      |
 *    |  $$$$$$$  \$$$$$$\\$$$$$$    \$$$$$$|
 *    | $$  | $$ /      $$ | $$ __  /      $$
 *    | $$__| $$|  $$$$$$$ | $$|  \|  $$$$$$$
 *     \$$    $$ \$$    $$  \$$  $$ \$$    $$
 *      \$$$$$$$  \$$$$$$$   \$$$$   \$$$$$$$
 *
 */
forward Help_Deferred(playerid,token,kind);

enum
{
    HELP_MENU,
    HELP_RULES
}

/**
 *      ______                                   __      __
 *     /      \                                 |  \    |  |
 *    |  $$$$$$\ __    __  _______    _______  _| $$_    \$$  ______   _______    _______
 *    | $$_  \$$|  \  |  \|       \  /       \|   $$ \  |  \ /      \ |       \  /       |
 *    | $$ \    | $$  | $$| $$$$$$$\|  $$$$$$$ \$$$$$$  | $$|  $$$$$$\| $$$$$$$\|  $$$$$$$
 *    | $$$$    | $$  | $$| $$  | $$| $$        | $$ __ | $$| $$  | $$| $$  | $$ \$$    |
 *    | $$      | $$__/ $$| $$  | $$| $$_____   | $$|  \| $$| $$__/ $$| $$  | $$ _\$$$$$$|
 *    | $$       \$$    $$| $$  | $$ \$$     \   \$$  $$| $$ \$$    $$| $$  | $$|       $$
 *     \$$        \$$$$$$  \$$   \$$  \$$$$$$$    \$$$$  \$$  \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
static Help_Commands(playerid)
{
    SendClientMessage(playerid,COLOR_TAB0,"|________________________| List of commands available to you |________________________|");
    SendClientMessage(playerid,COLOR_TAB1,"[GENERAL]:{DEDEDE} /spawn, /report, /ask, /id, /staff, /afklist, /animlist, /resyncambient, /safezone, /badge, /editmask");
    SendClientMessage(playerid,COLOR_TAB2,"[GENERAL]:{DEDEDE} /accept, /shakehand, /clearchat, /accent, /coin, /checktime, /roll, /frisk, /pay, /bank, /paycheck");
    SendClientMessage(playerid,COLOR_TAB1,"[GENERAL]:{DEDEDE} /ad(vertise), /setchat, /attributes, /examine, /charity, /servertime, /showinjuries, /namechange, /blockpm");
    SendClientMessage(playerid,COLOR_TAB2,"[GENERAL]:{DEDEDE} /checkjobcooldown (/cooldown), /resyncmask, /resynchorse, /nohorsesound, /gunpos, /licenses, /drink");
    SendClientMessage(playerid,COLOR_TAB2,"[GENERAL]:{DEDEDE} /prisontimeleft, /bail, /fixjob, /helpup, /transport, /reloadattachments");
    SendClientMessage(playerid,COLOR_TAB2,"[GENERAL]:{DEDEDE} /mypoints, /rentroom, /adminrecord, /streamdis, /attachments, /createdynamiclabel");
    SendClientMessage(playerid,COLOR_TAB1,"[MISC]:{DEDEDE} /ac, /accentlist, /acchelp, /bountyhelp, /chathelp, /gunhelp, /horsehelp, /point, /samphelp, /possehelp, /possechat");

    if (Staff_IsStaff(playerid))
    {
        SendClientMessage(playerid,COLOR_STAFF,"[STAFF]:{DEDEDE} /staffhelp");
    }
}

static Help_Faq(playerid)
{
    SendSplitMessage(playerid,COLOR_TAB0,"|________________________| Frequently Asked Questions (FAQ) |________________________|");
    SendSplitMessage(playerid,COLOR_TAB1,"1.{DEDEDE} Where do I start?");
    SendSplitMessage(playerid,COLOR_TAB2,"- We recommend starting by buying a fishing pole from a hunting store and finding any body of water to fish. Once you decide to sell your fish, go to a hunting store to sell what you've caught.");
    SendSplitMessage(playerid,COLOR_TAB1,"2.{DEDEDE} How do I get a horse?");
    SendSplitMessage(playerid,COLOR_TAB2,"- Go to a stablemaster either in Longcreek or Fremont, then type /buy.");
    SendSplitMessage(playerid,COLOR_TAB1,"3.{DEDEDE} How do I level up a skill?");
    SendSplitMessage(playerid,COLOR_TAB2,"- /levelup [skill name]");
    SendSplitMessage(playerid,COLOR_TAB1,"4.{DEDEDE} How do I enter a building?");
    SendSplitMessage(playerid,COLOR_TAB2,"- Press H (or to whichever key you've bound to \"Group Control Backwards\").");
    SendSplitMessage(playerid,COLOR_TAB0,"");
    SendSplitMessage(playerid,0xDEDEDEFF,"If you have any questions that aren't here, feel free to use /ask or check on the forums for guides to refer to!");
}

static Help_Flow(playerid,token,kind)
{
    yield 1;
    new response[DIALOG_RESPONSE];

    if (kind == HELP_RULES)
    {
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"Wild West Roleplay - Rules","1. You must roleplay at all times unless given an OOC tag.\n2. No advertisment of other SA-MP communties.\n3. No 3rd party mods that could give you or a group an advantage over others.\n4. No metagaming, powergaming, deathmatching and revenge killing.\n5. Do not abuse any server bugs or client exploits.\n6. You cannot commit crimes in safezones unless certain conditions are met. (see forums)\n7. Sexual or otherwise explicit roleplay shouldn't be done in public and requires permission from both parties.\n8. You cannot rob more than $60 off of someone or scam $1,500 out of someone. Both parties involved must be level 5+.\n9. When roleplaying your character, you must roleplay in line with the time period (see forums).\n\nFor more detail and understanding of the rules, please view them on the forums.","Exit","");
        return;
    }

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Help - Select a Category","Commands\nFrequently Asked Questions","Select","Exit");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
    {
        return;
    }

    if (response[DIALOG_RESPONSE_LISTITEM] == 0)
    {
        Help_Commands(playerid);
    }
    else
    {
        Help_Faq(playerid);
    }
}

public Help_Deferred(playerid,token,kind)
{
    Help_Flow(playerid,token,kind);
    return 1;
}

/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD:help(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SetTimerEx("Help_Deferred",0,false,"ddd",playerid,Account_GetToken(playerid),HELP_MENU);
    return 1;
}

CMD:rules(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SetTimerEx("Help_Deferred",0,false,"ddd",playerid,Account_GetToken(playerid),HELP_RULES);
    return 1;
}

CMD:gunhelp(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_TAB0,"|________________________| Weapon Help |________________________|");
    SendClientMessage(playerid,COLOR_TAB1,"(/guns): /holstered:{DEDEDE} Displays all your weapons, their slot, and their ammo.");
    SendClientMessage(playerid,COLOR_TAB2,"(/gh, /guh): /holster, /unholster:{DEDEDE} (Un)Holsters your weapon in the specified slot");
    SendClientMessage(playerid,COLOR_TAB1,"(/sgun): /switchgun:{DEDEDE} Switches your equipped weapon with a holstered one.");
    SendClientMessage(playerid,COLOR_TAB2,"(/dgun, /pgun): /dropgun, /pickupgun:{DEDEDE} Drops or picks up a dropped weapon");
    SendClientMessage(playerid,COLOR_TAB2,"/ammocrate:{DEDEDE} Use a ammo crate to refill your equipped weapon with ammo.");
    SendClientMessage(playerid,COLOR_TAB2,"/passgun:{DEDEDE} Passes your gun to someone else.");
    SendClientMessage(playerid,COLOR_TAB2,"/gunpos:{DEDEDE} Alter your holster positions [doesn't save].");
    return 1;
}

CMD:samphelp(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_TAB0,"|________________________| SA-MP Command Help |________________________|");
    SendClientMessage(playerid,COLOR_TAB1,"Note: there are more commands, this list just shows commands useful to you. For a full list go to {DEDEDE}http://wiki.sa-mp.com/wiki/Client_Commands");
    SendClientMessage(playerid,COLOR_TAB2,"/timestamp:{DEDEDE} Shows a HH/MM/SS timestamp infront of every client message");
    SendClientMessage(playerid,COLOR_TAB1,"/headmove:{DEDEDE} Disables head movement for every player (useful for screenshots)");
    SendClientMessage(playerid,COLOR_TAB2,"/pagesize:{DEDEDE} Increases the displayed server messages (useful for high resolutions) ");
    SendClientMessage(playerid,COLOR_TAB1,"/fpslimit:{DEDEDE} Limits your FPS. Should be kept at 60 for best stability and performance.");
    SendClientMessage(playerid,COLOR_TAB2,"/audiomsg:{DEDEDE} Disables the green audio messages whenever the server plays a sound file.");
    SendClientMessage(playerid,COLOR_TAB1,"/fontsize:{DEDEDE} Increases the font size of server messages (useful for high resolutions)");
    return 1;
}

CMD:acchelp(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_TAB0,"|________________________| Account Help |________________________|");
    SendClientMessage(playerid,COLOR_TAB1,"/selectcharacter:{DEDEDE} allows you to select a character in the selection menu.");
    SendClientMessage(playerid,COLOR_TAB1,"/logout:{DEDEDE} allows you to go to the login screen, after permission is given.");
    SendClientMessage(playerid,COLOR_TAB2,"/relog:{DEDEDE} usable at the login screen or character selection to fix issues.");
    SendClientMessage(playerid,COLOR_TAB1,"/statistics, /stats:{DEDEDE} displays your spawned character's statistics.");
    return 1;
}

CMD:chathelp(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_TAB0,"|________________________| Chat Help |________________________|");
    SendClientMessage(playerid,COLOR_TAB1,"/me(low), /my(low), /do(low):{DEDEDE} allows your character to perform a roleplaying action");
    SendClientMessage(playerid,COLOR_TAB2,"/s(hout), /low:{DEDEDE} allows your character to say something specifically");
    SendClientMessage(playerid,COLOR_TAB2,"/w(hisper):{DEDEDE} allows you to communicate privately to someone ICly");
    SendClientMessage(playerid,COLOR_TAB2,"/b, /o(oc), /pm:{DEDEDE} allows you to communicate Out of Characterly");
    SendClientMessage(playerid,COLOR_TAB1,"/ame, /ado:{DEDEDE} allows your character to perform a roleplaying action, but doesn't send a local message.");
    SendClientMessage(playerid,COLOR_TAB2,"** /ame or /ado does not send a local message, but instead show the action above your character's head.");
    return 1;
}

CMD:bountyhelp(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SendClientMessage(playerid,COLOR_TAB0,"|________________________| Bounty Help |________________________|");
    SendClientMessage(playerid,COLOR_TAB1,"/takebounty:{DEDEDE} allows you to take a bounty if you're near a poster. Use optional parameter to specify the poster id.");
    SendClientMessage(playerid,COLOR_TAB2,"/abandonbounty:{DEDEDE} allows you to abandon your current bounty.");
    SendClientMessage(playerid,COLOR_TAB1,"/pickbounty:{DEDEDE} allows you to pick up a bounty you killed.");
    SendClientMessage(playerid,COLOR_TAB2,"/claimbounty:{DEDEDE} allows you to claim your reward for the bounty.");
    return 1;
}

CMD:clearchat(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    for (new i = 0;i < 20;i++)
    {
        SendClientMessage(playerid,-1," ");
    }

    return 1;
}

CMD:id(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new line[144];

    if (!isnull(params) && params[0] >= '0' && params[0] <= '9')
    {
        new target = strval(params);

        if (!IsPlayerConnected(target))
        {
            SendClientMessage(playerid,COLOR_TAB2,"Player doesn't seem to exist.");
            return 1;
        }

        new name[MAX_PLAYER_NAME + 1];
        GetPlayerName(target,name,sizeof(name));
        format(line,sizeof(line),"[Search results for '%s']",params);
        SendClientMessage(playerid,COLOR_TAB0,line);
        format(line,sizeof(line),"%s (ID:%d)",name,target);
        SendClientMessage(playerid,COLOR_TAB1,line);
        return 1;
    }

    if (strlen(params) < 3)
    {
        SendServerMessage(playerid,"/id [name] - enter at least 3 characters",MSG_TYPE_ERROR);
        return 1;
    }

    new count = 0;
    format(line,sizeof(line),"[Search results for '%s']",params);
    SendClientMessage(playerid,COLOR_TAB0,line);

    foreach (new i : Player)
    {
        new name[MAX_PLAYER_NAME + 1];
        GetPlayerName(i,name,sizeof(name));

        if (strfind(name,params,true) != -1)
        {
            count++;
            format(line,sizeof(line),"%d. %s (ID:%d)",count,name,i);
            SendClientMessage(playerid,COLOR_TAB1,line);
        }
    }

    if (count == 0)
    {
        SendClientMessage(playerid,COLOR_TAB2,"Player doesn't seem to exist.");
    }

    return 1;
}

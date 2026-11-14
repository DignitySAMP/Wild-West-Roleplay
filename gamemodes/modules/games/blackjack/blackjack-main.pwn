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
#define BJ_BET_MIN (1)
#define BJ_BET_MAX (10000)
#define BJ_RANGE (2.0)
#define BJ_REQUEST_MS (30000)
#define BJ_TICK_MS (1000)
#define BJ_SLOTS (5)
#define BJ_HAND_MAX (14)
#define BJ_TARGET (21)
#define BJ_NONE (-1)
#define BJ_ROLE_NONE (0)
#define BJ_ROLE_HOUSE (1)
#define BJ_ROLE_GUEST (2)
#define BJ_TD_STATIC (6)
#define BJ_TD_ROW (6)

static const g_BjValue[14] = {0,11,2,3,4,5,6,7,8,9,10,10,10,10};

static Text:s_BjStatic[BJ_TD_STATIC];
static PlayerText:s_BjHouse[MAX_PLAYERS][BJ_TD_ROW];
static PlayerText:s_BjGuest[MAX_PLAYERS][BJ_TD_ROW];

static s_BjFrom[MAX_PLAYERS];
static s_BjInvite[MAX_PLAYERS];
static s_BjRequestBet[MAX_PLAYERS];
static s_BjDue[MAX_PLAYERS];
static s_BjRole[MAX_PLAYERS];
static s_BjOpponent[MAX_PLAYERS];
static s_BjBet[MAX_PLAYERS];
static bool:s_BjTurn[MAX_PLAYERS];
static s_BjHand[MAX_PLAYERS][BJ_HAND_MAX];
static s_BjCount[MAX_PLAYERS];
static s_BjDeck[MAX_PLAYERS][DECK_SIZE];
static s_BjDeckPos[MAX_PLAYERS];

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
static PlayerText:Bj_PlayerTd(playerid,Float:x,Float:y,const text[],font,Float:tx,Float:ty)
{
    new PlayerText:id = CreatePlayerTextDraw(playerid,x,y,text);
    PlayerTextDrawFont(playerid,id,TEXT_DRAW_FONT:font);
    PlayerTextDrawLetterSize(playerid,id,0.25,1.0);
    PlayerTextDrawAlignment(playerid,id,TEXT_DRAW_ALIGN_CENTER);
    PlayerTextDrawColor(playerid,id,font == 4 ? -1 : -780181761);
    PlayerTextDrawSetShadow(playerid,id,0);
    PlayerTextDrawSetOutline(playerid,id,1);
    PlayerTextDrawBackgroundColor(playerid,id,255);
    PlayerTextDrawSetProportional(playerid,id,true);
    PlayerTextDrawTextSize(playerid,id,tx,ty);
    return id;
}

static Text:Bj_StaticTd(Float:x,Float:y,const text[],Float:letterY,bool:box,boxColour,Float:tx,Float:ty)
{
    new Text:id = TextDrawCreate(x,y,text);
    TextDrawFont(id,TEXT_DRAW_FONT_2);
    TextDrawLetterSize(id,0.25,letterY);
    TextDrawAlignment(id,TEXT_DRAW_ALIGN_CENTER);
    TextDrawColor(id,box ? -1523963137 : -780181761);
    TextDrawSetShadow(id,0);
    TextDrawSetOutline(id,1);
    TextDrawBackgroundColor(id,255);
    TextDrawSetProportional(id,true);

    if (box)
    {
        TextDrawUseBox(id,true);
        TextDrawBoxColor(id,boxColour);
    }

    TextDrawTextSize(id,tx,ty);
    return id;
}

static Bj_BuildStatic()
{
    s_BjStatic[0] = Bj_StaticTd(323.5,138.0,"(( Use /blackjack to play ))",1.0,false,0,0.0,500.0);
    s_BjStatic[1] = Bj_StaticTd(322.5,149.5,"_",19.0,true,-780181761,25.0,160.0);
    s_BjStatic[2] = Bj_StaticTd(322.5,151.5,"_",18.6,true,286331391,440.0,157.0);
    s_BjStatic[3] = Bj_StaticTd(322.5,174.0,"_",4.5,true,858993578,0.0,150.0);
    s_BjStatic[4] = Bj_StaticTd(322.5,251.5,"_",4.5,true,858993578,0.0,150.0);
    s_BjStatic[5] = Bj_StaticTd(323.0,156.0,"Blackjack:~w~ One~r~ versus~w~ One",1.0,false,0,0.0,500.0);
}

static Bj_BuildPlayer(playerid)
{
    new Float:x = 250.0, text[CARD_SPRITE_LEN];
    Card_BackSprite(text);

    for (new i = 0;i < BJ_SLOTS;i++)
    {
        s_BjHouse[playerid][i] = Bj_PlayerTd(playerid,x,177.0,text,4,25.0,35.0);
        s_BjGuest[playerid][i] = Bj_PlayerTd(playerid,x,254.5,text,4,25.0,35.0);
        x += 30.0;
    }

    s_BjHouse[playerid][5] = Bj_PlayerTd(playerid,323.0,220.5,"_",2,0.0,500.0);
    s_BjGuest[playerid][5] = Bj_PlayerTd(playerid,323.0,298.5," ",2,0.0,500.0);
}

static Bj_DestroyPlayer(playerid)
{
    for (new i = 0;i < BJ_TD_ROW;i++)
    {
        if (s_BjHouse[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid,s_BjHouse[playerid][i]);
            s_BjHouse[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }

        if (s_BjGuest[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid,s_BjGuest[playerid][i]);
            s_BjGuest[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }
}

stock Bj_CardPoints(card)
{
    return g_BjValue[Card_Value(card)];
}

stock Bj_HandTotal(playerid)
{
    new total, aces;

    for (new i = 0;i < s_BjCount[playerid];i++)
    {
        total += Bj_CardPoints(s_BjHand[playerid][i]);

        if (Card_Value(s_BjHand[playerid][i]) == 1)
        {
            aces++;
        }
    }

    while (total > BJ_TARGET && aces > 0)
    {
        total -= 10;
        aces--;
    }

    return total;
}

stock bool:Bj_IsPlaying(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_BjRole[playerid] != BJ_ROLE_NONE;
}

stock Bj_GetOpponent(playerid)
{
    return Bj_IsPlaying(playerid) ? s_BjOpponent[playerid] : BJ_NONE;
}

stock Bj_GetRequestFrom(playerid)
{
    return s_BjFrom[playerid];
}

stock bool:Bj_IsHouse(playerid)
{
    return Bj_IsPlaying(playerid) && s_BjRole[playerid] == BJ_ROLE_HOUSE;
}

stock bool:Bj_HasTurn(playerid)
{
    return Bj_IsPlaying(playerid) && s_BjTurn[playerid];
}

stock Bj_GetBet(playerid)
{
    return s_BjBet[playerid];
}

stock Bj_GetCards(playerid)
{
    return s_BjCount[playerid];
}

static Bj_ShowTds(playerid)
{
    Bj_DestroyPlayer(playerid);
    Bj_BuildPlayer(playerid);

    for (new i = 0;i < BJ_TD_STATIC;i++)
    {
        TextDrawShowForPlayer(playerid,s_BjStatic[i]);
    }

    for (new i = 0;i < BJ_TD_ROW;i++)
    {
        PlayerTextDrawShow(playerid,s_BjHouse[playerid][i]);
        PlayerTextDrawShow(playerid,s_BjGuest[playerid][i]);
    }
}

static Bj_HideTds(playerid)
{
    for (new i = 0;i < BJ_TD_STATIC;i++)
    {
        TextDrawHideForPlayer(playerid,s_BjStatic[i]);
    }

    Bj_DestroyPlayer(playerid);
}

static Bj_Refresh(house)
{
    new guest = s_BjOpponent[house], sprite[CARD_SPRITE_LEN], back[CARD_SPRITE_LEN], text[96], houseName[ACCOUNT_NAME_LEN], guestName[ACCOUNT_NAME_LEN];
    Card_BackSprite(back);
    Name_Display(house,houseName);
    Name_Display(guest,guestName);
    new viewers[2];
    viewers[0] = house;
    viewers[1] = guest;

    for (new v = 0;v < 2;v++)
    {
        new viewer = viewers[v];

        for (new slot = 0;slot < BJ_SLOTS;slot++)
        {
            strcopy(sprite,back);

            for (new k = slot;k < s_BjCount[house];k += BJ_SLOTS)
            {
                Card_Sprite(s_BjHand[house][k],sprite);
            }

            PlayerTextDrawSetString(viewer,s_BjHouse[viewer][slot],sprite);
            strcopy(sprite,back);

            for (new k = slot;k < s_BjCount[guest];k += BJ_SLOTS)
            {
                Card_Sprite(s_BjHand[guest][k],sprite);
            }

            PlayerTextDrawSetString(viewer,s_BjGuest[viewer][slot],sprite);
        }

        format(text,sizeof(text),"(%d) %s~n~~r~(House):~w~ %d points total",house,houseName,Bj_HandTotal(house));
        PlayerTextDrawSetString(viewer,s_BjHouse[viewer][5],text);
        format(text,sizeof(text),"(%d) %s~n~~r~(Guest):~w~ %d points total",guest,guestName,Bj_HandTotal(guest));
        PlayerTextDrawSetString(viewer,s_BjGuest[viewer][5],text);
    }
}

static Bj_ClearGame(playerid)
{
    s_BjRole[playerid] = BJ_ROLE_NONE;
    s_BjOpponent[playerid] = BJ_NONE;
    s_BjBet[playerid] = 0;
    s_BjTurn[playerid] = false;
    s_BjCount[playerid] = 0;
    s_BjDeckPos[playerid] = 0;
}

static Bj_ClearRequest(playerid)
{
    new inviter = s_BjFrom[playerid];

    if (inviter != BJ_NONE && s_BjInvite[inviter] == playerid)
    {
        s_BjInvite[inviter] = BJ_NONE;
    }

    s_BjFrom[playerid] = BJ_NONE;
    s_BjRequestBet[playerid] = 0;
    s_BjDue[playerid] = 0;
}

static Bj_DropInvite(inviter)
{
    new target = s_BjInvite[inviter];

    if (target != BJ_NONE && s_BjFrom[target] == inviter)
    {
        s_BjFrom[target] = BJ_NONE;
        s_BjRequestBet[target] = 0;
        s_BjDue[target] = 0;
    }

    s_BjInvite[inviter] = BJ_NONE;
}

static Bj_Isolate(playerid)
{
    Bj_DropInvite(playerid);
    Bj_ClearRequest(playerid);
}

static Bj_Finish(house,guest)
{
    Bj_HideTds(house);
    Bj_HideTds(guest);
    Bj_ClearGame(house);
    Bj_ClearGame(guest);
}

static Bj_Pay(playerid,cents)
{
    if (IsPlayerConnected(playerid))
    {
        Money_Give(playerid,cents);
    }
}

static Bj_Win(winner,loser,house,guest)
{
    new bet = s_BjBet[house], winnerName[MAX_PLAYER_NAME], loserName[MAX_PLAYER_NAME];
    GetPlayerName(winner,winnerName,sizeof(winnerName));
    GetPlayerName(loser,loserName,sizeof(loserName));
    Bj_Pay(winner,Money_Make(bet) * 2);
    Log_Info("games/blackjack","%s won $%d from %s",winnerName,bet,loserName);
    Bj_Finish(house,guest);
}

static Bj_Tie(house,guest)
{
    new cents = Money_Make(s_BjBet[house]);
    Bj_Pay(house,cents);
    Bj_Pay(guest,cents);
    Bj_Finish(house,guest);
}

static Bj_Abandon(leaver,bool:quit)
{
    if (!Bj_IsPlaying(leaver))
    {
        return;
    }

    new other = s_BjOpponent[leaver], house = s_BjRole[leaver] == BJ_ROLE_HOUSE ? leaver : other, guest = s_BjRole[leaver] == BJ_ROLE_HOUSE ? other : leaver;

    if (quit)
    {
        SendServerMessage(other,"Your opponent has quit the server, you won.",MSG_TYPE_INFO);
    }
    else
    {
        SendServerMessage(other,"Your opponent has abandoned the game, you won.",MSG_TYPE_INFO);
        SendServerMessage(leaver,"You abandoned the game, thus you lost.",MSG_TYPE_INFO);
    }

    Bj_Win(other,leaver,house,guest);
}

static Bj_LeaveReasonText(reason,dest[],size = sizeof(dest))
{
    switch (reason)
    {
        case 0:
        {
            strcopy(dest,"timeout or crash",size);
        }
        case 1:
        {
            strcopy(dest,"quit",size);
        }
        case 2:
        {
            strcopy(dest,"kick or ban",size);
        }
        default:
        {
            strcopy(dest,"logout or character switch",size);
        }
    }
}

stock Bj_SettleLeave(leaver,reason)
{
    if (!Bj_IsPlaying(leaver))
    {
        return 0;
    }

    new other = s_BjOpponent[leaver], house = s_BjRole[leaver] == BJ_ROLE_HOUSE ? leaver : other, guest = s_BjRole[leaver] == BJ_ROLE_HOUSE ? other : leaver;
    new bet = s_BjBet[house], mine = Bj_HandTotal(leaver), theirs = Bj_HandTotal(other), bool:turn = s_BjTurn[leaver];
    new leaverName[MAX_PLAYER_NAME], otherName[MAX_PLAYER_NAME], why[32], line[200];
    GetPlayerName(leaver,leaverName,sizeof(leaverName));
    GetPlayerName(other,otherName,sizeof(otherName));
    Bj_LeaveReasonText(reason,why);

    if (reason == 0 || reason == 2)
    {
        Log_Info("games/blackjack","%s left a game against %s (%s, bet $%d, totals %d to %d, %s turn): both bets refunded",leaverName,otherName,why,bet,mine,theirs,turn ? "their own" : "the opponent's");

        if (mine < theirs)
        {
            format(line,sizeof(line),"[BLACKJACK] %s (%d) left a game against %s (%d) while behind %d to %d (%s); both $%d bets were refunded.",leaverName,leaver,otherName,other,mine,theirs,why,bet);
            SendModeratorWarning(line,MOD_WARNING_LOW);
        }

        SendServerMessage(other,"Your opponent has quit the server. You've both been refunded your bet.",MSG_TYPE_INFO);
        Bj_Tie(house,guest);
        return 1;
    }

    Log_Info("games/blackjack","%s left a game against %s (%s, bet $%d, totals %d to %d, %s turn): %s wins both bets",leaverName,otherName,why,bet,mine,theirs,turn ? "their own" : "the opponent's",otherName);
    SendServerMessage(other,"Your opponent has quit the server, you won.",MSG_TYPE_INFO);
    Bj_Win(other,leaver,house,guest);
    return 1;
}

static Bj_Draw(house)
{
    if (s_BjDeckPos[house] >= DECK_SIZE)
    {
        Deck_Shuffle(s_BjDeck[house]);
        s_BjDeckPos[house] = 0;
    }

    return s_BjDeck[house][s_BjDeckPos[house]++];
}

static Bj_PassTurn(house,guest,bool:toHouse)
{
    s_BjTurn[house] = toHouse;
    s_BjTurn[guest] = !toHouse;
}

static Bj_Call(playerid)
{
    if (!Bj_IsPlaying(playerid))
    {
        SendServerMessage(playerid,"You're not playing blackjack.",MSG_TYPE_ERROR);
        return;
    }

    if (!s_BjTurn[playerid])
    {
        SendServerMessage(playerid,"It is not your turn.",MSG_TYPE_ERROR);
        return;
    }

    new other = s_BjOpponent[playerid], bool:isHouse = s_BjRole[playerid] == BJ_ROLE_HOUSE, house = isHouse ? playerid : other, guest = isHouse ? other : playerid;
    new card = Bj_Draw(house), name[CARD_NAME_LEN], line[128];
    s_BjHand[playerid][s_BjCount[playerid]++] = card;
    Card_Name(card,name);
    format(line,sizeof(line),"You've been dealt a \"%s\", containing %d points.",name,Bj_CardPoints(card));
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"Opponent has been dealt a \"%s\", containing %d points.",name,Bj_CardPoints(card));
    SendServerMessage(other,line,MSG_TYPE_INFO);
    Bj_Refresh(house);
    new total = Bj_HandTotal(playerid);

    if (isHouse)
    {
        new guestTotal = Bj_HandTotal(guest);

        if (total > BJ_TARGET)
        {
            format(line,sizeof(line),"You busted with a total score of %d, your opponent has won.",total);
            SendServerMessage(playerid,line,MSG_TYPE_INFO);
            format(line,sizeof(line),"Your opponent has busted with a total score of %d, you've won.",total);
            SendServerMessage(guest,line,MSG_TYPE_INFO);
            Bj_Win(guest,house,house,guest);
            return;
        }

        if (total == guestTotal)
        {
            format(line,sizeof(line),"You made the same score as your opponent: %d.",total);
            SendServerMessage(playerid,line,MSG_TYPE_INFO);
            format(line,sizeof(line),"Your opponent has made the same score as you: %d.",guestTotal);
            SendServerMessage(guest,line,MSG_TYPE_INFO);
            Bj_Tie(house,guest);
            return;
        }

        if (total > guestTotal)
        {
            format(line,sizeof(line),"You have exceeded your opponent's score (%d), you win.",guestTotal);
            SendServerMessage(playerid,line,MSG_TYPE_INFO);
            format(line,sizeof(line),"Your opponent has passed your score (%d), you've lost.",total);
            SendServerMessage(guest,line,MSG_TYPE_INFO);
            Bj_Win(house,guest,house,guest);
        }

        return;
    }

    if (total > BJ_TARGET)
    {
        format(line,sizeof(line),"You bust (%d), your opponent has won.",total);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        format(line,sizeof(line),"Your opponent bust (%d), you won!",total);
        SendServerMessage(house,line,MSG_TYPE_INFO);
        Bj_Win(house,guest,house,guest);
        return;
    }

    if (total == BJ_TARGET)
    {
        Bj_PassTurn(house,guest,true);
        SendServerMessage(playerid,"You have made 21! Now it's your opponent's turn.",MSG_TYPE_INFO);
        SendServerMessage(house,"Your opponent has made 21! Now it's your turn.",MSG_TYPE_INFO);
    }
}

static Bj_Stand(playerid)
{
    if (!Bj_IsPlaying(playerid))
    {
        SendServerMessage(playerid,"You're not playing blackjack.",MSG_TYPE_ERROR);
        return;
    }

    if (s_BjRole[playerid] == BJ_ROLE_HOUSE)
    {
        SendServerMessage(playerid,"You can't stand being on the tour.",MSG_TYPE_ERROR);
        return;
    }

    if (!s_BjTurn[playerid])
    {
        SendServerMessage(playerid,"It is not your turn.",MSG_TYPE_ERROR);
        return;
    }

    if (s_BjCount[playerid] == 0)
    {
        SendServerMessage(playerid,"You can not be if you have not called not even a card.",MSG_TYPE_ERROR);
        return;
    }

    new house = s_BjOpponent[playerid];
    SendServerMessage(house,"Your opponent moved, your turn.",MSG_TYPE_ERROR);
    SendServerMessage(playerid,"You moved, it's your opponent's turn.",MSG_TYPE_ERROR);
    Bj_PassTurn(house,playerid,true);
}

static bool:Bj_Near(playerid,other)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(other,x,y,z);
    return IsPlayerInRangeOfPoint(playerid,BJ_RANGE,x,y,z) && GetPlayerInterior(playerid) == GetPlayerInterior(other) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(other);
}

static Bj_Accept(playerid)
{
    new starter = s_BjFrom[playerid];

    if (Bj_IsPlaying(playerid))
    {
        SendServerMessage(playerid,"You're already playing blackjack.",MSG_TYPE_ERROR);
        return;
    }

    if (starter == BJ_NONE)
    {
        SendServerMessage(playerid,"You don't have a pending game request.",MSG_TYPE_ERROR);
        return;
    }

    new bet = s_BjRequestBet[playerid];

    if (!IsPlayerConnected(starter) || Bj_IsPlaying(starter) || !Player_IsFree(starter) || !Player_IsFree(playerid))
    {
        Bj_ClearRequest(playerid);
        SendServerMessage(playerid,"The blackjack request is no longer valid.",MSG_TYPE_ERROR);
        return;
    }

    if (!Bj_Near(playerid,starter))
    {
        SendServerMessage(playerid,"Target isn't near you.",MSG_TYPE_ERROR);
        return;
    }

    new line[144], name[ACCOUNT_NAME_LEN];

    if (!Money_CanAfford(playerid,Money_Make(bet)))
    {
        format(line,sizeof(line),"You don't have enough money. ($%d)",bet);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        return;
    }

    if (!Money_CanAfford(starter,Money_Make(bet)))
    {
        format(line,sizeof(line),"The player does not have enough money. ($%d)",bet);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        return;
    }

    Money_Take(playerid,Money_Make(bet));
    Money_Take(starter,Money_Make(bet));
    Bj_Isolate(playerid);
    Bj_Isolate(starter);
    s_BjRole[starter] = BJ_ROLE_HOUSE;
    s_BjRole[playerid] = BJ_ROLE_GUEST;
    s_BjOpponent[starter] = playerid;
    s_BjOpponent[playerid] = starter;
    s_BjBet[starter] = bet;
    s_BjBet[playerid] = bet;
    s_BjCount[starter] = 0;
    s_BjCount[playerid] = 0;
    Deck_Shuffle(s_BjDeck[starter]);
    s_BjDeckPos[starter] = 0;
    Bj_PassTurn(starter,playerid,false);
    SendServerMessage(playerid,"You've agreed to play blackjack, to quit use /blackjack exit!",MSG_TYPE_INFO);
    SendServerMessage(playerid,"It's your turn, use the commands /blackjack call and /blackjack stand to call a card or stand.",MSG_TYPE_INFO);
    Name_Display(playerid,name);
    format(line,sizeof(line),"%s agreed to play the game. He must call first.",name);
    SendServerMessage(starter,line,MSG_TYPE_INFO);
    Bj_ShowTds(starter);
    Bj_ShowTds(playerid);
    Bj_Refresh(starter);
}

static Bj_Refuse(playerid)
{
    new starter = s_BjFrom[playerid];

    if (starter == BJ_NONE)
    {
        SendServerMessage(playerid,"You have no requests to play blackjack.",MSG_TYPE_ERROR);
        return;
    }

    new line[96], name[ACCOUNT_NAME_LEN];
    Bj_ClearRequest(playerid);
    SendServerMessage(playerid,"You have refused to play blackjack.",MSG_TYPE_ERROR);

    if (IsPlayerConnected(starter))
    {
        SendServerMessage(starter,"Your request to play blackjack has been refused.",MSG_TYPE_ERROR);
        Name_Display(playerid,name);
        format(line,sizeof(line),"%s refused to play blackjack.",name);
        SendServerMessage(starter,line,MSG_TYPE_INFO);
    }
}

static Bj_Play(playerid,target,amount)
{
    if (Bj_IsPlaying(playerid))
    {
        SendServerMessage(playerid,"You're already playing blackjack.",MSG_TYPE_ERROR);
        return;
    }

    if (target == BJ_NONE || amount < BJ_BET_MIN || amount > BJ_BET_MAX)
    {
        SendServerMessage(playerid,"/blackjack [play] [id/name] [bet(1 - 10000)]",MSG_TYPE_ERROR);
        return;
    }

    if (!IsPlayerConnected(target) || target == playerid || !Player_IsReady(target) || !Bj_Near(playerid,target))
    {
        SendServerMessage(playerid,"This player is not connected or not near you.",MSG_TYPE_ERROR);
        return;
    }

    if (Bj_IsPlaying(target))
    {
        SendServerMessage(playerid,"The player is already engaged in a game of blackjack.",MSG_TYPE_ERROR);
        return;
    }

    if (!Player_IsFree(playerid) || !Player_IsFree(target))
    {
        SendServerMessage(playerid,"This player is not connected or not near you.",MSG_TYPE_ERROR);
        return;
    }

    new line[160], name[ACCOUNT_NAME_LEN], targetName[ACCOUNT_NAME_LEN];

    if (!Money_CanAfford(playerid,Money_Make(amount)))
    {
        format(line,sizeof(line),"You don't have enough money. ($%d)",amount);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        return;
    }

    if (!Money_CanAfford(target,Money_Make(amount)))
    {
        format(line,sizeof(line),"The player does not have enough money. ($%d)",amount);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        return;
    }

    if (s_BjInvite[playerid] != BJ_NONE)
    {
        SendServerMessage(playerid,"You already have a blackjack invitation waiting for an answer.",MSG_TYPE_ERROR);
        return;
    }

    if (s_BjFrom[target] != BJ_NONE)
    {
        SendServerMessage(playerid,"That player already has a blackjack request waiting.",MSG_TYPE_ERROR);
        return;
    }

    s_BjFrom[target] = playerid;
    s_BjInvite[playerid] = target;
    s_BjRequestBet[target] = amount;
    s_BjDue[target] = GetTickCount() + BJ_REQUEST_MS;
    Name_Display(playerid,name);
    Name_Display(target,targetName);
    format(line,sizeof(line),"You have invited %s to play blackjack. (Bet: %d $ | Potential win:%d $)",targetName,amount,amount * 2);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    format(line,sizeof(line),"%s (banker) sent you to play blackjack. (Stake: %d $ | Potential win: %d $)",name,amount,amount * 2);
    SendServerMessage(target,line,MSG_TYPE_INFO);
    SendServerMessage(target,"The request will expire automatically in 30 seconds. (/ blackjack accept - / blackjack refuse)",MSG_TYPE_INFO);
}

static Bj_Expire(playerid)
{
    new starter = s_BjFrom[playerid];
    Bj_ClearRequest(playerid);
    SendServerMessage(playerid,"You have not accepted the blackjack invitation in time.",MSG_TYPE_INFO);

    if (starter != BJ_NONE && IsPlayerConnected(starter))
    {
        SendServerMessage(starter,"The player has not accepted the blackjack invitation in time.",MSG_TYPE_INFO);
    }
}

stock Bj_Tick()
{
    new now = GetTickCount();

    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (s_BjDue[i] != 0 && IsPlayerConnected(i) && now - s_BjDue[i] >= 0)
        {
            Bj_Expire(i);
        }
    }
}

static Bj_Leave(playerid,bool:quit)
{
    Bj_Abandon(playerid,quit);
    Bj_DropInvite(playerid);
    Bj_ClearRequest(playerid);
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
CMD:blackjack(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new option[20], id, amount;

    if (sscanf(params,"s[20]U(-1)I(-1)",option,id,amount))
    {
        SendServerMessage(playerid,"/blackjack [accept/refuse] -- [call/stand] -- [play/exit]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!strcmp(option,"accept",true))
    {
        Bj_Accept(playerid);
    }
    else if (!strcmp(option,"refuse",true))
    {
        Bj_Refuse(playerid);
    }
    else if (!strcmp(option,"play",true))
    {
        Bj_Play(playerid,id,amount);
    }
    else if (!strcmp(option,"call",false))
    {
        Bj_Call(playerid);
    }
    else if (!strcmp(option,"stand",false))
    {
        Bj_Stand(playerid);
    }
    else if (!strcmp(option,"exit",false))
    {
        if (!Bj_IsPlaying(playerid))
        {
            SendServerMessage(playerid,"You're not playing blackjack.",MSG_TYPE_ERROR);
        }
        else
        {
            Bj_Abandon(playerid,false);
        }
    }
    else
    {
        SendServerMessage(playerid,"Invalid parameter.",MSG_TYPE_ERROR);
    }

    return 1;
}

/**
 *     __                            __
 *    |  \                          |  |
 *    | $$____    ______    ______  | $$   __   _______
 *    | $$    \  /      \  /      \ | $$  /  \ /       |
 *    | $$$$$$$\|  $$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$$
 *    | $$  | $$| $$  | $$| $$  | $$| $$   $$  \$$    |
 *    | $$  | $$| $$__/ $$| $$__/ $$| $$$$$$\  _\$$$$$$|
 *    | $$  | $$ \$$    $$ \$$    $$| $$  \$$\|       $$
 *     \$$   \$$  \$$$$$$   \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
#include <pp-hooks>

Timer_Declare(Bj_Timer)
{
    Bj_Tick();
    return 1;
}

hook OnGameModeInit()
{
    Bj_BuildStatic();
    Timer_Start(Bj_Timer,BJ_TICK_MS);
}

hook OnPlayerConnect(playerid)
{
    for (new i = 0;i < BJ_TD_ROW;i++)
    {
        s_BjHouse[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        s_BjGuest[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    Bj_ClearGame(playerid);
    s_BjFrom[playerid] = BJ_NONE;
    s_BjInvite[playerid] = BJ_NONE;
    s_BjRequestBet[playerid] = 0;
    s_BjDue[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    Bj_SettleLeave(playerid,reason);
    Bj_Leave(playerid,true);
    Bj_DestroyPlayer(playerid);
}

hook Staff_OnServerRestart()
{
    for (new house = 0;house < MAX_PLAYERS;house++)
    {
        if (!Bj_IsPlaying(house) || s_BjRole[house] != BJ_ROLE_HOUSE)
        {
            continue;
        }

        new guest = s_BjOpponent[house], houseName[MAX_PLAYER_NAME], guestName[MAX_PLAYER_NAME];
        GetPlayerName(house,houseName,sizeof(houseName));
        GetPlayerName(guest,guestName,sizeof(guestName));
        Log_Info("games/blackjack","server restart ended a game between %s and %s (bet $%d, totals %d to %d): both bets refunded",houseName,guestName,s_BjBet[house],Bj_HandTotal(house),Bj_HandTotal(guest));
        SendServerMessage(house,"The server is restarting. You've both been refunded your bet.",MSG_TYPE_INFO);
        SendServerMessage(guest,"The server is restarting. You've both been refunded your bet.",MSG_TYPE_INFO);
        Bj_Tie(house,guest);
    }
}

hook Character_OnLeaving(playerid,characterid)
{
    Bj_SettleLeave(playerid,Account_GetLeaveReason(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    Bj_Leave(playerid,true);
}

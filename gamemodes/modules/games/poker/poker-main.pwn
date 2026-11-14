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
#define PK_MAX_SEATS (6)
#define PK_MIN_SEATS (2)
#define PK_CHIP_DIGITS (7)
#define PK_CHAIR_MODEL (2120)
#define PK_TURN_MS (20000)
#define PK_START_MS (5000)
#define PK_DEAL_MS (2000)
#define PK_RUNOUT_MS (2000)
#define PK_BUST_MS (3000)
#define PK_NEXT_MS (8000)
#define PK_TICK_MS (500)
#define PK_FEE_PERCENT (2)
#define PK_JOIN_RANGE (2.5)
#define PK_Z_OFFSET (0.442852)
#define PK_CHAIR_RANGE (1.25)
#define PK_CAMERA_Z (3.0)
#define PK_CHIP_OFFSET (0.13)
#define PK_BET_COLOUR (0x0080FFFF)
#define PK_NONE (-1)
#define PK_OBJECTS ((PK_MAX_SEATS + 1) * PK_CHIP_DIGITS * 2)
#define PK_TD_HOLE (PK_MAX_SEATS * 2)
#define PK_TD_COMMUNITY (5)
#define PK_TD_CHOICES (3)
#define PK_CHOICE_CALL (0)
#define PK_CHOICE_RAISE (1)
#define PK_CHOICE_FOLD (2)
#define PK_RAISE_BET (0)
#define PK_RAISE_RAISE (1)
#define PK_RAISE_ALLIN (2)

enum
{
    PK_IDLE,
    PK_COUNTDOWN,
    PK_DEALING,
    PK_HAND,
    PK_RUNOUT,
    PK_BETWEEN
}

enum e_PKT
{
    E_PKT_BUYIN,
    E_PKT_SB,
    E_PKT_SEATS,
    Float:E_PKT_X,
    Float:E_PKT_Y,
    Float:E_PKT_Z,
    E_PKT_WORLD,
    E_PKT_INT,
    E_PKT_TABLEOBJ,
    E_PKT_POTLABEL,
    E_PKT_SEAT[PK_MAX_SEATS],
    E_PKT_CHAIR[PK_MAX_SEATS],
    Float:E_PKT_SEATX[PK_MAX_SEATS],
    Float:E_PKT_SEATY[PK_MAX_SEATS],
    E_PKT_BETLABEL[PK_MAX_SEATS],
    E_PKT_OBJ[PK_OBJECTS],
    E_PKT_STATE,
    E_PKT_ROUND,
    E_PKT_DEALER,
    E_PKT_SBSEAT,
    E_PKT_BBSEAT,
    E_PKT_TURN,
    E_PKT_CURBET,
    E_PKT_MINRAISE,
    E_PKT_COMM[5],
    E_PKT_DECK[DECK_SIZE],
    E_PKT_DECKPOS,
    E_PKT_DUE_START,
    E_PKT_DUE_DEAL,
    E_PKT_DUE_TURN,
    E_PKT_DUE_NEXT,
    E_PKT_DUE_BUST,
    E_PKT_DUE_RUNOUT,
    E_PKT_LASTDEALER
}

enum e_PKPOT
{
    E_PKPOT_AMOUNT,
    E_PKPOT_ELIGIBLE,
    E_PKPOT_CONTRIB
}

static const g_PkChipColour[PK_CHIP_DIGITS] =
{
    0xFF0080C0,0xFF008000,0xFF324A4E,0xFF7C4303,0xFF63720E,0xFFE2C241,0xFFE4603F
};

static const g_PkChipText[PK_CHIP_DIGITS][8] =
{
    "$1","$10","$100","$1K","$10K","$100K","$1M"
};

static const g_PkRot[7][PK_MAX_SEATS] =
{
    {-1,-1,-1,-1,-1,-1},
    {-1,-1,-1,-1,-1,-1},
    {1,0,-1,-1,-1,-1},
    {1,0,2,-1,-1,-1},
    {1,0,3,2,-1,-1},
    {1,0,4,3,2,-1},
    {1,0,5,4,3,2}
};

forward Poker_Load();
forward Poker_RaiseDeferred(playerid,token);
forward Poker_BustedDeferred(playerid,token);

static Map:s_PkTables;
static s_PkTable[MAX_PLAYERS];
static s_PkSeat[MAX_PLAYERS];
static s_PkChips[MAX_PLAYERS];
static s_PkRoundBet[MAX_PLAYERS];
static s_PkCommitted[MAX_PLAYERS];
static bool:s_PkInHand[MAX_PLAYERS];
static bool:s_PkFolded[MAX_PLAYERS];
static bool:s_PkAllIn[MAX_PLAYERS];
static bool:s_PkActed[MAX_PLAYERS];
static s_PkCards[MAX_PLAYERS][2];
static s_PkAttach[MAX_PLAYERS];
static s_PkLabel[MAX_PLAYERS];
static s_PkRaiseKind[MAX_PLAYERS];
static bool:s_PkDialog[MAX_PLAYERS];
static Float:s_PkSaved[MAX_PLAYERS][4];
static PlayerText:s_PkHole[MAX_PLAYERS][PK_TD_HOLE];
static PlayerText:s_PkCommunity[MAX_PLAYERS][PK_TD_COMMUNITY];
static PlayerText:s_PkChoices[MAX_PLAYERS][PK_TD_CHOICES];

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
static Pk_Message(playerid,const text[])
{
    new line[200];
    format(line,sizeof(line),"{4B8774}[POKER] {E5861A}%s",text);
    SendClientMessage(playerid,-1,line);
}

static Pk_Cash(amount,dest[],size = sizeof(dest))
{
    new digits[24];
    Money_Delimit(amount,digits);
    format(dest,size,"$%s",digits);
}

static Pk_Name(playerid,dest[],size = sizeof(dest))
{
    Name_Display(playerid,dest,size);
}

static bool:Pk_Get(id,t[e_PKT])
{
    if (!map_valid(s_PkTables) || !map_has_key(s_PkTables,id))
    {
        return false;
    }

    map_get_arr(s_PkTables,id,t);
    return true;
}

static Pk_Put(id,const t[e_PKT])
{
    map_set_arr(s_PkTables,id,t);
}

static Pk_TableMessage(const t[e_PKT],const text[])
{
    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        if (t[E_PKT_SEAT][s] != PK_NONE)
        {
            SendClientMessage(t[E_PKT_SEAT][s],-1,text);
        }
    }
}

static bool:Pk_Alive(const t[e_PKT],seat)
{
    new p = t[E_PKT_SEAT][seat];
    return p != PK_NONE && s_PkInHand[p] && !s_PkFolded[p];
}

static bool:Pk_CanAct(const t[e_PKT],seat)
{
    return Pk_Alive(t,seat) && !s_PkAllIn[t[E_PKT_SEAT][seat]];
}

static Pk_Occupied(const t[e_PKT])
{
    new n;

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        if (t[E_PKT_SEAT][s] != PK_NONE)
        {
            n++;
        }
    }

    return n;
}

static Pk_Count(const t[e_PKT],bool:alive)
{
    new n;

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        if (alive ? Pk_Alive(t,s) : Pk_CanAct(t,s))
        {
            n++;
        }
    }

    return n;
}

static Pk_NextSeat(const t[e_PKT],from,bool:needsAction)
{
    for (new i = 1;i <= t[E_PKT_SEATS];i++)
    {
        new seat = (from + i) % t[E_PKT_SEATS];

        new bool:ok;

        if (needsAction)
        {
            ok = Pk_CanAct(t,seat);
        }
        else
        {
            ok = t[E_PKT_SEAT][seat] != PK_NONE && s_PkInHand[t[E_PKT_SEAT][seat]];
        }

        if (ok)
        {
            return seat;
        }
    }

    return PK_NONE;
}

static Pk_Reshuffle(t[e_PKT])
{
    new deck[DECK_SIZE];
    Deck_Shuffle(deck);

    for (new i = 0;i < DECK_SIZE;i++)
    {
        t[E_PKT_DECK][i] = deck[i];
    }

    t[E_PKT_DECKPOS] = 0;
}

static Pk_Draw(t[e_PKT])
{
    if (t[E_PKT_DECKPOS] >= DECK_SIZE)
    {
        Pk_Reshuffle(t);
    }

    return t[E_PKT_DECK][t[E_PKT_DECKPOS]++];
}

static Pk_Eval(const t[e_PKT],playerid)
{
    new cards[7];
    cards[0] = s_PkCards[playerid][0];
    cards[1] = s_PkCards[playerid][1];

    for (new i = 0;i < 5;i++)
    {
        cards[2 + i] = t[E_PKT_COMM][i];
    }

    return Pk_Eval7(cards);
}

static Pk_Pot(const t[e_PKT])
{
    new total;

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        if (t[E_PKT_SEAT][s] != PK_NONE)
        {
            total += s_PkCommitted[t[E_PKT_SEAT][s]];
        }
    }

    return total;
}

static List:Pk_BuildPots(const t[e_PKT])
{
    new List:pots = list_new(), remaining[PK_MAX_SEATS];

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];
        remaining[s] = p != PK_NONE && s_PkInHand[p] ? s_PkCommitted[p] : 0;
    }

    for (;;)
    {
        new low = cellmax;

        for (new s = 0;s < t[E_PKT_SEATS];s++)
        {
            if (Pk_Alive(t,s) && remaining[s] > 0 && remaining[s] < low)
            {
                low = remaining[s];
            }
        }

        new pot[e_PKPOT];

        if (low == cellmax)
        {
            for (new s = 0;s < t[E_PKT_SEATS];s++)
            {
                if (remaining[s] > 0)
                {
                    pot[E_PKPOT_AMOUNT] += remaining[s];
                    pot[E_PKPOT_CONTRIB] |= 1 << s;
                    remaining[s] = 0;
                }

                if (Pk_Alive(t,s))
                {
                    pot[E_PKPOT_ELIGIBLE] |= 1 << s;
                }
            }

            if (pot[E_PKPOT_AMOUNT] > 0)
            {
                list_add_arr(pots,pot);
            }

            break;
        }

        for (new s = 0;s < t[E_PKT_SEATS];s++)
        {
            if (remaining[s] > 0)
            {
                new part = remaining[s] < low ? remaining[s] : low;
                pot[E_PKPOT_AMOUNT] += part;
                pot[E_PKPOT_CONTRIB] |= 1 << s;

                if (Pk_Alive(t,s))
                {
                    pot[E_PKPOT_ELIGIBLE] |= 1 << s;
                }

                remaining[s] -= part;
            }
        }

        list_add_arr(pots,pot);
    }

    return pots;
}

static Pk_FreeAttach(playerid)
{
    for (new i = 0;i < 10;i++)
    {
        if (!IsPlayerAttachedObjectSlotUsed(playerid,i))
        {
            return i;
        }
    }

    return PK_NONE;
}

static Pk_ObjIndex(slot,digit,label)
{
    return (slot * PK_CHIP_DIGITS + digit) * 2 + label;
}

static Pk_SetChips(const t[e_PKT],slot,value)
{
    new Float:baseZ = t[E_PKT_Z] + 0.284, Float:x, Float:y, Float:z;

    for (new j = 0;j < PK_CHIP_DIGITS;j++)
    {
        new chip = t[E_PKT_OBJ][Pk_ObjIndex(slot,j,0)], label = t[E_PKT_OBJ][Pk_ObjIndex(slot,j,1)];
        GetDynamicObjectPos(STREAMER_TAG_OBJECT:chip,x,y,z);
        SetDynamicObjectPos(STREAMER_TAG_OBJECT:chip,x,y,baseZ);
        SetDynamicObjectPos(STREAMER_TAG_OBJECT:label,x,y,baseZ + 0.12);
    }

    new position;

    for (new rest = value;rest != 0 && position < PK_CHIP_DIGITS;rest /= 10)
    {
        new digit = rest % 10;

        if (digit)
        {
            new chip = t[E_PKT_OBJ][Pk_ObjIndex(slot,position,0)], label = t[E_PKT_OBJ][Pk_ObjIndex(slot,position,1)];
            GetDynamicObjectPos(STREAMER_TAG_OBJECT:chip,x,y,z);
            SetDynamicObjectPos(STREAMER_TAG_OBJECT:chip,x,y,baseZ + 0.016 * float(digit));
            SetDynamicObjectPos(STREAMER_TAG_OBJECT:label,x,y,baseZ + 0.125 + 0.016 * float(digit));
        }

        position++;
    }
}

static Pk_ResetLabel(const t[e_PKT])
{
    new line[160], buyIn[24], blind[24], big[24];
    Pk_Cash(t[E_PKT_BUYIN],buyIn);
    Pk_Cash(t[E_PKT_SB],blind);
    Pk_Cash(t[E_PKT_SB] * 2,big);
    format(line,sizeof(line),"Press ENTER To Play Poker\n{FFFFFF}%s Minimum\n%s / %s Blinds",buyIn,blind,big);
    UpdateDynamic3DTextLabelText(STREAMER_TAG_3D_TEXT_LABEL:t[E_PKT_POTLABEL],0xA9A9A9FF,line);
}

static Pk_CardSprite(card,dest[],size = sizeof(dest))
{
    Card_Sprite(card,dest,size);
}

static Pk_ShowHole(const t[e_PKT],viewer,bool:reveal)
{
    new seats = t[E_PKT_SEATS], back[CARD_SPRITE_LEN], sprite[CARD_SPRITE_LEN];
    Card_BackSprite(back);

    for (new s = 0;s < seats;s++)
    {
        new p = t[E_PKT_SEAT][s], idx = g_PkRot[seats][s];

        if (idx < 0)
        {
            continue;
        }

        new PlayerText:first = s_PkHole[viewer][idx * 2], PlayerText:second = s_PkHole[viewer][idx * 2 + 1];

        if (p == PK_NONE || !s_PkInHand[p] || (s_PkFolded[p] && !reveal) || t[E_PKT_STATE] < PK_HAND)
        {
            PlayerTextDrawHide(viewer,first);
            PlayerTextDrawHide(viewer,second);
            continue;
        }

        if (p == viewer || (reveal && !s_PkFolded[p]))
        {
            Pk_CardSprite(s_PkCards[p][0],sprite);
            PlayerTextDrawSetString(viewer,first,sprite);
            Pk_CardSprite(s_PkCards[p][1],sprite);
            PlayerTextDrawSetString(viewer,second,sprite);
        }
        else
        {
            PlayerTextDrawSetString(viewer,first,back);
            PlayerTextDrawSetString(viewer,second,back);
        }

        PlayerTextDrawShow(viewer,first);
        PlayerTextDrawShow(viewer,second);
    }
}

static Pk_ShowCommunity(const t[e_PKT],viewer)
{
    new sprite[CARD_SPRITE_LEN];

    for (new i = 0;i < 5;i++)
    {
        if (t[E_PKT_COMM][i] == CARD_NONE || (t[E_PKT_STATE] != PK_HAND && t[E_PKT_STATE] != PK_RUNOUT && t[E_PKT_STATE] != PK_BETWEEN))
        {
            PlayerTextDrawHide(viewer,s_PkCommunity[viewer][i]);
            continue;
        }

        Pk_CardSprite(t[E_PKT_COMM][i],sprite);
        PlayerTextDrawSetString(viewer,s_PkCommunity[viewer][i],sprite);
        PlayerTextDrawShow(viewer,s_PkCommunity[viewer][i]);
    }
}

static Pk_HideChoices(playerid)
{
    for (new i = 0;i < PK_TD_CHOICES;i++)
    {
        if (s_PkChoices[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawHide(playerid,s_PkChoices[playerid][i]);
        }
    }

    CancelSelectTextDraw(playerid);
}

static Pk_ShowChoices(const t[e_PKT],playerid)
{
    new curBet = t[E_PKT_CURBET], bet = s_PkRoundBet[playerid], chips = s_PkChips[playerid];
    PlayerTextDrawSetString(playerid,s_PkChoices[playerid][PK_CHOICE_CALL],curBet == bet ? "Check" : "Call");

    if (curBet == 0)
    {
        PlayerTextDrawSetString(playerid,s_PkChoices[playerid][PK_CHOICE_RAISE],"Bet");
        s_PkRaiseKind[playerid] = PK_RAISE_BET;
    }
    else if (chips + bet > curBet + t[E_PKT_MINRAISE] - 1)
    {
        PlayerTextDrawSetString(playerid,s_PkChoices[playerid][PK_CHOICE_RAISE],"Raise");
        s_PkRaiseKind[playerid] = PK_RAISE_RAISE;
    }
    else
    {
        PlayerTextDrawSetString(playerid,s_PkChoices[playerid][PK_CHOICE_RAISE],"All In");
        s_PkRaiseKind[playerid] = PK_RAISE_ALLIN;
    }

    if (chips + bet <= curBet)
    {
        PlayerTextDrawSetSelectable(playerid,s_PkChoices[playerid][PK_CHOICE_CALL],false);
        PlayerTextDrawColor(playerid,s_PkChoices[playerid][PK_CHOICE_CALL],-16776961);
    }
    else
    {
        PlayerTextDrawSetSelectable(playerid,s_PkChoices[playerid][PK_CHOICE_CALL],true);
        PlayerTextDrawColor(playerid,s_PkChoices[playerid][PK_CHOICE_CALL],-1);
    }

    for (new i = 0;i < PK_TD_CHOICES;i++)
    {
        PlayerTextDrawShow(playerid,s_PkChoices[playerid][i]);
    }

    SelectTextDraw(playerid,0x00FF00FF);
}

static Pk_Sync(const t[e_PKT])
{
    new line[200], chips[24], bet[24], pot[24], sideLine[24];
    new List:pots = Pk_BuildPots(t);
    new count = list_size(pots), potEntry[e_PKPOT];

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p == PK_NONE)
        {
            UpdateDynamic3DTextLabelText(STREAMER_TAG_3D_TEXT_LABEL:t[E_PKT_BETLABEL][s],0,"_");
            Pk_SetChips(t,s + 1,0);
            continue;
        }

        Pk_Cash(s_PkChips[p],chips);
        Pk_Cash(s_PkRoundBet[p],bet);
        format(line,sizeof(line),"{34c5db}Chips: {db8d34}%s\n{db3a34}Last bet: {db8d34}%s",chips,bet);
        UpdateDynamic3DTextLabelText(STREAMER_TAG_3D_TEXT_LABEL:t[E_PKT_BETLABEL][s],PK_BET_COLOUR,line);
        Pk_SetChips(t,s + 1,s_PkChips[p]);
    }

    new total = Pk_Pot(t);
    Pk_SetChips(t,0,total);

    if (total == 0 && t[E_PKT_STATE] != PK_HAND && t[E_PKT_STATE] != PK_RUNOUT)
    {
        Pk_ResetLabel(t);
    }
    else
    {
        new first = 0;

        if (count > 0)
        {
            list_get_arr(pots,0,potEntry);
            first = potEntry[E_PKPOT_AMOUNT];
        }

        Pk_Cash(first,pot);
        format(line,sizeof(line),"{59cdff}Main Pot: {ff9059}%s",pot);

        if (count > 1)
        {
            strcat(line,"\n{008000}Side Pot:\n{008080}");

            for (new i = 1;i < count;i++)
            {
                list_get_arr(pots,i,potEntry);
                Pk_Cash(potEntry[E_PKPOT_AMOUNT],sideLine);

                if (i > 1)
                {
                    strcat(line,"\n");
                }

                strcat(line,sideLine);
            }
        }

        UpdateDynamic3DTextLabelText(STREAMER_TAG_3D_TEXT_LABEL:t[E_PKT_POTLABEL],PK_BET_COLOUR,line);
    }

    list_delete(pots);
}

static Pk_RefreshViewers(const t[e_PKT],bool:reveal)
{
    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p != PK_NONE)
        {
            Pk_ShowHole(t,p,reveal);
            Pk_ShowCommunity(t,p);
        }
    }
}

static PlayerText:Pk_Td(playerid,Float:x,Float:y,const text[],font,Float:tx,Float:ty,bool:box,bool:selectable)
{
    new PlayerText:id = CreatePlayerTextDraw(playerid,x,y,text);
    PlayerTextDrawFont(playerid,id,TEXT_DRAW_FONT:font);
    PlayerTextDrawLetterSize(playerid,id,0.25,1.0);
    PlayerTextDrawAlignment(playerid,id,TEXT_DRAW_ALIGN_CENTER);
    PlayerTextDrawColor(playerid,id,font == 4 ? -1 : -780181761);
    PlayerTextDrawSetShadow(playerid,id,0);
    PlayerTextDrawSetOutline(playerid,id,0);
    PlayerTextDrawBackgroundColor(playerid,id,255);
    PlayerTextDrawSetProportional(playerid,id,true);

    if (box)
    {
        PlayerTextDrawUseBox(playerid,id,true);
        PlayerTextDrawBoxColor(playerid,id,286331306);
    }

    PlayerTextDrawTextSize(playerid,id,tx,ty);
    PlayerTextDrawSetSelectable(playerid,id,selectable);
    return id;
}

static Pk_BuildTds(playerid,seats)
{
    new Float:angle = 0.0, Float:step = 360.0 / float(seats), back[CARD_SPRITE_LEN];
    Card_BackSprite(back);

    switch (seats)
    {
        case 2: angle = 120.0;
        case 3: angle = 180.0;
        case 4: angle = 210.0;
        case 5, 6: angle = 240.0;
    }

    for (new i = 0;i < seats;i++)
    {
        new Float:x = 144.0 * floatcos(float(i) * step + angle,degrees) + 320.0, Float:y = 144.0 * floatsin(float(i) * step + angle,degrees) + 215.0 + 25.0;
        s_PkHole[playerid][i * 2] = Pk_Td(playerid,x,y,back,4,23.0,31.0,false,false);
        s_PkHole[playerid][i * 2 + 1] = Pk_Td(playerid,x + 23.904725,y,back,4,23.0,31.0,false,false);
    }

    for (new i = 0;i < PK_TD_COMMUNITY;i++)
    {
        s_PkCommunity[playerid][i] = Pk_Td(playerid,float(i) * 23.904725 + 320.0 - 58.0,225.0,back,4,23.0,31.0,false,false);
    }

    s_PkChoices[playerid][PK_CHOICE_CALL] = Pk_Td(playerid,290.0,274.0,"Call",1,25.0,25.0,true,true);
    s_PkChoices[playerid][PK_CHOICE_RAISE] = Pk_Td(playerid,320.0,274.0,"Raise",1,25.0,25.0,true,true);
    s_PkChoices[playerid][PK_CHOICE_FOLD] = Pk_Td(playerid,350.0,274.0,"Fold",1,25.0,25.0,true,true);
}

static Pk_DestroyTds(playerid)
{
    for (new i = 0;i < PK_TD_HOLE;i++)
    {
        if (s_PkHole[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid,s_PkHole[playerid][i]);
            s_PkHole[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }

    for (new i = 0;i < PK_TD_COMMUNITY;i++)
    {
        if (s_PkCommunity[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid,s_PkCommunity[playerid][i]);
            s_PkCommunity[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }

    for (new i = 0;i < PK_TD_CHOICES;i++)
    {
        if (s_PkChoices[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid,s_PkChoices[playerid][i]);
            s_PkChoices[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }
}

static Pk_ResetPlayer(playerid)
{
    s_PkTable[playerid] = PK_NONE;
    s_PkSeat[playerid] = PK_NONE;
    s_PkChips[playerid] = 0;
    s_PkRoundBet[playerid] = 0;
    s_PkCommitted[playerid] = 0;
    s_PkInHand[playerid] = false;
    s_PkFolded[playerid] = false;
    s_PkAllIn[playerid] = false;
    s_PkActed[playerid] = false;
    s_PkCards[playerid][0] = CARD_NONE;
    s_PkCards[playerid][1] = CARD_NONE;
    s_PkAttach[playerid] = PK_NONE;
    s_PkLabel[playerid] = 0;
    s_PkRaiseKind[playerid] = PK_RAISE_BET;
    s_PkDialog[playerid] = false;
}

static Pk_SetLabel(playerid,colour,const text[])
{
    UpdateDynamic3DTextLabelText(STREAMER_TAG_3D_TEXT_LABEL:s_PkLabel[playerid],colour,text);
}

static Pk_NameLabel(playerid,const role[] = "")
{
    new name[ACCOUNT_NAME_LEN], line[96];
    Pk_Name(playerid,name);

    if (role[0] == EOS)
    {
        format(line,sizeof(line),"%s",name);
        Pk_SetLabel(playerid,0x7AC72EFF,line);
        return;
    }

    format(line,sizeof(line),"{7AC72E}%s\n{FD4102}%s",name,role);
    Pk_SetLabel(playerid,-1,line);
}

stock bool:Pk_IsSeated(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_PkTable[playerid] != PK_NONE;
}

stock Pk_PlayerTable(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS ? s_PkTable[playerid] : PK_NONE;
}

stock Pk_GetChips(playerid)
{
    return s_PkChips[playerid];
}

stock Pk_GetRoundBet(playerid)
{
    return s_PkRoundBet[playerid];
}

stock Pk_GetCommitted(playerid)
{
    return s_PkCommitted[playerid];
}

stock bool:Pk_IsFolded(playerid)
{
    return s_PkFolded[playerid];
}

stock bool:Pk_IsAllIn(playerid)
{
    return s_PkAllIn[playerid];
}

stock bool:Pk_IsInHand(playerid)
{
    return s_PkInHand[playerid];
}

stock Pk_GetCard(playerid,index)
{
    return s_PkCards[playerid][index];
}

stock Pk_GetSeat(playerid)
{
    return s_PkSeat[playerid];
}

stock bool:Pk_Table(id,t[e_PKT])
{
    return Pk_Get(id,t);
}

stock Pk_TableCount()
{
    return map_valid(s_PkTables) ? map_size(s_PkTables) : 0;
}

stock bool:Pk_TableExists(id)
{
    return map_valid(s_PkTables) && map_has_key(s_PkTables,id);
}

stock Pk_GetPot(id)
{
    new t[e_PKT];
    return Pk_Get(id,t) ? Pk_Pot(t) : 0;
}

stock Pk_PotCount(id)
{
    new t[e_PKT];

    if (!Pk_Get(id,t))
    {
        return 0;
    }

    new List:pots = Pk_BuildPots(t), n = list_size(pots);
    list_delete(pots);
    return n;
}

static Pk_BuildTable(id,buyIn,smallBlind,Float:x,Float:y,Float:z,seats,world,interior)
{
    new t[e_PKT], line[8];
    t[E_PKT_BUYIN] = buyIn;
    t[E_PKT_SB] = smallBlind;
    t[E_PKT_SEATS] = seats;
    t[E_PKT_X] = x;
    t[E_PKT_Y] = y;
    t[E_PKT_Z] = z;
    t[E_PKT_WORLD] = world;
    t[E_PKT_INT] = interior;
    t[E_PKT_TABLEOBJ] = _:CreateDynamicObject(2189,x,y,z + PK_Z_OFFSET - 0.01,0.0,0.0,0.0,world,interior,.priority = 9999);

    if (buyIn >= 10000000)
    {
        SetDynamicObjectMaterial(STREAMER_TAG_OBJECT:t[E_PKT_TABLEOBJ],0,2189,"poker_tbl","roulette_6_256",-52310);
    }
    else if (buyIn >= 1000000)
    {
        SetDynamicObjectMaterial(STREAMER_TAG_OBJECT:t[E_PKT_TABLEOBJ],0,2189,"poker_tbl","roulette_6_256",-16737793);
    }
    else if (buyIn >= 100000)
    {
        SetDynamicObjectMaterial(STREAMER_TAG_OBJECT:t[E_PKT_TABLEOBJ],0,2189,"poker_tbl","roulette_6_256",-65485);
    }

    t[E_PKT_POTLABEL] = _:CreateDynamic3DTextLabel("-",-1,x + PK_CHIP_OFFSET,y + PK_CHIP_OFFSET,z + 0.5,10.0,.worldid = world,.interiorid = interior);
    new Float:step = 360.0 / float(seats), Float:digitStep = 360.0 / float(PK_CHIP_DIGITS);

    for (new i = 0;i < seats;i++)
    {
        new Float:cx = floatcos(float(i) * step,degrees), Float:cy = floatsin(float(i) * step,degrees);
        t[E_PKT_SEAT][i] = PK_NONE;
        t[E_PKT_SEATX][i] = cx * PK_CHAIR_RANGE + x;
        t[E_PKT_SEATY][i] = cy * PK_CHAIR_RANGE + y;
        t[E_PKT_CHAIR][i] = _:CreateDynamicObject(PK_CHAIR_MODEL,t[E_PKT_SEATX][i],t[E_PKT_SEATY][i],z + 0.25,0.0,0.0,step * float(i),world,interior,.priority = 9999);
        t[E_PKT_BETLABEL][i] = _:CreateDynamic3DTextLabel("_",PK_BET_COLOUR & ~0xFF,0.65 * cx + x,0.65 * cy + y,z + 0.36,3.0,.worldid = world,.interiorid = interior);
    }

    for (new slot = 0;slot <= seats;slot++)
    {
        new Float:centreX, Float:centreY;

        if (slot == 0)
        {
            centreX = x + PK_CHIP_OFFSET;
            centreY = y + PK_CHIP_OFFSET;
        }
        else
        {
            centreX = 0.70 * floatcos(float(slot - 1) * step,degrees) + x;
            centreY = 0.70 * floatsin(float(slot - 1) * step,degrees) + y;
        }

        for (new j = 0;j < PK_CHIP_DIGITS;j++)
        {
            new Float:px = 0.11 * floatcos(float(j) * digitStep,degrees) + centreX, Float:py = 0.11 * floatsin(float(j) * digitStep,degrees) + centreY, Float:pz = z + 0.284;
            new chip = Pk_ObjIndex(slot,j,0), label = Pk_ObjIndex(slot,j,1);
            t[E_PKT_OBJ][chip] = _:CreateDynamicObject(1902,px,py,pz,0.0,0.0,0.0,world,interior,.priority = 9999);
            SetDynamicObjectMaterialText(STREAMER_TAG_OBJECT:t[E_PKT_OBJ][chip],0," ",.backcolor = g_PkChipColour[j]);
            t[E_PKT_OBJ][label] = _:CreateDynamicObject(1905,px,py,pz + 0.12,0.0,0.0,0.0,world,interior,.priority = 9999);
            SetDynamicObjectMaterialText(STREAMER_TAG_OBJECT:t[E_PKT_OBJ][label],0,g_PkChipText[j],50,"Arial",44,1,g_PkChipColour[j],-1,1);
        }
    }

    for (new i = 0;i < 5;i++)
    {
        t[E_PKT_COMM][i] = CARD_NONE;
    }

    t[E_PKT_STATE] = PK_IDLE;
    t[E_PKT_TURN] = PK_NONE;
    t[E_PKT_LASTDEALER] = PK_NONE;
    t[E_PKT_DEALER] = PK_NONE;
    t[E_PKT_SBSEAT] = PK_NONE;
    t[E_PKT_BBSEAT] = PK_NONE;
    Pk_Reshuffle(t);
    Pk_ResetLabel(t);
    Pk_Put(id,t);
    #pragma unused line
}

static Pk_DestroyObjects(const t[e_PKT])
{
    DestroyDynamicObject(STREAMER_TAG_OBJECT:t[E_PKT_TABLEOBJ]);
    DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:t[E_PKT_POTLABEL]);

    for (new i = 0;i < t[E_PKT_SEATS];i++)
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:t[E_PKT_CHAIR][i]);
        DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:t[E_PKT_BETLABEL][i]);
    }

    for (new i = 0;i < (t[E_PKT_SEATS] + 1) * PK_CHIP_DIGITS * 2;i++)
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:t[E_PKT_OBJ][i]);
    }
}

static Pk_LeaveT(playerid,t[e_PKT])
{
    new seat = s_PkSeat[playerid], chips = s_PkChips[playerid];
    Pk_HideChoices(playerid);

    if (s_PkAttach[playerid] != PK_NONE)
    {
        RemovePlayerAttachedObject(playerid,s_PkAttach[playerid]);
    }

    ClearAnimations(playerid,SYNC_ALL);
    TogglePlayerControllable(playerid,true);

    if (seat >= 0 && seat < t[E_PKT_SEATS])
    {
        t[E_PKT_SEAT][seat] = PK_NONE;
        new Float:step = 360.0 / float(t[E_PKT_SEATS]);
        t[E_PKT_CHAIR][seat] = _:CreateDynamicObject(PK_CHAIR_MODEL,t[E_PKT_SEATX][seat],t[E_PKT_SEATY][seat],t[E_PKT_Z] + 0.25,0.0,0.0,step * float(seat),t[E_PKT_WORLD],t[E_PKT_INT],.priority = 9999);
    }

    if (s_PkLabel[playerid] != 0)
    {
        DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:s_PkLabel[playerid]);
    }

    Pk_DestroyTds(playerid);

    if (chips > 0)
    {
        Money_Give(playerid,Money_Make(chips));
    }

    SetPlayerPos(playerid,s_PkSaved[playerid][0],s_PkSaved[playerid][1],s_PkSaved[playerid][2]);
    SetPlayerFacingAngle(playerid,s_PkSaved[playerid][3]);
    SetCameraBehindPlayer(playerid);
    Player_SetBusy(playerid,E_PLAYER_BUSY_POKER,false);
    Pk_ResetPlayer(playerid);
    Streamer_Update(playerid);

    if (Pk_Occupied(t) == 0)
    {
        t[E_PKT_STATE] = PK_IDLE;
        t[E_PKT_DUE_START] = 0;
        t[E_PKT_DUE_DEAL] = 0;
        t[E_PKT_DUE_TURN] = 0;
        t[E_PKT_DUE_NEXT] = 0;
        t[E_PKT_DUE_BUST] = 0;
        t[E_PKT_DUE_RUNOUT] = 0;

        for (new i = 0;i < 5;i++)
        {
            t[E_PKT_COMM][i] = CARD_NONE;
        }

        Pk_Sync(t);
    }
    else if (t[E_PKT_STATE] == PK_COUNTDOWN && Pk_Occupied(t) < PK_MIN_SEATS)
    {
        t[E_PKT_STATE] = PK_IDLE;
        t[E_PKT_DUE_START] = 0;
    }
}

static Pk_EndHand(t[e_PKT])
{
    t[E_PKT_STATE] = PK_BETWEEN;
    t[E_PKT_TURN] = PK_NONE;
    t[E_PKT_DUE_TURN] = 0;
    t[E_PKT_DUE_RUNOUT] = 0;
    t[E_PKT_DUE_BUST] = GetTickCount() + PK_BUST_MS;
    t[E_PKT_DUE_NEXT] = GetTickCount() + PK_NEXT_MS;
    t[E_PKT_LASTDEALER] = t[E_PKT_DEALER];

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p != PK_NONE)
        {
            Pk_HideChoices(p);
            s_PkRoundBet[p] = 0;
            s_PkCommitted[p] = 0;
        }
    }
}

static Pk_Award(const t[e_PKT],id,bool:showdown)
{
    new List:pots = Pk_BuildPots(t), count = list_size(pots), line[200], cash[24], name[ACCOUNT_NAME_LEN], rankName[16];

    for (new i = 0;i < count;i++)
    {
        new pot[e_PKPOT], best = -1, winners[PK_MAX_SEATS], nWinners;
        list_get_arr(pots,i,pot);

        if (pot[E_PKPOT_CONTRIB] == pot[E_PKPOT_ELIGIBLE] && (pot[E_PKPOT_ELIGIBLE] & (pot[E_PKPOT_ELIGIBLE] - 1)) == 0)
        {
            for (new s = 0;s < t[E_PKT_SEATS];s++)
            {
                if (pot[E_PKPOT_ELIGIBLE] & (1 << s))
                {
                    new p = t[E_PKT_SEAT][s];
                    s_PkChips[p] += pot[E_PKPOT_AMOUNT];
                    Pk_Name(p,name);
                    Pk_Cash(pot[E_PKPOT_AMOUNT],cash);
                    format(line,sizeof(line),"{9FCF30}Uncalled bet of {377CC8}%s {9FCF30}returned to %s.",cash,name);
                    Pk_TableMessage(t,line);
                }
            }

            continue;
        }

        new scores[PK_MAX_SEATS];

        for (new s = 0;s < t[E_PKT_SEATS];s++)
        {
            if (!(pot[E_PKPOT_ELIGIBLE] & (1 << s)))
            {
                continue;
            }

            scores[s] = showdown ? Pk_Eval(t,t[E_PKT_SEAT][s]) : 0;

            if (scores[s] > best)
            {
                best = scores[s];
            }
        }

        for (new k = 1;k <= t[E_PKT_SEATS];k++)
        {
            new s = (t[E_PKT_DEALER] + k) % t[E_PKT_SEATS];

            if ((pot[E_PKPOT_ELIGIBLE] & (1 << s)) && scores[s] == best)
            {
                winners[nWinners++] = s;
            }
        }

        if (nWinners == 0)
        {
            continue;
        }

        new fee = pot[E_PKPOT_AMOUNT] * PK_FEE_PERCENT / 100, net = pot[E_PKPOT_AMOUNT] - fee, share = net / nWinners, odd = net % nWinners;
        Log_Info("games/poker","table %d burned %d chips of fee on a pot of %d",id,fee,pot[E_PKPOT_AMOUNT]);

        for (new w = 0;w < nWinners;w++)
        {
            s_PkChips[t[E_PKT_SEAT][winners[w]]] += share + (w == 0 ? odd : 0);
        }

        Pk_RankName(Pk_ScoreRank(best),rankName);
        Pk_TableMessage(t,"{9FCF30}****************************************************************************************");

        if (nWinners == 1)
        {
            Pk_Name(t[E_PKT_SEAT][winners[0]],name);
            Pk_Cash(net,cash);

            if (showdown)
            {
                format(line,sizeof(line),"{9FCF30}Player {FF8000}%s {9FCF30}has won with a {377CC8}%s",name,rankName);
            }
            else
            {
                format(line,sizeof(line),"{9FCF30}Player {FF8000}%s {9FCF30}has won the game!",name);
            }

            Pk_TableMessage(t,line);
            format(line,sizeof(line),"{9FCF30}Prize: {377CC8}%s | -%d percent fee.",cash,PK_FEE_PERCENT);
            Pk_TableMessage(t,line);
        }
        else
        {
            format(line,sizeof(line),"{9FCF30}Draw! These players have won with a {377CC8}%s:",rankName);
            Pk_TableMessage(t,line);

            for (new w = 0;w < nWinners;w++)
            {
                Pk_Name(t[E_PKT_SEAT][winners[w]],name);
                format(line,sizeof(line),"{9FCF30}%s",name);
                Pk_TableMessage(t,line);
            }

            format(line,sizeof(line),"{9FCF30}Each receives 1/%d of the total pot available. | -%d percent fee",nWinners,PK_FEE_PERCENT);
            Pk_TableMessage(t,line);
        }

        Pk_TableMessage(t,"{9FCF30}****************************************************************************************");
    }

    list_delete(pots);

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p != PK_NONE && s_PkInHand[p] && (s_PkFolded[p] || showdown))
        {
            ApplyAnimation(p,"INT_OFFICE","OFF_Sit_Crash",4.1,false,true,true,true,0,SYNC_ALL);
        }
    }

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p != PK_NONE)
        {
            s_PkCommitted[p] = 0;
        }
    }
}

static Pk_Showdown(t[e_PKT],id)
{
    Pk_TableMessage(t,"{F25B13} {[ Showdown ]}");
    t[E_PKT_STATE] = PK_BETWEEN;
    Pk_RefreshViewers(t,true);
    Pk_Award(t,id,true);
    Pk_EndHand(t);
    Pk_Sync(t);
}

static Pk_EndUncontested(t[e_PKT],id)
{
    Pk_Award(t,id,false);
    Pk_EndHand(t);
    Pk_RefreshViewers(t,false);
    Pk_Sync(t);
}

static Pk_BeginTurn(t[e_PKT],seat)
{
    new p = t[E_PKT_SEAT][seat], name[ACCOUNT_NAME_LEN], line[160];
    t[E_PKT_TURN] = seat;
    t[E_PKT_DUE_TURN] = GetTickCount() + PK_TURN_MS;
    Pk_Name(p,name);
    format(line,sizeof(line),"{008080}It's %s{008080}'s turn...",name);
    Pk_TableMessage(t,line);
    Pk_Message(p,"It's your turn. You have 20 seconds to make a decision.");
    Pk_ShowChoices(t,p);
    Pk_Sync(t);
}

static bool:Pk_NeedsAction(const t[e_PKT],seat)
{
    new p = t[E_PKT_SEAT][seat];

    if (!Pk_CanAct(t,seat))
    {
        return false;
    }

    if (s_PkRoundBet[p] < t[E_PKT_CURBET])
    {
        return true;
    }

    return !s_PkActed[p] && Pk_Count(t,false) >= 2;
}

static Pk_RoundDone(t[e_PKT],id)
{
    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p != PK_NONE)
        {
            s_PkRoundBet[p] = 0;
            s_PkActed[p] = false;
        }
    }

    t[E_PKT_CURBET] = 0;
    t[E_PKT_MINRAISE] = t[E_PKT_SB] * 2;

    if (t[E_PKT_ROUND] == 3)
    {
        Pk_Showdown(t,id);
        return;
    }

    t[E_PKT_ROUND]++;

    if (t[E_PKT_ROUND] == 1)
    {
        for (new i = 0;i < 3;i++)
        {
            t[E_PKT_COMM][i] = Pk_Draw(t);
        }

        Pk_TableMessage(t,"{D07035} {[ The Flop ]}");
    }
    else if (t[E_PKT_ROUND] == 2)
    {
        t[E_PKT_COMM][3] = Pk_Draw(t);
        Pk_TableMessage(t,"{D07035} {[ The Turn ]}");
    }
    else
    {
        t[E_PKT_COMM][4] = Pk_Draw(t);
        Pk_TableMessage(t,"{D07035} {[ The River ]} ");
    }

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        if (t[E_PKT_SEAT][s] != PK_NONE)
        {
            PlayerPlaySound(t[E_PKT_SEAT][s],1145,0.0,0.0,0.0);
        }
    }

    Pk_RefreshViewers(t,false);

    if (Pk_Count(t,false) >= 2)
    {
        t[E_PKT_STATE] = PK_HAND;
        new first = Pk_NextSeat(t,t[E_PKT_DEALER],true);
        Pk_BeginTurn(t,first);
    }
    else
    {
        t[E_PKT_STATE] = PK_RUNOUT;
        t[E_PKT_TURN] = PK_NONE;
        t[E_PKT_DUE_TURN] = 0;
        t[E_PKT_DUE_RUNOUT] = GetTickCount() + PK_RUNOUT_MS;
        Pk_Sync(t);
    }
}

static Pk_Advance(t[e_PKT],id,bool:moveTurn)
{
    if (Pk_Count(t,true) <= 1)
    {
        Pk_EndUncontested(t,id);
        return;
    }

    new pending;

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        if (Pk_NeedsAction(t,s))
        {
            pending++;
        }
    }

    if (pending == 0)
    {
        Pk_RoundDone(t,id);
        return;
    }

    if (moveTurn)
    {
        new from = t[E_PKT_TURN] == PK_NONE ? t[E_PKT_DEALER] : t[E_PKT_TURN];

        for (new i = 1;i <= t[E_PKT_SEATS];i++)
        {
            new seat = (from + i) % t[E_PKT_SEATS];

            if (Pk_NeedsAction(t,seat))
            {
                Pk_BeginTurn(t,seat);
                return;
            }
        }
    }

    Pk_Sync(t);
}

static Pk_Commit(const t[e_PKT],playerid,amount)
{
    new put = amount < s_PkChips[playerid] ? amount : s_PkChips[playerid];
    s_PkChips[playerid] -= put;
    s_PkRoundBet[playerid] += put;
    s_PkCommitted[playerid] += put;

    if (s_PkChips[playerid] == 0)
    {
        s_PkAllIn[playerid] = true;
    }

    #pragma unused t
}

static Pk_Bubble(playerid,const text[])
{
    SetPlayerChatBubble(playerid,text,-1,30.0,2000);
}

static Pk_FoldT(t[e_PKT],id,playerid)
{
    new name[ACCOUNT_NAME_LEN], line[96], seat = s_PkSeat[playerid], bool:wasTurn = t[E_PKT_TURN] == seat && t[E_PKT_STATE] == PK_HAND;
    ApplyAnimation(playerid,"INT_OFFICE","OFF_Sit_Crash",4.1,false,true,true,true,0,SYNC_ALL);
    s_PkFolded[playerid] = true;
    Pk_HideChoices(playerid);
    Pk_Name(playerid,name);
    format(line,sizeof(line),"{2DD9A9}  * * %s folds.. * *",name);
    Pk_TableMessage(t,line);
    Pk_Bubble(playerid,"{D6230A}** FOLDS ** ");

    if (wasTurn)
    {
        t[E_PKT_TURN] = PK_NONE;
        t[E_PKT_DUE_TURN] = 0;
    }

    Pk_Advance(t,id,wasTurn);
}

static bool:Pk_MyTurn(playerid,t[e_PKT],&id)
{
    id = s_PkTable[playerid];

    if (id == PK_NONE || !Pk_Get(id,t))
    {
        return false;
    }

    if (t[E_PKT_STATE] != PK_HAND || t[E_PKT_TURN] != s_PkSeat[playerid])
    {
        return false;
    }

    return true;
}

stock bool:Pk_Fold(playerid)
{
    new t[e_PKT], id;

    if (!Pk_MyTurn(playerid,t,id))
    {
        Pk_Message(playerid,"It is not your turn.");
        return false;
    }

    Pk_FoldT(t,id,playerid);
    Pk_Put(id,t);
    return true;
}

stock bool:Pk_CheckCall(playerid)
{
    new t[e_PKT], id;

    if (!Pk_MyTurn(playerid,t,id))
    {
        Pk_Message(playerid,"It is not your turn.");
        return false;
    }

    new name[ACCOUNT_NAME_LEN], line[128], cash[24], diff = t[E_PKT_CURBET] - s_PkRoundBet[playerid];
    Pk_Name(playerid,name);

    if (diff <= 0)
    {
        format(line,sizeof(line),"{2DD9A9}  * * %s checks .. * *",name);
        Pk_TableMessage(t,line);
        Pk_Bubble(playerid,"{22B1BD}** CHECKS ** ");
    }
    else
    {
        if (s_PkChips[playerid] < diff)
        {
            Pk_Message(playerid,"ERROR: You can't call as you don't have enough chips. You have two possible options: going all in or folding.");
            return false;
        }

        Pk_Cash(diff,cash);
        Pk_Commit(t,playerid,diff);
        format(line,sizeof(line),"{2DD9A9}  * * %s calls %s .. * *",name,cash);
        Pk_TableMessage(t,line);
        format(line,sizeof(line),"{22B1BD}** CALLS %s ** ",cash);
        Pk_Bubble(playerid,line);
    }

    s_PkActed[playerid] = true;
    Pk_HideChoices(playerid);
    t[E_PKT_DUE_TURN] = 0;
    Pk_Advance(t,id,true);
    Pk_Put(id,t);
    return true;
}

static Pk_Reopen(const t[e_PKT],playerid)
{
    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p != PK_NONE && p != playerid)
        {
            s_PkActed[p] = false;
        }
    }
}

stock bool:Pk_AllIn(playerid)
{
    new t[e_PKT], id;

    if (!Pk_MyTurn(playerid,t,id))
    {
        Pk_Message(playerid,"It is not your turn.");
        return false;
    }

    new name[ACCOUNT_NAME_LEN], line[128], cash[24], total = s_PkChips[playerid] + s_PkRoundBet[playerid], old = t[E_PKT_CURBET];
    ApplyAnimation(playerid,"INT_OFFICE","OFF_Sit_Idle_Loop",4.1,true,true,true,false,0,SYNC_ALL);
    Pk_Commit(t,playerid,s_PkChips[playerid]);
    Pk_Name(playerid,name);
    Pk_Cash(total,cash);
    format(line,sizeof(line),"{2DD9A9}  * * %s goes all in with %s .. * *",name,cash);
    Pk_TableMessage(t,line);
    format(line,sizeof(line),"{9512CD}** ALL IN with %s ** ",cash);
    Pk_Bubble(playerid,line);

    if (total > old)
    {
        if (total - old >= t[E_PKT_MINRAISE])
        {
            t[E_PKT_MINRAISE] = total - old;
        }

        t[E_PKT_CURBET] = total;
        Pk_Reopen(t,playerid);
    }

    s_PkActed[playerid] = true;
    Pk_HideChoices(playerid);
    t[E_PKT_DUE_TURN] = 0;
    Pk_Advance(t,id,true);
    Pk_Put(id,t);
    return true;
}

stock Pk_MinRaise(id)
{
    new t[e_PKT];

    if (!Pk_Get(id,t))
    {
        return 0;
    }

    return t[E_PKT_CURBET] == 0 ? t[E_PKT_SB] * 2 : t[E_PKT_CURBET] + (t[E_PKT_MINRAISE] > t[E_PKT_SB] * 2 ? t[E_PKT_MINRAISE] : t[E_PKT_SB] * 2);
}

stock bool:Pk_Raise(playerid,to)
{
    new t[e_PKT], id;

    if (!Pk_MyTurn(playerid,t,id))
    {
        Pk_Message(playerid,"It is not your turn.");
        return false;
    }

    new available = s_PkChips[playerid] + s_PkRoundBet[playerid];

    if (to > available)
    {
        Pk_Message(playerid,"You don't have that many chips available.");
        return false;
    }

    if (to == available)
    {
        return Pk_AllIn(playerid);
    }

    new minimum = t[E_PKT_CURBET] == 0 ? t[E_PKT_SB] * 2 : t[E_PKT_CURBET] + (t[E_PKT_MINRAISE] > t[E_PKT_SB] * 2 ? t[E_PKT_MINRAISE] : t[E_PKT_SB] * 2);

    if (to < minimum)
    {
        new cash[24], line[96];
        Pk_Cash(minimum,cash);
        format(line,sizeof(line),"The minimum raise is to %s.",cash);
        Pk_Message(playerid,line);
        return false;
    }

    new name[ACCOUNT_NAME_LEN], line[128], cash[24], old = t[E_PKT_CURBET], bool:bet = old == 0;
    Pk_Commit(t,playerid,to - s_PkRoundBet[playerid]);
    t[E_PKT_MINRAISE] = to - old;
    t[E_PKT_CURBET] = to;
    Pk_Reopen(t,playerid);
    s_PkActed[playerid] = true;
    Pk_Name(playerid,name);
    Pk_Cash(to,cash);
    format(line,sizeof(line),"{2DD9A9}  * * %s %s %s .. * *",name,bet ? ("bets") : ("raises to"),cash);
    Pk_TableMessage(t,line);
    format(line,sizeof(line),"{31CA15}** %s %s ** ",bet ? ("BETS") : ("RAISES to"),cash);
    Pk_Bubble(playerid,line);
    Pk_HideChoices(playerid);
    t[E_PKT_DUE_TURN] = 0;
    Pk_Advance(t,id,true);
    Pk_Put(id,t);
    return true;
}

static Pk_Post(t[e_PKT],seat,amount,const kind[])
{
    new p = t[E_PKT_SEAT][seat], name[ACCOUNT_NAME_LEN], line[128], cash[24];
    Pk_Name(p,name);

    if (s_PkChips[p] <= amount)
    {
        Pk_Cash(s_PkChips[p],cash);
        Pk_Commit(t,p,s_PkChips[p]);
        format(line,sizeof(line),"{2DD9A9}  * * %s goes all in with %s .. * *",name,cash);
    }
    else
    {
        Pk_Cash(amount,cash);
        Pk_Commit(t,p,amount);
        format(line,sizeof(line),"{2DD9A9} * * %s posts a %s blind of %s.. * *",name,kind,cash);
    }

    Pk_TableMessage(t,line);

    if (s_PkRoundBet[p] > t[E_PKT_CURBET])
    {
        t[E_PKT_CURBET] = s_PkRoundBet[p];
    }
}

static Pk_DealT(t[e_PKT],id)
{
    t[E_PKT_STATE] = PK_HAND;
    t[E_PKT_DUE_DEAL] = 0;
    t[E_PKT_ROUND] = 0;
    t[E_PKT_CURBET] = 0;
    t[E_PKT_MINRAISE] = t[E_PKT_SB] * 2;

    for (new card = 0;card < 2;card++)
    {
        for (new k = 1;k <= t[E_PKT_SEATS];k++)
        {
            new seat = (t[E_PKT_DEALER] + k) % t[E_PKT_SEATS], p = t[E_PKT_SEAT][seat];

            if (p != PK_NONE && s_PkInHand[p])
            {
                s_PkCards[p][card] = Pk_Draw(t);
            }
        }
    }

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        if (t[E_PKT_SEAT][s] != PK_NONE)
        {
            PlayerPlaySound(t[E_PKT_SEAT][s],1145,0.0,0.0,0.0);
        }
    }

    Pk_Post(t,t[E_PKT_SBSEAT],t[E_PKT_SB],"small");
    Pk_Post(t,t[E_PKT_BBSEAT],t[E_PKT_SB] * 2,"big");
    Pk_RefreshViewers(t,false);
    Pk_Sync(t);
    t[E_PKT_TURN] = t[E_PKT_BBSEAT];
    Pk_Advance(t,id,true);
}

static bool:Pk_StartHandT(t[e_PKT],id)
{
    new name[ACCOUNT_NAME_LEN], line[160];

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p != PK_NONE && s_PkChips[p] <= 0)
        {
            Pk_Message(p,"You don't have any chips left.");
            Pk_Message(p,"You may join the table again and pay the buy-in fee to play once again!");
            Pk_Name(p,name);
            format(line,sizeof(line),"{BEBEBE}-- {FFFFFF}Player %s has been kicked out of the table. [Reason: Ran out of chips]",name);
            Pk_TableMessage(t,line);
            Pk_LeaveT(p,t);
        }
    }

    if (Pk_Occupied(t) < PK_MIN_SEATS)
    {
        Pk_TableMessage(t,"{BEBEBE}-- {FFFFFF}There aren't enough players to start a game");
        t[E_PKT_STATE] = PK_IDLE;
        t[E_PKT_DUE_START] = 0;
        t[E_PKT_DUE_NEXT] = 0;
        t[E_PKT_DUE_BUST] = 0;
        return false;
    }

    for (new i = 0;i < 5;i++)
    {
        t[E_PKT_COMM][i] = CARD_NONE;
    }

    new occupied[PK_MAX_SEATS], n;

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p != PK_NONE)
        {
            s_PkInHand[p] = true;
            s_PkFolded[p] = false;
            s_PkAllIn[p] = false;
            s_PkActed[p] = false;
            s_PkRoundBet[p] = 0;
            s_PkCommitted[p] = 0;
            s_PkCards[p][0] = CARD_NONE;
            s_PkCards[p][1] = CARD_NONE;
            occupied[n++] = s;
            PlayerPlaySound(p,1058,0.0,0.0,0.0);
            ApplyAnimation(p,"INT_OFFICE","OFF_Sit_Bored_Loop",4.1,true,true,true,false,0,SYNC_ALL);
        }
    }

    new dealer = PK_NONE;

    if (t[E_PKT_LASTDEALER] != PK_NONE)
    {
        for (new i = 1;i <= t[E_PKT_SEATS];i++)
        {
            new seat = (t[E_PKT_LASTDEALER] + i) % t[E_PKT_SEATS];

            if (t[E_PKT_SEAT][seat] != PK_NONE)
            {
                dealer = seat;
                break;
            }
        }
    }

    if (dealer == PK_NONE)
    {
        dealer = occupied[random(n)];
    }

    t[E_PKT_DEALER] = dealer;
    new first = Pk_NextSeat(t,dealer,false);

    if (n == 2)
    {
        t[E_PKT_BBSEAT] = dealer;
        t[E_PKT_SBSEAT] = first;
        Pk_Name(t[E_PKT_SEAT][dealer],name);
        format(line,sizeof(line),"{BEBEBE}-- {FFFFFF}Player %s has been chosen to be the dealer and big blind in this first stage of the game!",name);
        Pk_TableMessage(t,line);
        Pk_NameLabel(t[E_PKT_SEAT][dealer],"Big Blind + Dealer");
        Pk_Name(t[E_PKT_SEAT][first],name);
        format(line,sizeof(line),"{BEBEBE}-- {FFFFFF}Player %s has been chosen to be the small blind in this first stage of the game!",name);
        Pk_TableMessage(t,line);
        Pk_NameLabel(t[E_PKT_SEAT][first],"Small Blind");
    }
    else
    {
        new big = Pk_NextSeat(t,first,false);
        t[E_PKT_SBSEAT] = first;
        t[E_PKT_BBSEAT] = big;
        Pk_Name(t[E_PKT_SEAT][dealer],name);
        format(line,sizeof(line),"{BEBEBE}-- {FFFFFF}Player %s has been chosen to be the dealer in this first stage of the game!",name);
        Pk_TableMessage(t,line);
        Pk_NameLabel(t[E_PKT_SEAT][dealer],"Dealer");
        Pk_Name(t[E_PKT_SEAT][first],name);
        format(line,sizeof(line),"{BEBEBE}-- {FFFFFF}Player %s has been chosen to be the Small Blind in this first stage of the game!",name);
        Pk_TableMessage(t,line);
        Pk_NameLabel(t[E_PKT_SEAT][first],"Small Blind");
        Pk_Name(t[E_PKT_SEAT][big],name);
        format(line,sizeof(line),"{BEBEBE}-- {FFFFFF}Player %s has been chosen to be the Big Blind in this first stage of the game!",name);
        Pk_TableMessage(t,line);
        Pk_NameLabel(t[E_PKT_SEAT][big],"Big Blind");
    }

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p != PK_NONE && s != t[E_PKT_DEALER] && s != t[E_PKT_SBSEAT] && s != t[E_PKT_BBSEAT])
        {
            Pk_NameLabel(p);
        }
    }

    Pk_Reshuffle(t);
    t[E_PKT_STATE] = PK_DEALING;
    t[E_PKT_TURN] = PK_NONE;
    t[E_PKT_DUE_START] = 0;
    t[E_PKT_DUE_NEXT] = 0;
    t[E_PKT_DUE_BUST] = 0;
    t[E_PKT_DUE_DEAL] = GetTickCount() + PK_DEAL_MS;
    Pk_TableMessage(t,"{BEBEBE}-- {FFFFFF}Dealer is shuffling the pack of cards. Cards will be handed out in two seconds...!");
    Pk_RefreshViewers(t,false);
    Pk_Sync(t);
    #pragma unused id
    return true;
}

static Pk_RefundHand(const t[e_PKT])
{
    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p != PK_NONE)
        {
            s_PkChips[p] += s_PkCommitted[p];
            s_PkCommitted[p] = 0;
            s_PkRoundBet[p] = 0;
            s_PkInHand[p] = false;
        }
    }
}

static Pk_EmptyT(t[e_PKT])
{
    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        if (t[E_PKT_SEAT][s] != PK_NONE)
        {
            Pk_LeaveT(t[E_PKT_SEAT][s],t);
        }
    }

    t[E_PKT_STATE] = PK_IDLE;
    t[E_PKT_DUE_START] = 0;
    t[E_PKT_DUE_DEAL] = 0;
    t[E_PKT_DUE_TURN] = 0;
    t[E_PKT_DUE_NEXT] = 0;
    t[E_PKT_DUE_BUST] = 0;
    t[E_PKT_DUE_RUNOUT] = 0;
}

stock bool:Pk_Abort(id)
{
    new t[e_PKT];

    if (!Pk_Get(id,t) || t[E_PKT_STATE] == PK_IDLE || t[E_PKT_STATE] == PK_BETWEEN)
    {
        return false;
    }

    Pk_RefundHand(t);
    Pk_EmptyT(t);
    Pk_ResetLabel(t);
    Pk_Put(id,t);
    return true;
}

stock bool:Pk_Destroy(id)
{
    new t[e_PKT];

    if (!Pk_Get(id,t))
    {
        return false;
    }

    Pk_RefundHand(t);
    Pk_EmptyT(t);
    Pk_DestroyObjects(t);
    map_remove(s_PkTables,id);
    return true;
}

static Pk_CleanupT(playerid,t[e_PKT],id,const reason[])
{
    new name[ACCOUNT_NAME_LEN], line[128];

    if (s_PkInHand[playerid] && !s_PkFolded[playerid] && (t[E_PKT_STATE] == PK_DEALING || t[E_PKT_STATE] == PK_HAND || t[E_PKT_STATE] == PK_RUNOUT))
    {
        Pk_FoldT(t,id,playerid);
    }

    Pk_Name(playerid,name);
    format(line,sizeof(line),"Player %s has been kicked out from the table [REASON: %s].",name,reason);
    Pk_LeaveT(playerid,t);
    Pk_TableMessage(t,line);
}

stock Pk_Cleanup(playerid,const reason[])
{
    new id = Pk_PlayerTable(playerid), t[e_PKT];

    if (id == PK_NONE || !Pk_Get(id,t))
    {
        return;
    }

    Pk_CleanupT(playerid,t,id,reason);
    Pk_Put(id,t);
}

stock bool:Pk_CanLeave(playerid)
{
    new id = Pk_PlayerTable(playerid), t[e_PKT];

    if (id == PK_NONE || !Pk_Get(id,t))
    {
        return false;
    }

    if (t[E_PKT_STATE] == PK_COUNTDOWN || t[E_PKT_STATE] == PK_DEALING)
    {
        return false;
    }

    return !((t[E_PKT_STATE] == PK_HAND || t[E_PKT_STATE] == PK_RUNOUT) && s_PkInHand[playerid] && !s_PkFolded[playerid]);
}

stock bool:Pk_Leave(playerid)
{
    new id = Pk_PlayerTable(playerid), t[e_PKT];

    if (id == PK_NONE || !Pk_Get(id,t))
    {
        return false;
    }

    if (!Pk_CanLeave(playerid))
    {
        Pk_Message(playerid,"You cannot exit this table as there's currently an active match under process.");
        return false;
    }

    Pk_LeaveT(playerid,t);
    Pk_Put(id,t);
    return true;
}

static bool:Pk_PlayerFree(playerid)
{
    return Player_IsFree(playerid) && Injury_GetMode(playerid) == INJURY_MODE_NORMAL && !Law_IsCuffed(playerid) && !Horse_IsRiding(playerid) && !Jail_IsJailed(playerid) && !Trap_IsCaught(playerid) && !Lasso_IsCaught(playerid) && !Point_IsSleeping(playerid) && !Bj_IsPlaying(playerid);
}

stock bool:Pk_Join(playerid,id)
{
    new t[e_PKT];

    if (!Pk_Get(id,t) || Pk_IsSeated(playerid))
    {
        return false;
    }

    if (!Pk_PlayerFree(playerid))
    {
        SendServerMessage(playerid,"You can't do this right now.",MSG_TYPE_ERROR);
        return false;
    }

    new seat = PK_NONE;

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        if (t[E_PKT_SEAT][s] == PK_NONE)
        {
            seat = s;
            break;
        }
    }

    if (seat == PK_NONE)
    {
        Pk_Message(playerid,"There aren't currently any unnocupied seats in this table at the moment. You cannot enter it.");
        return false;
    }

    new line[160], cash[24];

    if (!Money_CanAfford(playerid,Money_Make(t[E_PKT_BUYIN])))
    {
        Pk_Cash(t[E_PKT_BUYIN],cash);
        format(line,sizeof(line),"You don't have enough money to access this table. Buy In: %s",cash);
        Pk_Message(playerid,line);
        return false;
    }

    new index = Pk_FreeAttach(playerid);

    if (index == PK_NONE)
    {
        Pk_Message(playerid,"You cannot access this table in this moment.");
        return false;
    }

    Pk_ResetPlayer(playerid);
    GetPlayerPos(playerid,s_PkSaved[playerid][0],s_PkSaved[playerid][1],s_PkSaved[playerid][2]);
    GetPlayerFacingAngle(playerid,s_PkSaved[playerid][3]);
    new Float:sx = t[E_PKT_SEATX][seat], Float:sy = t[E_PKT_SEATY][seat], Float:facing = atan2(t[E_PKT_Y] - sy,t[E_PKT_X] - sx) - 90.0, name[ACCOUNT_NAME_LEN];
    DestroyDynamicObject(STREAMER_TAG_OBJECT:t[E_PKT_CHAIR][seat]);
    t[E_PKT_CHAIR][seat] = 0;
    SetPlayerPos(playerid,sx,sy,t[E_PKT_Z]);
    SetPlayerFacingAngle(playerid,facing);
    SetPlayerAttachedObject(playerid,index,PK_CHAIR_MODEL,7,0.061999,-0.046,0.095999,90.6,-171.8,-10.5,1.0,1.0,1.0);
    TogglePlayerControllable(playerid,false);
    InterpolateCameraPos(playerid,t[E_PKT_X],t[E_PKT_Y],t[E_PKT_Z] + PK_CAMERA_Z,t[E_PKT_X],t[E_PKT_Y],t[E_PKT_Z] + PK_CAMERA_Z,5000);
    InterpolateCameraLookAt(playerid,t[E_PKT_X],t[E_PKT_Y],t[E_PKT_Z],t[E_PKT_X],t[E_PKT_Y],t[E_PKT_Z],5000);
    ApplyAnimation(playerid,"INT_OFFICE","OFF_Sit_Bored_Loop",4.1,true,true,true,false,0,SYNC_ALL);
    Pk_Name(playerid,name);
    format(line,sizeof(line),"%s\n* waiting next game *",name);
    s_PkLabel[playerid] = _:CreateDynamic3DTextLabel(line,0x808080FF,sx,sy,t[E_PKT_Z],15.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,t[E_PKT_WORLD],t[E_PKT_INT],-1,5.0);
    s_PkAttach[playerid] = index;
    s_PkSeat[playerid] = seat;
    s_PkTable[playerid] = id;
    Pk_BuildTds(playerid,t[E_PKT_SEATS]);
    t[E_PKT_SEAT][seat] = playerid;
    Money_Take(playerid,Money_Make(t[E_PKT_BUYIN]));
    s_PkChips[playerid] = t[E_PKT_BUYIN];
    Player_SetBusy(playerid,E_PLAYER_BUSY_POKER,true);
    Pk_Cash(t[E_PKT_BUYIN],cash);
    format(line,sizeof(line),"You've been charged %s as a result of joining in the table.",cash);
    Pk_Message(playerid,line);

    if (t[E_PKT_STATE] == PK_IDLE)
    {
        if (Pk_Occupied(t) == PK_MIN_SEATS)
        {
            Pk_TableMessage(t,"{BEBEBE}-- {FFFFFF}There are currently two players in the table.");
            Pk_TableMessage(t,"{BEBEBE}-- {FFFFFF}Any players interested in being part of this game have 5 seconds to join the table.");
            Pk_TableMessage(t,"{BEBEBE}-- {FFFFFF}The game will begin in 5 seconds...");
            t[E_PKT_STATE] = PK_COUNTDOWN;
            t[E_PKT_DUE_START] = GetTickCount() + PK_START_MS;
        }
    }
    else if (t[E_PKT_STATE] != PK_COUNTDOWN)
    {
        Pk_Message(playerid,"You have entered this poker table but the game has already begun.");
        Pk_Message(playerid,"You must wait until this match is finished to play!");
        format(line,sizeof(line),"{25728B}- - Player %s has joined the table... - -",name);
        Pk_TableMessage(t,line);
    }

    SendClientMessage(playerid,0x3A5FCDFF,"[POKER WARNING]{DEDEDE} This script is {F4C100}EXPERIMENTAL{DEDEDE}! Bugs will be found!");
    Pk_RefreshViewers(t,false);
    Pk_Sync(t);
    Streamer_Update(playerid);
    Pk_Put(id,t);
    return true;
}

static Pk_Busted(t[e_PKT],id)
{
    new name[ACCOUNT_NAME_LEN], line[160], cash[24];

    for (new s = 0;s < t[E_PKT_SEATS];s++)
    {
        new p = t[E_PKT_SEAT][s];

        if (p == PK_NONE || s_PkChips[p] > 0)
        {
            continue;
        }

        if (!Money_CanAfford(p,Money_Make(t[E_PKT_BUYIN])))
        {
            Pk_Message(p,"You don't have any chips left.");
            Pk_Message(p,"You may join the table again and pay the buy-in fee to play once again!");
            Pk_Name(p,name);
            format(line,sizeof(line),"{BEBEBE}-- {FFFFFF}Player %s has been kicked out of the table. [Reason: Ran out of chips]",name);
            Pk_TableMessage(t,line);
            Pk_LeaveT(p,t);
        }
        else if (!s_PkDialog[p])
        {
            s_PkDialog[p] = true;
            SetTimerEx("Poker_BustedDeferred",0,false,"dd",p,Account_GetToken(p));
        }
    }

    #pragma unused id,cash
}

static Pk_BustedFlow(playerid,token)
{
    yield 1;
    new response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"Buy_In","{FFFFFF}You've ran out of chips. Do you want to pay the buy-in fee again to continue playing?","Yes","No");

    if (!Account_IsCurrent(playerid,token) || !Pk_IsSeated(playerid))
    {
        return;
    }

    s_PkDialog[playerid] = false;
    new id = Pk_PlayerTable(playerid), t[e_PKT];

    if (id == PK_NONE || !Pk_Get(id,t) || s_PkChips[playerid] > 0)
    {
        return;
    }

    new name[ACCOUNT_NAME_LEN], line[160], cash[24];
    Pk_Name(playerid,name);
    Pk_Cash(t[E_PKT_BUYIN],cash);

    if (response[DIALOG_RESPONSE_RESPONSE] && Money_Take(playerid,Money_Make(t[E_PKT_BUYIN])))
    {
        s_PkChips[playerid] = t[E_PKT_BUYIN];
        format(line,sizeof(line),"{BEBEBE}-- {FFFFFF}Player %s has paid the buy-in fee of %s chips to keep playing.",name,cash);
        Pk_TableMessage(t,line);
        Pk_Sync(t);
    }
    else
    {
        format(line,sizeof(line),"{BEBEBE}-- {FFFFFF}Player %s has been kicked out of the table. [Reason: Failure to pay the buy-in fee]",name);
        Pk_TableMessage(t,line);
        Pk_LeaveT(playerid,t);
    }

    Pk_Put(id,t);
}

public Poker_BustedDeferred(playerid,token)
{
    Pk_BustedFlow(playerid,token);
    return 1;
}

static Pk_RaiseFlow(playerid,token)
{
    yield 1;

    for (;;)
    {
        new response[DIALOG_RESPONSE], body[200], t[e_PKT], id;

        if (!Pk_MyTurn(playerid,t,id))
        {
            return;
        }

        format(body,sizeof(body),"{FFFFFF}Please input the desired amount of chips: \n{FFFFFF}You may type {FF8000}%d {FFFFFF} if you want to go All In\n",s_PkChips[playerid] + s_PkRoundBet[playerid]);
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_INPUT,"{FF8000}Input",body,"Submit","Cancel");

        if (!Account_IsCurrent(playerid,token) || !Pk_MyTurn(playerid,t,id))
        {
            return;
        }

        if (!response[DIALOG_RESPONSE_RESPONSE])
        {
            Pk_ShowChoices(t,playerid);
            return;
        }

        new amount;

        if (sscanf(response[DIALOG_RESPONSE_INPUTTEXT],"d",amount))
        {
            Pk_Message(playerid,"Input must be numeric.");
            continue;
        }

        if (amount <= 0)
        {
            Pk_Message(playerid,"Input must be greater than 0.");
            continue;
        }

        if (Pk_Raise(playerid,amount))
        {
            return;
        }
    }
}

public Poker_RaiseDeferred(playerid,token)
{
    Pk_RaiseFlow(playerid,token);
    return 1;
}

stock Pk_Tick()
{
    new ids[64], count, now = GetTickCount();

    if (!map_valid(s_PkTables))
    {
        return;
    }

    for (new Iter:it = map_iter(s_PkTables);iter_inside(it) && count < sizeof(ids);iter_move_next(it))
    {
        ids[count++] = iter_get_key(it);
    }

    for (new i = 0;i < count;i++)
    {
        new t[e_PKT], id = ids[i];

        if (!Pk_Get(id,t))
        {
            continue;
        }

        switch (t[E_PKT_STATE])
        {
            case PK_COUNTDOWN:
            {
                if (now - t[E_PKT_DUE_START] >= 0)
                {
                    if (Pk_Occupied(t) >= PK_MIN_SEATS)
                    {
                        Pk_StartHandT(t,id);
                    }
                    else
                    {
                        t[E_PKT_STATE] = PK_IDLE;
                        t[E_PKT_DUE_START] = 0;
                    }
                }
            }
            case PK_DEALING:
            {
                if (now - t[E_PKT_DUE_DEAL] >= 0)
                {
                    Pk_DealT(t,id);
                }
            }
            case PK_HAND:
            {
                if (t[E_PKT_TURN] != PK_NONE && t[E_PKT_DUE_TURN] != 0 && now - t[E_PKT_DUE_TURN] >= 0)
                {
                    new p = t[E_PKT_SEAT][t[E_PKT_TURN]];

                    if (p != PK_NONE)
                    {
                        Pk_FoldT(t,id,p);
                    }
                }
            }
            case PK_RUNOUT:
            {
                if (now - t[E_PKT_DUE_RUNOUT] >= 0)
                {
                    t[E_PKT_DUE_RUNOUT] = 0;
                    Pk_RoundDone(t,id);
                }
            }
            case PK_BETWEEN:
            {
                if (t[E_PKT_DUE_BUST] != 0 && now - t[E_PKT_DUE_BUST] >= 0)
                {
                    t[E_PKT_DUE_BUST] = 0;
                    Pk_Busted(t,id);
                }

                if (t[E_PKT_DUE_NEXT] != 0 && now - t[E_PKT_DUE_NEXT] >= 0)
                {
                    t[E_PKT_DUE_NEXT] = 0;
                    Pk_StartHandT(t,id);
                }
            }
        }

        Pk_Put(id,t);
    }
}

static Pk_Load()
{
    yield 1;
    await mysql_aquery_s(g_Mysql,str_new("SELECT poker_table_id, poker_table_buy_in, poker_table_small_blind, poker_table_x_pos, poker_table_y_pos, poker_table_z_pos, poker_table_seats, poker_table_vw, poker_table_interior FROM poker"),false);
    new loaded;

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, buyIn, blind, Float:x, Float:y, Float:z, seats, world, interior;
        cache_get_value_name_int(i,"poker_table_id",id);
        cache_get_value_name_int(i,"poker_table_buy_in",buyIn);
        cache_get_value_name_int(i,"poker_table_small_blind",blind);
        cache_get_value_name_float(i,"poker_table_x_pos",x);
        cache_get_value_name_float(i,"poker_table_y_pos",y);
        cache_get_value_name_float(i,"poker_table_z_pos",z);
        cache_get_value_name_int(i,"poker_table_seats",seats);
        cache_get_value_name_int(i,"poker_table_vw",world);
        cache_get_value_name_int(i,"poker_table_interior",interior);

        if (seats < PK_MIN_SEATS || seats > PK_MAX_SEATS || blind < 1 || buyIn <= blind * 2 || Pk_TableExists(id))
        {
            continue;
        }

        Pk_BuildTable(id,buyIn,blind,x,y,z,seats,world,interior);
        loaded++;
    }

    Log_Info("poker","Loaded %d poker tables",loaded);
    Boot_LoaderDone();
}

#pragma warning push
#pragma warning disable 204
public Poker_Load()
{
    Pk_Load();
    return 1;
}
#pragma warning pop

static Pk_Create(playerid,token,seats,blind,buyIn,Float:x,Float:y,Float:z,world,interior)
{
    yield 1;
    await mysql_aquery_s(g_Mysql,str_format("INSERT INTO poker (poker_table_buy_in, poker_table_small_blind, poker_table_x_pos, poker_table_y_pos, poker_table_z_pos, poker_table_seats, poker_table_vw, poker_table_interior) VALUES (%d, %d, %f, %f, %f, %d, %d, %d)",buyIn,blind,x,y,z,seats,world,interior),false);
    new id = cache_insert_id();

    if (id < 1)
    {
        return;
    }

    Pk_BuildTable(id,buyIn,blind,x,y,z,seats,world,interior);

    if (Account_IsCurrent(playerid,token))
    {
        new line[200], blindCash[24], bigCash[24], buyCash[24];
        Pk_Cash(blind,blindCash);
        Pk_Cash(blind * 2,bigCash);
        Pk_Cash(buyIn,buyCash);
        format(line,sizeof(line),"You have created table ID: %d | Small blind: %s | Big blind: %s | Buy In: %s | Seats: %d",id,blindCash,bigCash,buyCash,seats);
        Pk_Message(playerid,line);
    }
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
CMD:pokercam(cmdid,playerid,params[])
{
    #pragma unused cmdid, params
    new id = Pk_PlayerTable(playerid), t[e_PKT];

    if (id != PK_NONE && Pk_Get(id,t))
    {
        SetPlayerCameraPos(playerid,t[E_PKT_X],t[E_PKT_Y],t[E_PKT_Z] + PK_CAMERA_Z);
        SetPlayerCameraLookAt(playerid,t[E_PKT_X],t[E_PKT_Y],t[E_PKT_Z]);
    }

    return 1;
}

CMD:ctable(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new seats, blind, buyIn;

    if (sscanf(params,"ddd",seats,blind,buyIn))
    {
        SendServerMessage(playerid,"/ctable [number of seats] [small blind] [buy in]",MSG_TYPE_INFO);
        SendServerMessage(playerid,"Creating a table saves it in the database, /dtable deletes it for good.",MSG_TYPE_WARN);
        return 1;
    }

    if (seats < PK_MIN_SEATS || seats > PK_MAX_SEATS)
    {
        SendServerMessage(playerid,"A poker table needs 2 to 6 seats.",MSG_TYPE_ERROR);
        return 1;
    }

    if (blind < 1)
    {
        SendServerMessage(playerid,"The small blind has to be at least 1.",MSG_TYPE_ERROR);
        return 1;
    }

    if (buyIn <= blind * 2)
    {
        SendServerMessage(playerid,"Buy in cannot be less than the small blind or big blind.",MSG_TYPE_ERROR);
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid,x,y,z);
    Pk_Create(playerid,Account_GetToken(playerid),seats,blind,buyIn,x,y,z - 0.6,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));
    return 1;
}

CMD:dtable(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new id;

    if (sscanf(params,"d",id))
    {
        SendClientMessage(playerid,0x3E969FFF,"/dtable [pokertable ID]");
        return 1;
    }

    if (!Pk_TableExists(id))
    {
        SendClientMessage(playerid,0x3E969FFF,"Invalid pokertable ID");
        return 1;
    }

    new line[64];
    Pk_Destroy(id);
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM poker WHERE poker_table_id = %d",id));
    format(line,sizeof(line),"You have deleted poker table ID: %d",id);
    Pk_Message(playerid,line);
    return 1;
}

CMD:agame(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_ADVANCED))
    {
        return 1;
    }

    new id;

    if (sscanf(params,"d",id))
    {
        Pk_Message(playerid,"/agame [table ID]");
        Pk_Message(playerid,"Will abort a game if started, ejecting all the players out of the table.");
        return 1;
    }

    if (!Pk_TableExists(id))
    {
        SendClientMessage(playerid,0x3E969FFF,"Invalid pokertable ID");
        return 1;
    }

    if (Pk_Abort(id))
    {
        new line[96];
        format(line,sizeof(line),"You have successfully aborted the game on table ID: %d",id);
        Pk_Message(playerid,line);
    }
    else
    {
        Pk_Message(playerid,"No game has started in this table yet.");
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

hook OnMigrationRun()
{
    Migration_Add("games-1-poker","CREATE TABLE IF NOT EXISTS poker (poker_table_id INT UNSIGNED NOT NULL AUTO_INCREMENT, poker_table_buy_in INT NOT NULL DEFAULT 0, poker_table_small_blind INT NOT NULL DEFAULT 0, poker_table_x_pos FLOAT NOT NULL DEFAULT 0, poker_table_y_pos FLOAT NOT NULL DEFAULT 0, poker_table_z_pos FLOAT NOT NULL DEFAULT 0, poker_table_seats INT NOT NULL DEFAULT 0, poker_table_vw INT NOT NULL DEFAULT 0, poker_table_interior INT NOT NULL DEFAULT 0, PRIMARY KEY (poker_table_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

Timer_Declare(Pk_Timer)
{
    Pk_Tick();
    return 1;
}

hook OnGameModeInit()
{
    s_PkTables = map_new();
    Boot_RegisterLoader("Poker_Load");
    Timer_Start(Pk_Timer,PK_TICK_MS);
}

hook OnGameModeExit()
{
    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (Pk_IsSeated(i))
        {
            Pk_Cleanup(i,"Server restart");
        }
    }
}

hook OnPlayerConnect(playerid)
{
    for (new i = 0;i < PK_TD_HOLE;i++)
    {
        s_PkHole[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    for (new i = 0;i < PK_TD_COMMUNITY;i++)
    {
        s_PkCommunity[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    for (new i = 0;i < PK_TD_CHOICES;i++)
    {
        s_PkChoices[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }

    Pk_ResetPlayer(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Pk_Cleanup(playerid,"Disconnected");
}

hook OnPlayerDeath(playerid,killerid,WEAPON:reason)
{
    Pk_Cleanup(playerid,"Died");
}

hook Character_OnSavePosition(playerid)
{
    if (Pk_IsSeated(playerid))
    {
        SetPlayerPos(playerid,s_PkSaved[playerid][0],s_PkSaved[playerid][1],s_PkSaved[playerid][2]);
    }
}

hook Staff_OnServerRestart()
{
    if (!map_valid(s_PkTables))
    {
        return;
    }

    new ids[128], count = 0;

    for (new Iter:it = map_iter(s_PkTables);iter_inside(it) && count < sizeof(ids);iter_move_next(it))
    {
        ids[count++] = iter_get_key(it);
    }

    for (new i = 0;i < count;i++)
    {
        Pk_Abort(ids[i]);
    }
}

hook Character_OnLeaving(playerid,characterid)
{
    Pk_Cleanup(playerid,"Disconnected");
}

hook OnPlayerKeyStateChange(playerid,KEY:newkeys,KEY:oldkeys)
{
    if (!(newkeys & KEY_SECONDARY_ATTACK) || (oldkeys & KEY_SECONDARY_ATTACK))
    {
        return;
    }

    if (Pk_IsSeated(playerid))
    {
        Pk_Leave(playerid);
        return;
    }

    if (!map_valid(s_PkTables))
    {
        return;
    }

    new Float:x, Float:y, Float:z, best = PK_NONE, Float:bestDistance = 99999.0;
    GetPlayerPos(playerid,x,y,z);

    for (new Iter:it = map_iter(s_PkTables);iter_inside(it);iter_move_next(it))
    {
        new t[e_PKT], id = iter_get_key(it);

        if (!Pk_Get(id,t) || t[E_PKT_WORLD] != GetPlayerVirtualWorld(playerid) || t[E_PKT_INT] != GetPlayerInterior(playerid))
        {
            continue;
        }

        new Float:distance = VectorSize(x - t[E_PKT_X],y - t[E_PKT_Y],z - t[E_PKT_Z]);

        if (distance < bestDistance)
        {
            bestDistance = distance;
            best = id;
        }
    }

    if (best != PK_NONE && bestDistance <= PK_JOIN_RANGE)
    {
        Pk_Join(playerid,best);
    }
}

hook OnPlayerClickPlayerTextDraw(playerid,PlayerText:playertextid)
{
    if (!Pk_IsSeated(playerid) || s_PkChoices[playerid][PK_CHOICE_CALL] == PlayerText:INVALID_TEXT_DRAW)
    {
        return;
    }

    if (playertextid == s_PkChoices[playerid][PK_CHOICE_FOLD])
    {
        Pk_Fold(playerid);
    }
    else if (playertextid == s_PkChoices[playerid][PK_CHOICE_CALL])
    {
        Pk_CheckCall(playerid);
    }
    else if (playertextid == s_PkChoices[playerid][PK_CHOICE_RAISE])
    {
        if (s_PkRaiseKind[playerid] == PK_RAISE_ALLIN)
        {
            Pk_AllIn(playerid);
            return;
        }

        new line[128];
        format(line,sizeof(line),"Please enter an amount to %s, the total amount of chips you current have is: %d",s_PkRaiseKind[playerid] == PK_RAISE_BET ? ("bet") : ("raise"),s_PkChips[playerid]);
        Pk_Message(playerid,line);
        Pk_HideChoices(playerid);
        SetTimerEx("Poker_RaiseDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
    }
}

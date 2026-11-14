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
#define MSGSPLIT_MAX_LENGTH (144)
#define MSGSPLIT_HYPHEN_START "... "
#define MSGSPLIT_HYPHEN_END " ..."
#define MSGSPLIT_COLOUR_LEN (8)

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
static MessageSplit_LastColour(const message[], endPos, colour[], size)
{
    for (new i = endPos;i >= MSGSPLIT_COLOUR_LEN - 1;i--)
    {
        if (message[i] == '}' && message[i - (MSGSPLIT_COLOUR_LEN - 1)] == '{')
        {
            strmid(colour, message, i - (MSGSPLIT_COLOUR_LEN - 1), i + 1, size);
            return;
        }
    }
}

stock MessageSplit_SendClientMessage(playerid, colour, const message[])
{
    new length = strlen(message);

    if (length < MSGSPLIT_MAX_LENGTH)
    {
        return SendClientMessage(playerid, colour, message);
    }

    new start = 0, line = 0;
    new lastColour[MSGSPLIT_COLOUR_LEN + 1], chunk[MSGSPLIT_MAX_LENGTH + 24], slice[MSGSPLIT_MAX_LENGTH + 1];

    while (start < length)
    {
        new budget = MSGSPLIT_MAX_LENGTH - 1;

        if (line > 0)
        {
            budget -= strlen(MSGSPLIT_HYPHEN_START) + strlen(lastColour);
        }

        new endPos = start + budget;
        new bool:isLast = endPos >= length;

        if (isLast)
        {
            endPos = length;
        }
        else
        {
            budget -= strlen(MSGSPLIT_HYPHEN_END);
            endPos = start + budget;

            new cut = endPos;

            while (cut > start && message[cut] != ' ')
            {
                cut--;
            }

            if (cut > start)
            {
                endPos = cut;
            }
        }

        strmid(slice, message, start, endPos, sizeof(slice));

        if (line > 0)
        {
            format(chunk, sizeof(chunk), "%s%s%s%s", MSGSPLIT_HYPHEN_START, lastColour, slice, isLast ? ("") : (MSGSPLIT_HYPHEN_END));
        }
        else
        {
            format(chunk, sizeof(chunk), "%s%s", slice, MSGSPLIT_HYPHEN_END);
        }

        SendClientMessage(playerid, colour, chunk);

        MessageSplit_LastColour(message, endPos - 1, lastColour, sizeof(lastColour));

        start = endPos;

        while (start < length && message[start] == ' ')
        {
            start++;
        }

        line++;
    }

    return 1;
}

#if defined _ALS_SendClientMessage
    #undef SendClientMessage
#else
    #define _ALS_SendClientMessage
#endif
#define SendClientMessage MessageSplit_SendClientMessage

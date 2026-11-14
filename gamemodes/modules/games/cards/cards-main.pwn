#include <playing-cards>

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
#define DECK_SIZE (52)
#define CARD_NONE (-1)
#define CARD_SPRITE_LEN (MAX_CARD_SPRITE_LEN)
#define CARD_NAME_LEN (MAX_CARD_NAME_LEN)

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
stock Card_Suit(card)
{
    return card / 13;
}

stock Card_Value(card)
{
    return card % 13 + 1;
}

stock Card_Make(suit,value)
{
    return suit * 13 + value - 1;
}

stock bool:Card_IsValid(card)
{
    return card >= 0 && card < DECK_SIZE;
}

stock Card_Sprite(card,dest[],size = sizeof(dest))
{
    if (!Card_IsValid(card))
    {
        GetPlayingCardSprite(BACK_OF_CARD,CARD_VALUE_NONE,dest,size);
        return;
    }

    GetPlayingCardSprite(CardSets:(_:CARD_SET_SPADES + Card_Suit(card)),CardValues:(_:CARD_VALUE_ACE + Card_Value(card) - 1),dest,size);
}

stock Card_Name(card,dest[],size = sizeof(dest))
{
    if (!Card_IsValid(card))
    {
        GetPlayingCardName(BACK_OF_CARD,CARD_VALUE_NONE,dest,size);
        return;
    }

    GetPlayingCardName(CardSets:(_:CARD_SET_SPADES + Card_Suit(card)),CardValues:(_:CARD_VALUE_ACE + Card_Value(card) - 1),dest,size);
}

stock Card_BackSprite(dest[],size = sizeof(dest))
{
    GetPlayingCardSprite(BACK_OF_CARD,CARD_VALUE_NONE,dest,size);
}

stock Deck_Fill(deck[DECK_SIZE])
{
    for (new i = 0;i < DECK_SIZE;i++)
    {
        deck[i] = i;
    }
}

stock Deck_Shuffle(deck[DECK_SIZE])
{
    Deck_Fill(deck);

    for (new i = DECK_SIZE - 1;i > 0;i--)
    {
        new j = random(i + 1), swap = deck[i];
        deck[i] = deck[j];
        deck[j] = swap;
    }
}

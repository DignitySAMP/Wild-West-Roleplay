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
#define PK_RANK_HIGH (1)
#define PK_RANK_PAIR (2)
#define PK_RANK_TWO_PAIR (3)
#define PK_RANK_TRIPS (4)
#define PK_RANK_STRAIGHT (5)
#define PK_RANK_FLUSH (6)
#define PK_RANK_FULL_HOUSE (7)
#define PK_RANK_QUADS (8)
#define PK_RANK_STRAIGHT_FLUSH (9)
#define PK_RANK_ROYAL (10)

static const g_PkRankName[11][16] =
{
    "Undefined","High Card","Pair","Two Pair","Three of a Kind","Straight","Flush","Full House","Four of a Kind","Straight Flush","Royal Flush"
};

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
static Pk_EvalRank(card)
{
    new value = Card_Value(card);
    return value == 1 ? 14 : value;
}

static Pk_StraightHigh(mask)
{
    if (mask & (1 << 14))
    {
        mask |= 1 << 1;
    }

    for (new high = 14;high >= 5;high--)
    {
        new bits = 31 << (high - 4);

        if ((mask & bits) == bits)
        {
            return high;
        }
    }

    return 0;
}

static Pk_Score(category,k1 = 0,k2 = 0,k3 = 0,k4 = 0,k5 = 0)
{
    return (category << 20) | (k1 << 16) | (k2 << 12) | (k3 << 8) | (k4 << 4) | k5;
}

static Pk_TopRanks(const counts[15],minCount,skipA,skipB,out[],max)
{
    new found;

    for (new rank = 14;rank >= 2 && found < max;rank--)
    {
        if (counts[rank] >= minCount && rank != skipA && rank != skipB)
        {
            out[found++] = rank;
        }
    }

    return found;
}

stock Pk_Eval7(const cards[7])
{
    new counts[15], suitCounts[4], suitMasks[4], rankMask;

    for (new i = 0;i < 7;i++)
    {
        new rank = Pk_EvalRank(cards[i]), suit = Card_Suit(cards[i]);
        counts[rank]++;
        suitCounts[suit]++;
        suitMasks[suit] |= 1 << rank;
        rankMask |= 1 << rank;
    }

    new flushSuit = -1;

    for (new s = 0;s < 4;s++)
    {
        if (suitCounts[s] >= 5)
        {
            flushSuit = s;
        }
    }

    if (flushSuit >= 0)
    {
        new high = Pk_StraightHigh(suitMasks[flushSuit]);

        if (high == 14)
        {
            return Pk_Score(PK_RANK_ROYAL,14);
        }

        if (high > 0)
        {
            return Pk_Score(PK_RANK_STRAIGHT_FLUSH,high);
        }
    }

    new quads[1], trips[2], pairs[3], kick[5], nQuads = Pk_TopRanks(counts,4,0,0,quads,1), nTrips = Pk_TopRanks(counts,3,0,0,trips,2), nPairs = Pk_TopRanks(counts,2,0,0,pairs,3);

    if (nQuads > 0)
    {
        Pk_TopRanks(counts,1,quads[0],0,kick,1);
        return Pk_Score(PK_RANK_QUADS,quads[0],kick[0]);
    }

    if (nTrips > 0)
    {
        new pairRank = 0;

        for (new rank = 14;rank >= 2;rank--)
        {
            if (rank != trips[0] && counts[rank] >= 2)
            {
                pairRank = rank;
                break;
            }
        }

        if (pairRank > 0)
        {
            return Pk_Score(PK_RANK_FULL_HOUSE,trips[0],pairRank);
        }
    }

    if (flushSuit >= 0)
    {
        new top[5], found;

        for (new rank = 14;rank >= 2 && found < 5;rank--)
        {
            if (suitMasks[flushSuit] & (1 << rank))
            {
                top[found++] = rank;
            }
        }

        return Pk_Score(PK_RANK_FLUSH,top[0],top[1],top[2],top[3],top[4]);
    }

    new straight = Pk_StraightHigh(rankMask);

    if (straight > 0)
    {
        return Pk_Score(PK_RANK_STRAIGHT,straight);
    }

    if (nTrips > 0)
    {
        Pk_TopRanks(counts,1,trips[0],0,kick,2);
        return Pk_Score(PK_RANK_TRIPS,trips[0],kick[0],kick[1]);
    }

    if (nPairs >= 2)
    {
        Pk_TopRanks(counts,1,pairs[0],pairs[1],kick,1);
        return Pk_Score(PK_RANK_TWO_PAIR,pairs[0],pairs[1],kick[0]);
    }

    if (nPairs == 1)
    {
        Pk_TopRanks(counts,1,pairs[0],0,kick,3);
        return Pk_Score(PK_RANK_PAIR,pairs[0],kick[0],kick[1],kick[2]);
    }

    Pk_TopRanks(counts,1,0,0,kick,5);
    return Pk_Score(PK_RANK_HIGH,kick[0],kick[1],kick[2],kick[3],kick[4]);
}

stock Pk_ScoreRank(score)
{
    return score >> 20;
}

stock Pk_RankName(rank,dest[],size = sizeof(dest))
{
    strcopy(dest,g_PkRankName[rank >= 0 && rank <= PK_RANK_ROYAL ? rank : 0],size);
}

public OnPlayerStartBurn(playerid) {

    SetPlayerAttachedObject(playerid, 0, 18691, 1); 

    return 1;
}

public OnPlayerStopBurn(playerid) {

    RemovePlayerAttachedObject(playerid, 0);

    return 1;
}
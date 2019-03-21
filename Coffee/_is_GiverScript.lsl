/*
    Object Giver Script
    
    March 21 2018  Ishikawa Sou
*/

integer Channel_obj = 0;
integer listen_handle;

vector relativePosOffset = <0.015, 0.0, 0.055>;    // Object を Rez する位置
string rez_object_name = "MugCup"; // Rez する オブジェクト名

integer dlg_Channel = 0;
integer dlg_listen_handle;

integer rez_flg = FALSE;

string tea_sound = "c3735a9d-0595-aa29-5e7e-93c2995a971e";

// チャンネル
integer genCh()
{
    integer gen;
    key id = llGetKey();
    string str = llGetSubString((string)id,0,3);
    gen = -1-(integer)("0x"+str);
    return gen;
}

integer rez_object(/*key av*/)
{
    if(rez_flg == TRUE)
    {
        llSay(Channel_obj, "Reset" + (string)llDetectedKey(0));
        rez_flg = FALSE;
    }

    if(rez_flg == FALSE)
    {
        Channel_obj = genCh();
        listen_handle = llListen(Channel_obj, "", "", "");

        rotation relativeRot = <0.0, 0.0, 0.0, 0.0>;
        vector relativeVel = <0.0, 0.0, 0.3>;

        vector myPos = llGetPos();
        rotation myRot = llGetRot();
        vector rezPos = myPos + relativePosOffset * myRot;
        vector rezVel = relativeVel * myRot;
        rotation rezRot = myRot;



        llRezObject(rez_object_name, rezPos, rezVel, rezRot, Channel_obj);

        llTriggerSound(tea_sound, 1.0);

        rez_flg = TRUE;

        return TRUE;
    }

    return FALSE;
}

default
{
    state_entry()
    {
        rez_object_name = llGetInventoryName(INVENTORY_OBJECT, 0);
        llOwnerSay("Please touch saucer, a teacup will appear");
    }

    touch_start(integer total_number)
    {
        integer ret = rez_object(/*llDetectedKey(0)*/);

        if(ret == TRUE)
        {
            //llSay(Channel_obj, "Attch" + (string)llDetectedKey(0));
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        if(channel == Channel_obj)
        {
            if(message == "take")
            {
                llListenRemove(listen_handle);

                rez_flg = FALSE;

                rez_object(/*llDetectedKey(0)*/);
            }
            else if(message == "die")
            {
                llListenRemove(listen_handle);
            }
        }
    }

    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
        {
            // インベントリが変更になったらノートカードを読み込みます。
            llResetScript();
        }
    }

    on_rez(integer num)
    {
        llResetScript();
    }
}

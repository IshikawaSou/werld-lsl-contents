/*
    Attach Object Script

    March 21 2018  Ishikawa Sou
*/

integer attach_point = ATTACH_RHAND; // http://wiki.secondlife.com/wiki/ATTACH_MOUTH/ja

integer Channel = -1;
integer listen_handle;

string anim_stay = "stay";
string anim_drink = "drink";
key yuge_tex = "ecc790c4-ba41-47d4-87af-1c2a3ef98454";

float gap = 10.0; // タイマー間隔
vector attach_rot = <345.25000, 63.35001, 129.04999>;

key avatarKey = NULL_KEY;
integer atach_flg = FALSE;
integer anim_flg = FALSE;

integer dlg_Channel = 0;
integer dlg_listen_handle;

// チャンネル
integer genCh()
{
    integer gen;
    key id = llGetKey();
    string str = llGetSubString((string)id,0,3);
    gen = -1-(integer)("0x"+str);
    return gen;
}

open_dlg(key av)
{
    llListenRemove(dlg_listen_handle);

    dlg_Channel = genCh();

    string msg = "";

    string lang = llGetAgentLanguage(av);
    if(lang == "ja")
    {
        msg = "\nCup を取り外しますか？\n\n";
    }
    else
    {
        msg = "\nDo you wanna detach the cup ?\n\n";
    }

    dlg_listen_handle = llListen(dlg_Channel, "", "", "");
    llDialog( av, msg, ["Yes", "No"], dlg_Channel );
}

yuge_particle()
{
    llParticleSystem(
        [
            PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_ANGLE_CONE,
            PSYS_SRC_BURST_RADIUS,0,
            PSYS_SRC_ANGLE_BEGIN,0,
            PSYS_SRC_ANGLE_END,0,
            PSYS_SRC_TARGET_KEY,llGetKey(),
            PSYS_PART_START_COLOR,<1.000000,1.000000,1.000000>,
            PSYS_PART_END_COLOR,<1.000000,1.000000,1.000000>,
            PSYS_PART_START_ALPHA,0,
            PSYS_PART_END_ALPHA,0.7,
            PSYS_PART_START_GLOW,0,
            PSYS_PART_END_GLOW,0,
            PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
            PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
            PSYS_PART_START_SCALE,<0.050000,0.050000,1.00000>,
            PSYS_PART_END_SCALE,<0.250000,0.250000,2.00000>,
            PSYS_SRC_TEXTURE, yuge_tex,
            PSYS_SRC_MAX_AGE,0,
            PSYS_PART_MAX_AGE,2.0,
            PSYS_SRC_BURST_RATE,0.4,
            PSYS_SRC_BURST_PART_COUNT,1,
            PSYS_SRC_ACCEL,<0.000000,0.000000,0.000000>,
            PSYS_SRC_OMEGA,<0.000000,0.000000,0.000000>,
            PSYS_SRC_BURST_SPEED_MIN,0.2,
            PSYS_SRC_BURST_SPEED_MAX,0.1,
            PSYS_PART_FLAGS,
                0 |
                PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_INTERP_COLOR_MASK
        ]);
}

play_drink()
{
    llStartAnimation(anim_drink);
    llSleep(3);
    llStopAnimation(anim_drink);
}

default
{
    state_entry()
    {
        yuge_particle();
    }

    touch_start(integer total_number)
    {
        avatarKey = llDetectedKey(0);

        if(atach_flg == TRUE)
        {
            if(llGetAttached())
            {
                open_dlg(avatarKey);
            }
        }
        else
        {
            llRequestPermissions( avatarKey, PERMISSION_ATTACH);
        }
    }

    run_time_permissions( integer vBitPermissions )
    {
        if( vBitPermissions & PERMISSION_ATTACH )
        {
            if(atach_flg == FALSE)
            {
                // Demo Object を可視化する
                //llSetAlpha(1.0, ALL_SIDES);

                llAttachToAvatarTemp( attach_point );
                //llStartAnimation(anim_name);
            }
            else
            {
                // Timer 終了
                llSetTimerEvent(0.0);
                llDetachFromAvatar();
            }
        }

        if (vBitPermissions & PERMISSION_TRIGGER_ANIMATION)
        {
            if(anim_flg == FALSE)
            {
                llSetTimerEvent(gap);
                llStartAnimation(anim_stay);
                anim_flg = TRUE;
            }
            else
            {
                llSetTimerEvent(0.0);
                llStopAnimation(anim_stay);
            }
        }
    }

    on_rez(integer rez)
    {
        yuge_particle();

        Channel = rez;
        atach_flg = FALSE;
        anim_flg = FALSE;
        // Sleep で出現待機
        //llSleep(3.0);

        listen_handle = llListen(Channel, "", "", "");
        //llSetTimerEvent(gap);
        //llResetTime();

        // Demo Object を透明にする
        //llSetAlpha(0.0, ALL_SIDES);
    }

    listen(integer channel, string name, key id, string message)
    {
        string cmd = llGetSubString(message, 0, 4);
        string data = llGetSubString(message, 5, -1);

        if(channel == Channel)
        {
            if(cmd == "Reset" && atach_flg == FALSE)
            {
                llListenRemove(Channel);
                llDie();
            }
            else if(cmd == "Attch" && atach_flg == FALSE)
            {
                // アタッチ要求
                avatarKey = (key)data;//llDetectedKey(0);
                //llOwnerSay("Avatar : " + (string)avatarKey);
                llRequestPermissions( avatarKey, PERMISSION_ATTACH );
            }
        }
        else if(channel == dlg_Channel)
        {
            if(message == "Yes")
            {
                llListenRemove(dlg_listen_handle);
                llListenRemove(listen_handle);

                // Demo Object を取り外す
                llListenRemove(Channel);
                //llSetTimerEvent(0.0);
                if(atach_flg == TRUE)
                {
                    llRequestPermissions(avatarKey, PERMISSION_ATTACH);
                    //llRequestPermissions(avatarKey, PERMISSION_TRIGGER_ANIMATION);
                }

            }
            else if(message == "No")
            {
                llListenRemove(dlg_listen_handle);
            }
        }
    }

    attach(key id)
    {
        if(id)//有効なキーか NULL_KEY かを調べます
        {
            llSetRot( llEuler2Rot(attach_rot*DEG_TO_RAD) );
            llRequestPermissions(avatarKey, PERMISSION_TRIGGER_ANIMATION);
            atach_flg = TRUE;
            llShout(Channel, "take");
        }
        else
        {
            // 終了
            //llStopAnimation(anim_name);
            //llSetTimerEvent(0.0);
        }
    }

    timer()
    {
        if(atach_flg == TRUE)
        {
            play_drink();
        }
    }
}

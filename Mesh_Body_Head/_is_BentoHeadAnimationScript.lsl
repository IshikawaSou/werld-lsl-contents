// FairWing Script
// Written by いっちゃん

string AnimData_1 = "wink01";
string AnimData_2 = "Talk01";

string currentAnim = "";
key owner;
float gap = 0.5;

string current_voice_anim = "Talk01";
integer voice_anim_start_flag = FALSE;
integer voice_while_count = 2; // 音声が止まって2秒したらアニメを終了
integer ch_voice_anim = 777;
integer handle_voice_anim;

string current_smile_anim = "smile_01";
integer smile_anim_start_flag = FALSE;
integer SMILE_MAX = 10;
integer smile_while_count = 10; // 音声が止まって2秒したらアニメを終了

integer handle_hud_litener;
integer ch_hud;

list skin_1_list =
[
    "98aa6a1b-b57d-4c5b-ba85-aa666dd908c9",
    "8295dcbc-abcc-4f5b-8eb4-713f5db367cb"
];

list skin_2_list =
[
    "141a99fc-1c76-47e8-a4d4-3aa53a074a2f",
    "8295dcbc-abcc-4f5b-8eb4-713f5db367cb"
];

list skin_3_list =
[
    "17fbc393-586b-4c7d-b41b-8447ef6ffd47",
    "8295dcbc-abcc-4f5b-8eb4-713f5db367cb"
];

list skin_4_list =
[
    "ded071b4-0ab9-4369-a8f6-29c6a6182db4",
    "8295dcbc-abcc-4f5b-8eb4-713f5db367cb"
];

set_skin_tex(list tex_list)
{
    llSetLinkPrimitiveParams(0,
        [
        PRIM_TEXTURE, 0, llList2String(tex_list,0),<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, 0, <1,1,1>, 1.0,
        PRIM_TEXTURE, 1, llList2String(tex_list,1),<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, 1, <1,1,1>, 1.0
        ]);
}



startAnimation(string anim)
{
    if(currentAnim == anim) return;
    
    stopAnimation();
    
    currentAnim = anim;
    
    if( currentAnim != "")
    {
        llStartAnimation(currentAnim);
    }
}

stopAnimation()
{
    if(currentAnim != "")
    {
        llStopAnimation(currentAnim);
        currentAnim = "";
    }
}

integer random_integer( integer min, integer max )
{
  return min + (integer)( llFrand( max - min + 1 ) );
}

integer genCh()
{
    integer gen;
    key id = llGetOwner();
    string str = llGetSubString((string)id,0,3);
    gen = -1-(integer)("0x"+str);
    if(gen<0) gen*=-1;
    return gen;
}

default
{
    state_entry()
    {
        owner = llGetOwner();
        currentAnim = "";
        llRequestPermissions(owner, PERMISSION_TRIGGER_ANIMATION);
        
        // Voice Animation チャンネルオープン
        handle_voice_anim = llListen(ch_voice_anim,"",NULL_KEY,"");

        // HUD チャンネルオープン
        ch_hud = genCh();
        handle_hud_litener = llListen(ch_hud,"",NULL_KEY,"");
        
        llSetTimerEvent(gap);
    }
    
    attach(key id)
    {
        if(id)
        {
            owner = llGetOwner();
            currentAnim = "";
            llRequestPermissions(owner, PERMISSION_TRIGGER_ANIMATION);
            
            // Voice Animation チャンネルオープン
            handle_voice_anim = llListen(ch_voice_anim,"",NULL_KEY,"");
    
            // HUD チャンネルオープン
            ch_hud = genCh();
            handle_hud_litener = llListen(ch_hud,"",NULL_KEY,"");
            
            llSetTimerEvent(gap);
        }
        else
        {
            stopAnimation();
            llListenRemove(handle_voice_anim);
            llListenRemove(handle_hud_litener);
            llSetTimerEvent(0); // timer 停止
        }
    }

    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            startAnimation(currentAnim);
        }
    }

// Listen Handler
    listen(integer ch, string name, key id, string message)
    {
        id = llGetOwnerKey(id);
        if(id != llGetOwner()) return;

        // Voice Animation
        if(ch == ch_voice_anim)
        {
            if(current_voice_anim != "" && voice_anim_start_flag == FALSE)
            {
                voice_anim_start_flag = TRUE;
                llStartAnimation(AnimData_2);
            }
            voice_while_count = 2;
        }
        
        // Skin 変更
        else if(ch == ch_hud)
        { 
            if(message == "skin_1")
            {
                set_skin_tex(skin_1_list);
            }
            else if(message == "skin_2")
            {
                set_skin_tex(skin_2_list);
            }
            else if(message == "skin_3")
            {
                set_skin_tex(skin_3_list);
            }
            else if(message == "skin_4")
            {
                set_skin_tex(skin_4_list);
            }
        }
        
    }

    timer()
    {
        if(smile_anim_start_flag == FALSE && smile_while_count == 0)
        {
            smile_anim_start_flag = TRUE;
            smile_while_count = SMILE_MAX;
            integer rnd = random_integer(0,3);
            if(rnd == 1)
            {
                llStartAnimation(current_smile_anim);
            }
            
        }
        else
        {
            smile_while_count--;
            if(smile_while_count <= 0)
            {
                llStopAnimation(current_smile_anim);
                smile_while_count = 0;
                smile_anim_start_flag = FALSE;
            }
        }
        
        if(current_voice_anim != "" && voice_anim_start_flag == TRUE)
        {
            voice_while_count--;
            if(voice_while_count == 0)
            {
                llStopAnimation(current_voice_anim);
                voice_anim_start_flag = FALSE;
            }
        }
        
        /*
        AGENT_ALWAYS_RUN    // 走行モード("常に走る") になっている、もしくは tap-tap-hold を使っている 
        AGENT_ATTACHMENTS   // 装着している 
        AGENT_AUTOPILOT     // is in "オートパイロット" モード 
        AGENT_AWAY          // "away" モード 
        AGENT_BUSY          // "busy" モード 
        AGENT_CROUCHING     // しゃがんでいる 
        AGENT_FLYING        // 飛んでいる 
        AGENT_IN_AIR        // 空中に浮かんでいる 
        AGENT_MOUSELOOK     // マウスルック 
        AGENT_ON_OBJECT     // オブジェクトに座っている 
        AGENT_SCRIPTED      // スクリプトを装着 
        AGENT_SITTING       // 座っている 
        AGENT_TYPING        // 入力している 
        AGENT_WALKING       // 歩いている、走っている、しゃがみ歩きをしている 
        */
        
        integer info = llGetAgentInfo(owner);

/*
        if( info & AGENT_SITTING )
        {
            llOwnerSay("AGENT_SITTING");
            startAnimation(AnimData_1);
        }
        else if( info & AGENT_FLYING )
        {
            llOwnerSay("AGENT_FLYING");
            startAnimation(AnimData_1);
        }
        */
        if( info & AGENT_TYPING )
        {
            //llOwnerSay("AGENT_TYPING");
            startAnimation(AnimData_2);
        }
        else
        {
            startAnimation(AnimData_1);
        }
        
        /*
        else if( info & AGENT_WALKING )
        {
            llOwnerSay("AGENT_WALKING");
            startAnimation(AnimData_1);
        }
        else if( info & AGENT_ATTACHMENTS )
        {
            llOwnerSay("AGENT_ATTACHMENTS");
            startAnimation(AnimData_1);
        }
        else if( info & AGENT_IN_AIR )
        {
            llOwnerSay("AGENT_IN_AIR");
            startAnimation(AnimData_1);
        }
        else
        {
            llOwnerSay("else");
            stopAnimation();
        }
        */
    }
}

string currentAnim = "";
string current_Typing = "";
list Typing_list = "";

list Crouching_list = "";
list CrouchWalking_list = "";
list Falling_Down_list = "";
list Flying_list = "";
list FlyingSlow_list = "";
list Hovering_list = "";
list Hovering_Down_list = "";
list Hovering_Up_list = "";
list Jumping_list = "";
list Landing_list = "";
list PreJumping_list = "";
list Running_list = "";
list Sitting_list = "";
list Sitting_on_Ground_list = "";
list Standing_list = "";
list Standing_Up_list = "";
list Striding_list = "";
list Soft_Landing_list = "";
list Taking_Off_list = "";
list Turning_Left_list = "";
list Turning_Right_list = "";
list Walking_list = "";

string notecard;
key kQuery;
integer iLine = 0;

float gap = 1.0;
integer anim_change_cnt = 0;
integer ANIM_CHANGE = 8;

// Random
integer random_integer( integer min, integer max )
{
    return min + (integer)( llFrand( max - min + 1 ) );
}

string get_rand_anim(list anim_list)
{
    integer anim_cnt = llGetListLength(anim_list) - 1;
    integer index = 0;
    if(anim_cnt > 0)
    {
        index = random_integer(0,anim_cnt);
    }
    
    return llList2String(anim_list, index);
}

animOverride_ALL(integer sit_flag)
{
    if((string)Crouching_list != "")
    {
        llSetAnimationOverride("Crouching", get_rand_anim(Crouching_list));
    }
    if((string)CrouchWalking_list != "")
    {
        llSetAnimationOverride("CrouchWalking", get_rand_anim(CrouchWalking_list));
    }
    if((string)Falling_Down_list != "")
    {
        llSetAnimationOverride("Falling Down", get_rand_anim(Falling_Down_list));
    }
    if((string)Flying_list != "")
    {
        llSetAnimationOverride("Flying", get_rand_anim(Flying_list));
    }
    if((string)FlyingSlow_list != "")
    {
        llSetAnimationOverride("FlyingSlow", get_rand_anim(FlyingSlow_list));
    }
    if((string)Hovering_list != "")
    {
        llSetAnimationOverride("Hovering", get_rand_anim(Hovering_list));
    }
    if((string)Hovering_Down_list != "")
    {
        llSetAnimationOverride("Hovering Down", get_rand_anim(Hovering_Down_list));
    }
    if((string)Hovering_Up_list != "")
    {
        llSetAnimationOverride("Hovering Up", get_rand_anim(Hovering_Up_list));
    }
    if((string)Jumping_list != "")
    {
        llSetAnimationOverride("Jumping", get_rand_anim(Jumping_list));
    }
    if((string)Landing_list != "")
    {
        llSetAnimationOverride("Landing", get_rand_anim(Landing_list));
    }
    if((string)PreJumping_list != "")
    {
        llSetAnimationOverride("PreJumping", get_rand_anim(PreJumping_list));
    }
    if((string)Running_list != "")
    {
        llSetAnimationOverride("Running", get_rand_anim(Running_list));
    }
    if((string)Sitting_list != "" && sit_flag == FALSE)
    {
        llSetAnimationOverride("Sitting", get_rand_anim(Sitting_list));
    }
    if((string)Sitting_on_Ground_list != "")
    {
        llSetAnimationOverride("Sitting on Ground", get_rand_anim(Sitting_on_Ground_list));
    }
    if((string)Standing_list != "")
    {
        llSetAnimationOverride("Standing", get_rand_anim(Standing_list));
    }
    if((string)Standing_Up_list != "")
    {
        llSetAnimationOverride("Standing Up", get_rand_anim(Standing_Up_list));
    }
    if((string)Striding_list != "")
    {
        llSetAnimationOverride("Striding", get_rand_anim(Striding_list));
    }
    if((string)Soft_Landing_list != "")
    {
        llSetAnimationOverride("Soft Landing", get_rand_anim(Soft_Landing_list));
    }
    if((string)Taking_Off_list != "")
    {
        llSetAnimationOverride("Taking Off", get_rand_anim(Taking_Off_list));
    }
    if((string)Turning_Left_list != "")
    {
        llSetAnimationOverride("Turning Left", get_rand_anim(Turning_Left_list));
    }
    if((string)Turning_Right_list != "")
    {
        llSetAnimationOverride("Turning Right", get_rand_anim(Turning_Right_list));
    }
    if((string)Walking_list != "")
    {
        llSetAnimationOverride("Walking", get_rand_anim(Walking_list));
    }
    
    if((string)Typing_list != "")
    {
        current_Typing = get_rand_anim(Typing_list);
    }
}

integer checkPattern(string line_data, string pattern)
{
    string key_str = "[" + pattern + "]";
    
    if(llSubStringIndex(line_data, key_str) == -1) return FALSE;
    
    return TRUE;
}

// Line から Animation 名だけを抜き出す
list getAnimNameList(string line_data, string pattern)
{
    string key_str = "[" + pattern + "]";
    
    string temp = strReplace(line_data, key_str, "");
    string temp2 = strReplace(temp, " ", "");

    list ret_list = llCSV2List(temp2);
    
    llOwnerSay(key_str + " " + temp2);
    
    return ret_list;
}

// 文字列置換
string strReplace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls(str, [search], []), replace);
}

say_free_mem()
{
    integer free_memory = llGetFreeMemory() / 1024;
    llOwnerSay((string)free_memory + " KB free。");
}

startAnim(string anim)
{    
    if(currentAnim == anim) return;
    
    string temp = currentAnim;
    currentAnim = anim;
    
    if( currentAnim != "")
    {
        llStartAnimation(currentAnim);
    }
    
    if(temp != "")
    {
        llStopAnimation(temp);
    }
}

stopAnim()
{
    if(currentAnim != "")
    {
        llStopAnimation(currentAnim);
        currentAnim = "";
    }
}

default
{
    state_entry()
    {
        
        notecard = llGetInventoryName(INVENTORY_NOTECARD, 0);
        if(notecard != "")
        {
            kQuery = llGetNotecardLine(notecard, iLine);
        }
        say_free_mem();

        llRequestPermissions(llGetOwner(), PERMISSION_OVERRIDE_ANIMATIONS | PERMISSION_TRIGGER_ANIMATION);
        
        llSetTimerEvent(gap);
    }
    
    attach(key id)
    {
        integer perm = llGetPermissions();
 
        if (id)
        {
            llRequestPermissions(id, PERMISSION_OVERRIDE_ANIMATIONS | PERMISSION_TRIGGER_ANIMATION);
            llSetTimerEvent(gap);
        }
        else if (perm & PERMISSION_OVERRIDE_ANIMATIONS)
        {
            llResetAnimationOverride("ALL");
            list anim_list = llGetAnimationList(llGetOwner());
            integer i = 0;
            for(i = 0 ; i < llGetListLength(anim_list) ; i++)
            {
                llStopAnimation(llList2String(anim_list,i));
            }
            
            llSetTimerEvent(0);
        }
    }
 
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_OVERRIDE_ANIMATIONS)
        {
            animOverride_ALL(FALSE);
            
        }
    }
    
    changed(integer change)
    {
        if(change & CHANGED_INVENTORY)
        {
            llResetScript();
        }
    }
    
    dataserver(key query_id, string data)
    {
        if (query_id == kQuery)
        {
            // 対象となるノートカードの行
            if (data == EOF)
            {
                llSay(0, "Loadind is complete..." + (string)iLine + " lines loaded");
            }
            else
            {
                if(llGetSubString(data, 0, 0) != "#") // コメント行でなければ
                {
                    //llSay(0, "Line " + (string)iLine + ": " + data);   // data はノートカードの現在の行の内容をもつ
                    /*
                        Crouching
                        CrouchWalking
                        Falling_Down
                        Flying
                        FlyingSlow
                        Hovering
                        Hovering_Down
                        Hovering_Up
                        Jumping
                        Landing
                        PreJumping
                        Running
                        Sitting
                        Sitting_on_Ground
                        Standing
                        Standing_Up
                        Striding
                        Soft_Landing
                        Taking_Off
                        Turning_Left
                        Turning_Right
                        Walking
                    */                        
                    if(checkPattern(data, "Crouching") == TRUE)
                        Crouching_list = getAnimNameList(data, "Crouching");
                    if(checkPattern(data, "CrouchWalking") == TRUE)
                        CrouchWalking_list = getAnimNameList(data, "CrouchWalking");
                    if(checkPattern(data, "Falling Down") == TRUE)
                        Falling_Down_list = getAnimNameList(data, "Falling Down");
                    if(checkPattern(data, "Flying") == TRUE)
                        Flying_list = getAnimNameList(data, "Flying");
                    if(checkPattern(data, "FlyingSlow") == TRUE)
                        FlyingSlow_list = getAnimNameList(data, "FlyingSlow");
                    if(checkPattern(data, "Hovering") == TRUE)
                        Hovering_list = getAnimNameList(data, "Hovering");
                    if(checkPattern(data, "Hovering Down") == TRUE)
                        Hovering_Down_list = getAnimNameList(data, "Hovering Down");
                    if(checkPattern(data, "Hovering Up") == TRUE)
                        Hovering_Up_list = getAnimNameList(data, "Hovering Up");
                    if(checkPattern(data, "Jumping") == TRUE)
                        Jumping_list = getAnimNameList(data, "Jumping");
                    if(checkPattern(data, "Landing") == TRUE)
                        Landing_list = getAnimNameList(data, "Landing");
                    if(checkPattern(data, "PreJumping") == TRUE)
                        PreJumping_list = getAnimNameList(data, "PreJumping");
                    if(checkPattern(data, "Running") == TRUE)
                        Running_list = getAnimNameList(data, "Running");
                    if(checkPattern(data, "Sitting") == TRUE)
                        Sitting_list = getAnimNameList(data, "Sitting");
                    if(checkPattern(data, "Sitting on Ground") == TRUE)
                        Sitting_on_Ground_list = getAnimNameList(data, "Sitting on Ground");
                    if(checkPattern(data, "Standing") == TRUE)
                        Standing_list = getAnimNameList(data, "Standing");
                    if(checkPattern(data, "Standing Up") == TRUE)
                        Standing_Up_list = getAnimNameList(data, "Standing Up");
                    if(checkPattern(data, "Striding") == TRUE)
                        Striding_list = getAnimNameList(data, "Striding");
                    if(checkPattern(data, "Soft Landing") == TRUE)
                        Soft_Landing_list = getAnimNameList(data, "Soft Landing");
                    if(checkPattern(data, "Taking Off") == TRUE)
                        Taking_Off_list = getAnimNameList(data, "Taking Off");
                    if(checkPattern(data, "Turning Left") == TRUE)
                        Turning_Left_list = getAnimNameList(data, "Turning Left");
                    if(checkPattern(data, "Turning Right") == TRUE)
                        Turning_Right_list = getAnimNameList(data, "Turning Right");
                    if(checkPattern(data, "Walking") == TRUE)
                        Walking_list = getAnimNameList(data, "Walking");
                    
                    // Agent State Override Animation
                    if(checkPattern(data, "AGENT_TYPING") == TRUE)
                        Typing_list = getAnimNameList(data, "AGENT_TYPING");

                }
                //request next line
                iLine++;   // increment line count
                kQuery = llGetNotecardLine(notecard, iLine);   // 可能なら他の行を読む
            }
        }
    }
    
    timer()
    {
        /*
            AGENT_ALWAYS_RUN    0x1000    走行モード("常に走る") になっている、もしくは tap-tap-hold を使っている
            AGENT_ATTACHMENTS    0x0002    装着している
            AGENT_AUTOPILOT    0x2000    is in "オートパイロット" モード
            AGENT_AWAY    0x0040    "away" モード
            AGENT_BUSY    0x0800    "busy" モード
            AGENT_CROUCHING    0x0400    しゃがんでいる
            AGENT_FLYING    0x0001    飛んでいる
            AGENT_IN_AIR    0x0100    空中に浮かんでいる
            AGENT_MOUSELOOK    0x0008    マウスルック
            AGENT_ON_OBJECT    0x0020    オブジェクトに座っている
            AGENT_SCRIPTED    0x0004    スクリプトを装着
            AGENT_SITTING    0x0010    座っている
            AGENT_TYPING    0x0200    入力している
            AGENT_WALKING    0x0080    歩いている、走っている、しゃがみ歩きをしている
        */
        integer info = llGetAgentInfo(llGetOwner());
        
        anim_change_cnt++;
        if(anim_change_cnt >= ANIM_CHANGE)
        {
            if(info & AGENT_SITTING)
            {
                animOverride_ALL(TRUE);
            }
            else
            {
                animOverride_ALL(FALSE);
            }
            anim_change_cnt = 0;
        }

        
        if(info & AGENT_TYPING)
        {
            startAnim(current_Typing);
        }
        else
        {
            stopAnim();
        }
    }
}
integer index = 0;
vector cam_offset;
list cam_pos_list = [<0,0,0>,<0,0,0>,<0,0,0>,<0,0,0>];
list cam_look_list = [<0,0,0>,<0,0,0>,<0,0,0>,<0,0,0>];

get_permission()
{
    key permkey = llGetPermissionsKey();
    if (permkey != llGetOwner())
    {
        llRequestPermissions(llGetOwner(), PERMISSION_TRACK_CAMERA | PERMISSION_CONTROL_CAMERA);
    }
    else
    {
        integer perm = llGetPermissions();
        if (! (perm & PERMISSION_TRIGGER_ANIMATION))
        {
            llRequestPermissions(llGetOwner(), PERMISSION_TRACK_CAMERA | PERMISSION_CONTROL_CAMERA);
        }
        else
        {
            //llSetTimerEvent(1.0);
        }
    }
}

get_camera(integer indx)
{
    vector pos = llGetCameraPos();
    cam_pos_list =
        llListReplaceList(cam_pos_list, [pos], indx, indx );
    
    //vector look = <1.0, 0.0, 0.0> * llGetCameraRot();
    vector look = pos + llRot2Fwd(llGetCameraRot());
    cam_look_list =
        llListReplaceList(cam_look_list, [look], indx, indx );
        
    llOwnerSay("pos : " + (string)pos);
    llOwnerSay("look : " + (string)look);
}

clear_camera()
{
    llClearCameraParams();
    //llReleaseCamera(llGetPermissionsKey());
}

set_camera(integer indx)
{
    clear_camera(); // カメラをデフォルトにリセットします    
    
    
    vector pos = llList2Vector(cam_pos_list, indx);
    vector look = llList2Vector(cam_look_list, indx);

    llOwnerSay("pos : " + (string)pos);
    llOwnerSay("look : " + (string)look);

    
    /*
        CAMERA_ACTIVE               カメラの スクリプト でのコントロールをオンかオフに切り替えます
        CAMERA_BEHINDNESS_ANGLE     カメラが対象の回転に縛られないアングルを角度で設定します。
        CAMERA_BEHINDNESS_LAG       カメラが背後以外にあるとき、どのぐらいでターゲットの後ろに戻らなければならないかを設定します。
        CAMERA_DISTANCE             カメラをターゲットからどのくらい遠ざけたいか設定します。
        CAMERA_FOCUS                焦点（対象の位置）を リージョン座標 で設定します。
        CAMERA_FOCUS_LAG            カメラがターゲットに焦点を合わせようとするときの遅延時間
        CAMERA_FOCUS_LOCKED         カメラの焦点を固定し、動かなくします。
        CAMERA_FOCUS_OFFSET         カメラの焦点を、ターゲットに対する相対的な 位置 で合わせます。
        CAMERA_FOCUS_THRESHOLD      カメラの焦点が対象の動きに左右されない、カメラのターゲット位置を中心とした球の半径を設定します。
        CAMERA_PITCH                カメラの対角線上の焦点角度量を設定します。反比例の関係にあります。
        CAMERA_POSITION             カメラの位置を リージョン座標 で設定します。
        CAMERA_POSITION_LAG         カメラが「理想的な」位置に向かうまでの遅延時間
        CAMERA_POSITION_LOCKED      カメラの位置を固定し、動けなくします。
        CAMERA_POSITION_THRESHOLD   カメラが対象の動きに左右されない、カメラの理想的な位置を中心とした球の半径を設定します。
    */
    llSetCameraParams(
        [
            CAMERA_ACTIVE, TRUE,
            //CAMERA_BEHINDNESS_ANGLE, 10.0,
            //CAMERA_BEHINDNESS_LAG, 0.0,
            //CAMERA_DISTANCE, 3.0,
            CAMERA_FOCUS, look,
            CAMERA_FOCUS_LAG, 0.0,
            CAMERA_FOCUS_LOCKED, TRUE,
            CAMERA_FOCUS_OFFSET, <0,0,0>,
            CAMERA_FOCUS_THRESHOLD, 0.0,
            //CAMERA_PITCH, 0.0,
            CAMERA_POSITION, pos,
            CAMERA_POSITION_LAG, 0.0,//0.1,
            CAMERA_POSITION_LOCKED, TRUE,
            CAMERA_POSITION_THRESHOLD, 0.0
        ]);
}

default
{
    state_entry()
    {
        clear_camera();
        get_permission();
    }

    touch_start(integer total_number)
    {
        if(llDetectedKey(0) != llGetOwner()) return;
        
        string btn_name = llGetLinkName(llDetectedLinkNumber(0));
        
        if(btn_name == "btn_record_1")
        {
            get_camera(0);
        }
        else if(btn_name == "btn_record_2")
        {
            get_camera(1);
        }
        else if(btn_name == "btn_record_3")
        {
            get_camera(2);
        }
        else if(btn_name == "btn_record_4")
        {
            get_camera(3);
        }

        else if(btn_name == "btn_play_1")
        {
            set_camera(0);
        }
        else if(btn_name == "btn_play_2")
        {
            set_camera(1);
        }
        else if(btn_name == "btn_play_3")
        {
            set_camera(2);
        }
        else if(btn_name == "btn_play_4")
        {
            set_camera(3);
        }

    }
    
    run_time_permissions(integer perm)
    {
        if (! (perm & PERMISSION_TRACK_CAMERA))
        {
            llRequestPermissions(llGetOwner(), PERMISSION_TRACK_CAMERA | PERMISSION_CONTROL_CAMERA);
        }
        else
        {
            //llSetTimerEvent(1.0);
            
            vector p = llGetCameraPos();
            vector l = <1.0, 0.0, 0.0> * llGetCameraRot();
            cam_offset = l + p;
            
            clear_camera();
        }
    }
    
    attach(key id)
    {
        if (id != NULL_KEY)
        {
            get_permission();
        }
        else
        {
            clear_camera();
            llSetTimerEvent(0.0);
        }
    }
    
    timer()
    {
    }
}
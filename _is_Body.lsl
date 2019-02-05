list prim_list;
integer channel;
integer listen_handle;

// Prim List 作成
createIndex()
{
    prim_list = [];
    
    integer i;
    prim_list = [""];    // ルート ( 1 : 起算 )
    prim_list += [llGetObjectName()];
    for(i = 2; i <= llGetNumberOfPrims() ; i++)
    {
        string prim_name = llGetLinkName(i);
        prim_list += [prim_name];
    }
}

// Prim Nmae から インデックス を返す
integer getIndex(string prim_name)
{
    return llListFindList(prim_list, [prim_name]);   
}

// 文字列置換
string strReplace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
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
        createIndex();
        channel = genCh();
        
        listen_handle = llListen(channel, "", NULL_KEY, "");
    }
    
    listen( integer channel, string name, key user, string message )
    {
        if(llGetOwnerKey(user) != llGetOwner()) return;
        
        integer prim_num = getIndex(message);
        integer flag;
        if(prim_num != -1)
        {
            float alpha = llList2Float(
                llGetLinkPrimitiveParams(prim_num, [PRIM_COLOR, ALL_SIDES]),
                1);
                
            if(alpha == 0.0)
            {
                llSetLinkPrimitiveParams(prim_num,
                    [PRIM_COLOR, ALL_SIDES, <1,1,1>, 1.0]);
            }
            else
            {
                llSetLinkPrimitiveParams(prim_num,
                    [PRIM_COLOR, ALL_SIDES, <1,1,1>, 0.0]);
            }
        }
    }
}
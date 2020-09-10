public void ParseItems()
{
    RequestFrame(Frame_ParseItems);
}

public void Frame_ParseItems(any data)
{
    PrintToServer("%s Loading eItems data from local backup!", TAG_NCLR);
    LoadBackup();
}

public void LoadBackup()
{
    if(!FileExists(g_szLocalFilePath))
    {
        SetFailState("%s Local backup not found! Turning plugin off.", TAG_NCLR);
        return;
    }

    JSONObject jRoot = JSONObject.FromFile(g_szLocalFilePath);
    ParseData(jRoot);
}

public void BackupJson(JSON json)
{
    PrintToServer("%s Creating local backup file!", TAG_NCLR);
    File fLocalFile = null;
    if (fLocalFile == null)
    {
        if(FileExists(g_szLocalFilePath))
        {
            DeleteFile(g_szLocalFilePath);
        }
        fLocalFile = OpenFile(g_szLocalFilePath, "w+");
    }

    JSONObject jRoot = view_as<JSONObject>(json);

    jRoot.ToFile(g_szLocalFilePath, JSON_COMPACT);
    delete fLocalFile;
    fLocalFile = null;
    PrintToServer("%s Backup created!", TAG_NCLR);

    ParseData(jRoot);
}

public void ParseData(JSONObject jRoot)
{
    g_bItemsSyncing = true;
    g_fStart = GetEngineTime();

    JSONArray   jWeapons        = view_as<JSONArray>(jRoot.Get("weapons"));
    JSONArray   jPaints         = view_as<JSONArray>(jRoot.Get("paints"));
    JSONArray   jGloves         = view_as<JSONArray>(jRoot.Get("gloves"));
    JSONObject  jCoins          = view_as<JSONObject>(jRoot.Get("coins"));
    JSONArray   jPins           = view_as<JSONArray>(jRoot.Get("pins"));
    JSONArray   jCrates         = view_as<JSONArray>(jRoot.Get("crates"));
    JSONArray   jMusicKits      = view_as<JSONArray>(jRoot.Get("music_kits"));
    JSONArray   jPatches        = view_as<JSONArray>(jRoot.Get("patches"));
    JSONArray   jSprayes        = view_as<JSONArray>(jRoot.Get("sprayes"));
    JSONObject  jStickers       = view_as<JSONObject>(jRoot.Get("stickers"));
    

    /*              Paints parse                */

    ParsePaints(jPaints);

    /*              Weapon parse                */

    ParseWeapons(jWeapons);

    /*             Gloves parse                */

    ParseGloves(jGloves);

    /*           Music Kits parse               */

    ParseMusicKits(jMusicKits);

    /*              Pins parse                  */

    ParsePins(jPins);

    /*              Coins parse                  */

    ParseCoins(jCoins);

    /*              Stickers parse                  */

    ParseStickers(jStickers);

    delete jRoot;
    delete jWeapons;
    delete jPaints;
    delete jGloves;
    delete jCoins;
    delete jPins;
    delete jCrates;
    delete jMusicKits;
    delete jPatches;
    delete jSprayes;
    delete jStickers;
    float fEnd = GetEngineTime();
    PrintToServer("%s Items synced successfully in %0.5f seconds", TAG_NCLR, fEnd - g_fStart);
    g_bItemsSynced = true;
    g_bItemsSyncing = false;

    Call_StartForward(g_OnItemsSynced);
    Call_Finish(g_OnItemsSynced);
}

public void ParseWeapons(JSONArray array)
{
    g_iWeaponCount = array.Length;
    JSONObject jItem;
    char szWeaponClassname[48];
    char szWeaponDisplayName[64];
    char szWeaponViewModel[PLATFORM_MAX_PATH];
    char szWeaponWorldModel[PLATFORM_MAX_PATH];
    char szPosTemp[12];
    char szWepDefIndex[12];
    int iSkinDefIndex;
    int iWepDefIndex;
    bool bHasRareInspect;
    bool bHasRareDraw;
    int iRareInspect;
    int iRareDraw;
    int iTeam;
    int iSlot;
    int iClipAmmo;
    int iStickerSlotsCount;
    int iReserveAmmo;
    int iMaxPlayerSpeed;
    int iPrice;
    int iDamage;
    int iFullAuto;

    float fCycleTime;
    float fSpread;
 
    for(int iWeaponNum = 0; iWeaponNum < array.Length; iWeaponNum++)
    {
        iSkinDefIndex = 0;
        iWepDefIndex = 0;
        iTeam = 0;
        bHasRareInspect = false;
        bHasRareDraw = false;
        iRareInspect = -1;
        iRareDraw = -1;
        iSlot = -1;
        iClipAmmo = -1;
        iReserveAmmo = -1;
        iMaxPlayerSpeed = -1;
        iPrice = -1;
        iDamage = -1;
        iFullAuto = 0;
        iStickerSlotsCount = 0;
        fCycleTime = 0.0;
        fSpread = 0.0;
 
        jItem = view_as<JSONObject>(array.Get(iWeaponNum));
        iWepDefIndex = jItem.GetInt("def_index");
        iTeam = jItem.GetInt("team");

        if(jItem.HasKey("slot"))
        {
            iSlot = jItem.GetInt("slot");
        }
        
        bHasRareInspect = jItem.GetBool("has_rare_inspect");
        bHasRareDraw = jItem.GetBool("has_rare_draw");

        if(jItem.HasKey("rare_inspect"))
        {
            iRareInspect = jItem.GetInt("rare_inspect");
        }

        if(jItem.HasKey("rare_draw"))
        {
            iRareDraw = jItem.GetInt("rare_draw");
        }
        
        jItem.GetString("item_name", szWeaponDisplayName, sizeof(szWeaponDisplayName));
        jItem.GetString("class_name", szWeaponClassname, sizeof(szWeaponClassname));
        jItem.GetString("view_model", szWeaponViewModel, sizeof(szWeaponViewModel));
        jItem.GetString("world_model", szWeaponWorldModel, sizeof(szWeaponWorldModel));

        if(!jItem.IsNull("stickers_count"))
        {
            iStickerSlotsCount = jItem.GetInt("stickers_count");
        }

        IntToString(iWepDefIndex, szWepDefIndex, sizeof(szWepDefIndex));
    
        ArrayList arWeaponPaints = new ArrayList();
        if(jItem.HasKey("paints"))
        {
            JSONObject jPaintsObj = view_as<JSONObject>(jItem.Get("paints"));
            for(int iPos = 0; iPos < jPaintsObj.Size; iPos++)
            {
                IntToString(iPos, szPosTemp, sizeof(szPosTemp));
                iSkinDefIndex = jPaintsObj.GetInt(szPosTemp);
                arWeaponPaints.Push(iSkinDefIndex);
            }
            g_smWeaponPaints.SetValue(szWepDefIndex, arWeaponPaints);
            delete jPaintsObj;
        }

        if(jItem.HasKey("attributes"))
        {
            JSONObject jAttributesObj = view_as<JSONObject>(jItem.Get("attributes"));
            
            if(jAttributesObj.HasKey("primary_clip_size"))
            {
                iClipAmmo = jAttributesObj.GetInt("primary_clip_size");
            }

            if(jAttributesObj.HasKey("primary_reserve_ammo_max"))
            {
                iReserveAmmo = jAttributesObj.GetInt("primary_reserve_ammo_max");
            }

            if(jAttributesObj.HasKey("max_player_speed"))
            {
                iMaxPlayerSpeed = jAttributesObj.GetInt("max_player_speed");
            }

            if(jAttributesObj.HasKey("in_game_price"))
            {
                iPrice = jAttributesObj.GetInt("in_game_price");
            }

            if(jAttributesObj.HasKey("damage"))
            {
                iDamage = jAttributesObj.GetInt("damage");
            }

            if(jAttributesObj.HasKey("is_full_auto"))
            {
                iFullAuto = jAttributesObj.GetInt("is_full_auto");
            }

            if(jAttributesObj.HasKey("cycletime"))
            {
                fCycleTime = jAttributesObj.GetFloat("cycletime");
            }

            if(jAttributesObj.HasKey("spread"))
            {
                fSpread = jAttributesObj.GetFloat("spread");
            }




            delete jAttributesObj;
        }

        delete jItem;

        eWeaponInfo WeaponInfo;

        strcopy(WeaponInfo.DisplayName,     sizeof(eWeaponInfo::DisplayName),   szWeaponDisplayName);
        strcopy(WeaponInfo.ClassName,       sizeof(eWeaponInfo::ClassName),     szWeaponClassname);
        strcopy(WeaponInfo.ViewModel,       sizeof(eWeaponInfo::ViewModel),     szWeaponViewModel);
        strcopy(WeaponInfo.WorldModel,      sizeof(eWeaponInfo::WorldModel),    szWeaponWorldModel);
        strcopy(WeaponInfo.DisplayName,     sizeof(eWeaponInfo::DisplayName),   szWeaponDisplayName);
        strcopy(WeaponInfo.DisplayName,     sizeof(eWeaponInfo::DisplayName),   szWeaponDisplayName);
        strcopy(WeaponInfo.DisplayName,     sizeof(eWeaponInfo::DisplayName),   szWeaponDisplayName);

        WeaponInfo.WeaponNum            = iWeaponNum;
        WeaponInfo.Paints               = arWeaponPaints;
        WeaponInfo.Team                 = iTeam;
        WeaponInfo.Slot                 = iSlot;
        WeaponInfo.ClipAmmo             = iClipAmmo;
        WeaponInfo.ReserveAmmo          = iReserveAmmo;
        WeaponInfo.MaxPlayerSpeed       = iMaxPlayerSpeed;
        WeaponInfo.Price                = iPrice;
        WeaponInfo.Damage               = iDamage;
        WeaponInfo.StickerSlotsCount    = iStickerSlotsCount;
        WeaponInfo.FullAuto             = iFullAuto;
        WeaponInfo.CycleTime            = fCycleTime;
        WeaponInfo.Spread               = fSpread;
        WeaponInfo.HasRareInspect       = bHasRareInspect;
        WeaponInfo.HasRareDraw          = bHasRareDraw;
        WeaponInfo.RareInspect          = iRareInspect;
        WeaponInfo.RareDraw             = iRareDraw;

        g_smWeaponInfo.SetArray(szWepDefIndex, WeaponInfo, sizeof(eWeaponInfo));
        g_arWeaponsNum.Push(iWepDefIndex);
    }
    PrintToServer("%s %i weapons synced successfully!", TAG_NCLR, array.Length);
}

public void ParsePaints(JSONArray array)
{

    g_iPaintsCount = array.Length;
    JSONObject jItem;
    int iDefIndex = 0;
    char szDisplayName[64];
    char szDisplayNameExtra[32];
    char szSkinDef[12];
    for(int iSkinNum = 0; iSkinNum < array.Length; iSkinNum++)
    {
        jItem = view_as<JSONObject>(array.Get(iSkinNum));

        iDefIndex = jItem.GetInt("def_index");
        g_arSkinsNum.Push(iDefIndex);

        jItem.GetString("item_name", szDisplayName, sizeof(szDisplayName));
        
        if(jItem.HasKey("item_name_extra"))
        {
            jItem.GetString("item_name_extra", szDisplayNameExtra, sizeof(szDisplayNameExtra));
            FormatEx(szDisplayName, sizeof(szDisplayName), "%s %s", szDisplayName, szDisplayNameExtra);
        }

        IntToString(iDefIndex, szSkinDef, sizeof(szSkinDef));

        eSkinInfo SkinInfo;
        SkinInfo.SkinNum = iSkinNum;
        strcopy(SkinInfo.DisplayName, sizeof(eSkinInfo::DisplayName), szDisplayName);
        SkinInfo.GloveApplicable = false;
        g_smSkinInfo.SetArray(szSkinDef, SkinInfo, sizeof(eSkinInfo));

        delete jItem;
    }
    PrintToServer("%s %i paints synced successfully!", TAG_NCLR, array.Length);
}

public void ParseGloves(JSONArray array)
{

    g_iGlovesCount = array.Length;
    JSONObject jItem;

    int iDefIndex = 0;
    int iSkinDefIndex;
    char szSkinDef[12];
    char szDisplayName[64];
    char szViewModel[PLATFORM_MAX_PATH];
    char szWorldModel[PLATFORM_MAX_PATH];
    char szGloveDef[12];
    char szPosTemp[12];

    for(int iGloveNum = 0; iGloveNum < array.Length; iGloveNum++)
    {
        jItem = view_as<JSONObject>(array.Get(iGloveNum));

        iDefIndex = jItem.GetInt("def_index");
        g_arGlovesNum.Push(iDefIndex);

        jItem.GetString("item_name", szDisplayName, sizeof(szDisplayName));
        jItem.GetString("view_model", szViewModel, sizeof(szViewModel));
        jItem.GetString("world_model", szWorldModel, sizeof(szWorldModel));

        IntToString(iDefIndex, szGloveDef, sizeof(szGloveDef));

        ArrayList arGlovePaints = new ArrayList();
        if(jItem.HasKey("paints"))
        {
            JSONObject jPaintsObj = view_as<JSONObject>(jItem.Get("paints"));
            for(int iPos = 0; iPos < jPaintsObj.Size; iPos++)
            {
                IntToString(iPos, szPosTemp, sizeof(szPosTemp));
                iSkinDefIndex = jPaintsObj.GetInt(szPosTemp);
                IntToString(iSkinDefIndex, szSkinDef, sizeof(szSkinDef));
                eSkinInfo SkinInfo;
                g_smSkinInfo.GetArray(szSkinDef, SkinInfo, sizeof(eSkinInfo));
                SkinInfo.GloveApplicable = true;
                g_smSkinInfo.SetArray(szSkinDef, SkinInfo, sizeof(eSkinInfo));
                arGlovePaints.Push(iSkinDefIndex);
            }
            g_smGlovePaints.SetValue(szGloveDef, arGlovePaints);
            delete jPaintsObj;
        }

        eGlovesInfo GloveInfo;
        GloveInfo.GloveNum = iGloveNum;
        strcopy(GloveInfo.DisplayName, sizeof(eGlovesInfo::DisplayName), szDisplayName);
        strcopy(GloveInfo.ViewModel, sizeof(eGlovesInfo::ViewModel), szViewModel);
        strcopy(GloveInfo.WorldModel, sizeof(eGlovesInfo::WorldModel), szWorldModel);
        GloveInfo.Paints = arGlovePaints;

        g_smGloveInfo.SetArray(szGloveDef, GloveInfo, sizeof(eGlovesInfo));

        delete jItem;
    }
    PrintToServer("%s %i gloves synced successfully!", TAG_NCLR, array.Length);
}

public void ParseMusicKits(JSONArray array)
{

    g_iMusicKitsCount = array.Length;
    JSONObject jItem;

    int iDefIndex = 0;
    char szDisplayName[48];
    char szMusicKitDefIndex[12];

    for(int iMusicKitNum = 0; iMusicKitNum < array.Length; iMusicKitNum++)
    {
        jItem = view_as<JSONObject>(array.Get(iMusicKitNum));

        iDefIndex = jItem.GetInt("def_index");
        g_arMusicKitsNum.Push(iDefIndex);
        jItem.GetString("item_name", szDisplayName, sizeof(szDisplayName));

        IntToString(iDefIndex, szMusicKitDefIndex, sizeof(szMusicKitDefIndex));

        eMusicKitsInfo MusicKitsInfo;
        MusicKitsInfo.MusicKitNum = iMusicKitNum;
        strcopy(MusicKitsInfo.DisplayName, sizeof(eMusicKitsInfo::DisplayName), szDisplayName);

        g_smMusicKitInfo.SetArray(szMusicKitDefIndex, MusicKitsInfo, sizeof(eMusicKitsInfo));

        delete jItem;
    }
    PrintToServer("%s %i music kits synced successfully!", TAG_NCLR, array.Length);
}

public void ParsePins(JSONArray array)
{

    g_iPinsCount = array.Length;
    JSONObject jItem;

    int iDefIndex = 0;
    char szDisplayName[48];
    char szPinKitDefIndex[12];

    for(int iPinNum = 0; iPinNum < array.Length; iPinNum++)
    {
        jItem = view_as<JSONObject>(array.Get(iPinNum));

        iDefIndex = jItem.GetInt("def_index");
        g_arPinsNum.Push(iDefIndex);
        jItem.GetString("item_name", szDisplayName, sizeof(szDisplayName));

        IntToString(iDefIndex, szPinKitDefIndex, sizeof(szPinKitDefIndex));

        ePinInfo PinInfo;
        PinInfo.PinNum = iPinNum;
        strcopy(PinInfo.DisplayName, sizeof(ePinInfo::DisplayName), szDisplayName);

        g_smPinInfo.SetArray(szPinKitDefIndex, PinInfo, sizeof(ePinInfo));

        delete jItem;
    }
    PrintToServer("%s %i pins synced successfully!", TAG_NCLR, array.Length);
}

public void ParseCoins(JSONObject array)
{
    JSONArray jCategories   = view_as<JSONArray>(array.Get("categories"));
    JSONArray jCoins        = view_as<JSONArray>(array.Get("items"));

    g_iCoinsSetsCount = jCategories.Length;
    g_iCoinsCount = jCoins.Length;

    int iID;
    char szDisplayName[48];
    char szCoinIndex[12];
    char szCoinSetIndex[12];
    for(int iCoinSet = 0; iCoinSet < g_iCoinsSetsCount; iCoinSet++)
    {
        JSONObject jSet = view_as<JSONObject>(jCategories.Get(iCoinSet));

        iID = jSet.GetInt("id");
        jSet.GetString("name", szDisplayName, sizeof(szDisplayName));
        IntToString(iID, szCoinSetIndex, sizeof(szCoinSetIndex));
        JSONObject jItems = view_as<JSONObject>(jSet.Get("items"));

        ArrayList arCoins = new ArrayList();

        for(int iItems = 0; iItems < jItems.Size; iItems++)
        {
            IntToString(iItems, szCoinIndex, sizeof(szCoinIndex));

            int iCoinDefIndex = jItems.GetInt(szCoinIndex);
            arCoins.Push(iCoinDefIndex);
        }


        g_arCoinsSetsNum.Push(iID);

        eCoinsSets CoinsSets;
        CoinsSets.CoinSetNum = iCoinSet;
        strcopy(CoinsSets.DisplayName, sizeof(eCoinsSets::DisplayName), szDisplayName);
        CoinsSets.Coins = arCoins;

        g_smCoinsSets.SetArray(szCoinSetIndex, CoinsSets, sizeof(eCoinsSets));
        
        delete jItems;
        delete jSet;
    }

    for(int iCoinNum = 0; iCoinNum < g_iCoinsCount; iCoinNum++)
    {
        JSONObject jCoin = view_as<JSONObject>(jCoins.Get(iCoinNum));

        iID = jCoin.GetInt("def_index");
        IntToString(iID, szCoinIndex, sizeof(szCoinIndex));

        g_arCoinsNum.Push(iID);
        jCoin.GetString("item_name", szDisplayName, sizeof(szDisplayName));
        eCoinInfo CoinInfo;
        CoinInfo.CoinNum = iCoinNum;
        strcopy(CoinInfo.DisplayName, sizeof(eCoinInfo::DisplayName), szDisplayName);

        g_smCoinsInfo.SetArray(szCoinIndex, CoinInfo, sizeof(eCoinInfo));
        delete jCoin;
    }

    delete jCategories;
    delete jCoins;

    PrintToServer("%s %i coins (in %i sets) synced successfully!", TAG_NCLR, g_iCoinsCount, g_iCoinsSetsCount);
}

public void ParseStickers(JSONObject array)
{
    JSONArray jCategories   = view_as<JSONArray>(array.Get("categories"));
    JSONArray jStickers     = view_as<JSONArray>(array.Get("items"));

    g_iStickersSetsCount = jCategories.Length;
    g_iStickersCount = jStickers.Length;

    int iID;
    char szDisplayName[48];
    char szStickerIndex[12];
    char szStickerSetIndex[12];
    for(int iStickerSet = 0; iStickerSet < g_iStickersSetsCount; iStickerSet++)
    {
        JSONObject jSet = view_as<JSONObject>(jCategories.Get(iStickerSet));

        iID = jSet.GetInt("id");
        jSet.GetString("name", szDisplayName, sizeof(szDisplayName));
        IntToString(iID, szStickerSetIndex, sizeof(szStickerSetIndex));
        JSONObject jItems = view_as<JSONObject>(jSet.Get("items"));

        ArrayList arStickers = new ArrayList();

        for(int iItems = 0; iItems < jItems.Size; iItems++)
        {
            IntToString(iItems, szStickerIndex, sizeof(szStickerIndex));

            int iStickerDefIndex = jItems.GetInt(szStickerIndex);
            arStickers.Push(iStickerDefIndex);
        }


        g_arStickersSetsNum.Push(iID);

        eStickersSets StickersSets;
        StickersSets.StickerSetNum = iStickerSet;
        strcopy(StickersSets.DisplayName, sizeof(eStickersSets::DisplayName), szDisplayName);
        StickersSets.Stickers = arStickers;

        g_smStickersSets.SetArray(szStickerSetIndex, StickersSets, sizeof(eStickersSets));
        
        delete jItems;
        delete jSet;
    }

    for(int iStickerNum = 0; iStickerNum < g_iStickersCount; iStickerNum++)
    {
        JSONObject jSticker = view_as<JSONObject>(jStickers.Get(iStickerNum));

        iID = jSticker.GetInt("def_index");
        IntToString(iID, szStickerIndex, sizeof(szStickerIndex));

        g_arStickersNum.Push(iID);
        jSticker.GetString("item_name", szDisplayName, sizeof(szDisplayName));

        eStickerInfo StickerInfo;
        StickerInfo.StickerNum = iStickerNum;
        strcopy(StickerInfo.DisplayName, sizeof(eStickerInfo::DisplayName), szDisplayName);
        g_smStickersInfo.SetArray(szStickerIndex, StickerInfo, sizeof(eStickerInfo));
        delete jSticker;
    }

    delete jCategories;
    delete jStickers;

    PrintToServer("%s %i stickers (in %i sets) synced successfully!", TAG_NCLR, g_iStickersCount, g_iStickersSetsCount);
}
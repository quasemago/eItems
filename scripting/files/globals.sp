enum struct eSkinInfo
{
    int SkinNum;
    char DisplayName[48];
    bool GloveApplicable;
}

enum struct eGlovesInfo
{
    int GloveNum;
    char DisplayName[48];
    char ViewModel[PLATFORM_MAX_PATH];
    char WorldModel[PLATFORM_MAX_PATH];
    ArrayList Paints;
}

enum struct eMusicKitsInfo
{
    int MusicKitNum;
    char DisplayName[48];
}

enum struct ePinInfo
{
    int PinNum;
    char DisplayName[48];
}

enum struct eCoinsSets
{
    int CoinSetNum;
    char DisplayName[48];
    ArrayList Coins;
}

enum struct eCoinInfo
{
    int CoinNum;
    char DisplayName[48];
}

enum struct eStickersSets
{
    int StickerSetNum;
    char DisplayName[48];
    ArrayList Stickers;
}

enum struct eStickerInfo
{
    int StickerNum;
    char DisplayName[48];
}

enum struct eWeaponInfo
{
    int WeaponNum;
    char DisplayName[48];
    char ClassName[48];
    char ViewModel[PLATFORM_MAX_PATH];
    char WorldModel[PLATFORM_MAX_PATH];
    ArrayList Paints;
    int Team;
    int Slot;
    int ClipAmmo;
    int StickerSlotsCount;
    int ReserveAmmo;
    int MaxPlayerSpeed;
    int Price;
    float CycleTime;
    float Spread;
    int Damage;
    int FullAuto;
    bool HasRareInspect;
    bool HasRareDraw;
    int RareInspect;
    int RareDraw;
}

enum struct eClientInfo
{
    bool GivingWeapon;

    bool Reset()
    {
        this.GivingWeapon = false;
    }  
}

eClientInfo ClientInfo[MAXPLAYERS + 1];

StringMap g_smSkinInfo = null;
ArrayList g_arSkinsNum = null;

StringMap g_smWeaponPaints = null;
StringMap g_smWeaponInfo = null;
ArrayList g_arWeaponsNum = null;

StringMap g_smGlovePaints = null;
StringMap g_smGloveInfo = null;
ArrayList g_arGlovesNum = null;

ArrayList g_arMusicKitsNum = null;
StringMap g_smMusicKitInfo = null;

ArrayList g_arPinsNum = null;
StringMap g_smPinInfo = null;

ArrayList g_arCoinsSetsNum = null;
ArrayList g_arCoinsNum = null;
StringMap g_smCoinsSets = null;
StringMap g_smCoinsInfo = null;

ArrayList g_arStickersSetsNum = null;
ArrayList g_arStickersNum = null;
StringMap g_smStickersSets = null;
StringMap g_smStickersInfo = null;

float g_fStart;

int g_iWeaponCount = 0;
int g_iPaintsCount = 0;
int g_iGlovesCount = 0;
int g_iMusicKitsCount = 0;
int g_iPinsCount = 0;
int g_iCoinsSetsCount = 0;
int g_iCoinsCount = 0;
int g_iStickersSetsCount = 0;
int g_iStickersCount = 0;

bool g_bItemsSynced = false;
bool g_bItemsSyncing = false;
bool g_bIsRoundEnd = false;

Handle g_hSwitchWeaponCall = null;

GlobalForward g_OnWeaponGiven;
GlobalForward g_OnItemsSynced;

char g_szLocalFilePath[PLATFORM_MAX_PATH];
char g_szConfigFilePath[PLATFORM_MAX_PATH];
char g_szLanguageCode[12];
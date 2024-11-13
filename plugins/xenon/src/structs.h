#pragma once

#include <xtl.h>
#include <cstddef>
#include <cassert>

#define KEY_MASK_FIRE 1
#define KEY_MASK_SPRINT 2
#define KEY_MASK_MELEE 4
#define KEY_MASK_USE 8
#define KEY_MASK_RELOAD 16
#define KEY_MASK_USERELOAD 32
#define KEY_MASK_LEANLEFT 64
#define KEY_MASK_LEANRIGHT 128
#define KEY_MASK_PRONE 256
#define KEY_MASK_CROUCH 512
#define KEY_MASK_JUMP 1024
#define KEY_MASK_ADS_MODE 2048
#define KEY_MASK_TEMP_ACTION 4096
#define KEY_MASK_HOLDBREATH 8192
#define KEY_MASK_FRAG 16384
#define KEY_MASK_SMOKE 32768
#define KEY_MASK_NIGHTVISION 262144
#define KEY_MASK_ADS 524288

/* 9096 */
struct EntHandle
{
    unsigned __int16 number;
    unsigned __int16 infoIndex;
};

/* 9097 */
struct entityShared_t
{
    unsigned __int8 linked;
    unsigned __int8 bmodel;
    unsigned __int8 svFlags;
    int clientMask[2];
    unsigned __int8 inuse;
    int broadcastTime;
    float mins[3];
    float maxs[3];
    int contents;
    float absmin[3];
    float absmax[3];
    float currentOrigin[3];
    float currentAngles[3];
    EntHandle ownerNum;
    int eventTime;
};

static_assert(sizeof(entityShared_t) == 0x0068, "");

/* 662 */
enum OffhandSecondaryClass : __int32
{
    PLAYER_OFFHAND_SECONDARY_SMOKE = 0x0,
    PLAYER_OFFHAND_SECONDARY_FLASH = 0x1,
    PLAYER_OFFHAND_SECONDARIES_TOTAL = 0x2,
};

/* 663 */
enum ViewLockTypes : __int32
{
    PLAYERVIEWLOCK_NONE = 0x0,
    PLAYERVIEWLOCK_FULL = 0x1,
    PLAYERVIEWLOCK_WEAPONJITTER = 0x2,
    PLAYERVIEWLOCKCOUNT = 0x3,
};

/* 665 */
enum team_t : __int32
{
    TEAM_FREE = 0x0,
    TEAM_AXIS = 0x1,
    TEAM_ALLIES = 0x2,
    TEAM_SPECTATOR = 0x3,
    TEAM_NUM_TEAMS = 0x4,
};

/* 8733 */
struct SprintState
{
    int sprintButtonUpRequired;
    int sprintDelay;
    int lastSprintStart;
    int lastSprintEnd;
    int sprintStartMaxLength;
};

/* 8734 */
struct MantleState
{
    float yaw;
    int timer;
    int transIndex;
    int flags;
};

/* 664 */
enum ActionSlotType : __int32
{
    ACTIONSLOTTYPE_DONOTHING = 0x0,
    ACTIONSLOTTYPE_SPECIFYWEAPON = 0x1,
    ACTIONSLOTTYPE_ALTWEAPONTOGGLE = 0x2,
    ACTIONSLOTTYPE_NIGHTVISION = 0x3,
    ACTIONSLOTTYPECOUNT = 0x4,
};

/* 8721 */
struct ActionSlotParam_SpecifyWeapon
{
    unsigned int index;
};

/* 8735 */
struct ActionSlotParam
{
    ActionSlotParam_SpecifyWeapon specifyWeapon;
};

/* 660 */
enum objectiveState_t : __int32
{
    OBJST_EMPTY = 0x0,
    OBJST_ACTIVE = 0x1,
    OBJST_INVISIBLE = 0x2,
    OBJST_DONE = 0x3,
    OBJST_CURRENT = 0x4,
    OBJST_FAILED = 0x5,
    OBJST_NUMSTATES = 0x6,
};

/* 8736 */
struct objective_t
{
    objectiveState_t state;
    float origin[3];
    int entNum;
    int teamNum;
    int icon;
};

/* 667 */
enum he_type_t : __int32
{
    HE_TYPE_FREE = 0x0,
    HE_TYPE_TEXT = 0x1,
    HE_TYPE_VALUE = 0x2,
    HE_TYPE_PLAYERNAME = 0x3,
    HE_TYPE_MAPNAME = 0x4,
    HE_TYPE_GAMETYPE = 0x5,
    HE_TYPE_MATERIAL = 0x6,
    HE_TYPE_TIMER_DOWN = 0x7,
    HE_TYPE_TIMER_UP = 0x8,
    HE_TYPE_TENTHS_TIMER_DOWN = 0x9,
    HE_TYPE_TENTHS_TIMER_UP = 0xA,
    HE_TYPE_CLOCK_DOWN = 0xB,
    HE_TYPE_CLOCK_UP = 0xC,
    HE_TYPE_WAYPOINT = 0xD,
    HE_TYPE_COUNT = 0xE,
};

/* 8713 */
struct $0D0CB43DF22755AD856C77DD3F304010
{
    unsigned __int8 r;
    unsigned __int8 g;
    unsigned __int8 b;
    unsigned __int8 a;
};

/* 8714 */
union hudelem_color_t
{
    $0D0CB43DF22755AD856C77DD3F304010 __s0;
    int rgba;
};

/* 8737 */
struct hudelem_s
{
    he_type_t type;
    float x;
    float y;
    float z;
    int targetEntNum;
    float fontScale;
    int font;
    int alignOrg;
    int alignScreen;
    hudelem_color_t color;
    hudelem_color_t fromColor;
    int fadeStartTime;
    int fadeTime;
    int label;
    int width;
    int height;
    int materialIndex;
    int offscreenMaterialIdx;
    int fromWidth;
    int fromHeight;
    int scaleStartTime;
    int scaleTime;
    float fromX;
    float fromY;
    int fromAlignOrg;
    int fromAlignScreen;
    int moveStartTime;
    int moveTime;
    int time;
    int duration;
    float value;
    int text;
    float sort;
    hudelem_color_t glowColor;
    int fxBirthTime;
    int fxLetterTime;
    int fxDecayStartTime;
    int fxDecayDuration;
    int soundID;
    int flags;
};

typedef struct hudElemState_t
{
    hudelem_s current[31];
    hudelem_s archival[31];
};

struct playerState_s
{
    int commandTime;
    int pm_type;
    int bobCycle;
    int pm_flags;
    int weapFlags;
    int otherFlags;
    int pm_time;
    float origin[3];
    float velocity[3];
    float oldVelocity[2];
    int weaponTime;
    int weaponDelay;
    int grenadeTimeLeft;
    int throwBackGrenadeOwner;
    int throwBackGrenadeTimeLeft;
    int weaponRestrictKickTime;
    int foliageSoundTime;
    int gravity;
    float leanf;
    int speed;
    float delta_angles[3];
    int groundEntityNum;
    float vLadderVec[3];
    int jumpTime;
    float jumpOriginZ;
    int legsTimer;
    int legsAnim;
    int torsoTimer;
    int torsoAnim;
    int legsAnimDuration;
    int torsoAnimDuration;
    int damageTimer;
    int damageDuration;
    int flinchYawAnim;
    int movementDir;
    int eFlags;
    int eventSequence;
    int events[4];
    unsigned int eventParms[4];
    int oldEventSequence;
    int clientNum;
    int offHandIndex;
    OffhandSecondaryClass offhandSecondary;
    unsigned int weapon;
    int weaponstate;
    unsigned int weaponShotCount;
    float fWeaponPosFrac;
    int adsDelayTime;
    int spreadOverride;
    int spreadOverrideState;
    int viewmodelIndex;
    float viewangles[3];
    int viewHeightTarget;
    float viewHeightCurrent;
    int viewHeightLerpTime;
    int viewHeightLerpTarget;
    int viewHeightLerpDown;
    float viewAngleClampBase[2];
    float viewAngleClampRange[2];
    int damageEvent;
    int damageYaw;
    int damagePitch;
    int damageCount;
    int stats[5];
    int ammo[128];
    int ammoclip[128];
    unsigned int weapons[4];
    unsigned int weaponold[4];
    unsigned int weaponrechamber[4];
    float proneDirection;
    float proneDirectionPitch;
    float proneTorsoPitch;
    ViewLockTypes viewlocked;
    int viewlocked_entNum;
    int cursorHint;
    int cursorHintString;
    int cursorHintEntIndex;
    int iCompassPlayerInfo;
    int radarEnabled;
    int locationSelectionInfo;
    SprintState sprintState;
    float fTorsoPitch;
    float fWaistPitch;
    float holdBreathScale;
    int holdBreathTimer;
    float moveSpeedScaleMultiplier;
    MantleState mantleState;
    float meleeChargeYaw;
    int meleeChargeDist;
    int meleeChargeTime;
    int perks;
    ActionSlotType actionSlotType[4];
    ActionSlotParam actionSlotParam[4];
    int entityEventSequence;
    int weapAnim;
    float aimSpreadScale;
    int shellshockIndex;
    int shellshockTime;
    int shellshockDuration;
    float dofNearStart;
    float dofNearEnd;
    float dofFarStart;
    float dofFarEnd;
    float dofNearBlur;
    float dofFarBlur;
    float dofViewmodelStart;
    float dofViewmodelEnd;
    int hudElemLastAssignedSoundID;
    objective_t objective[16];
    unsigned __int8 weaponmodels[128];
    int deltaTime;
    int killCamEntity;
    hudElemState_t hud;
};

struct playerTeamState_t
{
    int location;
};

/* 8741 */
struct clientState_s
{
    int clientIndex;
    team_t team;
    int modelindex;
    int attachModelIndex[6];
    int attachTagIndex[6];
    char name[32];
    float maxSprintTimeMultiplier;
    int rank;
    int prestige;
    int perks;
    int voiceConnectivityBits;
    char clanAbbrev[8];
    int attachedVehEntNum;
    int attachedVehSlotIndex;
};

/* 770 */
enum clientConnected_t : __int32
{
    CON_DISCONNECTED = 0x0,
    CON_CONNECTING = 0x1,
    CON_CONNECTED = 0x2,
};

/* 771 */
enum sessionState_t : __int32
{
    SESS_STATE_PLAYING = 0x0,
    SESS_STATE_DEAD = 0x1,
    SESS_STATE_SPECTATOR = 0x2,
    SESS_STATE_INTERMISSION = 0x3,
};

/* 8748 */
struct __declspec(align(2)) usercmd_s
{
    int serverTime;
    int buttons;
    int angles[3];
    unsigned __int8 weapon;
    unsigned __int8 offHandIndex;
    char forwardmove;
    char rightmove;
    float meleeChargeYaw;
    unsigned __int8 meleeChargeDist;
    char selectedLocation[2];
};

static_assert(sizeof(usercmd_s) == 0x0020, "");

/* 9100 */
struct clientSession_t
{
    sessionState_t sessionState; // correct
    int forceSpectatorClient;
    int killCamEntity;
    int status_icon;
    int archiveTime;
    int score;
    int deaths;
    int kills;
    int assists;
    unsigned __int16 scriptPersId;
    clientConnected_t connected;
    usercmd_s cmd;
    usercmd_s oldcmd;
    int localClient;
    int predictItemPickup;
    char newnetname[32];
    int maxHealth;
    int enterTime;
    playerTeamState_t teamState;
    int voteCount;
    int teamVoteCount;
    float moveSpeedScaleMultiplier;
    int viewmodelIndex;
    int noSpectate;
    int teamInfo;
    clientState_s cs;
    int psOffsetTime;
};

struct gentity_s;

struct gclient_s
{
    playerState_s ps;
    char _pad[0x04]; // not sure in correct position but retail TU4 size is 4 bytes larger
    clientSession_t sess;
    int spectatorClient;
    int noclip; // 0x30a8
    int ufo;    // 0x30ac
    int bFrozen;
    int lastCmdTime;
    int buttons;
    int oldbuttons;
    int latched_buttons;
    int buttonsSinceLastFrame;
    float oldOrigin[3];
    float fGunPitch;
    float fGunYaw;
    int damage_blood;
    float damage_from[3];
    int damage_fromWorld;
    int accurateCount;
    int accuracy_shots;
    int accuracy_hits;
    int inactivityTime;
    int inactivityWarning;
    int lastVoiceTime;
    int switchTeamTime;
    float currentAimSpreadScale;
    gentity_s *persistantPowerup;
    int portalID;
    int dropWeaponTime;
    int sniperRifleFiredTime;
    float sniperRifleMuzzleYaw;
    int PCSpecialPickedUpCount;
    EntHandle useHoldEntity;
    int useHoldTime;
    int useButtonDone;
    int iLastCompassPlayerInfoEnt;
    int compassPingTime;
    int damageTime;
    float v_dmg_roll;
    float v_dmg_pitch;
    float swayViewAngles[3];
    float swayOffset[3];
    float swayAngles[3];
    float vLastMoveAng[3];
    float fLastIdleFactor;
    float vGunOffset[3];
    float vGunSpeed[3];
    int weapIdleTime;
    int lastServerTime;
    int lastSpawnTime;
    unsigned int lastWeapon;
    bool previouslyFiring;
    bool previouslyUsingNightVision;
    bool previouslySprinting;
    int hasRadar;
    int lastStand;
    int lastStandTime;
};

static_assert(offsetof(gclient_s, noclip) == 0x30a8, "");
static_assert(offsetof(gclient_s, ufo) == 0x30ac, "");
static_assert(sizeof(gclient_s) == 12724, "");

static_assert(offsetof(gclient_s, sess) + offsetof(clientSession_t, cmd) == 12180, "");
static_assert(offsetof(gclient_s, sess) + offsetof(clientSession_t, archiveTime) == 12152, "");

struct LerpEntityStatePhysicsJitter
{
    float innerRadius;
    float minDisplacement;
    float maxDisplacement;
};

struct LerpEntityStatePlayer
{
    float leanf;
    int movementDir;
};

struct LerpEntityStateLoopFx
{
    float cullDist;
    int period;
};

struct LerpEntityStateCustomExplode
{
    int startTime;
};

struct LerpEntityStateTurret
{
    float gunAngles[3];
};

struct LerpEntityStateAnonymous
{
    int data[7];
};

struct LerpEntityStateExplosion
{
    float innerRadius;
    float magnitude;
};

struct LerpEntityStateBulletHit
{
    float start[3];
};

struct LerpEntityStatePrimaryLight
{
    byte colorAndExp[4];
    float intensity;
    float radius;
    float cosHalfFovOuter;
    float cosHalfFovInner;
};

struct LerpEntityStateMissile
{
    int launchTime;
};

struct LerpEntityStateSoundBlend
{
    float lerp;
};

struct LerpEntityStateExplosionJolt
{
    float innerRadius;
    float impulse[3];
};

struct LerpEntityStateVehicle
{
    float bodyPitch;
    float bodyRoll;
    float steerYaw;
    int materialTime;
    float gunPitch;
    float gunYaw;
    int team;
};

struct LerpEntityStateEarthquake
{
    float scale;
    float radius;
    int duration;
};

/* 678 */
enum trType_t : __int32
{
    TR_STATIONARY = 0x0,
    TR_INTERPOLATE = 0x1,
    TR_LINEAR = 0x2,
    TR_LINEAR_STOP = 0x3,
    TR_SINE = 0x4,
    TR_GRAVITY = 0x5,
    TR_ACCELERATE = 0x6,
    TR_DECELERATE = 0x7,
    TR_PHYSICS = 0x8,
    TR_FIRST_RAGDOLL = 0x9,
    TR_RAGDOLL = 0x9,
    TR_RAGDOLL_GRAVITY = 0xA,
    TR_RAGDOLL_INTERPOLATE = 0xB,
    TR_LAST_RAGDOLL = 0xB,
};

/* 8750 */
struct trajectory_t
{
    trType_t trType;
    int trTime;
    int trDuration;
    float trBase[3];
    float trDelta[3];
};

/* 8743 */
union LerpEntityStateTypeUnion
{
    LerpEntityStateTurret turret;
    LerpEntityStateLoopFx loopFx;
    LerpEntityStatePrimaryLight primaryLight;
    LerpEntityStatePlayer player;
    LerpEntityStateVehicle vehicle;
    LerpEntityStateMissile missile;
    LerpEntityStateSoundBlend soundBlend;
    LerpEntityStateBulletHit bulletHit;
    LerpEntityStateEarthquake earthquake;
    LerpEntityStateCustomExplode customExplode;
    LerpEntityStateExplosion explosion;
    LerpEntityStateExplosionJolt explosionJolt;
    LerpEntityStatePhysicsJitter physicsJitter;
    LerpEntityStateAnonymous anonymous;
};

/* 8751 */
struct LerpEntityState
{
    int eFlags;
    trajectory_t pos;
    trajectory_t apos;
    LerpEntityStateTypeUnion u;
};

struct entityState_s
{
    int number; // entity index	//0x00
    int eType;  // entityType_t	//0x04

    LerpEntityState lerp;

    int time2; // 0x70

    int otherEntityNum;    // 0x74 shotgun sources, etc
    int attackerEntityNum; // 0x78

    int groundEntityNum; // 0x7c -1 = in air

    int loopSound; // 0x80 constantly loop this sound
    int surfType;  // 0x84

    int index;         // 0x88
    int clientNum;     // 0x8c 0 to (MAX_CLIENTS - 1), for players and corpses
    int iHeadIcon;     // 0x90
    int iHeadIconTeam; // 0x94

    int solid; // 0x98 for client side prediction, trap_linkentity sets this properly	0x98

    int eventParm;     // 0x9c impulse events -- muzzle flashes, footsteps, etc
    int eventSequence; // 0xa0

    int events[4];     // 0xa4
    int eventParms[4]; // 0xb4

    // for players
    int weapon;      // 0xc4 determines weapon and flash model, etc
    int weaponModel; // 0xc8
    int legsAnim;    // 0xcc mask off ANIM_TOGGLEBIT
    int torsoAnim;   // 0xd0 mask off ANIM_TOGGLEBIT

    union
    {
        int helicopterStage; // 0xd4
    } un1;

    int un2;                  // 0xd8
    int fTorsoPitch;          // 0xdc
    int fWaistPitch;          // 0xe0
    unsigned int partBits[4]; // 0xe4
};

static_assert(sizeof(entityState_s) == 0xf4, "");
static_assert(offsetof(entityState_s, index) == 0x88, "");

struct gentity_s
{
    entityState_s s;   // 0x0000, 0x00F4
    entityShared_t r;  // 0x00F4, 0x0068
    gclient_s *client; // 0x015c, 0x0004
};

static_assert(offsetof(gentity_s, client) == 0x0015C, "");

struct scr_entref_t
{
    unsigned __int16 entnum;
    unsigned __int16 classnum;
};

typedef void (*xfunction_t)(scr_entref_t);

/* 8925 */
union DvarValue
{
    bool enabled;
    int integer;
    unsigned int unsignedInt;
    float value;
    float vector[4];
    const char *string;
    unsigned __int8 color[4];
};

/* 8928 */
struct dvar_s
{
    const char *name;
    const char *description;
    unsigned __int16 flags;
    unsigned __int8 type;
    bool modified;
    DvarValue current;
    DvarValue latched;
    DvarValue reset;
    // DvarLimits domain;
    // dvar_s *hashNext;
};

/* 671 */
enum netsrc_t : __int32
{
    NS_CLIENT1 = 0x0,
    NS_CLIENT2 = 0x1,
    NS_CLIENT3 = 0x2,
    NS_CLIENT4 = 0x3,
    NS_SERVER = 0x4,
    NS_MAXCLIENTS = 0x4,
    NS_PACKET = 0x5,
};

/* 659 */
enum netadrtype_t : __int32
{
    NA_BOT = 0x0,
    NA_BAD = 0x1,
    NA_LOOPBACK = 0x2,
    NA_BROADCAST = 0x3,
    NA_IP = 0x4,
};

/* 8757 */
struct __declspec(align(4)) netadr_t
{
    netadrtype_t type;
    unsigned __int8 ip[4];
    unsigned __int16 port;
};

/* 8723 */
struct netProfilePacket_t
{
    int iTime;
    int iSize;
    int bFragment;
};

/* 8724 */
struct netProfileStream_t
{
    netProfilePacket_t packets[60];
    int iCurrPacket;
    int iBytesPerSecond;
    int iLastBPSCalcTime;
    int iCountedPackets;
    int iCountedFragments;
    int iFragmentPercentage;
    int iLargestPacket;
    int iSmallestPacket;
};

/* 8755 */
struct netProfileInfo_t
{
    netProfileStream_t send;
    netProfileStream_t recieve;
};

/* 8758 */
struct netchan_t
{
    int outgoingSequence;
    netsrc_t sock;
    int dropped;
    int incomingSequence;
    netadr_t remoteAddress;
    int fragmentSequence;
    int fragmentLength;
    unsigned __int8 *fragmentBuffer;
    int fragmentBufferSize;
    int unsentFragments;
    int unsentFragmentStart;
    int unsentLength;
    unsigned __int8 *unsentBuffer;
    int unsentBufferSize;
    netProfileInfo_t prof;
};

/* 9758 */
const struct clientHeader_t
{
    int state;
    int sendAsActive;
    int deltaMessage;
    int rateDelayed;
    netchan_t netchan;
    float predictedOrigin[3];
    int predictedOriginServerTime;
};

static_assert(offsetof(clientHeader_t, deltaMessage) == 0x8, "");

/* 9760 */
struct svscmd_info_t
{
    char cmd[1024];
    int time;
    int type;
};

struct __declspec(align(4)) client_t
{
    clientHeader_t header;
    const char *dropReason;
    char userinfo[1024];
    svscmd_info_t reliableCommandInfo[128];
    int reliableSequence;
    int reliableAcknowledge;
    int reliableSent;
    int messageAcknowledge;
    int gamestateMessageNum;
    int challenge;
    usercmd_s lastUsercmd;              // 0x20E5C, 0x0020
    int lastClientCommand;              // 0x20E7C, 0x0004
    char lastClientCommandString[1024]; // 0x20E80, 0x0004
    gentity_s *gentity;                 // 0x21280, 0x0004
    char name[32];                      // 0x21284, 0x0020
    char _padding[0x819e4];             // Padding to reach 666760 bytes
};

static_assert(sizeof(client_t) == 666760, "");
static_assert(offsetof(client_t, gentity) == 0x21280, "");

struct clientState_s;
struct svEntity_s;
struct archivedEntity_s;
struct cachedClient_s;
struct cachedSnapshot_t;

/* 9766 */
struct serverStaticHeader_t
{
    client_t *clients;
    int time;
    int snapFlagServerBit;
    int numSnapshotEntities;
    int numSnapshotClients;
    int nextSnapshotEntities;
    entityState_s *snapshotEntities;
    clientState_s *snapshotClients;
    svEntity_s *svEntities;
    float mapCenter[3];
    archivedEntity_s *cachedSnapshotEntities;
    cachedClient_s *cachedSnapshotClients;
    unsigned __int8 *archivedSnapshotBuffer;
    cachedSnapshot_t *cachedSnapshotFrames;
    int nextCachedSnapshotFrames;
    int nextArchivedSnapshotFrames;
    int nextCachedSnapshotEntities;
    int nextCachedSnapshotClients;
    int num_entities;
    int maxclients;
    int fps;
    int clientArchive;
    gentity_s *gentities;
    int gentitySize;
    clientState_s *firstClientState;
    playerState_s *firstPlayerState;
    int clientSize;
    unsigned int pad[3];
};

static_assert(sizeof(serverStaticHeader_t) == 0x0080, "");

/* 697 */
enum conChannel_t : __int32
{
    CON_CHANNEL_DONT_FILTER = 0x0,
    CON_CHANNEL_ERROR = 0x1,
    CON_CHANNEL_GAMENOTIFY = 0x2,
    CON_CHANNEL_BOLDGAME = 0x3,
    CON_CHANNEL_SUBTITLE = 0x4,
    CON_CHANNEL_OBITUARY = 0x5,
    CON_CHANNEL_LOGFILEONLY = 0x6,
    CON_CHANNEL_CONSOLEONLY = 0x7,
    CON_CHANNEL_GFX = 0x8,
    CON_CHANNEL_SOUND = 0x9,
    CON_CHANNEL_FILES = 0xA,
    CON_CHANNEL_DEVGUI = 0xB,
    CON_CHANNEL_PROFILE = 0xC,
    CON_CHANNEL_UI = 0xD,
    CON_CHANNEL_CLIENT = 0xE,
    CON_CHANNEL_SERVER = 0xF,
    CON_CHANNEL_SYSTEM = 0x10,
    CON_CHANNEL_PLAYERWEAP = 0x11,
    CON_CHANNEL_AI = 0x12,
    CON_CHANNEL_ANIM = 0x13,
    CON_CHANNEL_PHYS = 0x14,
    CON_CHANNEL_FX = 0x15,
    CON_CHANNEL_LEADERBOARDS = 0x16,
    CON_CHANNEL_PARSERSCRIPT = 0x17,
    CON_CHANNEL_SCRIPT = 0x18,
    CON_BUILTIN_CHANNEL_COUNT = 0x19,
};

/* 9735 */
struct BuiltinFunctionDef
{
    const char *actionString;
    void(__cdecl *actionFunc)();
    int type;
};

/* 8951 */
struct __declspec(align(4)) cLeaf_t
{
    unsigned __int16 firstCollAabbIndex;
    unsigned __int16 collAabbCount;
    int brushContents;
    int terrainContents;
    float mins[3];
    float maxs[3];
    int leafBrushNode;
    __int16 cluster;
};

/* 8960 */
struct cmodel_t
{
    float mins[3];
    float maxs[3];
    float radius;
    cLeaf_t leaf;
};

static_assert(sizeof(cmodel_t) == 72, "");

/* 8761 */
struct cplane_s
{
    float normal[3];
    float dist;
    unsigned __int8 type;
    unsigned __int8 signbits;
    unsigned __int8 pad[2];
};

/* 8798 */
struct __declspec(align(2)) cbrushside_t
{
    cplane_s *plane;
    unsigned int materialNum;
    __int16 firstAdjacentSideOffset;
    unsigned __int8 edgeCount;
};

/* 8961 */
struct __declspec(align(16)) cbrush_t
{
    float mins[3];
    int contents;
    float maxs[3];
    unsigned int numsides;
    cbrushside_t *sides;
    __int16 axialMaterialNum[2][3];
    unsigned __int8 *baseAdjacentSide;
    __int16 firstAdjacentSideOffsets[2][3];
    unsigned __int8 edgeCount[2][3];
};

static_assert(sizeof(cbrush_t) == 80, "");

/* 9073 */
struct MapEnts
{
    const char *name;
    char *entityString;
    int numEntityChars;
};

// stubs
struct cStaticModel_s;
struct dmaterial_t;
struct cNode_t;
struct cLeaf_t;
struct cLeafBrushNode_s;
struct CollisionBorder;
struct CollisionPartition;
struct CollisionAabbTree;
struct DynEntityDef;
struct DynEntityPose;
struct DynEntityClient;
struct DynEntityColl;

/* 9079 */
struct clipMap_t
{
    const char *name;
    int isInUse; // 82A23244
    int planeCount;
    cplane_s *planes;
    unsigned int numStaticModels;
    cStaticModel_s *staticModelList;
    unsigned int numMaterials;
    dmaterial_t *materials;
    unsigned int numBrushSides;
    cbrushside_t *brushsides;
    unsigned int numBrushEdges;
    unsigned __int8 *brushEdges;
    unsigned int numNodes;
    cNode_t *nodes;
    unsigned int numLeafs;
    cLeaf_t *leafs;
    unsigned int leafbrushNodesCount;
    cLeafBrushNode_s *leafbrushNodes;
    unsigned int numLeafBrushes;
    unsigned __int16 *leafbrushes;
    unsigned int numLeafSurfaces;
    unsigned int *leafsurfaces;
    unsigned int vertCount;
    float (*verts)[3];
    int triCount;
    unsigned __int16 *triIndices;
    unsigned __int8 *triEdgeIsWalkable;
    int borderCount;
    CollisionBorder *borders;
    int partitionCount;
    CollisionPartition *partitions;
    int aabbTreeCount;
    CollisionAabbTree *aabbTrees;
    unsigned int numSubModels;
    cmodel_t *cmodels;
    unsigned __int16 numBrushes;
    cbrush_t *brushes;
    int numClusters;
    int clusterBytes;
    unsigned __int8 *visibility;
    int vised;
    MapEnts *mapEnts;
    cbrush_t *box_brush;
    cmodel_t box_model;
    unsigned __int16 dynEntCount[2];
    DynEntityDef *dynEntDefList[2];
    DynEntityPose *dynEntPoseList[2];
    DynEntityClient *dynEntClientList[2];
    DynEntityColl *dynEntCollList[2];
    unsigned int checksum;
};

/* 8794 */
struct __declspec(align(8)) MaterialInfo
{
    const char *name;
    // unsigned __int8 gameFlags;
    // unsigned __int8 sortKey;
    // unsigned __int8 textureAtlasRowCount;
    // unsigned __int8 textureAtlasColumnCount;
    // GfxDrawSurf drawSurf;
    // unsigned int surfaceTypeBits;
};

/* 677 */
enum XAssetType : __int32
{
    ASSET_TYPE_XMODELPIECES = 0x0,
    ASSET_TYPE_PHYSPRESET = 0x1,
    ASSET_TYPE_XANIMPARTS = 0x2,
    ASSET_TYPE_XMODEL = 0x3,
    ASSET_TYPE_MATERIAL = 0x4,
    ASSET_TYPE_PIXELSHADER = 0x5,
    ASSET_TYPE_TECHNIQUE_SET = 0x6,
    ASSET_TYPE_IMAGE = 0x7,
    ASSET_TYPE_SOUND = 0x8,
    ASSET_TYPE_SOUND_CURVE = 0x9,
    ASSET_TYPE_LOADED_SOUND = 0xA,
    ASSET_TYPE_CLIPMAP = 0xB,
    ASSET_TYPE_CLIPMAP_PVS = 0xC,
    ASSET_TYPE_COMWORLD = 0xD,
    ASSET_TYPE_GAMEWORLD_SP = 0xE,
    ASSET_TYPE_GAMEWORLD_MP = 0xF,
    ASSET_TYPE_MAP_ENTS = 0x10,
    ASSET_TYPE_GFXWORLD = 0x11,
    ASSET_TYPE_LIGHT_DEF = 0x12,
    ASSET_TYPE_UI_MAP = 0x13,
    ASSET_TYPE_FONT = 0x14,
    ASSET_TYPE_MENULIST = 0x15,
    ASSET_TYPE_MENU = 0x16,
    ASSET_TYPE_LOCALIZE_ENTRY = 0x17,
    ASSET_TYPE_WEAPON = 0x18,
    ASSET_TYPE_SNDDRIVER_GLOBALS = 0x19,
    ASSET_TYPE_FX = 0x1A,
    ASSET_TYPE_IMPACT_FX = 0x1B,
    ASSET_TYPE_AITYPE = 0x1C,
    ASSET_TYPE_MPTYPE = 0x1D,
    ASSET_TYPE_CHARACTER = 0x1E,
    ASSET_TYPE_XMODELALIAS = 0x1F,
    ASSET_TYPE_RAWFILE = 0x20,
    ASSET_TYPE_STRINGTABLE = 0x21,
    ASSET_TYPE_COUNT = 0x22,
    ASSET_TYPE_STRING = 0x22,
    ASSET_TYPE_ASSETLIST = 0x23,
};

/* 8914 */
struct XModel
{
    const char *name;
    //   unsigned __int8 numBones;
    //   unsigned __int8 numRootBones;
    //   unsigned __int8 numsurfs;
    //   unsigned __int8 lodRampType;
    //   unsigned __int16 *boneNames;
    //   unsigned __int8 *parentList;
    //   __int16 *quats;
    //   float *trans;
    //   unsigned __int8 *partClassification;
    //   DObjAnimMat *baseMat;
    //   XSurface *surfs;
    //   Material **materialHandles;
    //   XModelLodInfo lodInfo[4];
    //   XModelCollSurf_s *collSurfs;
    //   int numCollSurfs;
    //   int contents;
    //   XBoneInfo *boneInfo;
    //   float radius;
    //   float mins[3];
    //   float maxs[3];
    //   __int16 numLods;
    //   __int16 collLod;
    //   XModelStreamInfo streamInfo;
    //   int memUsage;
    //   unsigned __int8 flags;
    //   PhysPreset *physPreset;
    //   PhysGeomList *physGeoms;
};

/* 9056 */
struct XModelPiece
{
    XModel *model;
    float offset[3];
};

/* 9057 */
struct XModelPieces
{
    const char *name;
    int numpieces;
    XModelPiece *pieces;
};

/* 8908 */
struct __declspec(align(4)) PhysPreset
{
    const char *name;
    int type;
    float mass;
    float bounce;
    float friction;
    float bulletForceScale;
    float explosiveForceScale;
    const char *sndAliasPrefix;
    float piecesSpreadFraction;
    float piecesUpwardVelocity;
    bool tempDefaultToCylinder;
};

/* 8884 */
struct XAnimParts
{
    const char *name;
    //   unsigned __int16 dataByteCount;
    //   unsigned __int16 dataShortCount;
    //   unsigned __int16 dataIntCount;
    //   unsigned __int16 randomDataByteCount;
    //   unsigned __int16 randomDataIntCount;
    //   unsigned __int16 numframes;
    //   bool bLoop;
    //   bool bDelta;
    //   unsigned __int8 boneCount[12];
    //   unsigned __int8 notifyCount;
    //   unsigned __int8 assetType;
    //   bool pad;
    //   unsigned int randomDataShortCount;
    //   unsigned int indexCount;
    //   float framerate;
    //   float frequency;
    //   unsigned __int16 *names;
    //   unsigned __int8 *dataByte;
    //   __int16 *dataShort;
    //   int *dataInt;
    //   __int16 *randomDataShort;
    //   unsigned __int8 *randomDataByte;
    //   int *randomDataInt;
    //   XAnimIndices indices;
    //   XAnimNotifyInfo *notify;
    //   XAnimDeltaPart *deltaPart;
};

/* 8820 */
struct Material
{
    MaterialInfo info;
    //   unsigned __int8 stateBitsEntry[26];
    //   unsigned __int8 textureCount;
    //   unsigned __int8 constantCount;
    //   unsigned __int8 stateBitsCount;
    //   unsigned __int8 stateFlags;
    //   unsigned __int8 cameraRegion;
    //   MaterialTechniqueSet *techniqueSet;
    //   MaterialTextureDef *textureTable;
    //   MaterialConstantDef *constantTable;
    //   GfxStateBits *stateBitsTable;
};

/* 8802 */
struct GfxPixelShaderLoadDef
{
    unsigned __int8 *cachedPart;
    unsigned __int8 *physicalPart;
    unsigned __int16 cachedPartSize;
    unsigned __int16 physicalPartSize;
};

/* 8803 */
union MaterialPixelShaderProgram
{
    D3DPixelShader *ps;
    GfxPixelShaderLoadDef loadDef;
};

/* 8804 */
struct MaterialPixelShader
{
    const char *name;
    MaterialPixelShaderProgram prog;
};

/* 8799 */
struct GfxVertexShaderLoadDef
{
    unsigned __int8 *cachedPart;
    unsigned __int8 *physicalPart;
    unsigned __int16 cachedPartSize;
    unsigned __int16 physicalPartSize;
};

/* 8800 */
union MaterialVertexShaderProgram
{
    D3DVertexShader *vs;
    GfxVertexShaderLoadDef loadDef;
};

/* 8801 */
struct MaterialVertexShader
{
    const char *name;
    MaterialVertexShaderProgram prog;
};

/* 8795 */
struct MaterialTechniqueSet
{
    const char *name;
    unsigned __int8 worldVertFormat;
    unsigned __int8 unused[2];
    MaterialTechniqueSet *remappedTechniqueSet;
    //   MaterialTechnique *techniques[26];
};

/* 943 */
enum MapType : __int32
{
    MAPTYPE_NONE = 0x0,
    MAPTYPE_INVALID1 = 0x1,
    MAPTYPE_INVALID2 = 0x2,
    MAPTYPE_2D = 0x3,
    MAPTYPE_3D = 0x4,
    MAPTYPE_CUBE = 0x5,
    MAPTYPE_COUNT = 0x6,
};

struct GfxImageLoadDef; // forward declaration

/* 8810 */
union GfxTexture
{
    D3DBaseTexture *basemap;
    D3DTexture *map;
    D3DVolumeTexture *volmap;
    D3DCubeTexture *cubemap;
    GfxImageLoadDef *loadDef;
};

/* 8811 */
struct GfxImageLoadDef
{
    unsigned __int8 levelCount;
    unsigned __int8 flags;
    __int16 dimensions[3];
    int format;
    GfxTexture texture;
};

static_assert(offsetof(GfxImageLoadDef, texture) == 12, "");

/* 8812 */
struct CardMemory
{
    int platform[1];
};

/* 8813 */
struct GfxImage
{
    MapType mapType;
    GfxTexture texture;
    unsigned __int8 semantic;
    CardMemory cardMemory;
    unsigned __int16 width;
    unsigned __int16 height;
    unsigned __int16 depth;
    unsigned __int8 category;
    bool delayLoadPixels;
    unsigned __int8 *pixels;
    unsigned int baseSize;
    unsigned __int16 streamSlot;
    bool streaming;
    const char *name;
};

struct snd_alias_t;

/* 8976 */
struct snd_alias_list_t
{
    const char *aliasName;
    snd_alias_t *head;
    int count;
};

/* 8930 */
struct SndCurve
{
    const char *filename;
    int knotCount;
    float knots[8][2];
};

/* 8924 */
struct LoadedSound
{
    const char *name;
    // XaSound sound;
};

// struct clipMap_t;

/* 9080 */
struct ComPrimaryLight
{
    unsigned __int8 type;
    unsigned __int8 canUseShadowMap;
    unsigned __int8 exponent;
    unsigned __int8 unused;
    float color[3];
    float dir[3];
    float origin[3];
    float radius;
    float cosHalfFovOuter;
    float cosHalfFovInner;
    float cosHalfFovExpanded;
    float rotationLimit;
    float translationLimit;
    const char *defName;
};

/* 9081 */
struct ComWorld
{
    const char *name;
    int isInUse;
    unsigned int primaryLightCount;
    ComPrimaryLight *primaryLights;
};

/* 9092 */
struct GameWorldSp
{
    const char *name;
    //   PathData path;
};

/* 9093 */
struct GameWorldMp
{
    const char *name;
};

/* 9131 */
struct GfxWorld
{
    const char *name;
    const char *baseName;
    int planeCount;
    int nodeCount;
    int indexCount;
    unsigned __int16 *indices;
    //   D3DIndexBuffer indexBuffer;
    //   int surfaceCount;
    //   GfxWorldStreamInfo streamInfo;
    //   int skySurfCount;
    //   int *skyStartSurfs;
    //   GfxImage *skyImage;
    //   unsigned __int8 skySamplerState;
    //   unsigned int vertexCount;
    //   GfxWorldVertexData vd;
    //   unsigned int vertexLayerDataSize;
    //   GfxWorldVertexLayerData vld;
    //   SunLightParseParams sunParse;
    //   GfxLight *sunLight;
    //   float sunColorFromBsp[3];
    //   unsigned int sunPrimaryLightIndex;
    //   unsigned int primaryLightCount;
    //   int cullGroupCount;
    //   unsigned int reflectionProbeCount;
    //   GfxReflectionProbe *reflectionProbes;
    //   GfxTexture *reflectionProbeTextures;
    //   GfxWorldDpvsPlanes dpvsPlanes;
    //   int cellBitsCount;
    //   GfxCell *cells;
    //   int lightmapCount;
    //   GfxLightmapArray *lightmaps;
    //   GfxLightGrid lightGrid;
    //   GfxTexture *lightmapPrimaryTextures;
    //   GfxTexture *lightmapSecondaryTextures;
    //   int modelCount;
    //   GfxBrushModel *models;
    //   float mins[3];
    //   float maxs[3];
    //   unsigned int checksum;
    //   int materialMemoryCount;
    //   MaterialMemory *materialMemory;
    //   sunflare_t sun;
    //   float outdoorLookupMatrix[4][4];
    //   GfxImage *outdoorImage;
    //   unsigned int *cellCasterBits;
    //   GfxSceneDynModel *sceneDynModel;
    //   GfxSceneDynBrush *sceneDynBrush;
    //   unsigned int *primaryLightEntityShadowVis;
    //   unsigned int *primaryLightDynEntShadowVis[2];
    //   unsigned __int8 *nonSunPrimaryLightForModelDynEnt;
    //   GfxShadowGeometry *shadowGeom;
    //   GfxLightRegion *lightRegion;
    //   GfxWorldDpvsStatic dpvs;
    //   GfxWorldDpvsDynamic dpvsDyn;
};

/* 8929 */
struct __declspec(align(4)) GfxLightImage
{
    GfxImage *image;
    unsigned __int8 samplerState;
};

/* 8933 */
struct GfxLightDef
{
    const char *name;
    GfxLightImage attenuation;
    int lmapLookupStart;
};

/* 8828 */
struct Glyph
{
    unsigned __int16 letter;
    char x0;
    char y0;
    unsigned __int8 dx;
    unsigned __int8 pixelWidth;
    unsigned __int8 pixelHeight;
    float s0;
    float t0;
    float s1;
    float t1;
};

/* 8829 */
struct Font_s
{
    const char *fontName;
    int pixelHeight;
    int glyphCount;
    Material *material;
    Material *glowMaterial;
    Glyph *glyphs;
};

/* 9030 */
struct MenuList
{
    const char *name;
    int menuCount;
    // menuDef_t **menus;
};

struct menuDef_t;

/* 9132 */
struct LocalizeEntry
{
    const char *value;
    const char *name;
};

/* 9133 */
struct WeaponDef
{
    const char *szInternalName;
    const char *szDisplayName;
    const char *szOverlayName;
    // ... lots of fields
};

/* 9049 */
struct XaReverbSettings;

/* 9134 */
struct SndDriverGlobals
{
    XaReverbSettings *reverbSettings;
    const char *name;
};

/* 8953 */
const struct FxElemDef;

/* 8947 */
const struct FxEffectDef
{
    const char *name;
    int flags;
    int totalSize;
    int msecLoopingLife;
    int elemDefCountLooping;
    int elemDefCountOneShot;
    int elemDefCountEmission;
    const FxElemDef *elemDefs;
};

/* 9050 */
struct FxImpactEntry;

/* 9055 */
struct FxImpactTable
{
    const char *name;
    FxImpactEntry *table;
};

/* 9135 */
struct RawFile
{
    const char *name;
    int len;
    const char *buffer;
};

/* 9053 */
struct StringTable
{
    const char *name;
    int columnCount;
    int rowCount;
    const char **values;
};

/* 9025 */
union XAssetHeader
{
    XModelPieces *xmodelPieces;
    PhysPreset *physPreset;
    XAnimParts *parts;
    XModel *model;
    Material *material;
    MaterialPixelShader *pixelShader;
    MaterialVertexShader *vertexShader;
    MaterialTechniqueSet *techniqueSet;
    GfxImage *image;
    snd_alias_list_t *sound;
    SndCurve *sndCurve;
    LoadedSound *loadSnd;
    clipMap_t *clipMap;
    ComWorld *comWorld;
    GameWorldSp *gameWorldSp;
    GameWorldMp *gameWorldMp;
    MapEnts *mapEnts;
    GfxWorld *gfxWorld;
    GfxLightDef *lightDef;
    Font_s *font;
    MenuList *menuList;
    menuDef_t *menu;
    LocalizeEntry *localize;
    WeaponDef *weapon;
    SndDriverGlobals *sndDriverGlobals;
    const FxEffectDef *fx;
    FxImpactTable *impactFx;
    RawFile *rawfile;
    StringTable *stringTable;
    void *data;
};

/* 1100 */
enum FsThread : __int32
{
    FS_THREAD_MAIN = 0x0,
    FS_THREAD_STREAM = 0x1,
    FS_THREAD_DATABASE = 0x2,
    FS_THREAD_BACKEND = 0x3,
};

/* 9646 */
struct XAsset
{
    XAssetType type;
    XAssetHeader header;
};

/* 9743 */
struct XAssetEntry
{
    XAsset asset;
    unsigned __int8 zoneIndex;
    bool inuse;
    unsigned __int16 nextHash;
    unsigned __int16 nextOverride;
    unsigned __int16 usageFrame;
};

/* 9748 */
union XAssetEntryPoolEntry
{
    XAssetEntry entry;
    XAssetEntryPoolEntry *next;
};

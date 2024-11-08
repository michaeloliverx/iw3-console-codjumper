#include <xtl.h>
#include <string>
#include <cstdint>
#include <iostream>
#include <cstddef>
#include <cassert>
#include <vector>
#include <map>
#include "detour.h"
#include "structs.h"

extern "C"
{
    uint32_t XamGetCurrentTitleId();

    uint32_t ExCreateThread(
        HANDLE *pHandle,
        uint32_t stackSize,
        uint32_t *pThreadId,
        void *pApiThreadStartup,
        PTHREAD_START_ROUTINE pStartAddress,
        void *pParameter,
        uint32_t creationFlags);

    long DbgPrint(const char *format, ...);
}

void *ResolveFunction(const std::string &moduleName, uint32_t ordinal)
{
    HMODULE moduleHandle = GetModuleHandle(moduleName.c_str());
    if (moduleHandle == nullptr)
        return nullptr;

    return GetProcAddress(moduleHandle, reinterpret_cast<const char *>(ordinal));
}

typedef void (*XNOTIFYQUEUEUI)(uint32_t type, uint32_t userIndex, uint64_t areas, const wchar_t *displayText, void *pContextData);
XNOTIFYQUEUEUI XNotifyQueueUI = static_cast<XNOTIFYQUEUEUI>(ResolveFunction("xam.xex", 656));

enum Games
{
    GAME_IW3 = 0x415607E6,
};

void InitIW3();

bool g_Running = true;

uint32_t MonitorTitleId(void *pThreadParameter)
{
    uint32_t currentTitleId = 0;

    while (g_Running)
    {
        uint32_t newTitleId = XamGetCurrentTitleId();

        if (newTitleId == currentTitleId)
            continue;

        currentTitleId = newTitleId;

        switch (newTitleId)
        {
        case GAME_IW3:
            InitIW3();
            break;
        }
    }

    return 0;
}

// Function pointers
void (*CG_GameMessage)(int localClientNum, const char *msg) = reinterpret_cast<void (*)(int localClientNum, const char *msg)>(0x8230AAF0);
dvar_s *(*Dvar_FindMalleableVar)(const char *dvarName) = reinterpret_cast<dvar_s *(*)(const char *dvarName)>(0x821D4C10);
int (*Scr_GetInt)(unsigned int index) = reinterpret_cast<int (*)(unsigned int index)>(0x8220FD10);
void (*Scr_GetVector)(unsigned int index, float *vectorValue) = reinterpret_cast<void (*)(unsigned int index, float *vectorValue)>(0x8220FA88);
xfunction_t *(*Scr_GetFunction)(const char **pName, int *type) = reinterpret_cast<xfunction_t *(*)(const char **pName, int *type)>(0x82256ED0);
xfunction_t *(*Scr_GetMethod)(const char **pName, int *type) = reinterpret_cast<xfunction_t *(*)(const char **pName, int *type)>(0x822570E0);
xfunction_t *(*Player_GetMethod)(const char **pName) = reinterpret_cast<xfunction_t *(*)(const char **pName)>(0x8227E098);
xfunction_t *(*ScriptEnt_GetMethod)(const char **pName) = reinterpret_cast<xfunction_t *(*)(const char **pName)>(0x82254D78);
xfunction_t *(*HudElem_GetMethod)(const char **pName) = reinterpret_cast<xfunction_t *(*)(const char **pName)>(0x822773A8);
xfunction_t *(*Helicopter_GetMethod)(const char **pName) = reinterpret_cast<xfunction_t *(*)(const char **pName)>(0x82265C68);
xfunction_t *(*BuiltIn_GetMethod)(const char **pName, int *type) = reinterpret_cast<xfunction_t *(*)(const char **pName, int *type)>(0x82256E20);
void (*SV_ClientThink)(client_t *cl, usercmd_s *cmd) = reinterpret_cast<void (*)(client_t *cl, usercmd_s *cmd)>(0x82208448);
void (*ClientThink)(int clientNum) = reinterpret_cast<void (*)(int clientNum)>(0x822886E8);
void (*G_SetLastServerTime)(int clientNum, int lastServerTime) = reinterpret_cast<void (*)(int clientNum, int lastServerTime)>(0x82285D08);
void (*Com_PrintError)(conChannel_t channel, const char *fmt, ...) = reinterpret_cast<void (*)(conChannel_t channel, const char *fmt, ...)>(0x82235C50);
char *(*va)(char *format, ...) = reinterpret_cast<char *(*)(char *format, ...)>(0x821CD858);
void (*Scr_AddInt)(int value) = reinterpret_cast<void (*)(int value)>(0x822111C0);
void (*Scr_Error)(const char *error) = reinterpret_cast<void (*)(const char *error)>(0x8220F6F0);
gentity_s *(*Scr_GetEntity)(scr_entref_t *entref) = reinterpret_cast<gentity_s *(*)(scr_entref_t *)>(0x8224EE68);
gentity_s *(*GetEntity)(scr_entref_t entref) = reinterpret_cast<gentity_s *(*)(scr_entref_t entref)>(0x82257F30);
void (*SV_UnlinkEntity)(gentity_s *ent) = reinterpret_cast<void (*)(gentity_s *ent)>(0x82355F08);
int (*SV_SetBrushModel)(gentity_s *ent) = reinterpret_cast<int (*)(gentity_s *ent)>(0x82205050);
void (*SV_LinkEntity)(gentity_s *ent) = reinterpret_cast<void (*)(gentity_s *ent)>(0x82355A00);

// Variables
serverStaticHeader_t *svsHeader = reinterpret_cast<serverStaticHeader_t *>(0x849F1580);
clipMap_t *cm = reinterpret_cast<clipMap_t *>(0x82A23240);

std::vector<int> originalBrushContents;
std::string lastMapName;

/**
 * Save the original contents of the brushes in the map.
 */
void SaveOriginalBrushContents()
{
    dvar_s *mapname = Dvar_FindMalleableVar("mapname");
    if (lastMapName != mapname->current.string)
    {
        originalBrushContents.clear();
        originalBrushContents.resize(cm->numBrushes);
        for (int i = 0; i < cm->numBrushes; i++)
            originalBrushContents[i] = cm->brushes[i].contents;

        lastMapName = mapname->current.string;
    }
}

void RemoveBrushCollisions(int heightLimit)
{
    SaveOriginalBrushContents();

    for (int i = 0; i < cm->numBrushes; i++)
    {
        cbrush_t &brush = cm->brushes[i];
        float height = brush.maxs[2] - brush.mins[2];
        if (height > heightLimit)
            brush.contents &= ~0x10000;
    }
}

void RestoreBrushCollisions()
{
    SaveOriginalBrushContents();

    for (int i = 0; i < cm->numBrushes; i++)
        cm->brushes[i].contents = originalBrushContents[i];
}

void GScr_RemoveBrushCollisionsOverHeight(scr_entref_t entref)
{
    int heightLimit = Scr_GetInt(0);
    RemoveBrushCollisions(heightLimit);
}

void GScr_RestoreBrushCollisions(scr_entref_t entref)
{
    RestoreBrushCollisions();
}

bool IsPointInsideBounds(const float point[3], const float mins[3], const float maxs[3])
{
    return (point[0] >= mins[0] && point[0] <= maxs[0] &&
            point[1] >= mins[1] && point[1] <= maxs[1] &&
            point[2] >= mins[2] && point[2] <= maxs[2]);
}

void GScr_EnableCollisionForBrushContainingOrigin()
{
    SaveOriginalBrushContents();

    float point[3] = {0.0f, 0.0f, 0.0f};
    Scr_GetVector(0, point);

    int matchBrushIndex = -1;

    for (int i = 0; i < cm->numBrushes; i++)
    {
        cbrush_t &brush = cm->brushes[i];
        if (IsPointInsideBounds(point, brush.mins, brush.maxs) && !(brush.contents & 0x10000))
        {
            matchBrushIndex = i;
            break;
        }
    }

    if (matchBrushIndex == -1)
    {
        CG_GameMessage(0, "No brush found");
        DbgPrint("No brush found\n");
        return;
    }

    cbrush_t &brush = cm->brushes[matchBrushIndex];
    // Enable the collision flag
    brush.contents |= 0x10000;

    // log and print the brush index
    DbgPrint("Brush collision enabled %d\n", matchBrushIndex);

    const char *state = (brush.contents & 0x10000) ? "^2enabled" : "^1disabled";
    CG_GameMessage(0, va("brush %d collision %s", matchBrushIndex, state));
}

void GScr_DisableCollisionForBrushContainingOrigin()
{
    SaveOriginalBrushContents();

    float point[3] = {0.0f, 0.0f, 0.0f};
    Scr_GetVector(0, point);

    int matchBrushIndex = -1;

    for (int i = 0; i < cm->numBrushes; i++)
    {
        cbrush_t &brush = cm->brushes[i];
        if (IsPointInsideBounds(point, brush.mins, brush.maxs) && (brush.contents & 0x10000))
        {
            matchBrushIndex = i;
            break;
        }
    }

    if (matchBrushIndex == -1)
    {
        CG_GameMessage(0, "No brush found with collision enabled");
        DbgPrint("No brush found with collision enabled\n");
        return;
    }

    cbrush_t &brush = cm->brushes[matchBrushIndex];
    // Disable the collision flag
    brush.contents &= ~0x10000;

    // Log and print the brush index
    DbgPrint("Brush collision disabled %d\n", matchBrushIndex);

    const char *state = (brush.contents & 0x10000) ? "^2enabled" : "^1disabled";
    CG_GameMessage(0, va("brush %d collision %s", matchBrushIndex, state));
}

Detour Scr_GetFunction_Detour;
xfunction_t *Scr_GetFunction_Hook(const char **pName, int *type)
{
    if (std::strcmp(*pName, "removebrushcollisionsoverheight") == 0)
        return reinterpret_cast<xfunction_t *>(&GScr_RemoveBrushCollisionsOverHeight);

    if (std::strcmp(*pName, "restorebrushcollisions") == 0)
        return reinterpret_cast<xfunction_t *>(&GScr_RestoreBrushCollisions);
    
    if (std::strcmp(*pName, "enablecollisionforbrushcontainingorigin") == 0)
        return reinterpret_cast<xfunction_t *>(&GScr_EnableCollisionForBrushContainingOrigin);
    
    if (std::strcmp(*pName, "disablecollisionforbrushcontainingorigin") == 0)
        return reinterpret_cast<xfunction_t *>(&GScr_DisableCollisionForBrushContainingOrigin);

    // Reimplement the function fully because we can't call the original function in Xenia
    BuiltinFunctionDef *functions = reinterpret_cast<BuiltinFunctionDef *>(0x823A2C00);
    for (BuiltinFunctionDef *i = functions; i < functions + 205; ++i)
    {
        // Access fields in *i, which is a BuiltinFunctionDef instance
        const char *actionString = i->actionString;
        void (*actionFunc)() = i->actionFunc;

        if (std::strcmp(*pName, actionString) == 0)
            return reinterpret_cast<xfunction_t *>(actionFunc);
    }

    return 0;
}

struct BotAction
{
    bool jump;
};

// map of client index to bot action
std::map<int, BotAction> botActions;

void GScr_BotJump(scr_entref_t entref)
{
    client_t *cl = &svsHeader->clients[entref.entnum];

    if (cl->header.state && cl->header.netchan.remoteAddress.type == NA_BOT)
    {
        botActions[entref.entnum].jump = true;
    }
}

Detour SV_ClientThinkDetour;

// TODO: maybe recreate the original and call it in the hook
void SV_ClientThinkHook(client_t *cl, usercmd_s *cmd)
{
    // Check if the client is a bot
    if (cl->header.state && cl->header.netchan.remoteAddress.type == NA_BOT)
    {
        // Reset bot's movement and actions set in SV_BotUserMove
        cmd->forwardmove = 0;
        cmd->rightmove = 0;
        cmd->buttons = 0;

        int clientIndex = cl - svsHeader->clients;
        if (botActions.find(clientIndex) != botActions.end())
        {
            if (botActions[clientIndex].jump)
            {
                cmd->buttons = KEY_MASK_JUMP;
                botActions[clientIndex].jump = false;
            }
        }
    }

    // Now do the original function logic
    if (cmd->serverTime - svsHeader->time <= 20000)
    {
        memcpy(&cl->lastUsercmd, cmd, sizeof(usercmd_s));

        if (cl->header.state == 4)
        {
            int clientIndex = cl - svsHeader->clients;
            G_SetLastServerTime(clientIndex, cmd->serverTime);
            ClientThink(clientIndex);
        }
    }
    else
    {
        char *msg = va("Invalid command time %i from client %s, current server time is %i", cmd->serverTime, cl->name, svsHeader->time);
        Com_PrintError(CON_CHANNEL_SERVER, msg);
    }
}

void GScr_CloneBrushModelToScriptModel(scr_entref_t scriptModelEntRef)
{
    gentity_s *scriptEnt = GetEntity(scriptModelEntRef);
    gentity_s *brushEnt = Scr_GetEntity(0);

    SV_UnlinkEntity(scriptEnt);
    scriptEnt->s.index = brushEnt->s.index;
    int contents = scriptEnt->r.contents;
    SV_SetBrushModel(scriptEnt);
    scriptEnt->r.contents |= contents;
    SV_LinkEntity(scriptEnt);
}

void PlayerCmd_HoldBreathButtonPressed(scr_entref_t entref)
{
    gentity_s *ent = GetEntity(entref);
    Scr_AddInt(((ent->client->buttonsSinceLastFrame | ent->client->buttons) & KEY_MASK_HOLDBREATH) != 0);
}

void PlayerCmd_JumpButtonPressed(scr_entref_t entref)
{
    gentity_s *ent = GetEntity(entref);
    Scr_AddInt(((ent->client->buttonsSinceLastFrame | ent->client->buttons) & KEY_MASK_JUMP) != 0);
}

void PlayerCmd_GetForwardMove(scr_entref_t entref)
{
    client_t *cl = &svsHeader->clients[entref.entnum];
    Scr_AddInt(cl->lastUsercmd.rightmove);
}

void PlayerCmd_GetRightMove(scr_entref_t entref)
{
    client_t *cl = &svsHeader->clients[entref.entnum];
    Scr_AddInt(cl->lastUsercmd.forwardmove);
}

void PlayerCmd_GetUFO(scr_entref_t entref)
{
    gentity_s *ent = GetEntity(entref);
    Scr_AddInt(ent->client->ufo);
}

void PlayerCmd_SetUFO(scr_entref_t entref)
{
    gentity_s *ent = GetEntity(entref);
    int ufo = Scr_GetInt(0);
    if (ufo == 1)
        ent->client->ufo = true;
    else if (ufo == 0)
        ent->client->ufo = false;
    else
    {
        Scr_Error("Invalid argument for SetUFO\n");
    }
}

void PlayerCmd_GetNoclip(scr_entref_t entref)
{
    gentity_s *ent = GetEntity(entref);
    Scr_AddInt(ent->client->noclip);
}

void PlayerCmd_SetNoclip(scr_entref_t entref)
{
    gentity_s *ent = GetEntity(entref);
    int noclip = Scr_GetInt(0);
    if (noclip == 1)
        ent->client->noclip = true;
    else if (noclip == 0)
        ent->client->noclip = false;
    else
    {
        Scr_Error("Invalid argument for SetNoclip\n");
    }
}

Detour Scr_GetMethodDetour;

xfunction_t *Scr_GetMethodHook(const char **pName, int *type)
{
    // Reimplement the function fully because we can't call the original function in Xenia
    *type = 0;
    xfunction_t *result = Player_GetMethod(pName);
    if (!result)
    {
        result = ScriptEnt_GetMethod(pName);
        if (!result)
        {
            result = HudElem_GetMethod(pName);
            if (!result)
            {
                result = Helicopter_GetMethod(pName);
                if (!result)
                    result = BuiltIn_GetMethod(pName, type);
            }
        }
    }
    if (result)
        return result;

    if (std::strcmp(*pName, "botjump") == 0)
        return reinterpret_cast<xfunction_t *>(&GScr_BotJump);

    if (std::strcmp(*pName, "clonebrushmodeltoscriptmodel") == 0)
        return reinterpret_cast<xfunction_t *>(&GScr_CloneBrushModelToScriptModel);

    if (std::strcmp(*pName, "holdbreathbuttonpressed") == 0)
        return reinterpret_cast<xfunction_t *>(&PlayerCmd_HoldBreathButtonPressed);

    if (std::strcmp(*pName, "jumpbuttonpressed") == 0)
        return reinterpret_cast<xfunction_t *>(&PlayerCmd_JumpButtonPressed);

    if (std::strcmp(*pName, "getforwardmove") == 0)
        return reinterpret_cast<xfunction_t *>(&PlayerCmd_GetForwardMove);

    if (std::strcmp(*pName, "getrightmove") == 0)
        return reinterpret_cast<xfunction_t *>(&PlayerCmd_GetRightMove);

    if (std::strcmp(*pName, "getufo") == 0)
        return reinterpret_cast<xfunction_t *>(&PlayerCmd_GetUFO);

    if (std::strcmp(*pName, "setufo") == 0)
        return reinterpret_cast<xfunction_t *>(&PlayerCmd_SetUFO);

    if (std::strcmp(*pName, "getnoclip") == 0)
        return reinterpret_cast<xfunction_t *>(&PlayerCmd_GetNoclip);

    if (std::strcmp(*pName, "setnoclip") == 0)
        return reinterpret_cast<xfunction_t *>(&PlayerCmd_SetNoclip);

    return result;
}

void InitIW3()
{
    // Waiting a little bit for the game to be fully loaded in memory
    Sleep(1000);

    XNotifyQueueUI(0, 0, XNOTIFY_SYSTEM, L"CodJumper - by mo", nullptr);

    Scr_GetFunction_Detour = Detour(Scr_GetFunction, Scr_GetFunction_Hook);
    Scr_GetFunction_Detour.Install();

    Scr_GetMethodDetour = Detour(Scr_GetMethod, Scr_GetMethodHook);
    Scr_GetMethodDetour.Install();

    SV_ClientThinkDetour = Detour(SV_ClientThink, SV_ClientThinkHook);
    SV_ClientThinkDetour.Install();
}

int DllMain(HANDLE hModule, DWORD reason, void *pReserved)
{
    switch (reason)
    {
    case DLL_PROCESS_ATTACH:
        printf("CodJumper Loaded!\n");
        ExCreateThread(nullptr, 0, nullptr, nullptr, reinterpret_cast<PTHREAD_START_ROUTINE>(MonitorTitleId), nullptr, 2);
        break;
    case DLL_PROCESS_DETACH:
        printf("CodJumper Unloaded!\n");
        break;
    }

    return TRUE;
}

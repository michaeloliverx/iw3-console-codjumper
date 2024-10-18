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
char (*va)(char *format, ...) = reinterpret_cast<char (*)(char *format, ...)>(0x821CD858);
void (*Scr_AddInt)(int value) = reinterpret_cast<void (*)(int value)>(0x822111C0);
void (*Scr_Error)(const char *error) = reinterpret_cast<void (*)(const char *error)>(0x8220F6F0);
gentity_s *(*Scr_GetEntity)(scr_entref_t entref) = reinterpret_cast<gentity_s *(*)(scr_entref_t entref)>(0x8224EE68);

// Variables
serverStaticHeader_t *svsHeader = reinterpret_cast<serverStaticHeader_t *>(0x849F1580);

std::vector<int> originalBrushContents;
std::string lastMapName;

void RemoveBrushCollisions(int heightLimit)
{
    // cm.numBrushes
    uintptr_t cm_numBrushesOffset = 0x82A232CC;
    unsigned __int16 *cm_numBrushesPtr = reinterpret_cast<unsigned __int16 *>(cm_numBrushesOffset);
    unsigned __int16 cm_numBrushes = *cm_numBrushesPtr;

    // cm.brushes
    uintptr_t cm_brushesOffset = 0x82A232D0;
    cbrush_t **cm_brushesArrayPtr = reinterpret_cast<cbrush_t **>(cm_brushesOffset);
    cbrush_t *cm_brushesFirst = *cm_brushesArrayPtr;

    dvar_s *mapname = Dvar_FindMalleableVar("mapname");
    if (lastMapName != mapname->current.string)
    {
        originalBrushContents.clear();
        originalBrushContents.resize(cm_numBrushes);
        for (int i = 0; i < cm_numBrushes; i++)
        {
            cbrush_t &brush = *(cm_brushesFirst + i);
            originalBrushContents[i] = brush.contents;
        }
        lastMapName = mapname->current.string;
    }

    for (int i = 0; i < cm_numBrushes; i++)
    {
        cbrush_t &brush = *(cm_brushesFirst + i);
        float height = brush.maxs[2] - brush.mins[2];
        if (height > heightLimit)
            brush.contents &= ~0x10000;
    }
}

void RestoreBrushCollisions()
{
    if (lastMapName == "")
        return;

    // cm.numBrushes
    uintptr_t cm_numBrushesOffset = 0x82A232CC;
    unsigned __int16 *cm_numBrushesPtr = reinterpret_cast<unsigned __int16 *>(cm_numBrushesOffset);
    unsigned __int16 cm_numBrushes = *cm_numBrushesPtr;

    // cm.brushes
    uintptr_t cm_brushesOffset = 0x82A232D0;
    cbrush_t **cm_brushesArrayPtr = reinterpret_cast<cbrush_t **>(cm_brushesOffset);
    cbrush_t *cm_brushesFirst = *cm_brushesArrayPtr;

    for (int i = 0; i < cm_numBrushes; i++)
    {
        cbrush_t &brush = *(cm_brushesFirst + i);
        brush.contents = originalBrushContents[i];
    }
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
        char msg = va("Invalid command time %i from client %s, current server time is %i", cmd->serverTime, cl->name, svsHeader->time);
        Com_PrintError(CON_CHANNEL_SERVER, &msg);
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

    if (std::strcmp(*pName, "removebrushcollisionsoverheight") == 0)
        return reinterpret_cast<xfunction_t *>(&GScr_RemoveBrushCollisionsOverHeight);

    if (std::strcmp(*pName, "restorebrushcollisions") == 0)
        return reinterpret_cast<xfunction_t *>(&GScr_RestoreBrushCollisions);

    if (std::strcmp(*pName, "botjump") == 0)
        return reinterpret_cast<xfunction_t *>(&GScr_BotJump);

    return result;
}

void InitIW3()
{
    // Waiting a little bit for the game to be fully loaded in memory
    Sleep(1000);

    XNotifyQueueUI(0, 0, XNOTIFY_SYSTEM, L"CodJumper - by mo", nullptr);

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

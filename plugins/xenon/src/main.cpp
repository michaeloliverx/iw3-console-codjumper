#include <xtl.h>
#include <string>
#include <cstdint>
#include <iostream>
#include <cstddef>
#include <cassert>
#include <vector>
#include "detour.h"

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

void (*CG_GameMessage)(int localClientNum, const char *msg) = reinterpret_cast<void (*)(int localClientNum, const char *msg)>(0x8230AAF0);
dvar_s *(*Dvar_FindMalleableVar)(const char *dvarName) = reinterpret_cast<dvar_s *(*)(const char *dvarName)>(0x821D4C10);
int (*Scr_GetInt)(unsigned int index) = reinterpret_cast<int (*)(unsigned int index)>(0x8220FD10);
xfunction_t *(*Scr_GetMethod)(const char **pName, int *type) = reinterpret_cast<xfunction_t *(*)(const char **pName, int *type)>(0x822570E0);
xfunction_t *(*Player_GetMethod)(const char **pName) = reinterpret_cast<xfunction_t *(*)(const char **pName)>(0x8227E098);
xfunction_t *(*ScriptEnt_GetMethod)(const char **pName) = reinterpret_cast<xfunction_t *(*)(const char **pName)>(0x82254D78);
xfunction_t *(*HudElem_GetMethod)(const char **pName) = reinterpret_cast<xfunction_t *(*)(const char **pName)>(0x822773A8);
xfunction_t *(*Helicopter_GetMethod)(const char **pName) = reinterpret_cast<xfunction_t *(*)(const char **pName)>(0x82265C68);
xfunction_t *(*BuiltIn_GetMethod)(const char **pName, int *type) = reinterpret_cast<xfunction_t *(*)(const char **pName, int *type)>(0x82256E20);

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
    if (lastMapName !=  mapname->current.string)
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

    return result;
}

void InitIW3()
{
    // Waiting a little bit for the game to be fully loaded in memory
    Sleep(1000);

    XNotifyQueueUI(0, 0, XNOTIFY_SYSTEM, L"CodJumper - by mo", nullptr);

    Scr_GetMethodDetour = Detour(Scr_GetMethod, Scr_GetMethodHook);
    Scr_GetMethodDetour.Install();
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

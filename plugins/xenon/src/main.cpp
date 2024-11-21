#include <xtl.h>
#include <string>
#include <cstdint>
#include <iostream>
#include <cstddef>
#include <cassert>
#include <vector>
#include <map>
#include <fstream>
#include <algorithm>

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
char *(*Scr_ReadFile_FastFile)(const char *filename, const char *extFilename, const char *codePos) = reinterpret_cast<char *(*)(const char *filename, const char *extFilename, const char *codePos)>(0x82221220);
void (*Scr_AddSourceBufferInternal)(const char *extFilename, const char *codePos, char *sourceBuf, int len, bool doEolFixup, bool archive) = reinterpret_cast<void (*)(const char *extFilename, const char *codePos, char *sourceBuf, int len, bool doEolFixup, bool archive)>(0x822210E0);
XAssetHeader *(*DB_FindXAssetHeader)(XAssetType type, const char *name) = reinterpret_cast<XAssetHeader *(*)(XAssetType type, const char *name)>(0x822A0298);
unsigned int (*FS_FOpenFileReadForThread)(const char *filename, int *file, FsThread thread) = reinterpret_cast<unsigned int (*)(const char *filename, int *file, FsThread thread)>(0x821DB8B0);
int (*FS_ReadFile)(const char *qpath, void **buffer) = reinterpret_cast<int (*)(const char *qpath, void **buffer)>(0x821DBB60);
int (*FS_FCloseFile)(int f) = reinterpret_cast<int (*)(int f)>(0x821DB780);
int (*DB_GetAllXAssetOfType_FastFile)(XAssetType type, XAssetHeader *assets, int maxCount) = reinterpret_cast<int (*)(XAssetType type, XAssetHeader *assets, int maxCount)>(0x8229E8E0);
// void (*Image_Upload3D_CopyData_Xbox)(const GfxImage *image, _D3DFORMAT format, unsigned int mipLevel, const unsigned __int8 *src) = reinterpret_cast<void (*)(const GfxImage *image, _D3DFORMAT format, unsigned int mipLevel, const unsigned __int8 *src)>(0x821332A8);
// void (*Image_Upload2D_CopyData_Xbox)(const GfxImage *image, _D3DFORMAT format, _D3DCUBEMAP_FACES face, unsigned int mipLevel, const unsigned __int8 *src) = reinterpret_cast<void (*)(const GfxImage *image, _D3DFORMAT format, _D3DCUBEMAP_FACES face, unsigned int mipLevel, const unsigned __int8 *src)>(0x821333C0);
// void (*Image_UploadData)(const GfxImage *image, _D3DFORMAT format, _D3DCUBEMAP_FACES face, unsigned int mipLevel, const unsigned __int8 *src) = reinterpret_cast<void (*)(const GfxImage *image, _D3DFORMAT format, _D3DCUBEMAP_FACES face, unsigned int mipLevel, const unsigned __int8 *src)>(0x821334E0);

// void (*Image_SetupAndLoad)(GfxImage *image, int width, int height, int depth, int imageFlags, _D3DFORMAT imageFormat, const char *name) = reinterpret_cast<void (*)(GfxImage *image, int width, int height, int depth, int imageFlags, _D3DFORMAT imageFormat, const char *name)>(0x82133798);
// void (*Image_Setup)(GfxImage *image, int width, int height, int depth, int imageFlags, _D3DFORMAT imageFormat, const char *name) = reinterpret_cast<void (*)(GfxImage *image, int width, int height, int depth, int imageFlags, _D3DFORMAT imageFormat, const char *name)>(0x821336A0);

int (*Com_sprintf)(char *dest, int size, const char *fmt, ...) = reinterpret_cast<int (*)(char *dest, int size, const char *fmt, ...)>(0x821CCED8);

// Variables
serverStaticHeader_t *svsHeader = reinterpret_cast<serverStaticHeader_t *>(0x849F1580);
clipMap_t *cm = reinterpret_cast<clipMap_t *>(0x82A23240);
XAssetEntryPoolEntry *g_assetEntryPool = reinterpret_cast<XAssetEntryPoolEntry *>(0x82583B60);
const int POOL_SIZE = 30000;

/* 9724 */
union XAssetPoolEntryRawFile
{
    RawFile entry;
    XAssetPoolEntryRawFile *next;
};

/* 9725 */
struct XAssetPoolRawFile
{
    XAssetPoolEntryRawFile *freeHead;
    XAssetPoolEntryRawFile entries[1024];
};

XAssetPoolRawFile *xassetpool_rawfile = reinterpret_cast<XAssetPoolRawFile *>(0x82708C20);

// void (*Load_XAssetHeader)(bool value) = reinterpret_cast<void (*)(bool atStreamStart)>(0x822B1838);
// XAsset *varXAsset = reinterpret_cast<XAsset *>(0x82475654);
// XAssetHeader *varXAssetHeader = reinterpret_cast<XAssetHeader *>(0x824756E0);

// // custom image loading
// void (*Load_GfxImagePixels)(bool atStreamStart) = reinterpret_cast<void (*)(bool atStreamStart)>(0x822A8420);

// Detour Load_GfxImagePixels_Detour;
// void Load_GfxImagePixels_Hook(bool atStreamStart)
// {
//     DbgPrint("[LOAD_GFXIMAGEPIXELS_HOOK]\n");

//     // necessary pointers
//     GfxImage *varGfxImage = reinterpret_cast<GfxImage *>(0x8247572C);
//     void (*DB_PushStreamPos)(unsigned int index) = reinterpret_cast<void (*)(unsigned int index)>(0x8229D410);
//     unsigned __int8 *g_streamPos = reinterpret_cast<unsigned __int8 *>(0x826B91F4);
//     unsigned __int8 **varGfxImagePixels = reinterpret_cast<unsigned __int8 **>(0x82475660);
//     unsigned __int8 *varbyte4096 = reinterpret_cast<unsigned __int8 *>(0x82475600);
//     void (*Load_Stream)(bool atStreamStart, void *ptr, size_t size) = reinterpret_cast<void (*)(bool atStreamStart, void *ptr, size_t size)>(0x8229D148);
//     void (*DB_PopStreamPos)() = reinterpret_cast<void (*)()>(0x8229D390);

//     // original code taken from IDA
//     unsigned int v1;     // r3
//     GfxImage *v2;        // r31
//     unsigned __int8 *v3; // r4
//     size_t v4;           // r5

//     v1 = 5;
//     v2 = varGfxImage;
//     if (varGfxImage->delayLoadPixels)
//         v1 = 2;
//     DB_PushStreamPos(v1);
//     DbgPrint("Loading GfxImagePixels\n");
//     if (*varGfxImagePixels)
//     {
//         DbgPrint("GfxImagePixels already loaded\n");
//         v3 = (unsigned __int8 *)((unsigned int)(g_streamPos + 4095) & 0xFFFFF000);
//         g_streamPos = v3;
//         *varGfxImagePixels = v3;
//         v4 = v2->cardMemory.platform[0];
//         varbyte4096 = v3;
//         Load_Stream(1, v3, v4);
//     }
//     DB_PopStreamPos();
//     DbgPrint("GfxImagePixels loaded\n");
// }

// int (*Load_Texture)(unsigned __int8 **a1, int a2) = reinterpret_cast<int (*)(unsigned __int8 **a1, int a2)>(0x821528B0);

// Detour Load_Texture_Detour;

// int Load_Texture_Hook(unsigned __int8 **a1, int a2)
// {
//     DbgPrint("[GFXIMAGELOADDEF_HOOK]\n");

//     GfxImage *image = (GfxImage *)a2;
//     DbgPrint("[GFXIMAGELOADDEF_HOOK] Loading image %s\n", image->name);

//     void (*sub_820F51D8)(int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8) = reinterpret_cast<void (*)(int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8)>(0x820F51D8);
//     void (*sub_820F5250)(int a1, int a2, int a3, int a4) = reinterpret_cast<void (*)(int a1, int a2, int a3, int a4)>(0x820F5250);
//     void (*sub_820F5168)(int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8) = reinterpret_cast<void (*)(int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8)>(0x820F5168);
//     void (*sub_820F5330)(int a1, int a2) = reinterpret_cast<void (*)(int a1, int a2)>(0x820F5330);
//     int (*sub_820F5B18)(int a1, int a2, char *a3) = reinterpret_cast<int (*)(int a1, int a2, char *a3)>(0x820F5B18);

//     // Original code taken from IDA
//     unsigned __int8 *v2; // r31
//     int v4;              // r11
//     int v5;              // r11
//     int v6;              // r4
//     int v7;              // r3
//     int result;          // r3
//     char v9;             // [sp+70h] [-70h] BYREF

//     v2 = *a1;
//     v4 = *((DWORD *)*a1 + 3);
//     *(DWORD *)(a2 + 4) = v4;
//     if ((v2[1] & 4) != 0)
//     {
//         DbgPrint("[GFXIMAGELOADDEF_HOOK] MAPTYPE_CUBE");

//         sub_820F51D8(*((__int16 *)v2 + 1), *v2, 0, *((DWORD *)v2 + 2), 0, 0, -1, v4);
//         v5 = 5;
//     }
//     else if ((v2[1] & 8) != 0)
//     {
//         DbgPrint("[GFXIMAGELOADDEF_HOOK] MAPTYPE_3D");
//         sub_820F5250(*((__int16 *)v2 + 1), *((__int16 *)v2 + 2), *((__int16 *)v2 + 3), *v2);
//         v5 = 4;
//     }
//     else
//     {
//         DbgPrint("[GFXIMAGELOADDEF_HOOK] MAPTYPE_2D");
//         sub_820F5168(*((__int16 *)v2 + 1), *((__int16 *)v2 + 2), *v2, 0, *((DWORD *)v2 + 2), 0, 0, -1);
//         v5 = 3;
//     }
//     DbgPrint("[GFXIMAGELOADDEF_HOOK] After switch");
//     v6 = *(DWORD *)(a2 + 24);
//     v7 = *(DWORD *)(a2 + 4);
//     *(DWORD *)a2 = v5;
//     sub_820F5330(v7, v6);
//     result = sub_820F5B18(*(DWORD *)(a2 + 4), 0, &v9);
//     *(WORD *)(a2 + 16) = *((WORD *)v2 + 1);
//     *(WORD *)(a2 + 18) = *((WORD *)v2 + 2);
//     *(WORD *)(a2 + 20) = *((WORD *)v2 + 3);
//     return result;
// }

void (*Load_GfxImageLoadDef)(bool atStreamStart) = reinterpret_cast<void (*)(bool atStreamStart)>(0x822A9BC8);

Detour Load_GfxImageLoadDef_Detour;

void Load_GfxImageLoadDef_Hook(bool atStreamStart)
{
    DbgPrint("[GFXIMAGELOADDEF_HOOK]\n");

    void (*Load_Stream)(bool atStreamStart, void *ptr, size_t size) = reinterpret_cast<void (*)(bool atStreamStart, void *ptr, size_t size)>(0x8229D148);
    void (*DB_PushStreamPos)(unsigned int index) = reinterpret_cast<void (*)(unsigned int index)>(0x8229D410);
    void (*Load_GfxTexture)(bool atStreamStart) = reinterpret_cast<void (*)(bool atStreamStart)>(0x822A84A8);
    void (*DB_PopStreamPos)() = reinterpret_cast<void (*)()>(0x8229D390);

    GfxImageLoadDef *varGfxImageLoadDef = reinterpret_cast<GfxImageLoadDef *>(0x82475708);
    GfxTexture *varGfxTexture = reinterpret_cast<GfxTexture *>(0x82475798);

    Load_Stream(1, varGfxImageLoadDef, 16);
    DB_PushStreamPos(4);
    varGfxTexture = &varGfxImageLoadDef->texture;
    Load_GfxTexture(0);
    DB_PopStreamPos();
}

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

// // Function to print a GfxTexture (union), depending on its type
// void PrintGfxTexture(GfxTexture texture, MapType mapType)
// {
//     switch (mapType)
//     {
//     case MAPTYPE_2D:
//         DbgPrint("Texture (2D): %p\n", texture.map);
//         break;
//     case MAPTYPE_3D:
//         DbgPrint("Texture (3D): %p\n", texture.volmap);
//         break;
//     case MAPTYPE_CUBE:
//         DbgPrint("Texture (Cube): %p\n", texture.cubemap);
//         break;
//     default:
//         DbgPrint("Texture (Base): %p\n", texture.basemap);
//         break;
//     }
// }

// // Function to dump a GfxImage instance to the console
// void DumpGfxImage(const GfxImage *image)
// {
//     if (!image)
//     {
//         DbgPrint("GfxImage is NULL\n");
//         return;
//     }

//     DbgPrint("GfxImage Dump:\n");
//     DbgPrint("Map Type: %d\n", image->mapType);
//     PrintGfxTexture(image->texture, image->mapType);
//     DbgPrint("Semantic: %u\n", image->semantic);
//     DbgPrint("Card Memory Platform: %d\n", image->cardMemory.platform[0]);
//     DbgPrint("Width: %u\n", image->width);
//     DbgPrint("Height: %u\n", image->height);
//     DbgPrint("Depth: %u\n", image->depth);
//     DbgPrint("Category: %u\n", image->category);
//     DbgPrint("Delay Load Pixels: %s\n", image->delayLoadPixels ? "True" : "False");
//     DbgPrint("Pixels Pointer: %p\n", image->pixels);
//     DbgPrint("Base Size: %u\n", image->baseSize);
//     DbgPrint("Stream Slot: %u\n", image->streamSlot);
//     DbgPrint("Streaming: %s\n", image->streaming ? "True" : "False");
//     DbgPrint("Name: %s\n", image->name ? image->name : "NULL");
// }

// Helper function to convert 32-bit values to little-endian
uint32_t to_little_endian(uint32_t value)
{
    return ((value & 0xFF000000) >> 24) |
           ((value & 0x00FF0000) >> 8) |
           ((value & 0x0000FF00) << 8) |
           ((value & 0x000000FF) << 24);
}

// Helper function to convert 16-bit values to little-endian
uint16_t to_little_endian(uint16_t value)
{
    return (value >> 8) | (value << 8);
}

// DDS constants as const variables with explicit types
const uint32_t DDS_MAGIC = 0x20534444; // 'DDS ' in hexadecimal
const uint32_t DDS_HEADER_SIZE = 124;
const uint32_t DDS_PIXEL_FORMAT_SIZE = 32;
const uint32_t DXT1_FOURCC = 0x31545844; // 'DXT1' in hexadecimal
const uint32_t DDSD_CAPS = 0x1;
const uint32_t DDSD_HEIGHT = 0x2;
const uint32_t DDSD_WIDTH = 0x4;
const uint32_t DDSD_PIXELFORMAT = 0x1000;
const uint32_t DDPF_FOURCC = 0x4;
const uint32_t DDSCAPS_TEXTURE = 0x1000;

// DDS header structure
struct DDSHeader
{
    uint32_t magic;
    uint32_t size;
    uint32_t flags;
    uint32_t height;
    uint32_t width;
    uint32_t pitchOrLinearSize;
    uint32_t depth;
    uint32_t mipMapCount;
    uint32_t reserved1[11];
    struct
    {
        uint32_t size;
        uint32_t flags;
        uint32_t fourCC;
        uint32_t rgbBitCount;
        uint32_t rBitMask;
        uint32_t gBitMask;
        uint32_t bBitMask;
        uint32_t aBitMask;
    } pixelFormat;
    uint32_t caps;
    uint32_t caps2;
    uint32_t caps3;
    uint32_t caps4;
    uint32_t reserved2;
};

// Function to write DDS file with raw pixel data using ofstream
void dumpGfxImageToDDS(const GfxImage *gfxImage, const char *filename)
{
    // Construct the full file path
    std::string path_str = "game:\\dump\\images\\";
    path_str += filename; // Concatenate the filename to the path

    // Open file in binary mode using ofstream
    std::ofstream file(path_str.c_str(), std::ios::binary);
    if (!file)
    {
        DbgPrint("Failed to open file for writing.\n");
        return;
    }

    // Prepare DDS header with little-endian conversion
    DDSHeader header;
    memset(&header, 0, sizeof(DDSHeader));
    header.magic = to_little_endian(DDS_MAGIC);
    header.size = to_little_endian(DDS_HEADER_SIZE);
    header.flags = to_little_endian(DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH | DDSD_PIXELFORMAT);
    header.height = to_little_endian(static_cast<uint32_t>(gfxImage->height));
    header.width = to_little_endian(static_cast<uint32_t>(gfxImage->width));
    header.pitchOrLinearSize = to_little_endian(static_cast<uint32_t>(gfxImage->baseSize));
    header.depth = to_little_endian(static_cast<uint32_t>(gfxImage->depth));
    header.mipMapCount = to_little_endian(static_cast<uint32_t>(1));
    header.pixelFormat.size = to_little_endian(DDS_PIXEL_FORMAT_SIZE);
    header.pixelFormat.flags = to_little_endian(DDPF_FOURCC);
    header.pixelFormat.fourCC = to_little_endian(DXT1_FOURCC);
    header.caps = to_little_endian(DDSCAPS_TEXTURE);

    // Write the DDS header with little-endian format
    file.write(reinterpret_cast<const char *>(&header), sizeof(DDSHeader));
    if (!file)
    {
        DbgPrint("Failed to write DDS header.\n");
        return;
    }

    // Write the pixel data (no endian conversion needed for raw bytes)
    file.write(reinterpret_cast<const char *>(gfxImage->pixels), gfxImage->baseSize);
    if (!file)
    {
        DbgPrint("Failed to write pixel data.\n");
        return;
    }

    file.close();
    DbgPrint("Image dumped to %s successfully.\n", path_str.c_str());
}

void Gscr_LogAssetInfo()
{
    // XAssetHeader *assets = new XAssetHeader[1024];
    // int count = DB_GetAllXAssetOfType_FastFile(ASSET_TYPE_MATERIAL, assets, 1024);
    // for (int i = 0; i < count; i++)
    // {
    //     auto material = assets[i].material;
    //     DbgPrint("Material %s\n", material->info.name);
    // }
    // delete[] assets;

    // XAssetHeader *assets = new XAssetHeader[1024];
    // int count = DB_GetAllXAssetOfType_FastFile(ASSET_TYPE_IMAGE, assets, 1024);
    // for (int i = 0; i < count; i++)
    // {
    //     auto image = assets[i].image;
    //     if (strcmp(image->name, "viewhands_marine_gloves_col") == 0)
    //         DumpGfxImage(image);
    //     // DbgPrint("Image %s\n", image->name);
    // }

    DbgPrint("g_assetEntryPool logging info\n");

    const char *XAssetTypeNames[] = {
        "ASSET_TYPE_XMODELPIECES",
        "ASSET_TYPE_PHYSPRESET",
        "ASSET_TYPE_XANIMPARTS",
        "ASSET_TYPE_XMODEL",
        "ASSET_TYPE_MATERIAL",
        "ASSET_TYPE_PIXELSHADER",
        "ASSET_TYPE_TECHNIQUE_SET",
        "ASSET_TYPE_IMAGE",
        "ASSET_TYPE_SOUND",
        "ASSET_TYPE_SOUND_CURVE",
        "ASSET_TYPE_LOADED_SOUND",
        "ASSET_TYPE_CLIPMAP",
        "ASSET_TYPE_CLIPMAP_PVS",
        "ASSET_TYPE_COMWORLD",
        "ASSET_TYPE_GAMEWORLD_SP",
        "ASSET_TYPE_GAMEWORLD_MP",
        "ASSET_TYPE_MAP_ENTS",
        "ASSET_TYPE_GFXWORLD",
        "ASSET_TYPE_LIGHT_DEF",
        "ASSET_TYPE_UI_MAP",
        "ASSET_TYPE_FONT",
        "ASSET_TYPE_MENULIST",
        "ASSET_TYPE_MENU",
        "ASSET_TYPE_LOCALIZE_ENTRY",
        "ASSET_TYPE_WEAPON",
        "ASSET_TYPE_SNDDRIVER_GLOBALS",
        "ASSET_TYPE_FX",
        "ASSET_TYPE_IMPACT_FX",
        "ASSET_TYPE_AITYPE",
        "ASSET_TYPE_MPTYPE",
        "ASSET_TYPE_CHARACTER",
        "ASSET_TYPE_XMODELALIAS",
        "ASSET_TYPE_RAWFILE",
        "ASSET_TYPE_STRINGTABLE",
        "ASSET_TYPE_COUNT",
        "ASSET_TYPE_STRING",
        "ASSET_TYPE_ASSETLIST"};

    for (int i = 0; i < POOL_SIZE; i++)
    {
        auto entry = &g_assetEntryPool[i];
        // if (entry == nullptr || entry->next == nullptr)
        //     break;

        int type = entry->entry.asset.type;

        // Check if the asset type is within range
        const char *typeName = (type >= 0 && type < sizeof(XAssetTypeNames) / sizeof(XAssetTypeNames[0]))
                                   ? XAssetTypeNames[type]
                                   : "UNKNOWN_TYPE";

        const char *name = "UNKNOWN_NAME";

        // if (type == ASSET_TYPE_XMODELPIECES)
        //     name = entry->entry.asset.header.xmodelPieces->name;
        // else if (type == ASSET_TYPE_PHYSPRESET)
        //     name = entry->entry.asset.header.physPreset->name;
        // else if (type == ASSET_TYPE_XANIMPARTS)
        //     name = entry->entry.asset.header.parts->name;
        if (type == ASSET_TYPE_XMODEL)
            name = entry->entry.asset.header.model->name;
        else if (type == ASSET_TYPE_MATERIAL)
            name = entry->entry.asset.header.material->info.name;
        // else if (type == ASSET_TYPE_PIXELSHADER)
        //     name = entry->entry.asset.header.pixelShader->name;
        // else if (type == ASSET_TYPE_TECHNIQUE_SET)
        //     name = entry->entry.asset.header.techniqueSet->name;
        else if (type == ASSET_TYPE_IMAGE)
            name = entry->entry.asset.header.image->name;
        // else if (type == ASSET_TYPE_SOUND)
        //     name = entry->entry.asset.header.sound->aliasName;
        // else if (type == ASSET_TYPE_SOUND_CURVE)
        //     name = entry->entry.asset.header.sndCurve->filename;
        // else if (type == ASSET_TYPE_LOADED_SOUND)
        //     name = entry->entry.asset.header.loadSnd->name;
        // else if (type == ASSET_TYPE_CLIPMAP || type == ASSET_TYPE_CLIPMAP_PVS)
        //     name = entry->entry.asset.header.clipMap->name;
        // else if (type == ASSET_TYPE_COMWORLD)
        //     name = entry->entry.asset.header.comWorld->name;
        // else if (type == ASSET_TYPE_GAMEWORLD_SP)
        //     name = entry->entry.asset.header.gameWorldSp->name;
        // else if (type == ASSET_TYPE_GAMEWORLD_MP)
        //     name = entry->entry.asset.header.gameWorldMp->name;
        else if (type == ASSET_TYPE_MAP_ENTS)
            name = entry->entry.asset.header.mapEnts->name;
        // else if (type == ASSET_TYPE_GFXWORLD)
        //     name = entry->entry.asset.header.gfxWorld->name;
        // else if (type == ASSET_TYPE_LIGHT_DEF)
        //     name = entry->entry.asset.header.lightDef->name;
        // else if (type == ASSET_TYPE_FONT)
        //     name = entry->entry.asset.header.font->fontName;
        // else if (type == ASSET_TYPE_MENULIST)
        //     name = entry->entry.asset.header.menuList->name;
        // // else if (type == ASSET_TYPE_MENU)
        // //     name = entry->entry.asset.header.menu->name;
        // else if (type == ASSET_TYPE_LOCALIZE_ENTRY)
        //     name = entry->entry.asset.header.localize->name;
        // else if (type == ASSET_TYPE_WEAPON)
        //     name = entry->entry.asset.header.weapon->szInternalName;
        // else if (type == ASSET_TYPE_SNDDRIVER_GLOBALS)
        //     name = entry->entry.asset.header.sndDriverGlobals->name;
        // else if (type == ASSET_TYPE_FX)
        //     name = entry->entry.asset.header.fx->name;
        // else if (type == ASSET_TYPE_IMPACT_FX)
        //     name = entry->entry.asset.header.impactFx->name;
        else if (type == ASSET_TYPE_RAWFILE)
            name = entry->entry.asset.header.rawfile->name;
        // else if (type == ASSET_TYPE_STRINGTABLE)
        //     name = entry->entry.asset.header.stringTable->name;

        DbgPrint("g_assetEntryPool[%d] type: %d (%s) name: %s", i, type, typeName, name);
        if (type == ASSET_TYPE_MAP_ENTS)
        {
            auto mapEnts = entry->entry.asset.header.mapEnts;
            // DbgPrint("entityString: \n%s", mapEnts->entityString);s
        }
        else if (type == ASSET_TYPE_IMAGE)
        {
            auto image = entry->entry.asset.header.image;
            // DbgPrint("width: %d height: %d depth: %d delayLoadPixels: %d", image->width, image->height, image->depth, image->delayLoadPixels);
            // viewhands_marine_gloves_col
            if (strcmp(image->name, "viewhands_marine_gloves_col") == 0 || strcmp(image->name, "weapon_desert_eagle_silver_col") == 0)
            {
                // Dump the raw pixels data to a DDS file
                dumpGfxImageToDDS(image, image->name);
            }
        }
    }

    CG_GameMessage(0, "Logged asset info");
}

#include <cstdlib> // For std::rand
#include <ctime>   // For std::time

void fill_pixels_with_random(GfxImage *image)
{
    // Seed random number generator for unpredictable values
    std::srand(static_cast<unsigned int>(std::time(nullptr)));

    // Loop through the pixels array and replace each byte up to baseSize with random values
    for (unsigned int i = 0; i < image->baseSize; ++i)
    {
        image->pixels[i] = static_cast<unsigned __int8>(std::rand() % 256); // Random value between 0 and 255
    }
}

bool ends_with(const std::string &str, const std::string &suffix)
{
    return str.size() >= suffix.size() &&
           str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

void GScrLogInfo()
{
    for (int i = 0; i < POOL_SIZE; i++)
    {
        auto entry = &g_assetEntryPool[i];
        if (entry->entry.asset.type == ASSET_TYPE_IMAGE)
        {
            auto image = entry->entry.asset.header.image;
            // if (strcmp(image->name, "viewhands_marine_gloves_col") == 0)
            // {
            //     const std::string file_path = "game:\\raw\\images\\viewhands_marine_gloves_col";

            //     // Open file in binary mode
            //     std::ifstream file(file_path, std::ios::binary);
            //     if (!file)
            //     {
            //         DbgPrint("[GScrLogInfo] Error opening file: %s\n", file_path.c_str());
            //         return;
            //     }

            //     // Get the file size
            //     file.seekg(0, std::ios::end);
            //     std::streamsize file_size = file.tellg();
            //     file.seekg(0, std::ios::beg);

            //     // Read the file data into a vector of bytes
            //     std::vector<char> buffer(file_size);
            //     if (!file.read(buffer.data(), file_size))
            //     {
            //         DbgPrint("[GScrLogInfo] Error reading file: %s\n", file_path.c_str());
            //         return;
            //     }

            //     file.close();

            //     // Now buffer contains the raw bytes of the file

            //     DbgPrint("[GScrLogInfo] File read successfully. Size: %d bytes\n", file_size);

            //     // copy the raw bytes to the image pixels
            //     for (unsigned int i = 0; i < image->baseSize; ++i)
            //     {
            //         image->pixels[i] = static_cast<unsigned __int8>(buffer[i]);
            //     }
            // }

            if (ends_with(image->name, "_ft"))
            {
                const std::string file_path = "game:\\raw\\images\\mp_crash_ft";

                DbgPrint("[GScrLogInfo] Attempting to replace image pixels for: %s\n", image->name);

                // Open file in binary mode
                std::ifstream file(file_path, std::ios::binary);
                if (!file)
                {
                    DbgPrint("[GScrLogError] Error opening file: %s\n", file_path.c_str());
                    return;
                }

                DbgPrint("[GScrLogInfo] File opened successfully: %s\n", file_path.c_str());

                // Get the file size
                file.seekg(0, std::ios::end);
                std::streamsize file_size = file.tellg();
                file.seekg(0, std::ios::beg);

                DbgPrint("[GScrLogInfo] File size determined: %d bytes\n", file_size);

                if (file_size <= 0)
                {
                    DbgPrint("[GScrLogError] Invalid file size: %d bytes. Exiting.\n", file_size);
                    return;
                }

                // Read the file data into a vector of bytes
                std::vector<char> buffer(file_size);
                if (!file.read(buffer.data(), file_size))
                {
                    DbgPrint("[GScrLogError] Error reading file: %s\n", file_path.c_str());
                    return;
                }

                file.close();
                DbgPrint("[GScrLogInfo] File read successfully. Size: %d bytes\n", file_size);

                // Log image properties before modification
                DbgPrint("[GScrLogInfo] Image base size: %d bytes\n", image->baseSize);

                if (image->baseSize != file_size)
                {
                    DbgPrint("[GScrLogWarning] File size (%d bytes) does not match image base size (%d bytes). Proceeding anyway.\n", file_size, image->baseSize);
                }

                // Verify buffer bounds before copying
                const unsigned int bytes_to_copy = min(static_cast<unsigned int>(file_size), image->baseSize);

                // Copy the raw bytes to the image pixels
                for (unsigned int i = 0; i < bytes_to_copy; ++i)
                {
                    if (i < 10 || i > bytes_to_copy - 10) // Log first and last 10 bytes
                    {
                        DbgPrint("[GScrLogDebug] Byte[%d]: Original: 0x%02X, New: 0x%02X\n", i, image->pixels[i], static_cast<unsigned __int8>(buffer[i]));
                    }
                    image->pixels[i] = static_cast<unsigned __int8>(buffer[i]);
                }

                DbgPrint("[GScrLogInfo] Image pixels updated successfully for %s. Bytes replaced: %d\n", image->name, bytes_to_copy);

                if (bytes_to_copy < image->baseSize)
                {
                    DbgPrint("[GScrLogWarning] Not all image pixels were replaced. Bytes replaced: %d, Total base size: %d\n", bytes_to_copy, image->baseSize);
                }
            }

            // strcmp(image->name, "viewhands_marine_gloves_col") == 0 || strcmp(image->name, "palmtrees_col") == 0
            // if (ends_with(image->name, "_ft") || strcmp(image->name, "viewhands_marine_gloves_col") == 0 || strcmp(image->name, "palmtrees_col") == 0)
            // {
            //     DbgPrint("[GScrLogInfo] Image name: %s width: %d height: %d baseSize: %d\n", image->name, image->width, image->height, image->baseSize);
            // DbgPrint("GfxImage Info: Name='%s', MapType=%d, Width=%d, Height=%d, Depth=%d, LevelCount=%d, Flags=0x%02X\n",
            //          image->name,
            //          image->mapType,
            //          image->width,
            //          image->height,
            //          image->depth,
            //          image->texture.loadDef->levelCount,
            //          image->texture.loadDef->flags);

            // dumpGfxImageToDDS(image, image->name);

            // fill_pixels_with_random(image);
            // Loop through the pixels array and replace each byte up to baseSize with random values

            // // solid black skybox
            // for (unsigned int i = 0; i < image->baseSize; ++i)
            // {
            //     image->pixels[i] = 255;
            // }

            // DbgPrint("[GScrLogInfo] Image pixels filled with random values\n");

            // const std::string file_path = "game:\\raw\\images\\sky_replacement";

            // // Open file in binary mode
            // std::ifstream file(file_path, std::ios::binary);
            // if (!file)
            // {
            //     DbgPrint("[GScrLogInfo] Error opening file: %s\n", file_path.c_str());
            //     return;
            // }

            // // Get the file size
            // file.seekg(0, std::ios::end);
            // std::streamsize file_size = file.tellg();
            // file.seekg(0, std::ios::beg);

            // // Read the file data into a vector of bytes
            // std::vector<char> buffer(file_size);
            // if (!file.read(buffer.data(), file_size))
            // {
            //     DbgPrint("[GScrLogInfo] Error reading file: %s\n", file_path.c_str());
            //     return;
            // }

            // file.close();

            // // Now buffer contains the raw bytes of the file

            // DbgPrint("[GScrLogInfo] File read successfully. Size: %d bytes\n", file_size);

            // // copy the raw bytes to the image pixels
            // for (unsigned int i = 0; i < image->baseSize; ++i)
            // {
            //     image->pixels[i] = static_cast<unsigned __int8>(buffer[i]);
            // }
            // }
        }
    }
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

    if (std::strcmp(*pName, "logassetinfo") == 0)
        return reinterpret_cast<xfunction_t *>(&Gscr_LogAssetInfo);

    if (std::strcmp(*pName, "loginfo") == 0)
        return reinterpret_cast<xfunction_t *>(&GScrLogInfo);

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

Detour Scr_ReadFile_FastFile_Detour;

char *Scr_ReadFile_FastFile_Hook(const char *filename, const char *extFilename, const char *codePos, bool archive)
{
    // Check if the file is in the raw folder
    char *path = va("raw/%s", extFilename);
    auto file_handle = 0;
    auto file_size = FS_FOpenFileReadForThread(path, &file_handle, FS_THREAD_MAIN);
    if (file_size != -1)
    {
        DbgPrint("[SCR_READFILE_FASTFILE_HOOK] Loading file from raw folder: FilePath=%s\n", path);
        void *fileData = nullptr;
        int result = FS_ReadFile(path, &fileData);
        if (result)
        {
            Scr_AddSourceBufferInternal(extFilename, codePos, static_cast<char *>(fileData), file_size, 1, 1);
            return static_cast<char *>(fileData);
        }

        FS_FCloseFile(file_handle);
    }

    DbgPrint("[SCR_READFILE_FASTFILE_HOOK] Loading file from fastfile: FilePath=%s\n", path);

    // original function logic

    XAssetHeader *v6; // r3
    char *result;     // r3
    char *v8;         // r31
    char *v9;         // r11

    v6 = DB_FindXAssetHeader(ASSET_TYPE_RAWFILE, extFilename);
    if (v6)
    {
        v8 = (char *)v6[2].xmodelPieces;
        v9 = v8;
        while (*v9++)
            ;
        Scr_AddSourceBufferInternal(
            extFilename,
            codePos,
            (char *)v6[2].xmodelPieces,
            v9 - (char *)v6[2].xmodelPieces - 1,
            1,
            archive);
        result = v8;
    }
    else
    {
        Scr_AddSourceBufferInternal(extFilename, codePos, 0, -1, 1, archive);
        result = 0;
    }

    return result;
}

// Detour Image_Upload2D_CopyData_Xbox_Detour;

// void Image_Upload2D_CopyData_Xbox_Hook(const GfxImage *image, _D3DFORMAT format, _D3DCUBEMAP_FACES face, unsigned int mipLevel, const unsigned __int8 *src)
// {
//     DbgPrint("[IMAGE_UPLOAD_2D_COPY_DATA_XBOX_HOOK] Image %s uploaded\n", image->name);

//     // original function logic

//     // Image_Upload2D_CopyData_Xbox(image, format, face, mipLevel, src);
// }

// Detour Image_Upload3D_CopyData_Xbox_Detour;

// void Image_Upload3D_CopyData_Xbox_Hook(const GfxImage *image, _D3DFORMAT format, unsigned int mipLevel, const unsigned __int8 *src)
// {
//     DbgPrint("[IMAGE_UPLOAD_3D_COPY_DATA_XBOX_HOOK] Image %s uploaded\n", image->name);

//     // original function logic

//     // Image_Upload3D_CopyData_Xbox(image, format, mipLevel, src);
// }

// Detour Image_UploadData_Detour;

// void Image_UploadData_Hook(const GfxImage *image, _D3DFORMAT format, _D3DCUBEMAP_FACES face, unsigned int mipLevel, const unsigned __int8 *src)
// {
//     DbgPrint("[IMAGE_UPLOAD_DATA_HOOK] Image %s uploaded\n", image->name);

//     // original function logic

//     if (image->mapType == MAPTYPE_3D)
//         Image_Upload3D_CopyData_Xbox(image, D3DFMT_L8, mipLevel, src);
//     else
//         Image_Upload2D_CopyData_Xbox(image, D3DFMT_L8, D3DCUBEMAP_FACE_POSITIVE_X, mipLevel, src);
// }

// Detour Image_SetupAndLoad_Detour;

// void Image_SetupAndLoad_Hook(GfxImage *image, int width, int height, int depth, int imageFlags, _D3DFORMAT imageFormat, const char *name)
// {
//     DbgPrint("[IMAGE_SETUP_AND_LOAD_HOOK] Image %s loaded\n width: %d height: %d depth: %d imageFlags: %d imageFormat: %d", name, width, height, depth, imageFlags, imageFormat);

// // original function logic

// int v12;      // r10
// _BYTE v14[2]; // [sp+50h] [-50h] BYREF
// __int16 v15;  // [sp+52h] [-4Eh]
// __int16 v16;  // [sp+54h] [-4Ch]
// __int16 v17;  // [sp+56h] [-4Ah]
// int v18;      // [sp+58h] [-48h]
// int v19;      // [sp+5Ch] [-44h]

// sub_821336A0();
// v12 = *(_DWORD *)(image + 4);
// v14[1] = a5;
// v15 = a2;
// v16 = a3;
// v17 = a4;
// v19 = v12;
// *(_DWORD *)(image + 4) = v14;
// v18 = a6;
// v14[0] = (a5 & 2) != 0;
// return sub_821528B0(image + 4, image);
// }

// Detour Image_Setup_Detour;

// void Image_Setup_Hook(GfxImage *image, int width, int height, int depth, int imageFlags, _D3DFORMAT imageFormat, const char *name)
// {
//     DbgPrint("[IMAGE_SETUP_HOOK] Image %s setup\n width: %d height: %d depth: %d imageFlags: %d imageFormat: %d", name, width, height, depth, imageFlags, imageFormat);
// }

bool starts_with(const char *dest, const char *prefix)
{
    size_t prefix_length = std::strlen(prefix);
    size_t dest_length = std::strlen(dest);

    if (dest_length < prefix_length)
    {
        return false;
    }

    return std::strncmp(dest, prefix, prefix_length) == 0;
}

bool file_exists(const char *path)
{
    FILE *file = fopen(path, "r");
    if (file)
    {
        fclose(file);
        return true;
    }
    return false;
}

Detour Com_sprintf_Detour;

int Com_sprintf_Hook(char *dest, int size, const char *fmt, ...)
{
    // DbgPrint("[COM_SPRINTF_HOOK] %s\n", fmt);
    va_list va;
    va_start(va, fmt);
    int result = vsnprintf(dest, size, fmt, va);
    va_end(va);
    // DbgPrint("[COM_SPRINTF_HOOK] Final output: %s\n", dest);

    // Check if the path starts with "highmip\"
    if (starts_with(dest, "highmip\\"))
    {
        // Construct the path with the "game:\" prefix for existence check
        char check_path[1024];
        sprintf(check_path, "game:\\highmip_override\\%s", dest + 8);

        if (file_exists(check_path))
        {
            char new_path[1024];
            sprintf(new_path, "highmip_override\\%s", dest + 8);
            std::strcpy(dest, new_path);
            DbgPrint("[COM_SPRINTF_HOOK] Replacing path: %s -> %s\n", dest, new_path);
        }
    }

    return result;

    // // original function logic
    // DbgPrint("[COM_SPRINTF_HOOK] %s\n", fmt);
    // va_list va;
    // va_start(va, fmt);
    // int result = vsnprintf(dest, size, fmt, va);
    // DbgPrint("[COM_SPRINTF_HOOK] Final output: %s\n", dest);
    // va_end(va);

    // return result;
}

// Detour Load_XAssetHeader_Detour;

// void Load_XAssetHeader_Hook(bool atStreamStart)
// {
//     DbgPrint("[LOAD_XASSET_HEADER_HOOK] atStreamStart: %d\n", atStreamStart);

//     // original function logic
//     XAssetType type = varXAsset->type;
//     switch (type)
//     {
//     case ASSET_TYPE_PHYSPRESET:
//         varPhysPresetPtr = (PhysPreset **)varXAssetHeader;
//         Load_PhysPresetPtr(0);
//         break;
//     case ASSET_TYPE_XANIMPARTS:
//         varXAnimPartsPtr = (XAnimParts **)varXAssetHeader;
//         Load_XAnimPartsPtr(0);
//         break;
//     case ASSET_TYPE_XMODEL:
//         varXModelPtr = (XModel **)varXAssetHeader;
//         Load_XModelPtr(0);
//         break;
//     case ASSET_TYPE_MATERIAL:
//         varMaterialHandle = (Material **)varXAssetHeader;
//         Load_MaterialHandle(0);
//         break;
//     case ASSET_TYPE_PIXELSHADER:
//         varMaterialPixelShaderPtr = (MaterialPixelShader **)varXAssetHeader;
//         Load_MaterialPixelShaderPtr(0);
//         break;
//     case ASSET_TYPE_TECHNIQUE_SET:
//         varMaterialTechniqueSetPtr = (MaterialTechniqueSet **)varXAssetHeader;
//         Load_MaterialTechniqueSetPtr(0);
//         break;
//     case ASSET_TYPE_IMAGE:
//         varGfxImagePtr = (GfxImage **)varXAssetHeader;
//         Load_GfxImagePtr(0);
//         break;
//     case ASSET_TYPE_SOUND:
//         varsnd_alias_list_ptr = (snd_alias_list_t **)varXAssetHeader;
//         Load_snd_alias_list_ptr(0);
//         break;
//     case ASSET_TYPE_SOUND_CURVE:
//         varSndCurvePtr = (SndCurve **)varXAssetHeader;
//         Load_SndCurvePtr(0);
//         break;
//     case ASSET_TYPE_LOADED_SOUND:
//         varLoadedSoundPtr = (LoadedSound **)varXAssetHeader;
//         Load_LoadedSoundPtr(0);
//         break;
//     case ASSET_TYPE_CLIPMAP:
//     case ASSET_TYPE_CLIPMAP_PVS:
//         varclipMap_ptr = (clipMap_t **)varXAssetHeader;
//         Load_clipMap_ptr(0);
//         break;
//     case ASSET_TYPE_COMWORLD:
//         varComWorldPtr = (ComWorld **)varXAssetHeader;
//         Load_ComWorldPtr(0);
//         break;
//     case ASSET_TYPE_GAMEWORLD_SP:
//         varGameWorldSpPtr = (GameWorldSp **)varXAssetHeader;
//         Load_GameWorldSpPtr(0);
//         break;
//     case ASSET_TYPE_GAMEWORLD_MP:
//         varGameWorldMpPtr = (GameWorldMp **)varXAssetHeader;
//         Load_GameWorldMpPtr(0);
//         break;
//     case ASSET_TYPE_MAP_ENTS:
//         varMapEntsPtr = (MapEnts **)varXAssetHeader;
//         Load_MapEntsPtr(0);
//         break;
//     case ASSET_TYPE_GFXWORLD:
//         varGfxWorldPtr = (GfxWorld **)varXAssetHeader;
//         Load_GfxWorldPtr(0);
//         break;
//     case ASSET_TYPE_LIGHT_DEF:
//         varGfxLightDefPtr = (GfxLightDef **)varXAssetHeader;
//         Load_GfxLightDefPtr(0);
//         break;
//     case ASSET_TYPE_FONT:
//         varFontHandle = (Font_s **)varXAssetHeader;
//         Load_FontHandle(0);
//         break;
//     case ASSET_TYPE_MENULIST:
//         varMenuListPtr = (MenuList **)varXAssetHeader;
//         Load_MenuListPtr(0);
//         break;
//     case ASSET_TYPE_MENU:
//         varmenuDef_ptr = (menuDef_t **)varXAssetHeader;
//         Load_menuDef_ptr(0);
//         break;
//     case ASSET_TYPE_LOCALIZE_ENTRY:
//         varLocalizeEntryPtr = (LocalizeEntry **)varXAssetHeader;
//         Load_LocalizeEntryPtr(0);
//         break;
//     case ASSET_TYPE_WEAPON:
//         varWeaponDefPtr = (WeaponDef **)varXAssetHeader;
//         Load_WeaponDefPtr(0);
//         break;
//     case ASSET_TYPE_SNDDRIVER_GLOBALS:
//         varSndDriverGlobalsPtr = (SndDriverGlobals **)varXAssetHeader;
//         Load_SndDriverGlobalsPtr(0);
//         break;
//     case ASSET_TYPE_FX:
//         varFxEffectDefHandle = (const FxEffectDef **)varXAssetHeader;
//         Load_FxEffectDefHandle(0);
//         break;
//     case ASSET_TYPE_IMPACT_FX:
//         varFxImpactTablePtr = (FxImpactTable **)varXAssetHeader;
//         Load_FxImpactTablePtr(0);
//         break;
//     case ASSET_TYPE_RAWFILE:
//         varRawFilePtr = (RawFile **)varXAssetHeader;
//         Load_RawFilePtr(0);
//         break;
//     case ASSET_TYPE_STRINGTABLE:
//         varStringTablePtr = (StringTable **)varXAssetHeader;
//         Load_StringTablePtr(0);
//         break;
//     }
// }

// // Convert RGB values (8 bits each) to RGB 5:6:5 format (16 bits)
// uint16_t rgb_to_565(uint8_t red, uint8_t green, uint8_t blue)
// {
//     return ((red >> 3) << 11) | ((green >> 2) << 5) | (blue >> 3);
// }

// // Function to fill DXT1 pixel data with a solid color
// void fill_dxt1_with_color(uint8_t *pixel_data, int width, int height, uint8_t red, uint8_t green, uint8_t blue)
// {
//     uint16_t color565 = rgb_to_565(red, green, blue);
//     uint64_t dxt1_block;

//     // Set color0 and color1 to the same color for a solid fill
//     dxt1_block = (static_cast<uint64_t>(color565) << 48) | (static_cast<uint64_t>(color565) << 32);

//     // Set all indices to 0 to use the color0 value
//     // This fills in the last 4 bytes (32 bits) of the block
//     dxt1_block |= 0x00000000FFFFFFFF;

//     // Calculate the number of blocks (4x4 pixels per block)
//     int num_blocks = (width / 4) * (height / 4);

//     // Fill each 8-byte block with the solid color
//     for (int i = 0; i < num_blocks; ++i)
//     {
//         memcpy(pixel_data + i * 8, &dxt1_block, sizeof(dxt1_block));
//     }
// }

XAssetEntryPoolEntry *(*DB_FindXAssetEntry)(XAssetType type, const char *name) = reinterpret_cast<XAssetEntryPoolEntry *(*)(XAssetType type, const char *name)>(0x8229EB98);

void InitIW3()
{
    // Waiting a little bit for the game to be fully loaded in memory
    Sleep(1000);

    // XNotifyQueueUI(0, 0, XNOTIFY_SYSTEM, L"CodJumper - by mo", nullptr);

    Scr_ReadFile_FastFile_Detour = Detour(Scr_ReadFile_FastFile, Scr_ReadFile_FastFile_Hook);
    Scr_ReadFile_FastFile_Detour.Install();

    Scr_GetFunction_Detour = Detour(Scr_GetFunction, Scr_GetFunction_Hook);
    Scr_GetFunction_Detour.Install();

    Scr_GetMethodDetour = Detour(Scr_GetMethod, Scr_GetMethodHook);
    Scr_GetMethodDetour.Install();

    SV_ClientThinkDetour = Detour(SV_ClientThink, SV_ClientThinkHook);
    SV_ClientThinkDetour.Install();

    // Image_UploadData_Detour = Detour(Image_UploadData, Image_UploadData_Hook);
    // Image_UploadData_Detour.Install();

    // Image_Upload2D_CopyData_Xbox_Detour = Detour(Image_Upload2D_CopyData_Xbox, Image_Upload2D_CopyData_Xbox_Hook);
    // Image_Upload2D_CopyData_Xbox_Detour.Install();

    // Image_Upload3D_CopyData_Xbox_Detour = Detour(Image_Upload3D_CopyData_Xbox, Image_Upload3D_CopyData_Xbox_Hook);
    // Image_Upload3D_CopyData_Xbox_Detour.Install();

    // Image_SetupAndLoad_Detour = Detour(Image_SetupAndLoad, Image_SetupAndLoad_Hook);
    // Image_SetupAndLoad_Detour.Install();

    // Image_Setup_Detour = Detour(Image_Setup, Image_Setup_Hook);
    // Image_Setup_Detour.Install();

    // Com_sprintf_Detour = Detour(Com_sprintf, Com_sprintf_Hook);
    // Com_sprintf_Detour.Install();

    // Load_XAssetHeader_Detour = Detour(Load_XAssetHeader, Load_XAssetHeader_Hook);
    // Load_XAssetHeader_Detour.Install();

    // Load_GfxImagePixels_Detour = Detour(Load_GfxImagePixels, Load_GfxImagePixels_Hook);
    // Load_GfxImagePixels_Detour.Install();

    // Load_Texture_Detour = Detour(Load_Texture, Load_Texture_Hook);
    // Load_Texture_Detour.Install();

    // Load_GfxImageLoadDef_Detour = Detour(Load_GfxImageLoadDef, Load_GfxImageLoadDef_Hook);
    // Load_GfxImageLoadDef_Detour.Install();

    XNotifyQueueUI(0, 0, XNOTIFY_SYSTEM, L"iw3xenon loaded", nullptr);

    Sleep(5000);

    // Create directories if they don't already exist
    CreateDirectory("game:\\dump", nullptr);
    CreateDirectory("game:\\dump\\images", nullptr);
    CreateDirectory("game:\\dump\\rawfiles", nullptr);

    // for (int i = 0; i < POOL_SIZE; i++)
    // {
    //     auto entry = &g_assetEntryPool[i];
    //     // if (entry == nullptr || entry->next == nullptr)
    //     //     break;

    //     int type = entry->entry.asset.type;

    //     if (type == ASSET_TYPE_IMAGE)
    //     {
    //         auto image = entry->entry.asset.header.image;

    //         if (strcmp(image->name, "viewhands_marine_gloves_col") == 0)
    //         {
    //             DbgPrint("Found image: %s baseSize: %d\n", image->name, image->baseSize);
    //             fill_pixels_with_random(image);
    //             // fill_dxt1_with_color(image->pixels, image->width, image->height, 255, 0, 0);
    //         }
    //     }
    // }

    // auto *image = DB_FindXAssetEntry(ASSET_TYPE_IMAGE, "viewhands_marine_gloves_col");
    // if (image)
    // {
    //     DbgPrint("Found image: %s\n", image->entry.asset.header.image->name);

    //     fill_dxt1_with_color(image->entry.asset.header.image->pixels, image->entry.asset.header.image->width, image->entry.asset.header.image->height, 255, 0, 0);
    // }

    // Gscr_LogAssetInfo();

    // // Loop through all 1024 entries
    // for (int i = 0; i < 383; ++i)
    // {
    //     RawFile &rawFile = xassetpool_rawfile->entries[i].entry;
    //     if (rawFile.name != nullptr && rawFile.len != 0)
    //     {
    //         std::cout << "Dumping Entry " << i << ": Name = " << rawFile.name << " Length = " << rawFile.len << "\n";
    //         std::string path_str = rawFile.name;
    //         std::replace(path_str.begin(), path_str.end(), '/', '_');
    //         std::cout << "Modified string: " << path_str << std::endl;
    //         path_str = "game:\\dump\\rawfiles\\" + path_str;

    //         // Open a file for binary writing
    //         std::ofstream file(path_str);
    //         // Check if the file is open
    //         if (file.is_open())
    //         {
    //             // Write the buffer to the file
    //             file.write(rawFile.buffer, strlen(rawFile.buffer)); // use strlen to get the length of the buffer minus the null terminator

    //             // Close the file after writing
    //             file.close();
    //             std::cout << "Buffer written to file successfully." << std::endl;
    //         }
    //         else
    //         {
    //             std::cerr << "Error opening file for writing: " << std::strerror(errno) << std::endl;
    //         }
    //     }
    // }

    // GScrLogInfo();
}

int DllMain(HANDLE hModule, DWORD reason, void *pReserved)
{
    switch (reason)
    {
    case DLL_PROCESS_ATTACH:
        DbgPrint("CodJumper Loaded!\n");
        ExCreateThread(nullptr, 0, nullptr, nullptr, reinterpret_cast<PTHREAD_START_ROUTINE>(MonitorTitleId), nullptr, 2);
        break;
    case DLL_PROCESS_DETACH:
        DbgPrint("CodJumper Unloaded!\n");
        break;
    }

    return TRUE;
}

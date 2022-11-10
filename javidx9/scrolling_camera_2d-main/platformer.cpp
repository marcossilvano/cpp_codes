#include <iostream>
#include <string>

#define OLC_PGE_APPLICATION
#include "olcPixelGameEngine.h"

using namespace std;
using namespace olc;

class olcPlatformer : public olc::PixelGameEngine {
public:
	olcPlatformer() {
		sAppName = "Tile-based platform game";
	}
private:
	wstring sLevel;
	int nLevelWidth;
	int nLevelHeight;

	float fCameraPosX = 0.0f;
	float fCameraPosY = 0.0f;

protected:
	bool OnUserCreate() override {

		nLevelWidth = 64; // tiles
		nLevelHeight= 16;

		sLevel += L"................................................................";
		sLevel += L"................................................................";
		sLevel += L".......ooooo....................................................";
		sLevel += L"........ooo.....................................................";
		sLevel += L".......................########.................................";
		sLevel += L".....BB?BBBB?BB.......###..............#.#......................";
		sLevel += L"....................###................#.#......................";
		sLevel += L"...................####.........................................";
		sLevel += L"GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG.##############.....########";
		sLevel += L"...................................#.#...............###........";
		sLevel += L"........................############.#............###...........";
		sLevel += L"........................#............#.........###..............";
		sLevel += L"........................#.############......###.................";
		sLevel += L"........................#................###....................";
		sLevel += L"........................#################.......................";
		sLevel += L"................................................................";		

		return true;
	}

	bool OnUserUpdate(float fElapsedTime) override {

		DrawLevel(fElapsedTime);

		return true;
	}

	wchar_t GetTile(int x, int y) {
		if (x >= 0 && x < nLevelWidth && y >= 0 && y < nLevelHeight)
			return sLevel[y * nLevelWidth + x];
		else
			return L' ';
	}

	void GetTile(int x, int y, wchar_t c) {
		if (x >= 0 && x < nLevelWidth && y >= 0 && y < nLevelHeight)
			sLevel[y * nLevelWidth + x] = c;
	}

	void DrawLevel(float fElapsedTime) {
		// Determine how many tiles should be drawn on screen
		int nTileWidth = 16;
		int nTileHeight = 16;
		int nVisibleTilesX = ScreenWidth() / nTileWidth;
		int nVisibleTilesY = ScreenHeight() / nTileHeight;

		// Calculate Top-Leftmost visible tile (camera is centered)
		float fOffsetX = fCameraPosX - (float)nVisibleTilesX / 2.0f;
		float fOffsetY = fCameraPosY - (float)nVisibleTilesY / 2.0f;

		// Clamp camera to game boundaries
		if (fOffsetX < 0) fOffsetX = 0;
		if (fOffsetY < 0) fOffsetY = 0;

		if (fOffsetX > nLevelWidth - nVisibleTilesX) fOffsetX = nLevelWidth - nVisibleTilesX;
		if (fOffsetY > nLevelHeight - nVisibleTilesY) fOffsetY = nLevelHeight - nVisibleTilesY;

		// Draw visible tile map
		for (int x = 0; x < nVisibleTilesX; x++)
		{
			for (int y = 0; y < nVisibleTilesY; y++)
			{
				wchar_t sTileID = GetTile(x, y);
				switch (sTileID)
				{
				case L'.':
					FillRect(x * nTileWidth, y * nTileHeight, nTileWidth, nTileHeight, GREY);
					break;
				case L'#':
					FillRect(x * nTileWidth, y * nTileHeight, nTileWidth, nTileHeight, RED);
					break;
				default:
					FillRect(x * nTileWidth, y * nTileHeight, nTileWidth, nTileHeight, BLUE);
					break;
				}
			}
		}
		
	}
};

int main() {
	olcPlatformer game;
	if (game.Construct(256, 240, 4, 4))
		game.Start();

	return 0;
}


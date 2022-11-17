/*
	Instalar dependências:
		sudo apt update
		sudo apt install build-essential libglu1-mesa-dev libpng-dev

	Compilar e executar:
		make && ./game
*/

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
	int nLevelTilesX;
	int nLevelTilesY;

	float fPlayerPosX = 0.0f;
	float fPlayerPosY = 0.0f;

	float fPlayerVelX = 0.0f;
	float fPlayerVelY = 0.0f;

	float fCameraPosX = 0.0f;
	float fCameraPosY = 0.0f;

protected:
	bool OnUserCreate() override {


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
		sLevel += L"................................................................";		
		sLevel += L"................................................................";		
		sLevel += L"................................................................";		
		sLevel += L"................................................................";		
		sLevel += L"................................................................";		
		sLevel += L"................................................................";		
		sLevel += L"................................................................";		

		nLevelTilesX = 64;
		nLevelTilesY = sLevel.length()/nLevelTilesX;

		return true;
	}

	bool OnUserUpdate(float fElapsedTime) override {

		fPlayerVelX = 0;
		//fPlayerVelY = 0;

		// Handle Input
		if (IsFocused()) {
			if (GetKey(Key::UP).bHeld) {
				fPlayerVelY = -6.0f;
			} 
			if (GetKey(Key::DOWN).bHeld) {
				fPlayerVelY = 6.0f;
			} 
			if (GetKey(Key::LEFT).bHeld) {
				fPlayerVelX = -6.0f;
			} 
			if (GetKey(Key::RIGHT).bHeld) {
				fPlayerVelX = 6.0f;
			} 
		}

		fPlayerVelY += 20.0f * fElapsedTime; // add gravity!

		float fNewPlayerPosX = fPlayerPosX + fPlayerVelX * fElapsedTime;
		float fNewPlayerPosY = fPlayerPosY + fPlayerVelY * fElapsedTime;

		// clamp velocities
		fPlayerVelX = clamp(fPlayerVelX, -10.0f, 10.0f);
		fPlayerVelY = clamp(fPlayerVelY, -100.0f, 100.0f);

		// Check collision with level map
		CheckAndResolveMapCollisions(fNewPlayerPosX, fNewPlayerPosY);

		fCameraPosX = fPlayerPosX;
		fCameraPosY = fPlayerPosY;

		DrawGame(fElapsedTime);

		return true;
	}

	void CheckAndResolveMapCollisions(float fNewPlayerPosX, float fNewPlayerPosY) {
		// Separate velocity vector's X component and check it
		// player is moving left
		if (fPlayerVelX <= 0) { 
			// check top left and bottom left of player's rect
			if (GetTile(fNewPlayerPosX + 0.0f, fPlayerPosY + 0.0f) != L'.' || GetTile(fNewPlayerPosX + 0.0f, fPlayerPosY + 0.9f) != L'.') {
				fNewPlayerPosX = (int)fNewPlayerPosX + 1;
				fPlayerVelX = 0;
			}
		// player if moving right
		} else { 
			// check top right and bottom right of player's rect
			if (GetTile(fNewPlayerPosX + 1.0f, fPlayerPosY + 0.0f) != L'.' || GetTile(fNewPlayerPosX + 1.0f, fPlayerPosY + 0.9f) != L'.') {
				fNewPlayerPosX = (int)fNewPlayerPosX;
				fPlayerVelX = 0;
			}
		}

		// Now that we resolved the collision for the velocity vector's X component, check the Y componenent with the NewX position
		// player is moving up
		if (fPlayerVelY <= 0) { 
			// check top left and top right of player's rect
			if (GetTile(fNewPlayerPosX + 0.0f, fNewPlayerPosY + 0.0f) != L'.' || GetTile(fNewPlayerPosX + 0.9f, fNewPlayerPosY + 0.0f) != L'.') {
				fNewPlayerPosY = (int)fNewPlayerPosY + 1;
				fPlayerVelY = 0;
			}
		} 
		// player if moving down
		else { 
			// check bottom left and bottom right of player's rect
			if (GetTile(fNewPlayerPosX + 0.0f, fNewPlayerPosY + 1.0f) != L'.' || GetTile(fNewPlayerPosX + 0.9f, fNewPlayerPosY + 1.0f) != L'.') {
				fNewPlayerPosY = (int)fNewPlayerPosY;
				fPlayerVelY = 0;
			}
		}

		fPlayerPosX = fNewPlayerPosX;
		fPlayerPosY = fNewPlayerPosY;
	}

	wchar_t GetTile(int x, int y) {
		if (x >= 0 && x < nLevelTilesX && y >= 0 && y < nLevelTilesY)
			return sLevel[y * nLevelTilesX + x];
		else
			return L' ';
	}

	void GetTile(int x, int y, wchar_t c) {
		if (x >= 0 && x < nLevelTilesX && y >= 0 && y < nLevelTilesY)
			sLevel[y * nLevelTilesX + x] = c;
	}

	void DrawGame(float fElapsedTime) {
		// Determine how many tiles should be drawn on screen
		int nTileWidth = 8;
		int nTileHeight = 8;
		int nVisibleTilesX = ScreenWidth() / nTileWidth;
		int nVisibleTilesY = ScreenHeight() / nTileHeight;
		cout << nVisibleTilesX << '\n';
		cout << nVisibleTilesY << '\n';

		// Calculate Top-Leftmost visible tile (camera is centered)
		float fCameraTopLeftX = fCameraPosX - (float)nVisibleTilesX / 2.0f;
		float fCameraTopLeftY = fCameraPosY - (float)nVisibleTilesY / 2.0f;

		// Clamp camera to game boundaries (in tiles)
		if (fCameraTopLeftX < 0) fCameraTopLeftX = 0;
		if (fCameraTopLeftY < 0) fCameraTopLeftY = 0;

		if (fCameraTopLeftX > nLevelTilesX - nVisibleTilesX) fCameraTopLeftX = nLevelTilesX - nVisibleTilesX;
		if (fCameraTopLeftY > nLevelTilesY - nVisibleTilesY) fCameraTopLeftY = nLevelTilesY - nVisibleTilesY;

		float fTileOffsetX = (fCameraTopLeftX - (int)fCameraTopLeftX) * nTileWidth;
		float fTileOffsetY = (fCameraTopLeftY - (int)fCameraTopLeftY) * nTileWidth;

		// Draw visible tile map
		for (int x = -1; x < nVisibleTilesX + 1; x++)
		{
			for (int y = -1; y < nVisibleTilesY + 1; y++)
			{
				wchar_t sTileID = GetTile(x + fCameraTopLeftX, y + fCameraTopLeftY);
				switch (sTileID)
				{
				case L'.':
					FillRect(x * nTileWidth - fTileOffsetX, y * nTileHeight - fTileOffsetY, nTileWidth, nTileHeight, CYAN);
					break;
				case L'#':
					FillRect(x * nTileWidth - fTileOffsetX, y * nTileHeight - fTileOffsetY, nTileWidth, nTileHeight, RED);
					break;
				default:
					FillRect(x * nTileWidth - fTileOffsetX, y * nTileHeight - fTileOffsetY, nTileWidth, nTileHeight, BLUE);
					break;
				}
			}
		}
		
		// Draw Player
		FillRect((fPlayerPosX - fCameraTopLeftX) * nTileWidth, (fPlayerPosY - fCameraTopLeftY) * nTileHeight, nTileWidth, nTileHeight, GREEN);
	}
};

int main() {
	olcPlatformer game;
	if (game.Construct(200, 200*(3.0f/4), 4, 4)) // 4:3 ratio
		game.Start();

	return 0;
}


#include "Game.h"
#include "Components/AnimationComponent.h"
#include "Components/BoxColliderComponent.h"
#include "Components/RigidBodyComponent.h"
#include "Components/SpriteComponent.h"
#include "Components/TransformComponent.h"
#include "Logger/Logger.h"
#include "Systems/AnimationSystem.h"
#include "Systems/CollisionSystem.h"
#include "Systems/MovementSystem.h"
#include "Systems/RenderColliderSystem.h"
#include "Systems/RenderSystem.h"
#include <SDL2/SDL_image.h>
#include <fstream>
#include <glm/glm.hpp>

Game::Game() {
  isRunning = false;
  isDebug = false;
  registry = std::make_unique<Registry>();
  assetStore = std::make_unique<AssetStore>();

  Logger::Log("Game constructor called!");
}

Game::~Game() { Logger::Log("Game destructor called!"); }

void Game::Initialize() {
  if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
    Logger::Err("Could not initialize SDL.");
    return;
  }
  SDL_DisplayMode displayMode;
  SDL_GetCurrentDisplayMode(0, &displayMode);
  windowWidth = displayMode.w;
  windowHeight = displayMode.h;
  window = SDL_CreateWindow("Roraima v1.0.0", SDL_WINDOWPOS_CENTERED,
                            SDL_WINDOWPOS_CENTERED, windowWidth, windowHeight,
                            SDL_WINDOW_BORDERLESS);
  if (!window) {
    Logger::Err("ERROR: could not create SDL window.");
  }
  renderer = SDL_CreateRenderer(
      window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
  if (!renderer) {
    Logger::Err("ERROR: could not create SDL renderer.");
  }
  SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN);
  isRunning = true;
}

void Game::ProcessInput() {
  SDL_Event sdlEvent;
  while (SDL_PollEvent(&sdlEvent)) {
    switch (sdlEvent.type) {
    case SDL_QUIT:
      isRunning = false;
      break;
    case SDL_KEYDOWN:
      if (sdlEvent.key.keysym.sym == SDLK_ESCAPE) {
        isRunning = false;
      }
      if (sdlEvent.key.keysym.sym == SDLK_d) {
        isDebug = !isDebug;
      }
      break;
    }
  }
}

void Game::LoadLevel(int level) {
  registry->AddSystem<MovementSystem>();
  registry->AddSystem<RenderSystem>();
  registry->AddSystem<AnimationSystem>();
  registry->AddSystem<CollisionSystem>();
  registry->AddSystem<RenderColliderSystem>();

  assetStore->AddTexture(renderer, "tank-image",
                         "assets/images/tank-panther-right.png");
  assetStore->AddTexture(renderer, "truck-image",
                         "assets/images/truck-ford-right.png");
  assetStore->AddTexture(renderer, "chopper-image",
                         "assets/images/chopper.png");
  assetStore->AddTexture(renderer, "radar-image", "assets/images/radar.png");
  assetStore->AddTexture(renderer, "tilemap-image",
                         "assets/tilemaps/jungle.png");

  int tileSize = 32;
  double tileScale = 2.25;
  int mapNumCols = 25;
  int mapNumRows = 20;
  std::fstream mapFile;
  mapFile.open("assets/tilemaps/jungle.map");

  for (int y = 0; y < mapNumRows; y++) {
    for (int x = 0; x < mapNumCols; x++) {
      char ch;
      mapFile.get(ch);
      int srcRectY = std::atoi(&ch) * tileSize;
      mapFile.get(ch);
      int srcRectX = std::atoi(&ch) * tileSize;
      mapFile.ignore();

      Entity tile = registry->CreateEntity();
      double posX = x * tileSize * tileScale;
      double posY = y * tileSize * tileScale;
      glm::vec2 position = glm::vec2(posX, posY);
      glm::vec2 scale = glm::vec2(tileScale, tileScale);
      tile.AddComponent<TransformComponent>(position, scale, 0);
      tile.AddComponent<SpriteComponent>("tilemap-image", tileSize, tileSize,
                                         srcRectX, srcRectY, 0);
    }
  }
  mapFile.close();

  Entity chopper = registry->CreateEntity();
  chopper.AddComponent<TransformComponent>(glm::vec2(100, 100), glm::vec2(1, 1),
                                           0);
  chopper.AddComponent<RigidBodyComponent>(glm::vec2(50, 0));
  chopper.AddComponent<SpriteComponent>("chopper-image", 32, 32, 0, 0, 1);
  chopper.AddComponent<AnimationComponent>(2, 10);

  Entity radar = registry->CreateEntity();
  radar.AddComponent<TransformComponent>(glm::vec2(windowWidth - 74, 10),
                                         glm::vec2(1, 1), 0);
  radar.AddComponent<RigidBodyComponent>(glm::vec2(0, 0));
  radar.AddComponent<SpriteComponent>("radar-image", 64, 64, 0, 0, 2);
  radar.AddComponent<AnimationComponent>(8, 5);

  Entity tank = registry->CreateEntity();
  tank.AddComponent<TransformComponent>(glm::vec2(200, 10), glm::vec2(1, 1), 0);
  tank.AddComponent<RigidBodyComponent>(glm::vec2(-30, 0));
  tank.AddComponent<SpriteComponent>("tank-image", 32, 32, 0, 0, 100);
  tank.AddComponent<BoxColliderComponent>(32, 32);

  Entity truck = registry->CreateEntity();
  truck.AddComponent<TransformComponent>(glm::vec2(10, 10), glm::vec2(1, 1), 0);
  truck.AddComponent<RigidBodyComponent>(glm::vec2(20, 0));
  truck.AddComponent<SpriteComponent>("truck-image", 32, 32, 0, 0, 10);
  truck.AddComponent<BoxColliderComponent>(32, 32);
}

void Game::Setup() { LoadLevel(1); }

void Game::Update() {
  int timeToWait =
      MILLISECS_PER_FRAME - (SDL_GetTicks() - millisecsPreviousFrame);

  if (timeToWait > 0 && timeToWait <= MILLISECS_PER_FRAME) {
    SDL_Delay(timeToWait);
  }

  // The difference in ticks since the last frame, converted to seconds
  double deltaTime = (SDL_GetTicks() - millisecsPreviousFrame) / 1000.0;

  // Store the "previous" frame time
  millisecsPreviousFrame = SDL_GetTicks();

  registry->Update();

  registry->GetSystem<AnimationSystem>().Update();
  registry->GetSystem<MovementSystem>().Update(deltaTime);
  registry->GetSystem<CollisionSystem>().Update();
}

void Game::Render() {
  SDL_SetRenderDrawColor(renderer, 21, 21, 21, 255);
  SDL_RenderClear(renderer);

  registry->GetSystem<RenderSystem>().Update(renderer, assetStore);
  if (isDebug)
    registry->GetSystem<RenderColliderSystem>().Update(renderer);

  SDL_RenderPresent(renderer);
}

void Game::Run() {
  Setup();
  while (isRunning) {
    ProcessInput();
    Update();
    Render();
  }
}

void Game::Destroy() {
  SDL_DestroyWindow(window);
  SDL_DestroyRenderer(renderer);
  SDL_Quit();
}

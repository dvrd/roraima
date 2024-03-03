#include "Game.h"
#include <iostream>

Game::Game() { std::cout << "Game constructor called!" << std::endl; }

Game::~Game() { std::cout << "Game desconstructor called!" << std::endl; }

void Game::Initialize() {}

void Game::ProcessInput() {}

void Game::Run() {
  while (true) {
    ProcessInput();
    Update();
    Render();
  }
}

void Game::Update() {}

void Game::Render() {}

void Game::Destroy() {}

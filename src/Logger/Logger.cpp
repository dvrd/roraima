#include "Logger.h"
#include <spdlog/spdlog.h>

void Logger::Log(const std::string &message) { spdlog::info(message); }

void Logger::Err(const std::string &message) { spdlog::error(message); }

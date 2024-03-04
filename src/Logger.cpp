#include "Logger.h"
#include <chrono>
#include <ctime>
#include <iostream>
#include <string>

const std::string LOG = "\x1B[34m \x1B[0m";
const std::string ERROR = "\x1B[31m \x1B[0m";
// const std::string WARNING = "\x1B[33m \x1B[0m";
// const std::string DEBUG = "\x1B[35m \x1B[0m";

std::string CurrentDateTime() {
  std::time_t now =
      std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
  std::string output(20, '\0');
  std::strftime(&output[0], output.size(), "%d/%b/%Y %H:%M:%S",
                std::localtime(&now));
  return output;
}

void Logger::Log(const std::string &message) {
  std::string output = LOG + message + "\t\t\t\t[" + CurrentDateTime() + "]";
  std::cout << output << std::endl;
}

void Logger::Err(const std::string &message) {
  std::string output = ERROR + " [" + CurrentDateTime() + "]: " + message;
  std::cout << output << std::endl;
}

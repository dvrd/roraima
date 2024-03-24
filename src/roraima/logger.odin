package roraima

import "core:fmt"
import "core:log"
import "core:os"

DEBUG_FILE :: "debug.log"

BLUE :: "\x1B[34m"
RED :: "\x1B[91m"
PURPLE :: "\x1B[35m"
END :: "\x1b[0m"

ERROR :: "\x1B[91m\x1b[0m"
SUCCESS :: "\x1B[32m\x1b[0m"
WARNING :: "\x1B[33m\x1b[0m"
INFO :: "\x1B[34m\x1B[0m"
DEBUG :: "\x1B[35m\x1B[0m"

when ODIN_DEBUG {
	lowest :: log.Level.Debug
} else {
	lowest :: log.Level.Info
}

inform :: proc(message: string, args: ..any) {
	fmt.print(INFO, "")
	log.infof(message, ..args)
}

debug :: proc(message: string, args: ..any) {
	when ODIN_DEBUG {fmt.print(DEBUG, "")}
	log.debugf(message, ..args)
}

error :: proc(message: string, args: ..any) {
	fmt.print(ERROR, "")
	log.errorf(message, ..args)
}

create_logger :: proc() -> (logger: ^log.Logger, err: Error) {
	logger = new(log.Logger) or_return

	logger_options := log.Options{.Terminal_Color, .Level, .Time, .Date}
	console_logger := log.create_console_logger(lowest, logger_options)

	logger^ = console_logger

	when ODIN_DEBUG {
		fd, errno := os.open(
			DEBUG_FILE,
			os.O_RDWR | os.O_CREATE | os.O_APPEND,
			os.S_IRUSR | os.S_IWUSR | os.S_IRGRP | os.S_IROTH,
		)
		defer os.close(fd)
		if Errno(errno) != .ERROR_NONE {
			err = SystemError{.File, ERRORNO_MSGS[errno]}
			return
		}

		file_logger := log.create_file_logger(fd, lowest, logger_options)
		logger^ = log.create_multi_logger(file_logger, console_logger)
	}

	return
}

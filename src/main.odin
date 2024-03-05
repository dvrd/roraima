package roraima

import "core:fmt"
import "core:log"
import "core:os"

DEBUG_FILE :: "debug.log"

when ODIN_DEBUG {
	lowest :: log.Level.Debug
} else {
	lowest :: log.Level.Info
}

main :: proc() {
	logger_options := log.Options{.Terminal_Color, .Level, .Time, .Date}
	console_logger := log.create_console_logger(lowest, logger_options)
	when ODIN_DEBUG {
		fd, err := os.open(DEBUG_FILE, os.O_RDWR | os.O_CREATE | os.O_APPEND)
		if err != os.ERROR_NONE {
			fmt.eprintln(ERROR_MSG[err])
			os.exit(1)
		}
		defer os.close(fd)

		file_logger := log.create_file_logger(fd, lowest, logger_options)
		context.logger = log.create_multi_logger(file_logger, console_logger)
	} else {
		context.logger = console_logger
	}

	inform("Initializing game enginre 'Roraima v1.0.0'")

	game := new(State)
	initialize(game)
	run(game)
	defer destroy(game)
}

ERROR_MSG: [105]string = {
	"THIS ONE SHOULD BE UNREACHABLE",
	"Operation not permitted",
	"No such file or directory",
	"No such process",
	"Interrupted system call",
	"Input/output error",
	"Device not configured",
	"Argument list too long",
	"Exec format error",
	"Bad file descriptor",
	"No child processes",
	"Resource deadlock avoided",
	"Cannot allocate memory",
	"Permission denied",
	"Bad address",
	"Block device required",
	"Device / Resource busy",
	"File exists",
	"Cross-device link",
	"Operation not supported by device",
	"Not a directory",
	"Is a directory",
	"Invalid argument",
	"Too many open files in system",
	"Too many open files",
	"Inappropriate ioctl for device",
	"Text file busy",
	"File too large",
	"No space left on device",
	"Illegal seek",
	"Read-only file system",
	"Too many links",
	/* math software */
	"Numerical argument out of domain",
	"Result too large",
	/* non-blocking and interrupt i/o */
	"Resource temporarily unavailable or Operation would block",
	"Operation now in progress",
	"Operation already in progress",
	/* ipc/network software -- argument errors */
	"Socket operation on non-socket",
	"Destination address required",
	"Message too long",
	"Protocol wrong type for socket",
	"Protocol not available",
	"Protocol not supported",
	"Socket type not supported",
	"Operation not supported",
	"Protocol family not supported",
	"Address family not supported by protocol family",
	"Address already in use",
	"Can't assign requested address",
	/* ipc/network software -- operational errors */
	"Network is down",
	"Network is unreachable",
	"Network dropped connection on reset",
	"Software caused connection abort",
	"Connection reset by peer",
	"No buffer space available",
	"Socket is already connected",
	"Socket is not connected",
	"Can't send after socket shutdown",
	"Too many references: can't splice",
	"Operation timed out",
	"Connection refused",
	"Too many levels of symbolic links",
	"File name too long",
	/* should be rearranged */
	"Host is down",
	"No route to host",
	"Directory not empty",
	/* quotas & mush */
	"Too many processes",
	"Too many users",
	"Disc quota exceeded",
	/* Network File System */
	"Stale NFS file handle",
	"Too many levels of remote in path",
	"RPC struct is bad",
	"RPC version wrong",
	"RPC prog. not avail",
	"Program version wrong",
	"Bad procedure for program",
	"No locks available",
	"Function not implemented",
	"Inappropriate file type or format",
	"Authentication error",
	"Need authenticator",
	/* Intelligent device errors */
	"Device power is off",
	"Device error, e.g. paper out",
	"Value too large to be stored in data type",
	/* Program loading errors */
	"Bad executable",
	"Bad CPU type in executable",
	"Shared library version mismatch",
	"Malformed Macho file",
	"Operation canceled",
	"Identifier removed",
	"No message of desired type",
	"Illegal byte sequence",
	"Attribute not found",
	"Bad message",
	"Reserved",
	"No message available on STREAM",
	"Reserved",
	"No STREAM resources",
	"Not a STREAM",
	"Protocol error",
	"STREAM ioctl timeout",
	"No such policy registered",
	"State not recoverable",
	"Previous owner died",
	"Interface output queue is full",
}

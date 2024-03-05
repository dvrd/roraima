package roraima

import "core:fmt"
import "core:log"

ERROR :: "\x1B[91m\x1b[0m"
SUCCESS :: "\x1B[32m\x1b[0m"
WARNING :: "\x1B[33m\x1b[0m"
INFO :: "\x1B[34m\x1B[0m"
DEBUG :: "\x1B[35m\x1B[0m"

inform :: proc(message: string, args: ..any) {
	fmt.print(INFO, "")
	log.infof(message, ..args)
}

debug :: proc(message: string, args: ..any) {
	fmt.print(DEBUG, "")
	log.debugf(message, ..args)
}

error :: proc(message: string, args: ..any) {
	fmt.print(ERROR, "")
	log.errorf(message, ..args)
}

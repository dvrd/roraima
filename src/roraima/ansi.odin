package roraima

import "core:fmt"
import "core:strings"

END :: "\x1b[0m"
BOLD :: "\x1b[1m"
UNDERLINE :: "\x1b[1m"

PURPLE :: "\x1B[35m"

RGB :: "\x1B[38;2;%d;%d;%d;0m"

bold :: proc(str: string) -> string {
	return strings.concatenate({BOLD, str, END})
}

underline :: proc(str: string) -> string {
	return strings.concatenate({UNDERLINE, str, END})
}

purple :: proc(str: string) -> string {
	return strings.concatenate({PURPLE, str, END})
}

colorize :: proc(str: string, color: [3]u8) -> string {
	color := fmt.tprintf(RGB, color.r, color.g, color.b)
	return strings.concatenate({color, str, END})
}

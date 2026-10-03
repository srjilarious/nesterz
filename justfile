alias t := test
alias b := build
alias bwin := build_win
# alias d := docs

# docs :
# 	zig build docs

test *OPTS:
	zig build tests -- {{OPTS}}

build *OPTS:
	zig build {{OPTS}}

build_win *OPTS:
	zig build -Dtarget=x86_64-windows {{OPTS}}

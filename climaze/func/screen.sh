declare -a SCREEN_SIZE

function @screenSizeGetter(){
	SCREEN_SIZE=(
		"$(($(tput lines) + 1))"
		"$(tput cols)"
	)
}

function @screenSizeChangeDetector(){
	if ((SCREEN_SIZE[0] != $(tput lines) + 1)) \
		|| ((SCREEN_SIZE[1] != $(tput cols))); then
		@logger -e \
			"Screen size change detected!" \
			"Line   :[${SCREEN_SIZE[0]} --> $(tput lines)]" \
			"Column :[${SCREEN_SIZE[1]} --> $(tput cols)]"
		return 1
	fi
}

function @screenClear(){
	echo -en "\e[2J"
}

declare -a CURSOR_POS=( 1 1 )
declare -a CURSOR_MOVE_KEY

function @cursorJump(){
	echo -en "\e[${1:-${CURSOR_POS[0]}};${2:-${CURSOR_POS[1]}}H"
}

function @cursorMove(){
	case ${1} in
		"${CURSOR_MOVE_KEY[0]:-"u"}")
			((CURSOR_POS[0] > 1)) \
				&& ((CURSOR_POS[0]--))
			;;
		"${CURSOR_MOVE_KEY[1]:-"l"}")
			((CURSOR_POS[1] > 1)) \
				&& ((CURSOR_POS[1]--))
			;;
		"${CURSOR_MOVE_KEY[2]:-"d"}")
			((CURSOR_POS[0] < SCREEN_SIZE[0])) \
				&& ((CURSOR_POS[0]++))
			;;
		"${CURSOR_MOVE_KEY[3]:-"r"}")
			((CURSOR_POS[1] < SCREEN_SIZE[1])) \
				&& ((CURSOR_POS[1]++))
			;;
	esac
}

function @cursorSetUpperLeft(){
	echo -en "\e[1;1H"
}

function @cursorSetLowerLeft(){
	echo -en "\e[${SCREEN_SIZE[1]};1H"
}

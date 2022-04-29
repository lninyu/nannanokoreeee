#!/usr/bin/env bash
# shellcheck disable=1090,2034

declare -A SCRIPT_INFO=(
	[NAME]='cliMaze'
	[VERSION]='Pre-1.0'
	[AUTHORS]='💩man, 💩woman, pro💩fessional, dark💩, 💩god, 💩xhe💩, 💩lninyu💩, 💩t2💩'
)

for __ in func/*;do
    source "${__}"
done

CURSOR_MOVE_KEY=( w a s d )

function @usage(){
	printf '%s\n%s\n' \
		"${SCRIPT_INFO[NAME]} v.${SCRIPT_INFO[VERSION]}" \
		"UnkoPeeright (💩) 2022 ${SCRIPT_INFO[AUTHORS]}"
}

function @main(){
	while [[ -n ${1} ]];do
		case ${1} in
			('-h'|'--help') @usage ;;
			('-l'|'--log')  LOG_FLAG_ENABLE=true ;;
			(*) break ;;
		esac
		shift
	done

	@screenSizeGetter

	@logger -i \
		"#==============================#" \
		"# name    : ${SCRIPT_INFO[NAME]}" \
		"# version : ${SCRIPT_INFO[VERSION]}" \
		"# time    : $( date '+%Y%m%d%H%M%S' )" \
		"# scsize  : ${SCREEN_SIZE[*]}" \
		"#==============================#"

	if (( SCREEN_SIZE[0] % 2 == 1 ));then
		@logger -e "Lines are not odd."
		return 1
	fi

	if (( SCREEN_SIZE[1] % 2 == 1 ));then
		@logger -e "Columns are not even."
		return 1
	fi

	@screenClear

	if @eventloop
		then @logger -i "Normal end."
		else @logger -e "Abnormal end."
	fi

	@screenClear
	@cursorSetUpperLeft
}
@main "${@}"

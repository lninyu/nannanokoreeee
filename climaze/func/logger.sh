# shellcheck disable=2155

declare    LOG_FLAG_ENABLE=false
declare    LOG_LOGFILE="${SCRIPT_INFO[NAME]}_log/$( date '+%Y%m%d%H%M%S' ).log"
declare -i LOG_COUNT=0
declare -i LOG_COUNT_DIGITSIZE=8

function   @logger(){
	${LOG_FLAG_ENABLE:-false} || return 0

	local    __TEMP
	local    __TYPE
	local -r __FILE="${LOG_LOGFILE:-${SCRIPT_INFO[NAME]}.log}"
	local -i __SIZE=${LOG_COUNT_DIGITSIZE:-8}

	((LOG_COUNT++))

	case ${1:0:2} in
		(-e) __TYPE='[ERROR] '; shift ;;
		(-f) __TYPE='[FATAL] '; shift ;;
		(-w) __TYPE='[WARN]  '; shift ;;
		(-i) __TYPE='[INFO]  '; shift ;;
	esac

	[[ -d ${__FILE%/*} ]] \
		|| mkdir -p "${__FILE%/*}"

	for __TEMP in "${@}";do
		printf \
			"[%0${__SIZE}d:%-10s] ${__TYPE}%s\n" \
			"$((LOG_COUNT))"   \
			"${FUNCNAME[1]#@}" \
			"${__TEMP}"        \
			>> "${__FILE}"
	done
}
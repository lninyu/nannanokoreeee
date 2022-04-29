# shellcheck disable=2034,2155,2165,2167

declare -a MAZE_MAP

function @mazeCreate(){
	local    __TEMP
	local -a __MAZE_SIZE
	# Init
	MAZE_MAP=()

	@logger -i "Begin map generate."

	for (( __MAZE_SIZE[0] = 0; __MAZE_SIZE[0] < SCREEN_SIZE[0]; __MAZE_SIZE[0]++ ));do
	    for (( __MAZE_SIZE[1] = 0; __MAZE_SIZE[1] < SCREEN_SIZE[1]/2; __MAZE_SIZE[1]++ ));do
	    	__TEMP=$(( RANDOM % 16 ))
	        case ${__TEMP} in
	        	(10) MAZE_MAP+=(      a      ) ;;
	        	(11) MAZE_MAP+=(      b      ) ;;
	        	(12) MAZE_MAP+=(      c      ) ;;
	        	(13) MAZE_MAP+=(      d      ) ;;
	        	(14) MAZE_MAP+=(      e      ) ;;
	        	(15) MAZE_MAP+=(      f      ) ;;
				(*)  MAZE_MAP+=( "${__TEMP}" ) ;;
	    	esac
	    done
	done
}

function @mazePrint(){
	local -a __MAZE_SIZE
	local __OUT

	@logger -i "Maze print start."
	for (( __MAZE_SIZE[0] = 0; __MAZE_SIZE[0] < SCREEN_SIZE[0]; __MAZE_SIZE[0]++ ));do
	    for (( __MAZE_SIZE[1] = 0; __MAZE_SIZE[1] < SCREEN_SIZE[1]/2; __MAZE_SIZE[1]++ ));do
    	    case ${MAZE_MAP[$(( __MAZE_SIZE[0] * SCREEN_SIZE[1]/2 + __MAZE_SIZE[1] ))]} in
    	    	(0) __OUT+='██';;
    	    	(1) __OUT+='██';;
    	    	(*) __OUT+='  ';;
    	    esac
    	done
    	@cursorJump $((__MAZE_SIZE[0]+1)) 1
    	echo -en "${__OUT}"; __OUT=''
    done
}

function @mazeLoad(){
	local    __FILENAME="${1}"
	local    __DATA=$( gunzip < "map/${__FILENAME}.map" | xxd -p | tr -d '\n' )
	local -a __MAP_SIZE=(
		$(( 16#${__DATA:0:4} ))
		$(( 16#${__DATA:4:4} ))
	)
	local -i __COUNTER=-1
	__DATA=${__DATA:8}

	if (( __MAP_SIZE[0] != SCREEN_SIZE[0] )) \
	|| (( __MAP_SIZE[1] != SCREEN_SIZE[1] ));then
		@logger -e \
			"Different map size." \
			"__MAP_SIZE[${__MAP_SIZE[0]}:${SCREEN_SIZE[0]}]" \
			"SCREEN_SIZE[${__MAP_SIZE[1]}:${SCREEN_SIZE[1]}]"
		return 1
	fi

	MAZE_MAP=()
	@logger -i "Loading start."
#	while [[ -n ${__DATA:$((++__COUNTER)):1} ]];do
#		(( __COUNTER % (SCREEN_SIZE[0]*SCREEN_SIZE[1]/20) == 0 )) \
#			&& @logger -i "Loading map: ${__COUNTER}/$((SCREEN_SIZE[0]*SCREEN_SIZE[1]/2))"
#		MAZE_MAP+=( "${__DATA:$((__COUNTER)):1}" )
#	done
	MAZE_MAP=( $(fold -w1 <<< "${__DATA}") )
	@logger -i "Loading complete."
}

function @mazeSave(){
	local __FILENAME="${1}"
	local __TEMP="$( tr -d ' ' <<< "${MAZE_MAP[*]}" )"

		[[ -d map ]] || mkdir "map"

		printf \
			'%04x%04x%s' \
			"${SCREEN_SIZE[0]}" \
			"${SCREEN_SIZE[1]}" \
			"${__TEMP}" \
				| xxd -p -r \
				| gzip -cf \
				> "map/${__FILENAME}"
		@logger -i "Save map data to 'map/${__FILENAME}'"
}

function @mazeIsCollision(){
	:
}

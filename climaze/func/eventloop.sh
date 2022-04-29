declare    IB_DUMP=false
function @eventloop(){
	local -i EVENTLOOP_COUNT=0
	local    INPUT_BUFFER
	local    __TEMP

	@logger -i "eventloop start."

    while :;do ((EVENTLOOP_COUNT++))
    	# Check
    	if ((EVENTLOOP_COUNT%16 == 0));then
			@screenSizeChangeDetector || return 1
		fi

		# Init
		@cursorSetUpperLeft
		printf "\e[2K_S:[%3d:%3d] P:[%3d:%3d] B:[%2d]\e[1G" \
			"${SCREEN_SIZE[0]}" "${SCREEN_SIZE[1]}" \
			"${CURSOR_POS[0]}"  "${CURSOR_POS[1]}"  \
			"${#INPUT_BUFFER}"

    	# Input
		for ((__TEMP=0;__TEMP<4;__TEMP++));do
		    @input; INPUT_BUFFER+=${REPLY}
		done

		if ${IB_DUMP} && [[ -n ${INPUT_BUFFER} ]];then
			@logger -i "IBuffer:${#INPUT_BUFFER}: ${INPUT_BUFFER}"
		fi

		# Main process
		case ${INPUT_BUFFER:0:1} in
			(c) @screenClear ;;
			(h) @cursorJump 2 1
				printf '\n%s\n%s\n%s\n%s' \
					"  ${CURSOR_MOVE_KEY[0]}: UP     |  q: Quit     " \
					"  ${CURSOR_MOVE_KEY[1]}: LEFT   |  h: Help     " \
					"  ${CURSOR_MOVE_KEY[2]}: DOWN   |  c: Clear    " \
					"  ${CURSOR_MOVE_KEY[3]}: RIGHT  |  m: map menu "
				;;
			(m) @screenClear
				while :;do
					echo -en "\e[2K_ map menu: \e[4mn\e[mew/\e[4ml\e[moad/\e[4mb\e[mack\e[1G"
					@input
					case ${REPLY,,} in
						(n) echo -en "\e[1A\e[2K"
							read -r -p "map name: "
							if [[ -f map/${REPLY}.map ]];then
								@logger -e "'${REPLY}.map' is exists."
								echo -en "\e[2K_Failed: '${REPLY}.map' is exists.\e[1G"
								@bell; sleep 1.5
							fi

							if [[ -n ${REPLY} ]];then
								@logger -i "Creating maze... '${REPLY}.map'"
								@mazeCreate
								@mazeSave "${REPLY}.map"
								@mazePrint &
							else
								@logger -e "map name is empty."
								echo -en "\e[2K_Failed: map name is empty.\e[1G"
								@bell; sleep 1.5
							fi
							break
							;;
						(l) echo -en "\e[1A\e[2K"
							read -r -p "map name: "
							if [[ -f map/${REPLY}.map ]];then
								@logger -i "Loading maze... '${REPLY}'"
								if @mazeLoad "${REPLY}";then
									@mazePrint &
								else
									echo -en "\e[1A\e[2K_Failed: map size different."
									@bell; sleep 1.5
								fi
							else
								@logger -e "'${REPLY}' is not exists."
								echo -en "\e[2K_Failed: '${REPLY}' is not exists.\e[1G"
								@bell; sleep 1.5
							fi
							break
							;;
						(b) break ;;
					esac
				done
				;;
			(q) @screenClear
				while :;do
					echo -en "\e[2K Quit? \e[4my\e[mes/\e[4mn\e[mo\e[1G"
					@input
					case ${REPLY,,} in
						(y) @bell; return 0 ;;
						(n) @bell; break ;;
					esac
				done
				;;

			(*) @cursorMove "${INPUT_BUFFER:0:1}" ;;
		esac

		if   [[ ${#INPUT_BUFFER} -lt 10 ]];then
			INPUT_BUFFER="${INPUT_BUFFER:1}"
		elif [[ ${#INPUT_BUFFER} -lt 50 ]];then
			INPUT_BUFFER="${INPUT_BUFFER:2}"
		elif [[ ${#INPUT_BUFFER} -lt 100 ]];then
			INPUT_BUFFER="${INPUT_BUFFER:5}"
			@logger -w "Processing is delayed."
		else
			INPUT_BUFFER=""
			@logger -w "IBuffer reset!"
		fi
    done

    @logger -i "eventloop end."
}

function @input(){
    read -s -r -n1 -t0.01 2> /dev/null
}

function @bell(){
	echo -en "\a"
}
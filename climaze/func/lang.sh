declare -A MESSAGE

function @setMessage(){
	@logger -i "Lang: ${LANG}"

    case ${LANG%%.*} in
    	('ja_JP')
    		MESSAGE=(
    			[dummy]='ダミー'
    		) ;;
		(*) # en_US
			MESSAGE=(
				[dummy]='dummy'
			) ;;
    esac
}
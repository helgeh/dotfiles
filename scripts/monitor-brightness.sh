#!/bin/bash

# Usage:
#
#    bright [MONITOR] [COMMAND/VALUE] [VALUE (if command is toggle)]



# Discover monitor name with: xrandr | grep " connected"
MON="$1"    # input parameter must be name of monitor
CMND=$2
VAL=$3
EXTRA=$4
[[ -z $4 ]] && EXTRA=$3


[[ "$MON" == "1" ]] && MON="DP-1"
[[ "$MON" == "2" ]] && MON="DP-3"
[[ "$MON" == "3" ]] && MON="DP-3"

[[ "$MON" == "main" ]] && MON="DP-4"
[[ "$MON" == "left" || "$MON" == "l" ]] && MON="DP-1"
[[ "$MON" == "right" || "$MON" == "r" ]] && MON="DP-3"

[[ "$MON" == "DP-1" || "$MON" == "DP-3" || "$MON" == "DP-4" ]] || MON="error"

[[ "$CMND" == "inc" || "$CMND" == "increment" || "$CMND" == "up" || "$CMND" == "+" ]]   && CMND="increment"
[[ "$CMND" == "dec" || "$CMND" == "decrement" || "$CMND" == "down" || "$CMND" == "-" ]] && CMND="decrement"
[[ "$CMND" == "toggle" || "$CMND" == "tgl" || "$CMND" == "t" ]]                         && CMND="toggle"
[[ "$CMND" -eq 100 || "$CMND" -gt 0 && "$CMND" -lt 100 ]]                               && VAL="$CMND" CMND="value"
[[ -z "$CMND" && "$MON" != "error" ]]                                                   && CMND="get"

if [[ "$CMND" != "increment" && "$CMND" != "decrement" && "$CMND" != "toggle" && "$CMND" != "value" && "$CMND" != "get" ]] ; then
    echo "ERROR: mon is $MON, command is $CMND, val is $VAL"
    CMND="error"
    VAL="error"
fi

# echo "mon is $MON, command is $CMND, val is $VAL, extra is $EXTRA"



CurrBright=$( xrandr --verbose --current | grep ^"$MON" -A5 | tail -n1 )
CurrBright="${CurrBright##* }"  # Get brightness level with decimal place


if [[ "$CMND" == "increment" || "$CMND" == "decrement" ]] ; then

    STEP=10

    Left=${CurrBright%%"."*}        # Extract left of decimal point
    Right=${CurrBright#*"."}        # Extract right of decimal point

    MathBright="0"
    [[ "$Left" != 0 ]] && MathBright="$Left"00          # 1.0 becomes "100"
    [[ "${#Right}" -eq 1 ]] && Right="$Right"0          # 0.5 becomes "50"
    MathBright=$(( MathBright + Right ))

    [[ "$CMND" == "increment" ]] && MathBright=$(( MathBright + STEP ))
    [[ "$CMND" == "decrement" ]] && MathBright=$(( MathBright - STEP ))
    [[ "${MathBright:0:1}" == "-" ]] && MathBright=0    # Negative not allowed
    [[ "$MathBright" -gt 100  ]] && MathBright=100      # Can't go over 9.99

    if [[ "${#MathBright}" -eq 3 ]] ; then
        MathBright="$MathBright"000         # Pad with lots of zeros
        NewBright="${MathBright:0:1}.${MathBright:1:2}"
    else
        MathBright="$MathBright"000         # Pad with lots of zeros
        NewBright=".${MathBright:0:2}"
    fi

elif [[ "$CMND" == "toggle" || "$CMND" == "value" ]] ; then

    if [[ "$CMND" == "toggle" ]] ; then

        ToggleBright="$VAL"
        [[ -z "$ToggleBright" ]] && ToggleBright="50"   # Default toggle value
        NewBright="$ToggleBright"  # Lazily setting the low value
        
        CurrLeft=${CurrBright%%"."*}
        [[ "$CurrLeft" -lt 1 ]] && NewBright="100"  # Current is not full so toggling to full

    else

        NewBright="$VAL"   # Nothing special, we just set the given value

    fi

    MathBright="$NewBright"
    [[ "${MathBright:0:1}" == "-" ]] && MathBright=0    # Negative not allowed
    [[ "$MathBright" -gt 100  ]] && MathBright=100      # Can't go over 9.99

    if [[ "${#MathBright}" -eq 3 ]] ; then
        MathBright="$MathBright"000         # Pad with lots of zeros
        NewBright="${MathBright:0:1}.${MathBright:1:2}"
    else
        if [[ "$MathBright" -eq 1 ]] ; then
            NewBright=1
        else
            MathBright="$MathBright"000         # Pad with lots of zeros
            NewBright=".${MathBright:0:2}"
        fi
    fi

fi


if [[ "$MON" == "error" || "$CMND" == "error" || "$VAL" == "error" ]] ; then
    echo "Something went wrong, no monitor has been adjusted."
    echo "  (MON=$MON, CMND=$CMND, VAL=$VAL, NewBright=$NewBright)"
elif [[ "$CMND" == "get" ]] ; then
    echo "Current brightness for $MON is $CurrBright"
else
    # echo "Calling xrandr with arguments: --output $MON --brightness $NewBright"
    xrandr --output "$MON" --brightness "$NewBright"   # Set new brightness
    CurrBright=$( xrandr --verbose --current | grep ^"$MON" -A5 | tail -n1 )
    CurrBright="${CurrBright##* }"
    [[ "$EXTRA" == "--verbose" ]] && echo "Current brightness for $MON is now $CurrBright (set with the $CMND command)"
fi
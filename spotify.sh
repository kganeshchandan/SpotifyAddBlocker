#!/bin/bash
set -e

function spotstart {

  ( spotify >/dev/null 2>&1 & )
  grep -m 1 spotify <( exec dbus-monitor "member='AddMatch'" ) >/dev/null
  kill $! 2>/dev/null
  sleep 1
  echo "[      Launched Spotify!      ]"
}

function spotplay {
  dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Play 1>/dev/null 2>&1
  echo "Playing Music"
}

function main {
temp2=$(whoami)
while true ;do
 temp1=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep -Ev "^method"  | grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)' | sed -E '2~2 a|' | tr -d '\n'|sed -E 's/\|/\n/g'| sed -E 's/(xesam:)|(mpris:)//' | sed -E 's/^"//'| sed -E 's/"$//'| sed -E 's/"+/|/' | grep "title")
  if [ "$temp1" = "title|Advertisement" ]; then
    echo "[      Add detected      ]"
    killall spotify
    grep -m 1 spotify <( exec dbus-monitor "member='RemoveMatch'" ) >/dev/null
  kill $! 2>/dev/null
 
    spotstart
     sleep 5
    spotplay
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next 1>/dev/null 2>&1

  else
    if [ "$temp1" != "$temp2" ]; then 
      echo "$temp1"
      temp2=$temp1
      fi
  fi
  done
}
echo "[Listening...]"
echo "[The tracks you are Listening ....]"
main

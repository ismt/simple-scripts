#!/usr/bin/env bash

detectDE()
{
    # see https://bugs.freedesktop.org/show_bug.cgi?id=34164
    unset GREP_OPTIONS

    if [[ -n "${XDG_CURRENT_DESKTOP}" ]]; then
      case "${XDG_CURRENT_DESKTOP}" in
         GNOME)
           DE=gnome;
           ;;
         KDE)
           DE=kde;
           ;;
         LXDE)
           DE=lxde;
           ;;
         XFCE)
           DE=xfce
           ;;
         Unity|UNITY|unity)
           DE=unity;
           ;;
      esac
    fi
    
    if [[ x"$DE" = x"" ]]; then
      # classic fallbacks
      if [[ x"$KDE_FULL_SESSION" = x"true" ]]; then DE=kde;
      elif [[ x"$GNOME_DESKTOP_SESSION_ID" != x"" ]]; then DE=gnome;
      elif `dbus-send --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.GetNameOwner string:org.gnome.SessionManager > /dev/null 2>&1` ; then DE=gnome;
      elif xprop -root _DT_SAVE_MODE 2> /dev/null | grep ' = \"xfce4\"$' >/dev/null 2>&1; then DE=xfce;
      elif xprop -root 2> /dev/null | grep -i '^xfce_desktop_window' >/dev/null 2>&1; then DE=xfce
      fi
    fi
    
    if [[ x"$DE" = x"" ]]; then
      # fallback to checking $DESKTOP_SESSION
      case "$DESKTOP_SESSION" in
         gnome)
           DE=gnome;
           ;;
         LXDE)
           DE=lxde; 
           ;;
         xfce|xfce4)
           DE=xfce;
           ;;
      esac
    fi

    if [[ x"$DE" = x"" ]]; then

      # fallback to uname output for other platforms
      case "$(uname 2>/dev/null)" in 
        Darwin)
          DE=darwin;
          ;;
      esac
    fi
    
    if [[ x"$DE" = x"gnome" ]]; then
      # gnome-default-applications-properties is only available in GNOME 2.x
      # but not in GNOME 3.x
      which gnome-default-applications-properties > /dev/null 2>&1  || DE="gnome3"
    fi
    echo ${DE}
}

detectDE

exit 0



#!/bin/sh

# Make script halt if encountering an error, as opposed to the standard shell
# behavior of ignoring them
set -e

# Use a POSIX-friendly way of detecting whether a command is installed
is_available() {
  command -v "${1}" > /dev/null 2>&1
}

is_null() {
  [ -z "${1}" ]
}

get_mimetype() {
  FILE="${1}"

  file --brief --mime-type "${FILE}"
}

while getopts ":p:c:i:o:q:t:h" opt; do
  case $opt in
    h)
      echo "An FFmpeg frontend for converting gifs into standalone gfy files."
      echo
      echo "Usage: gif2gfy -i infile -o outfile"
      echo
      echo "Getting help:"
      echo "  -h     Print basic options available"
      echo
      echo "Flags available:"
      echo "  -c     Choose background color of gfy; default is black"
      echo "  -o     Set filename of output; default is o.{mp4,webm}.html"
      echo "  -p     Specify a custom directory to look for FFmpeg and FFprobe"
      echo "  -q     Set bitrate in MBs for gif-to-webm conversion; default is 3.5"
      echo "  -t     Set title in HTML page; default is whatever -o is set to"
      exit 1
      ;;
    i)
      IN_FILE="${OPTARG}"
      ;;
    c)
      COLOR="${OPTARG}"
      ;;
    o)
      OUT_FILE="${OPTARG}"
      ;;
    p)
      P="${OPTARG}"
      ;;
    q)
      Q="${OPTARG}"
      ;;
    t)
      TITLE="${OPTARG}"
      ;;
    \?)
      echo "Invalid option: -$OPTARG. Aborting" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument. Aborting." >&2
      exit 1
      ;;
  esac
done

# Set default values if they aren't defined in GETOPTS
if is_null "${Q}"; then
  Q="3.5"
fi

if is_null "${COLOR}"; then
  COLOR="black"
fi

if [ -n "${P}" ]; then
  FULL_PATH="$(realpath "${P}")"

  if [ -x "${FULL_PATH}/ffmpeg" ] && [ -x "${FULL_PATH}/ffprobe" ]; then
    BACKEND="${FULL_PATH}/ffmpeg"
    PROBE="${FULL_PATH}/ffprobe"
  else
    echo "FFmpeg and FFprobe aren't available on ${FULL_PATH}. Aborting."
    exit 1
  fi
elif is_available "ffmpeg" && is_available "ffprobe"; then
  BACKEND="ffmpeg"
  PROBE="ffprobe"
else
  echo "FFmpeg needs to be installed to continue. Aborting."
  exit 1
fi

if is_null "${IN_FILE}"; then
  echo "No file specified. Aborting."
  exit 1
fi

if [ ! -f "${IN_FILE}" ]; then
  echo "${INPUT} isn't a file. Aborting."
  exit 1
fi

IN_MIMETYPE="$(get_mimetype "${IN_FILE}")"
IN_EXTENSION="${IN_MIMETYPE#*/}"

# Temporary location for FFmpeg output that'll be deleted once the script ends
GFY="$(mktemp --dry-run)" || echo 1
trap 'rm -f "${GFY}"' EXIT

# If file is .webm, then simply extract the encoded video losslessly
if [ "${IN_MIMETYPE}" = "video/webm" ] || [ "${IN_MIMETYPE}" = "video/mp4" ]; then
  PARAMETERS="-f ${IN_EXTENSION} -loglevel quiet -vcodec copy -an"
  "${BACKEND}" -i "${IN_FILE}" ${PARAMETERS} "${GFY}"

elif [ "${IN_MIMETYPE}" = "image/gif" ]; then
  PARAMETERS="-f webm -loglevel quiet -minrate ${Q}M -maxrate ${Q}M -b:v ${Q}M"
  "${BACKEND}" -i "${IN_FILE}" ${PARAMETERS} "${GFY}"
else
  echo "Not a supported filetype. Aborting."
  exit 1
fi

PARAMETERS="-loglevel quiet -show_entries stream=width,height -print_format csv"
VIDEO_DATA="$("${PROBE}" "${GFY}" ${PARAMETERS})"

OUT_MIMETYPE="$(get_mimetype "${GFY}")"
OUT_EXTENSION="${OUT_MIMETYPE#*/}"

WIDTH="$(echo "${VIDEO_DATA}" | cut -d "," -f2)"
HEIGHT="$(echo "${VIDEO_DATA}"|  cut -d "," -f3)"
DATA="$(base64 --wrap 0 "${GFY}")"

if is_null "${OUT_FILE}"; then
  OUT_FILE="o.${OUT_EXTENSION}.html"
fi

if is_null "${TITLE}"; then
  TITLE="${OUT_FILE}"
fi

cat << HTML > "${OUT_FILE}"
<!DOCTYPE html>
<html>
  <meta charset="utf-8">
  <title>${TITLE} (${WIDTH}x${HEIGHT}px)</title>
  <style type="text/css">
    * {
      margin: 0;
      padding: 0;
    }
    html, body {
      width: 100%;
      height: 100%;
    }
    html {
      display: table;
    }
    body {
      display: table-cell;
      vertical-align: middle;
      text-align: center;
      background-color: ${COLOR};
    }
    video, source {
      display: block;
      margin: 0 auto;
    }
  </style>
  <video width="${WIDTH}" height="${HEIGHT}" autoplay="autoplay" loop="">
    <source type="${OUT_MIMETYPE}" src="data:${OUT_MIMETYPE};base64,${DATA}">
  </video>
</html>
HTML

realpath "${OUT_FILE}"

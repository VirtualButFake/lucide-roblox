#!/bin/bash
magick convert -channel RGB -negate -background none -size "${1}x${1}" "$2" "$3" &
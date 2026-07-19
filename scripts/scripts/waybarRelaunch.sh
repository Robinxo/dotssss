#!/usr/bin/env bash
pkill -9 waybar
pkill -9 quickshell
waybar &
quickshell &

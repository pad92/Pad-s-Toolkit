#!/usr/bin/env bash

cat $@ | sort -n -t. +0 -1 +1 -2 +2 -3 +3 -4

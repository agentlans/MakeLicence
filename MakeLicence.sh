#!/usr/bin/bash

# Copyright 2022 Alan Tseng
# 
# This program is free software: you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free Software 
# Foundation, either version 3 of the License, or (at your option) any later 
# version.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with 
# this program. If not, see <https://www.gnu.org/licenses/>.

HELP_TEXT=$(cat <<HELP
Generates a comment containing the text of an open source software licence
Usage: MakeLicence.sh [license name] [language] [program name]

To customize the year and copyright holder, set the YEAR and AUTHOR environment variables.

licence name:   gpl3, apache, mit, bsd3, mpl, cc0
language:       for example, c, java, python, bash, javascript
program name:   (optional) name of the program in the copyright
HELP
)

# Example invocation (GPL-3 license with C programming language)
# AUTHOR="Lisbeth Salander" YEAR=2005 bash MakeLicence.sh gpl c

if [[ $# -lt 2 || $# -gt 3 ]]; then
	echo "$HELP_TEXT"
	exit 1
fi

LICENCE=$1
LANG=$2
PROG_NAME=$3

# Converts its input to lowercase and prints to stdout
lowercase() {
	echo $1 | tr 'A-Z' 'a-z'
}

# Prints string a certain number of times
print_repeat() {
	STR=$1
	TIMES=$2
	seq $TIMES | awk "{print \"$STR\"}" | sed -z 's/\n//g'
}

LICENCE=`lowercase $LICENCE`
SCRIPT_DIR=`dirname "$0"` # Directory the script is in

if [[ $PROG_NAME == "" ]]; then
	case $LICENCE in
		gpl3) LICENCE=$SCRIPT_DIR/gpl3_plain.txt ;;
		lgpl3) LICENCE=$SCRIPT_DIR/lgpl3_plain.txt ;;
		cc0) LICENCE=$SCRIPT_DIR/cc0_plain.txt ;;
		*) LICENCE=$SCRIPT_DIR/$LICENCE.txt ;;
	esac
else
	LICENCE=$SCRIPT_DIR/$LICENCE.txt
fi

# Set default year
if [[ $YEAR == "" ]]; then
	YEAR=`date +"%Y"`
fi

# Set default author
if [[ $AUTHOR == "" ]]; then
	AUTHOR=`whoami`
fi

# Change language to lowercase
LANG=`lowercase $LANG`

STYLE=""
case $LANG in
	c) STYLE="c" ;;
	c++) STYLE="slash" ;;
	java) STYLE="slash" ;;
	javascript) STYLE="slash" ;;
	go) STYLE="slash" ;;
	rust) STYLE="slash" ;;
	bash) STYLE="hash" ;;
	python) STYLE="hash" ;;
	perl) STYLE="hash" ;;
	kotlin) STYLE="slash" ;;
	php) STYLE="slash" ;;
	ruby) STYLE="hash" ;;
	r) STYLE="hash" ;;
	lisp) STYLE="lisp" ;;
	scheme) STYLE="lisp" ;;
	racket) STYLE="lisp" ;;
	haskell) STYLE="dash" ;;
	html) STYLE="html" ;;
	css) STYLE="c" ;;
	erlang) STYLE="percent" ;;
	prolog) STYLE="percent" ;;
	pascal) STYLE="slash" ;;
	ada) STYLE="dash" ;;
	lua) STYLE="dash" ;;
	basic) STYLE="basic" ;;
	latex) STYLE="percent" ;;
	matlab) STYLE="percent" ;;
	fortran) STYLE="exclamation" ;;
	nim) STYLE="hash" ;;
	ocaml) STYLE="ocaml" ;;
	powershell) STYLE="hash" ;;
	sql) STYLE="dash" ;;
esac
if [[ $STYLE == "" ]]; then
	echo "ERROR: Unknown language"
	exit 1
fi

BLOCKSTART=""
BLOCKEND=""

case $STYLE in
	c) BLOCKSTART=1
	   BLOCKEND=1
	   LINECOMMENT="* " ;;
	slash) LINECOMMENT="// " ;;
	hash) LINECOMMENT="# " ;;
	lisp) LINECOMMENT=";; " ;;
	percent) LINECOMMENT="% " ;;
	dash) LINECOMMENT="-- " ;;
	basic) LINECOMMENT="' " ;;
	exclamation) LINECOMMENT="! " ;;
	html) LINECOMMENT="   - " ;;
esac

LINECOMMENT_LEN=${#LINECOMMENT}
CHARS_PER_LINE=`echo "80 - $LINECOMMENT_LEN" | bc`

# Print start of comment block
if [[ $STYLE == "c" ]]; then
	printf "/"; print_repeat '*' 79
	echo
fi
if [[ $STYLE == "html" ]]; then
	echo "<!-- "
fi
if [[ $STYLE == "ocaml" ]]; then
	echo "(* "
fi

# Print copyright notice
sed -n "s/<YEAR>/$YEAR/g; s/<COPYRIGHT HOLDER>/$AUTHOR/g; s/<PROGRAM NAME>/$PROG_NAME/g; p" $LICENCE |
	fold -w $CHARS_PER_LINE -s | awk "{print \"$LINECOMMENT\" \$0 ;}"

# Print end of comment block
if [[ $STYLE == "c" ]]; then
	print_repeat '*' 79; printf "/"
	echo
fi
if [[ $STYLE == "html" ]]; then
	echo " -->"
fi
if [[ $STYLE == "ocaml" ]]; then
	echo "*)"
fi


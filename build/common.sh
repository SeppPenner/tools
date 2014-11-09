#!/bin/sh

# Copyright (c) 2014 Franco Fichtner <franco@lastsummer.de>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

set -e

# build directories
export STAGEDIR="/usr/local/stage"
export IMAGESDIR="/tmp/images"
export SETSDIR="/tmp/sets"

# target files
export ISOPATH="${IMAGESDIR}/LiveCD.iso"

# code reositories
export SRCDIR="/usr/src"

# misc. foo
export CPUS=`sysctl kern.smp.cpus | awk '{ print $2 }'`

# print environment to showcase all of our variables
env

git_clear()
{
	# Reset the git repository into a known state by
	# enforcing a hard-reset to HEAD (so you keep your
	# selected commit, but no manual changes) and all
	# unknown files are cleared (so it looks like a
	# freshly cloned repository).

	echo -n ">>> Resetting ${1}... "

	# set used here to avoid errors when git isn't bootstrapped
	set +e
	git -C ${1} reset --hard HEAD
	git -C ${1} clean -xdqf .
	set -e
}

setup_base()
{
	echo ">>> Setting up world in ${1}"

	(cd ${1} && tar -Jxpf ${SETSDIR}/base.txz)
}

setup_kernel()
{
	echo ">>> Setting up kernel in ${1}"

	(cd ${1} && tar -Jxpf ${SETSDIR}/kernel.txz)
}

setup_stage()
{
	rm -rf "${1}" 2>/dev/null ||
	    (chflags -R noschg "${1}"; rm -rf "${1}" 2>/dev/null)
	mkdir -p "${1}"
}
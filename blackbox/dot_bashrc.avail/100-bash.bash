# Bash
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::


function l() {
  if [ -z "$1" ]; then
    ls -lhSt --color
  else
    ls -lhSt --color "$@"
  fi
}


function ll() {
  if [ -z "$1" ]; then
    ls -lht --color
  else
    ls -lht --color "$@"
  fi
}

function mroe() {
  if [ -z "$1" ]; then
    more
  else
    more "$@"
  fi
}


function la() {
  if [ -z "$1" ]; then
    ls -lat --color
  else
    ls -lat --color "$@"
  fi
}

function host-runtime() {
    if [ -f /proc/cpuinfo ] && grep -q '^flags.* hypervisor' /proc/cpuinfo; then
	echo "kernel"
    elif [ -f /proc/1/environ ] && grep -q 'container=lxc' /proc/1/environ; then
	echo "system"
    elif [ -f /.dockerenv ] || [ -f /.containerenv ]; then
	echo "process"
    else
	# Default case if none of the above are detected
	echo "kernel"
    fi
}

export HOST_RUNTIME=$(host-runtime)

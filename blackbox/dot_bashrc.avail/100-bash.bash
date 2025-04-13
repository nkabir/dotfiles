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

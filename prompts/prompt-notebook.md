# prompt notebook

Perform a code review of this ChezMoi repository. The "blackbox/dot_local/{gig,lib}" probably do not belong here?

  - .local/lib is documented as part of the intended structure, so blackbox/dot_local/lib does belong. .local/gig is not mentioned anywhere in docs; is it meant to be a public “module” like .local/lib, or should it move under .local/lib (e.g., lib/gig or lib/bitwarden) and be documented? docs/architecture/directory-structure.md, blackbox/dot_local/gig/bitwarden/core.bash

.local/gig should be a documented part of the structure under .local/gig

Perform 1, 2, and 3

---

How do I organize the ChezMoi repository so it can be forked from a shared base?


https://github.com/nkabir/dotfiles
https://github.com/cwiq-seed/dotfiles

# zsh-git-prompt a lightweight git prompt for zsh.
# Copyright © 2018 Wolfgang Popp
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

setopt PROMPT_SUBST
autoload -U colors
colors


: "${ZSH_THEME_GIT_PROMPT_PREFIX:="["}"
: "${ZSH_THEME_GIT_PROMPT_SUFFIX:="] "}"
: "${ZSH_THEME_GIT_PROMPT_SEPARATOR:="|"}"
: "${ZSH_THEME_GIT_PROMPT_BRANCH:="%{$fg_bold[magenta]%}"}"
: "${ZSH_THEME_GIT_PROMPT_BEHIND:="↓"}"
: "${ZSH_THEME_GIT_PROMPT_AHEAD:="↑"}"
: "${ZSH_THEME_GIT_PROMPT_UNMERGED:="%{$fg[red]%}✖"}"
: "${ZSH_THEME_GIT_PROMPT_STAGED:="%{$fg[red]%}●"}"
: "${ZSH_THEME_GIT_PROMPT_UNSTAGED:="%{$fg[blue]%}✚"}"
: "${ZSH_THEME_GIT_PROMPT_UNTRACKED:="…"}"
: "${ZSH_THEME_GIT_PROMPT_CLEAN:="%{$fg_bold[green]%}✔"}"


function gitprompt() {
    git status --branch --porcelain=v2 2>&1 | awk \
        -v PREFIX="$ZSH_THEME_GIT_PROMPT_PREFIX" \
        -v SUFFIX="$ZSH_THEME_GIT_PROMPT_SUFFIX" \
        -v SEPARATOR="$ZSH_THEME_GIT_PROMPT_SEPARATOR" \
        -v BRANCH="$ZSH_THEME_GIT_PROMPT_BRANCH" \
        -v BEHIND="$ZSH_THEME_GIT_PROMPT_BEHIND" \
        -v AHEAD="$ZSH_THEME_GIT_PROMPT_AHEAD" \
        -v UNMERGED="$ZSH_THEME_GIT_PROMPT_UNMERGED" \
        -v STAGED="$ZSH_THEME_GIT_PROMPT_STAGED" \
        -v UNSTAGED="$ZSH_THEME_GIT_PROMPT_UNSTAGED" \
        -v UNTRACKED="$ZSH_THEME_GIT_PROMPT_UNTRACKED" \
        -v CLEAN="$ZSH_THEME_GIT_PROMPT_CLEAN" \
        -v RC="%{$reset_color%}" \
        '
            BEGIN {
                ORS = "";

                fatal = 0;
                oid = "";
                head = "";
                ahead = 0;
                behind = 0;
                untracked = 0;
                unmerged = 0;
                staged = 0;
                unstaged = 0;
            }

            $1 == "fatal:" {
                fatal = 1;
            }

            $2 == "branch.oid" {
                oid = $3;
            }

            $2 == "branch.head" {
                head = $3;
            }

            $2 == "branch.ab" {
                ahead = $3;
                behind = $4;
            }

            $1 == "?" {
                ++untracked;
            }

            $1 == "u" {
                ++unmerged;
            }

            $1 == "1" || $1 == "2" {
                split($2, arr, "");
                if (arr[1] != ".") {
                    ++staged;
                }
                if (arr[2] != ".") {
                    ++unstaged;
                }
            }

            END {
                if (fatal == 1) {
                    exit(1);
                }

                print PREFIX;

                print BRANCH;
                if (head == "(detached)") {
                    print substr(oid, 0, 7);
                } else {
                    print head;
                }
                print RC;

                if (behind < 0) {
                    print BEHIND;
                    printf "%d", behind * -1;
                    print RC;
                }

                if (ahead > 0) {
                    print AHEAD
                    printf "%d", ahead;
                    print RC;
                }

                print SEPARATOR;

                if (unmerged > 0) {
                    print UNMERGED;
                    print unmerged;
                    print RC;
                }

                if (staged > 0) {
                    print STAGED;
                    print staged;
                    print RC;
                }

                if (unstaged > 0) {
                    print UNSTAGED;
                    print unstaged;
                    print RC;
                }

                if (untracked > 0) {
                    print UNTRACKED;
                    print untracked;
                    print RC;
                }

                if (unmerged == 0 && staged == 0 && unstaged == 0 && untracked == 0) {
                    print CLEAN;
                    print RC;
                }

                print SUFFIX;
            }
        '
}

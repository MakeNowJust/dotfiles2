#!/bin/zsh

# == プロンプト関連 ==
setopt prompt_subst

function rgb() {
  local red=$(( $1 * 6 / 256 ))
  local green=$(( $2 * 6 / 256 ))
  local blue=$(( $3 * 6 / 256 ))
  echo $(( red * 36 + green * 6 + blue + 16 ))
}
function color() {
  echo "%{"$'\e'"[38;5;${1}m%}"
}
function background() {
  echo "%{"$'\e'"[48;5;${1}m%}"
}
default_color="%{"$'\e'"[0m%}"

# プロンプトの設定
BGCOLOR=$(is_docker && echo "36" || echo "26")
PROMPT=$'\n'
# 1行目
PROMPT="$PROMPT%{"$'\e'"[48;5;%(?.$BGCOLOR.161)m%}$(color 15) %n@%M "
PROMPT="$PROMPT$(background 242) %? "
PROMPT="$PROMPT$(background 240) %D{%Y/%m/%d %H:%M:%S} "
PROMPT="$PROMPT$(background 238) %\$((\$COLUMNS - 55))<...<%~%<< ${default_color}"
# 2行目
PROMPT="$PROMPT"$'\n'"$(color 15)$(background 236) %# ${default_color} "
# 行継続時のプロンプト
PROMPT2="$(color 15)$(background 236) %_ ${default_color} "


# == ディレクトリ移動 ==

# cd時にpushdもする
setopt auto_pushd
# pushdの重複を無くす
setopt pushd_ignore_dups
# pushd、popd時の出力を無くす
setopt pushd_silent

# == 動作関連 ==

# ビープ音を鳴らさない
setopt no_beep
# !でヒストリを展開しない
setopt no_bang_hist
# 対話環境でもコメントを有効にする
setopt interactive_comments

# == 履歴関連 ==

# 履歴を保存するファイルの場所
export HISTFILE=$ZDOTDIR/.zsh_history
# メモリに保存される履歴の件数
export HISTSIZE=100000
# ファイルに保存される履歴の件数
export SAVEHIST=100000

# 重複を記録しない
setopt hist_ignore_dups
setopt hist_ignore_all_dups
# 実行時刻と終了時刻も保存する
setopt extended_history
# すぐにファイルに保存する
setopt inc_append_history
# スペースから始まる場合は履歴に保存しない
setopt hist_ignore_space
# 履歴の冗長なスペースを削除
setopt hist_reduce_blanks
# プロセス間で履歴を共有する
setopt share_history


# == エイリアス関連 ==

# clearよりclsの方が好き（DOS脳）
alias cls='clear'
# lsを色付け
alias ls='ls -F --color=auto'
# cd後にlsを実行
# （zshのフックで実行しないのは、読み込みが遅いディスクのときに
# \cdで無効にできるようにするため）
alias cd='(){ cd $@ && ls }'
# .. = popd
alias ..='popd'
# mkdirで深いディレクトリを掘れるようにする
alias mkdir='mkdir -p'
# mkdir + cd = take
alias take='(){ mkdir -p $1 && cd $1 }'
# echo, sudoのあとでエイリアスを有効にする
alias echo='echo '
alias sudo='sudo '
# 安全対策
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
# Copy to here!  Move to here!
alias ch='(){ cp $@ . }'
alias mh='(){ mv $@ . }'
# /bin/openとか使わないから
alias open='xdg-open'
# xclip使うとしたらこっちだよなぁ
alias xclip='xclip -selection clipboard'
# メモリのキャッシュを削除
alias cache_clear='sync && sudo sysctl -w vm.drop_caches=3'

# git系
alias gst='git status -s -b'
alias gcm='git commit'
alias gcmm='gcm -m'
alias gcma='gcm -a'
alias gcmam='gcm -am'
alias gad='git add'
alias gps='git push'
alias gpl='git pull'
alias gcl='git clone'
alias gclr='gcl --recursive'
alias gco='git checkout'
alias gcob='gco -b'
alias gbc='git branch'
alias gtag='git tag'
alias gdiff='git diff HEAD'
alias gm='git merge'
alias gmf='gm --ff-only'
alias ginit='git init'
alias ghelp='git help'
function gremote-github() {
  name=$1
  repo=$2

  if [[ -z "$name" ]]; then
    echo "gremote-github [name] <repo>" 1>&2
    return 1
  fi
  if [[ -z "$repo" ]]; then
    repo=$name
    name="origin"
  fi

  git remote add $name "https://github.com/${repo}.git"
}


# bindkey関連
bindkey -e
# Ctrl-Left/Rightでword単位で移動
bindkey ";5C" forward-word
bindkey ";5D" backward-word

# antigenの設定
if [[ -f $ZDOTDIR/antigen/antigen.zsh ]]; then
  # 読み込み
  source $ZDOTDIR/antigen/antigen.zsh

  # シンタックスハイライト
  antigen bundle zsh-users/zsh-syntax-highlighting

  # pecoを便利にする
  if type peco >&/dev/null; then
    antigen bundle mollifier/anyframe
    # Ctrl-hでヒストリを検索
    bindkey '^h' anyframe-widget-execute-history
    # Ctrl-hでヒストリを検索して、現在のテキストに挿入
    bindkey '^p' anyframe-widget-put-history
    # Ctrl-x gでghqのディレクトリ移動
    bindkey '^g' anyframe-widget-cd-ghq-repository
  fi
fi

# == 補完関連 ==
autoload -Uz compinit
compinit
if type npm >&/dev/null; then
  eval "$(npm completion)"
fi

# キャッシュを使う
zstyle ':completion::complete:*' use-cache true
# 上下左右で補完候補を選択する
zstyle ':completion:*:default' menu select=1
# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..
# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'
# LS_COLORSを設定する
eval "$(dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

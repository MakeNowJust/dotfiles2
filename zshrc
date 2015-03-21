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
BGCOLOR=$([[ -x /.dockerinit ]] && echo "36" || echo "26")
PROMPT=$'\n'
# 1行目
PROMPT="$PROMPT%{"$'\e'"[48;5;%(?.$BGCOLOR.161)m%}$(color 15) %n@%M "
PROMPT="$PROMPT$(background 242) %? "
PROMPT="$PROMPT$(background 240) %D{%Y/%m/%d %H:%M:%S} "
PROMPT="$PROMPT$(background 238) %\$((\$COLUMNS - 50))<...<%~%<< ${default_color}"
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

# == ヒストリ関連 ==

# ヒストリを保存するファイルの場所
export HISTFILE=$ZDOTDIR/.zsh_history
# メモリに保存されるヒストリの件数
export HISTSIZE=100000
# ファイルに保存されるヒストリの件数
export SAVEHIST=100000

# 重複を記録しない
setopt hist_ignore_dups
setopt hist_ignore_all_dups
# 実行時刻と終了時刻も保存する
setopt extended_history
# すぐにファイルに保存する
setopt inc_append_history
# スペースから始まる場合はヒストリに保存しない
setopt hist_ignore_space
# プロセス間でヒストリを共有する
setopt share_history


# == エイリアス関連 ==

# clearよりclsの方が好き（DOS脳）
alias cls='clear'
# lsを色付け
alias ls='ls -F --color'
# cd後にlsを実行
# （zshのフックで実行しないのは、読み込みが遅いディスクのときに
# \cdで無効にできるようにするため）
alias cd='(){ cd $1 && ls }'
# .. = popd
alias ..='popd'
# mkdirで深いディレクトリを掘れるようにする
alias mkdir='mkdir -p'
# mkdir + cd = take
alias take='(){ mkdir -p $1; cd $1 }'
# sudoのあとでエイリアスを有効にする
alias sudo='sudo '
# 安全対策
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'


# antigenの設定
# 読み込み
source "$ZDOTDIR/antigen/antigen.zsh"

# シンタックスハイライト
antigen bundle zsh-users/zsh-syntax-highlighting

# pecoを便利にする
antigen bundle mollifier/anyframe
# Ctrl-hでヒストリを検索
bindkey '^h' anyframe-widget-execute-history


# == 補完関連 ==
autoload -Uz compinit
compinit

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
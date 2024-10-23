#!/bin/bash

# -x: 実行したコマンドと引数も出力する
# -e: スクリプト内のコマンドが失敗したとき（終了ステータスが0以外）にスクリプトを直ちに終了する
# -E: '-e'オプションと組み合わせて使用し、サブシェルや関数内でエラーが発生した場合もスクリプトの実行を終了する
# -u: 未定義の変数を参照しようとしたときにエラーメッセージを表示してスクリプトを終了する
# -o pipefail: パイプラインの左辺のコマンドが失敗したときに右辺を実行せずスクリプトを終了する 
set -eEuo pipefail
# shopt -s inherit_errexit # '-e'オプションをサブシェルや関数内にも適用する

# このスクリプトがあるフォルダへカレントディレクトリを移動
cd "$(dirname "$0")"

user_name="sys"
user_pass="password"
# cdb_name="XE"
pdb_name="XEPDB1"

sqlplus ${user_name}/${user_pass}@${pdb_name} as sysdba << EOF
    SHUTDOWN IMMEDIATE;
    STARTUP NOMOUNT;
    EXIT;
EOF
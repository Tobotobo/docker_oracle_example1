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
cdb_name="XE"
pdb_name="XEPDB1"

rman target ${user_name}/${user_pass}@${cdb_name} << EOF
    RESTORE PLUGGABLE DATABASE ${pdb_name} FROM TAG 'TAG20241023T020442';
    RECOVER PLUGGABLE DATABASE ${pdb_name};
EOF




    # SET UNTIL TIME "TO_DATE('2024-10-23 1:00:00', 'YYYY-MM-DD HH24:MI:SS')"; 
    # RESTORE PLUGGABLE DATABASE ${pdb_name};
    # RECOVER PLUGGABLE DATABASE ${pdb_name};
# ALTER PLUGGABLE DATABASE ${pdb_name} OPEN RESETLOGS;
# rman target sys/password@xe
# RMAN> CATALOG START WITH '/backup/db_';

# using target database control file instead of recovery catalog
# searching for all files that match the pattern /backup/db_
# no files found to be unknown to the database
# →　既に登録されているよ

# rman target sys/password@xe
# CATALOG START WITH '/backup/db_';
# LIST BACKUP;
# CROSSCHECK BACKUP;
# DELETE EXPIRED BACKUP;
# SET DBID=3064196869;
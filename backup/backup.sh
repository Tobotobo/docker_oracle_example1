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

# sqlplus $user_name/$user_pass@$cdb_name as sysdba
# sqlplus $user_name/$user_pass as sysdba

# CDBに接続してPDBを停止およびマウント状態にする
sqlplus ${user_name}/${user_pass}@${pdb_name} as sysdba << EOF
    shutdown immediate;
    EXIT;
EOF


# PDBをバックアップ
rman target ${user_name}/${user_pass}@${pdb_name} << EOF
RUN {
    ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
    BACKUP DATABASE FORMAT '/backup/db_%U.bak';
    RELEASE CHANNEL c1;
}
EOF


# > /backup/backup_log.txt 2>&1

#!/bin/bash

# -x: 実行したコマンドと引数も出力する
# -e: スクリプト内のコマンドが失敗したとき（終了ステータスが0以外）にスクリプトを直ちに終了する
# -E: '-e'オプションと組み合わせて使用し、サブシェルや関数内でエラーが発生した場合もスクリプトの実行を終了する
# -u: 未定義の変数を参照しようとしたときにエラーメッセージを表示してスクリプトを終了する
# -o pipefail: パイプラインの左辺のコマンドが失敗したときに右辺を実行せずスクリプトを終了する 
set -eEuo pipefail
shopt -s inherit_errexit # '-e'オプションをサブシェルや関数内にも適用する

# スクリプトファイルがあるフォルダのパスを取得
SCRIPT_DIR=$(dirname "$(realpath "$BASH_SOURCE")")

# 引数からURLを取得
ZIP_URL=$1

# 一時フォルダを作成
TEMP_DIR=$(mktemp -d)

# 一時フォルダの作成が成功したか確認
if [[ ! "$TEMP_DIR" || ! -d "$TEMP_DIR" ]]; then
  echo "一時フォルダの作成に失敗しました"
  exit 1
fi

# エラーハンドリング
function cleanup {
  rm -rf "$TEMP_DIR"
}

# スクリプト終了時に一時フォルダを削除
trap cleanup EXIT

ZIP_FILE=${TEMP_DIR}/oracle.zip
OUTPUT_DIR=${SCRIPT_DIR}/dockerfiles

# ZIPファイルを一時フォルダにダウンロード
curl -L -o "${ZIP_FILE}" "${ZIP_URL}"

# ZIPファイルを一時フォルダに解凍
unzip "${ZIP_FILE}" "*/OracleDatabase/SingleInstance/dockerfiles/*" -d "$TEMP_DIR"

# 目的のディレクトリにファイルを移動
mkdir -p "${OUTPUT_DIR}"
mv "$TEMP_DIR"/*/OracleDatabase/SingleInstance/dockerfiles/* "${OUTPUT_DIR}/"

# 終了メッセージ
echo "ファイルの解凍と移動が完了しました"
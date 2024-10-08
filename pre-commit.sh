#! /usr/bin/env bash

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! command_exists git; then
  echo "ERRO: git não está no PATH."
  exit 1
fi

if ! command_exists mvn; then
  echo "ERRO: mvn não está no PATH."
  exit 1
fi 


POM_FILE="pom.xml"
echo "Checando diff no ${POM_FILE}"
DIFF=$(git diff ${POM_FILE})
SIZE_DIFF=${#DIFF}

if [ "$SIZE_DIFF" -ne "0" ]; then
  echo "ERRO: Existem mudanças não salvas no ${POM_FILE}."
  exit 1
fi

echo "Buscando a versão atual no  ${POM_FILE}."

VERSION=$(awk '/<project/,/<\/project>/' "${POM_FILE}" | grep -m1 -oP '(?<=<version>)[^<]+')

if [ -z "$VERSION" ]; then
  echo "ERRO: Não foi possível extrair a versão do  ${POM_FILE}."
  exit 1
fi

echo "Vesão atual: $VERSION"

MAJOR_VERSION=${VERSION%.*}
MINOR_VERSION=${VERSION##*.}
let NEW_MINOR_VERSION=MINOR_VERSION+1

NEW_VERSION="${MAJOR_VERSION}.${NEW_MINOR_VERSION}"

echo "Nova versão: $NEW_VERSION"

sed -i "0,/<version>$VERSION<\/version>/s//<version>$NEW_VERSION<\/version>/" ${POM_FILE}

git add ${POM_FILE}

echo "Vesão autalizada de $VERSION para $NEW_VERSION"

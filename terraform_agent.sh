#!/bin/bash

# 引数チェック
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <terraform_file.tf>"
    exit 1
fi

TF_FILE=$1

# ファイルの存在チェック
if [ ! -f "$TF_FILE" ]; then
    echo "Error: File $TF_FILE not found!"
    exit 1
fi

# .tf ファイルからリソース情報を抽出
RESOURCES=$(grep 'resource "' $TF_FILE | awk '{print $2 "." $3}' | sed 's/"//g')

if [ -z "$RESOURCES" ]; then
    echo "No resources found in $TF_FILE"
    exit 1
fi

echo "Found resources in $TF_FILE:"
echo "$RESOURCES"

TF_ARGS=$(echo $RESOURCES | tr " " ',')

echo "Choose action:"
echo "1) Apply"
echo "2) Destroy"
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        echo "Running terraform apply..."
        echo "terraform apply -target={$TF_ARGS}"
        ;;
    2)
        echo "Running terraform destroy..."
        echo "terraform destroy -target={$TF_ARGS}"
        ;;
    *)
        echo "Invalid choice! Exiting."
        exit 1
        ;;
esac

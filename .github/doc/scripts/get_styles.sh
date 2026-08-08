get_style () {
    echo "Installing $2 from $1 ..."
    wget -q "https://github.com/vale-cli/$2/releases/latest/download/$2.zip"
    unzip -q "$2.zip" -d styles && rm -f "$2.zip"
}

#styles=( Microsoft )
styles=( Google )
for i in "${styles[@]}"
do
	get_style "errata-ai" $i
done

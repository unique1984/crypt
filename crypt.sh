#!/bin/bash
#---------------------------------------------------------------------
# crypt.sh
#
# basit cryptolama konsol aracı
#
# Script: crypt.sh
# Version: 1.0.0
# Author: Yasin KARABULAK <yasinkarabulak@gmail.com>
#
# openssl ve tar kullanarak dosya/dizin cryptolama konsol aracı 
# geliştirme veya kullanma scripti kullanan kişinin sorumluluğundadır 
# ve çıkabilecek sorun kullanan kişiyi ilgilendirir yazarı değil.
#
#---------------------------------------------------------------------

#~ işlem encrypt mı? yoksa decrypt mi?
if [ -z "$1" ]; then
	echo "işlem seçin <e|d>"
	#~ e encrypt | d decrypt
	exit
fi

#~ crypto keyimiz ne?
if [ -z "$2" ]; then
	echo "cryptolama anahtarını girin.."
	exit
fi

#~ klasör veya dosya ismi girilmediyse
if [ -z "$3" ]; then
	echo "klasör veya dosya ismi girin"
	exit
fi

function parcala {
	#~ https://stackoverflow.com/questions/3362920/get-just-the-filename-from-a-path-in-a-bash-script?answertab=votes#tab-top
	FULL="$1"
	F_PATH=${FULL%/*}
	F_BASE=${FULL##*/}
	F_NAME=${F_BASE%.*}
	F_EXT=${F_BASE##*.}
	#~ echo $F_PATH
	#~ echo $F_BASE
	#~ echo $F_NAME
	#~ echo $F_EXT
	#~ exit
}

function tarla {
	#~ https://www.howtogeek.com/248780/how-to-compress-and-extract-files-using-the-tar-command-on-linux/
	parcala "$1"
	TARIH=$(date +"%Y%m%d%H%M%S")
	if [ -f "$1" ]; then
		TARLA=$TARIH"_"$(echo $F_BASE | awk '{gsub(/[ \/]/, "_", $0); print $0}').tgz
	elif [ -d "$1" ]; then
		TARLA=$TARIH"_"$(echo $1 | awk '{gsub(/[ \/]/, "_", $0); print $0}').tgz
	fi

	tar -cvzf "$TARLA" "$1"
	cryptola "$TARLA" "$2"
}

function cryptola {
	#~ echo "$1" "$2"
	#~ exit
	
	#~https://www.shellhacks.com/encrypt-decrypt-file-password-openssl/ 
	openssl enc -aes-256-cbc -salt -k "$2" -in "$1" -out "$1.enc"
	rm $1
}

function cryptocoz {
	parcala "$1"
	#~https://www.shellhacks.com/encrypt-decrypt-file-password-openssl/
	DECRYPT=$(openssl enc -aes-256-cbc -d -k "$2" -in "$1" -out "$F_NAME" 2>&1 | grep -o "bad decrypt:" | wc -l)
	if [ $DECRYPT = "1" ]; then
		echo "Şifre hatalı."
		exit
	fi
	tarac "$F_NAME"
}

function tarac {
	tar -xvzf "$1"
	rm "$1"
}

#~ işlem encrypt ise:
if [ $1 == "e" ]; then

	#~ eğer dosyaysa:
	if [ -f "$3" ]; then
		tarla "$3" "$2"
		echo "rm \"$3\" komutu ile \"$3\" dosyasını silebilirsiniz."
		
	#~ eğer klasörse:
	elif [ -d "$3" ]; then
		HEDEF=${3%/}
		tarla "$HEDEF" "$2"
		echo "rm -rf \"$3\" komutu ile \"$3\" klasörünü silebilirsiniz."
	#~ eğer girilen isimde birşey yoksa:
	else
		echo " '$3' klasör yada dosya bulunamadı !"
	fi

#~ işlem decrypt ise:
elif [ $1 == "d" ]; then
	cryptocoz "$3" "$2"
	echo "rm \"$3\" komutu ile cryptolu dosyayı silebilirsiniz."

#~ işlem tanımlanamadıysa.
else
	echo "söz dizimi hatalı!"
	echo "./crypt.sh < e | d > p455w0rd < dir/to/crypt/file.txt | dir/to/crypt >"
fi

#!/usr/bin/env bash

set +o history;

SHELL_STATE="$(set +o)";

set \
-o noclobber \
-o nounset \
-o pipefail;

PARAMETER="$(\
getopt \
--quiet \
--alternative \
--options v:n: \
--longoptions version:,npm: \
-- "$@"\
)";

[[ $? > 0 ]] && \
exit 1;

TARGET_VERSION=;
TARGET_NPM_VERSION=;

eval set -- "$PARAMETER";

while true;
do
	case "$1" in
		-v | --version )
			TARGET_VERSION=$2;
			shift 2
			;;
		-n | --npm )
			TARGET_NPM_VERSION=$2;
			shift 2
			;;
		-- )
			shift;
			break
			;;
		* )
			break
			;;
	esac
done

set +vx; eval "$SHELL_STATE";

#;	@section: setup mongodb version:

#;	@section: install needed module;
[[ ! -x /usr/bin/curl ]] && \
sudo apt-get install -y curl;

curl --version;

REPOSITORY_URI_PATH="https://raw.githubusercontent.com/volkovasystem/setup-mongodb-version/main";

if 		[[ 								\
				-f "setup-jq.sh"		\
			&&							\
				! -x $(which jq) 		\
		]]
	then
		source setup-jq.sh;
elif 	[[ 								\
				! -f "setup-jq.sh"		\
			&&							\
				-x $(which setup-jq)	\
			&&							\
				! -x $(which jq)		\
		]]
	then
		source setup-jq;
elif [[ ! -x $(which jq) ]]
	then
		source <(curl -sqL "$REPOSITORY_URI_PATH/setup-jq.sh");
else
		jq --version;
fi

if  	[[								\
				-f "setup-wget.sh"		\
			&&							\
				! -x $(which wget)		\
		]]
	then
		source setup-wget.sh;
elif 	[[								\
				! -f "setup-wget.sh"	\
			&&							\
				-x $(which setup-wget)	\
			&&							\
				! -x $(which wget)		\
		]]
	then
		source setup-wget;
elif [[ ! -x $(which wget) ]]
	then
		source <(curl -sqL "$REPOSITORY_URI_PATH/setup-wget.sh");
else
		wget --version;
fi

PLATFORM_ROOT_DIRECTORY_PATH="";
PRDP=""

#;	@section: set platform root directory;
[[ -z "$PLATFORM_ROOT_DIRECTORY_PATH" ]] && \
[[ $PLATFORM_ROOT_DIRECTORY_PATH == $PRDP ]] && \
PLATFORM_ROOT_DIRECTORY_PATH=$HOME;
PRDP=$PLATFORM_ROOT_DIRECTORY_PATH;

#;	@note: set mongodb version path namespace;
MONGODB_VERSION_PATH_NAMESPACE="mongodb-version";
MVPN=$MONGODB_VERSION_PATH_NAMESPACE;

#;	@note: set mongodb version path;
MONGODB_VERSION_PATH="$PRDP/$MVPN";
MVP=$MONGODB_VERSION_PATH;

#;	@note: set mongodb version;
CURRENT_MONGODB_LTS_VERSION="$(								\
wget -qO- https://mongodb.org/download/release/index.json | 	\
jq '.[] | select(.lts!=false) | .version' | 				\
grep -Eo '[0-9]+.[0-9]+.[0-9]+'|							\
head -n 1)";
MONGODB_VERSION="$TARGET_VERSION";
[[ -z "$MONGODB_VERSION" ]] && \
MONGODB_VERSION=$CURRENT_MONGODB_LTS_VERSION;
MV=$MONGODB_VERSION;

#;	@note: set mongodb package namespace;
MONGODB_PACKAGE_NAMESPACE="node-v$MV-linux-x64";
MPN=$MONGODB_PACKAGE_NAMESPACE;

#;	@note: set mongodb download URL path;
MONGODB_DOWNLOAD_URL_PATH="https://mongodb.org/dist/v$MV/$MPN.tar.gz";
NDUP=$MONGODB_DOWNLOAD_URL_PATH;

#;	@note: set mongodb package file path;
MONGODB_PACKAGE_FILE_PATH="$MVP/$MPN.tar.gz";
MPFP=$MONGODB_PACKAGE_FILE_PATH;

#;	@note: set mongodb package directory path;
MONGODB_PACKAGE_DIRECTORY_PATH="$MVP/$MPN";
MPDP=$MONGODB_PACKAGE_DIRECTORY_PATH;

#;	@note: initialize mongodb version directory;
[[ ! -d $MVP ]] && \
mkdir $MVP;

#;	@note: download mongodb package;
[[ ! -f $MPFP ]] && \
wget $NDUP -P $MVP;

#;	@note: extract mongodb package;
[[ ! -d $MPDP ]] && \
tar -xzvf $MPFP -C $MVP;

#;	@note: set mongodb path;
MONGODB_PATH="$(			\
ls -d $MVP/$(ls $MVP |	\
grep $MV |				\
grep -v "\.tar\.gz$"	\
) 2>/dev/null)/bin";
MP=$MONGODB_PATH;

#;	@note: clean mongodb binary path;
[[ $(echo $PATH | grep -oP $MVPN | head -1) == $MVPN ]] && \
export PATH="$(			\
echo $PATH |			\
tr ":" "\n" |			\
grep -v $MVPN |			\
tr "\n" ":" |			\
sed "s/:\{2,\}/:/g" |	\
sed "s/:$//")";

#;	@note: export mongodb binary path;
[[ $(echo $PATH | grep -oP $MP ) != $MP ]] && \
export PATH="$PATH:$MP";

echo "mongod@$(node --version)";
echo "mongo@$(npm --version)";

[[ ! -x $(which setup-mongodb-version) ]] && \
npm install @volkovasystem/setup-mongodb-version --yes --global;

#;	@section: setup mongodb version;

set -o history;

exec $SHELL -i;

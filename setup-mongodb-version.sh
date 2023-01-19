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
--options v:t:a:p: \
--longoptions version:,npm: \
-- "$@"\
)";

[[ $? > 0 ]] && \
exit 1;

TARGET_VERSION=;
TARGET_TOOL_VERSION=;
TARGET_ARCHITECTURE_VERSION=;
TARGET_PLATFORM_VERSION=;

eval set -- "$PARAMETER";

while true;
do
	case "$1" in
		-v | --version )
			TARGET_VERSION=$2;
			shift 2
			;;
		-t | --toolVersion )
			TARGET_TOOL_VERSION=$2;
			shift 2
			;;
		-a | --architectureVersion )
			TARGET_ARCHITECTURE_VERSION=$2;
			shift 2
			;;
		-p | --platformVersion )
			TARGET_PLATFORM_VERSION=$2;
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
elif	[[ ! -x $(which jq) ]]
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
elif	[[ ! -x $(which wget) ]]
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
CURRENT_MONGODB_STABLE_VERSION="$(							\
wget -qO- $REPOSITORY_URI_PATH/mongodb-version-list.json |	\
jq '.[] | select(.stable!=false) | .version' | 				\
grep -Eo '[0-9]+.[0-9]+.[0-9]+'|							\
head -n 1)";
MONGODB_VERSION="$TARGET_VERSION";
[[ -z "$MONGODB_VERSION" ]] && \
MONGODB_VERSION=$CURRENT_MONGODB_STABLE_VERSION;
MV=$MONGODB_VERSION;

#;	@note: set mongodb tool version;
CURRENT_MONGODB_TOOL_VERSION="$(									\
wget -qO- $REPOSITORY_URI_PATH/mongodb-tool-version-list.json | 	\
jq '.[] | select(.stable!=false) | .version' | 						\
grep -Eo '[0-9]+.[0-9]+.[0-9]+'|									\
head -n 1)";
MONGODB_TOOL_VERSION="$TARGET_TOOL_VERSION";
[[ -z "$MONGODB_TOOL_VERSION" ]] && \
MONGODB_TOOL_VERSION=$CURRENT_MONGODB_TOOL_VERSION;
MTV=$MONGODB_TOOL_VERSION;

MONGODB_ARCHITECTURE_VERSION="$TARGET_ARCHITECTURE_VERSION";
[[ -z "$MONGODB_ARCHITECTURE_VERSION" ]] && \
MONGODB_ARCHITECTURE_VERSION="x86_64";
MAV=$MONGODB_ARCHITECTURE_VERSION;

MONGODB_PLATFORM_VERSION="$TARGET_PLATFORM_VERSION";
[[ -z "$MONGODB_PLATFORM_VERSION" ]] && \
MONGODB_PLATFORM_VERSION="ubuntu2004";
MPV=$MONGODB_PLATFORM_VERSION;

#;	@note: set mongodb package namespace;
MONGODB_PACKAGE_NAMESPACE="mongodb-linux-$MAV-$MPV-$MV";
MPN=$MONGODB_PACKAGE_NAMESPACE;

#;	@note: set mongodb download URL path;
MONGODB_DOWNLOAD_URL_PATH="https://fastdl.mongodb.org/linux/$MPN.tgz";
MDUP=$MONGODB_DOWNLOAD_URL_PATH;

#;	@note: set mongodb package file path;
MONGODB_PACKAGE_FILE_PATH="$MVP/$MPN.tgz";
MPFP=$MONGODB_PACKAGE_FILE_PATH;

#;	@note: set mongodb package directory path;
MONGODB_PACKAGE_DIRECTORY_PATH="$MVP/$MPN";
MPDP=$MONGODB_PACKAGE_DIRECTORY_PATH;

#;	@note: initialize mongodb version directory;
[[ ! -d $MVP ]] && \
mkdir $MVP;

#;	@note: download mongodb package;
[[ ! -f $MPFP ]] && \
wget $MDUP -P $MVP;

#;	@note: extract mongodb package;
[[ ! -d $MPDP ]] && \
tar -xzvf $MPFP -C $MVP;

#;	@note: set mongodb path;
MONGODB_PATH="$(			\
ls -d $MVP/$(ls $MVP |		\
grep $MV |					\
grep -v "\.tgz$"			\
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

echo "mongod@$(mongod --version)";

[[ -x $(which mongo) ]] && \
echo "mongo@$(mongo --version)";

[[ -x $(which mongos) ]] && \
echo "mongos@$(mongos --version)";

if  	[[													\
				-f "setup-mongodb-tool-version.sh"			\
			&&												\
				! -x $(which mongodump)						\
		]]
	then
		source setup-mongodb-tool-version.sh				\
		-t $MTV												\
		-a $TARGET_ARCHITECTURE_VERSION						\
		-p $TARGET_PLATFORM_VERSION;
elif 	[[													\
				! -f "setup-mongodb-tool-version.sh"		\
			&&												\
				-x $(which setup-mongodb-tool-version)		\
			&&												\
				! -x $(which mongodump)						\
		]]
	then
		source setup-mongodb-tool-version					\
		-t $MTV												\
		-a $TARGET_ARCHITECTURE_VERSION						\
		-p $TARGET_PLATFORM_VERSION;
elif	[[ ! -x $(which mongodump) ]]
	then
		source <(curl -sqL "$REPOSITORY_URI_PATH/setup-mongodb-tool-version.sh") \
		-t $MTV												\
		-a $TARGET_ARCHITECTURE_VERSION						\
		-p $TARGET_PLATFORM_VERSION;
else
		wget --version;
fi

[[ ! -x $(which setup-mongodb-version) ]] && \
npm install @volkovasystem/setup-mongodb-version --yes --global;

#;	@section: setup mongodb version;

set -o history;

exec $SHELL -i;

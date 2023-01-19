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
--options t:a:p: \
--longoptions version:,npm: \
-- "$@"\
)";

[[ $? > 0 ]] && \
exit 1;

TARGET_TOOL_VERSION=;
TARGET_TOOL_ARCHITECTURE_VERSION=;
TARGET_TOOL_PLATFORM_VERSION=;

eval set -- "$PARAMETER";

while true;
do
	case "$1" in
		-t | --toolVersion )
			TARGET_TOOL_VERSION=$2;
			shift 2
			;;
		-a | --architectureVersion )
			TARGET_TOOL_ARCHITECTURE_VERSION=$2;
			shift 2
			;;
		-p | --platformVersion )
			TARGET_TOOL_PLATFORM_VERSION=$2;
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

#;	@section: setup mongodb tool version:

#;	@section: install needed module;
[[ ! -x /usr/bin/curl ]] && \
sudo apt-get install -y curl;

curl --version;

REPOSITORY_URI_PATH="https://raw.githubusercontent.com/volkovasystem/setup-mongodb-version/main";

if		[[ 								\
				-f "setup-jq.sh"		\
			&&							\
				! -x $(which jq) 		\
		]]
	then
		source setup-jq.sh;
elif	[[ 								\
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

if		[[								\
				-f "setup-wget.sh"		\
			&&							\
				! -x $(which wget)		\
		]]
	then
		source setup-wget.sh;
elif	[[								\
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

#;	@note: set mongodb tool version path;
MONGODB_TOOL_VERSION_PATH="$PRDP/$MVPN";
MTVP=$MONGODB_TOOL_VERSION_PATH;

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

MONGODB_TOOL_ARCHITECTURE_VERSION="$TARGET_TOOL_ARCHITECTURE_VERSION";
[[ -z "$MONGODB_TOOL_ARCHITECTURE_VERSION" ]] && \
MONGODB_TOOL_ARCHITECTURE_VERSION="x86_64";
MTAV=$MONGODB_TOOL_ARCHITECTURE_VERSION;

MONGODB_TOOL_PLATFORM_VERSION="$TARGET_TOOL_PLATFORM_VERSION";
[[ -z "$MONGODB_TOOL_PLATFORM_VERSION" ]] && \
MONGODB_TOOL_PLATFORM_VERSION="ubuntu2004";
MTPV=$MONGODB_TOOL_PLATFORM_VERSION;

#;	@note: set mongodb tool package namespace;
MONGODB_TOOL_PACKAGE_NAMESPACE="mongodb-database-tools-$MTPV-$MTAV-$MTV";
MTPN=$MONGODB_TOOL_PACKAGE_NAMESPACE;

#;	@note: set mongodb tool download URL path;
MONGODB_TOOL_DOWNLOAD_URL_PATH="https://fastdl.mongodb.org/tools/db/$MTPN.tgz";
MTDUP=$MONGODB_TOOL_DOWNLOAD_URL_PATH;

#;	@note: set mongodb tool package file path;
MONGODB_TOOL_PACKAGE_FILE_PATH="$MTVP/$MTPN.tgz";
MTPFP=$MONGODB_TOOL_PACKAGE_FILE_PATH;

#;	@note: set mongodb tool package directory path;
MONGODB_TOOL_PACKAGE_DIRECTORY_PATH="$MTVP/$MTPN";
MTPDP=$MONGODB_TOOL_PACKAGE_DIRECTORY_PATH;

#;	@note: initialize mongodb tool version directory;
[[ ! -d $MTVP ]] && \
mkdir $MTVP;

#;	@note: download mongodb tool package;
[[ ! -f $MTPFP ]] && \
wget $MTDUP -P $MTVP;

#;	@note: extract mongodb tool package;
[[ ! -d $MTPDP ]] && \
tar -xzvf $MTPFP -C $MTVP;

#;	@note: set mongodb tool path;
MONGODB_TOOL_PATH="$(		\
ls -d $MTVP/$(ls $MTVP |	\
grep $MTV |					\
grep -v "\.tgz$"			\
) 2>/dev/null)/bin";
MTP=$MONGODB_TOOL_PATH;

#;	@note: clean mongodb tool binary path;
[[ $(echo $PATH | grep -oP $MVPN | head -1) == $MVPN ]] && \
export PATH="$(				\
echo $PATH |				\
tr ":" "\n" |				\
grep -v $MVPN |				\
tr "\n" ":" |				\
sed "s/:\{2,\}/:/g" |		\
sed "s/:$//")";

#;	@note: export mongodb tool binary path;
[[ $(echo $PATH | grep -oP $MTP ) != $MTP ]] && \
export PATH="$PATH:$MTP";

echo "mongodump@$(mongodump --version)";
echo "mongorestore@$(mongorestore --version)";

#;	@section: setup mongodb tool version;

set -o history;

[[ $SHLVL -lt 2 ]] && \
exec $SHELL -i;

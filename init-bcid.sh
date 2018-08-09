#!/bin/sh

if [ ! -f "/bcid/.init" ]; then 
	echo -e " init-bcid.sh: Performing init..."

	# If there is no .init, this can be a new install
	# or an upgrade... in the second case, we want to do some cleanup to ensure
	# that the upgrade will go smooth
	
	rm -Rf /ChainCoin/lib && \
	mkdir /ChainCoin/conf
	
	# if a script was provided, we download it locally
	# then we run it before anything else starts
	if [ -n "${SCRIPT-}" ]; then
		filename=$(basename "$SCRIPT")
		wget "$SCRIPT" -O "/bcid-boot/scripts/$filename"
		chmod u+x "/bcid-boot/scripts/$filename"
		/bcid-boot/scripts/$filename
	fi  

	cd /
	
	# Now time to get the NRS client
	wget --no-check-certificate https://chainplatform.sgp1.digitaloceanspaces.com/ChainCoin.zip && \
	unzip ChainCoin.zip && \
	rm *.zip && \
	cd /ChainCoin && \
	rm -Rf *.exe src changelogs

	if [ -n "${PLUGINS-}" ]; then
		/bcid-boot/scripts/install-plugins.sh "$PLUGINS"
	else
		echo " PLUGINS not provided"
	fi  

	# We figure out what is the current db folder
	if [ "$NXTNET" = "main" ]; then
		DB="bcid_db"
	else
		DB="bcid_test_db"
	fi  

	# just to be sure :)
	echo " Database is $DB"

	# if we need to bootstrap, we do that first.
	# Warning, bootstrapping will delete the current blockchain.
	# $BLOCKCHAINDL must point to a zip that contains the nxt_db folder itself.
	if [ -n "${BLOCKCHAINDL-}" ] && [ ! -d "$DB" ]; then
		echo " init-bcid.sh: $DB not found, downloading blockchain from $BLOCKCHAINDL";
		wget "$BLOCKCHAINDL" && unzip *.zip && rm *.zip
		echo " init-bcid.sh: Blockchain download complete"
	else
		echo " BLOCKCHAINDL not provided"
	fi

	# linking of the config
	if [ "$NXTNET" = "main" ]; then
		echo " init-bcid.sh: Linking config to mainnet"
		cp /bcid-boot/conf/bcid-main.properties /bcid/conf/bcid.properties
	else
		echo " init-bcid.sh: Linking config to testnet"
		cp /bcid-boot/conf/bcid-test.properties /bcid/conf/bcid.properties
	fi  

	# if the admin password is defined in the ENV variable, we append to the config
	if [ -n "${ADMINPASSWD-}" ]; then
		echo -e "\bcid.adminPassword=${ADMINPASSWD-}" >> /bcid/conf/bcid.properties
	else
		echo " ADMINPASSWD not provided"
	fi

	# If we did all of that, we dump a file that will signal next time that we
	# should not run the init-script again
	touch /bcid/.init
else
	echo -e " init-bcid.sh: Init already done, skipping init."
fi
chmod u+x ./init-bcid.sh
cd /ChainCoin
chmod u+x ./run.sh
./run.sh

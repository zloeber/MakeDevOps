#!/bin/bash

readonly VERSION="0.3.1"
readonly DEFAULT_CIPHER="aes-256-ecb"

init_config() {
	local answer
	while [ 1 ]; do
		while [ -z "$SALT" ]; do
			echo -n "Generate a random salt? [Y/n] "
			read answer

			case "$answer" in
				n*|N*)
					echo -n "Shared salt as hex characters: "
					read SALT
					;;
				*)
					local md5=$(which md5 2>/dev/null || which md5sum 2>/dev/null)
                    SALT=$()
                    SALT=$(hexdump -n 16 -e '4/4 "%08X"' /dev/random | tr '[:upper:]' '[:lower:]')
					;;
			esac
            if [ $(echo "$SALT" | grep '[^a-f0-9]' | wc -l) -ne 0 ]; then
                echo "Error: non-hex characters in salt"
                unset -v SALT
            fi

		done

		while [ -z "$PASS" ]; do
			echo -n "Generate a random password? [Y/n]"
			read answer

			case "$answer" in
				n*|N*)
					echo -n "Enter your passphrase: "
					read PASS
					;;
				*)
					PASS=$(hexdump -n 16 -e '4/4 "%08X"' /dev/random | tr '[:upper:]' '[:lower:]')
					;;
			esac
		done

		while [ 1 ]; do
			echo -n "What encryption cipher do you want to use? [$DEFAULT_CIPHER] "
			read CIPHER
			[ -z "$CIPHER" ] && CIPHER="$DEFAULT_CIPHER"

			local exists
			exists=$(openssl list-cipher-commands | grep "$CIPHER")
			[ $? -eq 0 ] && break

			echo "Error: Cipher '$CIPHER' is not available"
		done

		echo -e "\nThis configuration will be stored:\n"
		echo "salt:   $SALT"
		echo "pass:   $PASS"
		echo "cipher: $CIPHER"
		echo -e -n "\nDoes this look right? [Y/n] "
		read answer

		case "$answer" in
			n*|N*)
				# Reconfigure
				unset -v SALT
				unset -v PASS
				unset -v CIPHER
				;;
			*)
				# Finished
				break
				;;
		esac
	done

	echo -n "Do you want to use .git/info/attributes? [Y/n] "
	read answer

	local attrs
	case "$answer" in
		n*|N*)
			attrs=".gitattributes"
			;;
		*)
			attrs=".git/info/attributes"
			;;
	esac

	local pattern
	echo -n "What files do you want encrypted? [*] "
	read pattern
	[ -z "$pattern" ] && pattern="*"

    _setup
}

_init() {
    eval `sed '/^ *#/d;s/:/ /;' < "$1" | while read key val; do echo "$key='$val'"; done`
    _setup
    git reset --hard HEAD
}

_setup() {
    _cryptcheck

    # Need a pattern
    if [ -z "$pattern" ]; then
        echo "Gitcrypt: filter pattern has not been configured"
        exit 1
    fi

    # Need a attr
    if [ -z "$pattern" ]; then
        echo "Gitcrypt: filter attr has not been configured"
        exit 1
    fi

    echo "$pattern filter=encrypt diff=encrypt" >> $attrs
    echo "[merge]" >> $attrs
    echo "    renormalize=true" >> $attrs

    # Encryption
    git config gitcrypt.salt "$SALT"
    git config gitcrypt.pass "$PASS"
    git config gitcrypt.cipher "$CIPHER"

    # Filters
    git config filter.encrypt.smudge "gitcrypt smudge"
    git config filter.encrypt.clean "gitcrypt clean"
    git config diff.encrypt.textconv "gitcrypt diff"

    echo "SALT: $SALT" > .git/gitcrypt
    echo "PASS: $PASS" >> .git/gitcrypt
    echo "CIPHER: $CIPHER" >> .git/gitcrypt
    echo "pattern: $pattern" >> .git/gitcrypt
    echo "attrs: $attrs" >> .git/gitcrypt

    echo "gitcrypt config has been saved to .git/gitcrypt"
}

_clean() {
    # Encrypt using OpenSSL
    openssl enc -base64 -$CIPHER -S "$SALT" -k "$PASS"
}

_smudge() {
    # If decryption fails, use `cat` instead
    openssl enc -d -base64 -$CIPHER -k "$PASS" 2> /dev/null || cat
}

_diff() {
    # If decryption fails, use `cat` instead
    openssl enc -d -base64 -$CIPHER -k "$PASS" -in "$1" 2> /dev/null || cat "$1"
}

_cryptcheck() {
    # Need a shared salt
    if [ -z "$SALT" ]; then
        echo "Gitcrypt: shared salt (gitcrypt.salt) has not been configured"
        exit 1
    fi

    # Need a secure passphrase
    if [ -z "$PASS" ]; then
        echo "Gitcrypt: secure passphrase (gitcrypt.pass) has not been configured"
        exit 1
    fi

}

case "$1" in
    clean|smudge|diff)
        # Need a shared salt
        SALT=$(git config gitcrypt.salt)

        # Need a secure passphrase
        PASS=$(git config gitcrypt.pass)

        # And a cipher mode
        CIPHER=$(git config gitcrypt.cipher)
        [ -z "$CIPHER" ] && CIPHER="$DEFAULT_CIPHER"

        _cryptcheck

        # Execute command
        _$1 "$2"
        ;;
    init)
        # Run setup commands
        if [ -z "$2" ]; then
            init_config
        else
            _$1 "$2"
        fi
        ;;
    version)
        # Show version
        echo "gitcrypt version $VERSION"
        ;;
    *)
        # Not a valid option
        if [ -z "$1" ]; then
            echo "Gitcrypt: available options: init, version"
        else
            echo "Gitcrypt: command does not exist: $1"
        fi
        exit 1
        ;;
esac
exit 0

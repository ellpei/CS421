#!/bin/sh
# This script was generated using Makeself 2.3.0

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="3585088958"
MD5="09eac6ea8727c5051a2ffc3a42b2f932"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"; export USER_PWD

label="Extracting calculator"
script="echo"
scriptargs="The initial files can be found in the newly created directory: calculator"
licensetxt=""
helpheader=''
targetdir="calculator"
filesizes="4021"
keep="y"
nooverwrite="n"
quiet="n"
nodiskspace="n"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    echo "$licensetxt"
    while true
    do
      MS_Printf "Please type y to accept, n otherwise: "
      read yn
      if test x"$yn" = xn; then
        keep=n
	eval $finish; exit 1
        break;
      elif test x"$yn" = xy; then
        break;
      fi
    done
  fi
}

MS_diskspace()
{
	(
	if test -d /usr/xpg4/bin; then
		PATH=/usr/xpg4/bin:$PATH
	fi
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd $@
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.3.0
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet		Do not print anything except error messages
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory
                        directory path can be either absolute or relative
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
	test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n 532 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				else
					test x"$verb" = xy && MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" = x"$crc"; then
				test x"$verb" = xy && MS_Printf " CRC checksums are OK." >&2
			else
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2;
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    else

		tar $1f - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 40 KB
	echo Compression: gzip
	echo Date of packaging: Thu Jan 30 18:41:39 CST 2020
	echo Built with Makeself version 2.3.0 on linux-gnu
	echo Build command was: "./makeself/makeself.sh \\
    \"--notemp\" \\
    \"../../questions/Functional_Programming-adts-code_haskell_autograded-calculator/calculator\" \\
    \"../../questions/Functional_Programming-adts-code_haskell_autograded-calculator/clientFilesQuestion/calculator.sh\" \\
    \"Extracting calculator\" \\
    \"echo\" \\
    \"The initial files can be found in the newly created directory: calculator\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"y" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\"calculator\"
	echo KEEP=y
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=40
	echo OLDSKIP=533
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 532 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 532 "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir=${2:-.}
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir=$TMPROOT/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp $tmpdir || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n 532 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 40 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
	MS_Printf "Uncompressing $label"
fi
res=3
if test x"$keep" = xn; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf $tmpdir; eval $finish; exit 15' 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace $tmpdir`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 40; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (40 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(PATH=/usr/xpg4/bin:$PATH; cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test x"$keep" = xn; then
    cd $TMPROOT
    /bin/rm -rf $tmpdir
fi
eval $finish; exit $res
�     �:ks�8���_ѫ\��X�~e����%��#yE9��T*�HH"�$hGss�����d{2�={��)�����j�z���vrtD['G��߼�j��O�O����|G�^����b�WOJ�����f5$Kd�����M��6���G;�����%�y�|�?><|J�'����[���+h����/�"�0B#��co��E|ՀM�4��=Ձ,�"�f<
n]��,N��ܿ�Ιۆ*�á%�媘z�'X�3c����)8����wP"EQ����C?���D������ȗ\D�L6'*N���xt�<�
T�"�!x��؋W4���Z_�!��%,�c	��Dƌ%��[�P9���k<�d���`�ҋ�I
�wW&�ZP��Y0BJ�Y_�1��%(������a��ר���2C]ٯ�N�/�7�����Gߦ�ͯb�U��0x�.%�t
u+�s3[[�;�=��%�G�GN$����?��KK�-�m5��Zu���?��>�h��{�ڃ_���{��^�fXt�~�h#"J��`�b�1�&mQ��q�[ `G�dG(E���kD�l9gH-bS�1��R����O��D�N���B$��zd�H1(�29��I�~���B5�X��V7ƚ)%~M�րa�l%�J����-�*��͌Xs�vvĉ�	��$�/�ڪ��D#|�0��HBȿo۳�N!���/ػ��{�|U�m8�
�7�m�嗬��{Z�,�ь�!�KI�d^��Z�U4�z�ԟh�75�!`ll~Er�3}rǒV㏀=���[��V�I�v�����3�b(�m�P!�F��z�)a������!=)b��&^���_�}|���Z-���G��]��-��t;yX��A{S�M��ղ�V�HV�"O6F��K∟p`�],�i,���o�&�)��"��r�|0`���X�s�>	����齷�E`�ł-��&'s)��i�1C�����"�L�4�fۜ���{3/X0#�>��-a����|Ĝ�p=|�t�k^*�"�aGu	Tԧ\V�?V�d_=�{��(D�\�|6�e�m�/q�(ԙ�Wkdc��00�jYf�崆��b|0�ƾf����� ��xײZM�0�B�<�Q<�՟ľAL-1x�B��N�¤@��%���f&�����u�3��2���Ћfi��K/�ea��h��LR�v�5̵Ś4Bq��\�\�"`f".L�⧘ɰ���-��X�5���Y�Y�YO@l��e��6��ʮ�f���l�Bm�k���V�|Ԍe��	��%�_���oRM&̘�!p�t���*�}��C�&���[[��`�ծ�O��(�l��E�\k|#�����:�98���i�a4�	P$�{/gE�q��+�1�Xf��`OY
&�\�����b�Œx���V s*0��L�<�����'h��P�*�-�u����n`iNИ��1�rD�cR>�H���bGr�,҂S�F��	�H���M��E<k��l~��_DS>Kc��a�lL�E�1��k1�G�ϧ���9�>H"o�̅"^Q��Đ�Ob����s����z���$�7$X" �K�T����	�bF���JG��%��c�O�*%�˞B(�u`�7:#�5����l��l�6�)P�`�ߚ��?%�J�<�ߠsKw�X��h`��+Xl�+OT1��>��mR�ƃB&�D(K�/�"M2�@c�Bbh{�]�)�f2��P�[JR9Z��e4nJP��TW�J�Zc*Dc����g�
�Bwb�~V
>�i�ujS�>&͙�f>����H 4��LZ���ğN'o�I�����d꿝6�r|�n5����߱dC�����(�����$�ԯ�a�ʥ��T>�L������x'�9�Y�-jio��aʿ�>E�_�>�n���Dd�`Un1wdZ���ik�Y/%O�r�D�MpҜ(�]��p��zqY�?��l��j��{��R�.�9Ӣ��X[�	{:J�	۲�e����0*Pɹ'���""��|7 �*�f��y.x�P
��wP3
�aN��g�-���ILCow^�2�K���k�Hk,A#���/�eS�/ԥGy.ytUؐ4f����ee?�`R���9��D���^mR���e�~N9�"4�KO�qR�J��4���v�\5��1���=���F���ǘ�*빦�Z�<�����D�4\�ʢ��"�4����m˗i�9�Ҍ��T�5�'��#2+�$�z
���q�����/Ǉj���'���Į4�*d���y�i��6?6H�)��s��� �KCt�(�ݣ�<qYȤ1�Y��"�e�P��c��*�S��T�v����g�|��k�''�������%Z7?ozp�U��N����P�Iz`Ɛc��2O\ɋӁ�:б�Gt�E)YR�'|���4" ���
zKcB��R_*: �\�<�r:וMZ0yj���7�IU�&�~`A��1�^Y�����L
��	�^.QB�GhʋfI��"\�=�I��%�bI9%�f��lMLFBA���aX�����k�.�
�h�,���rϰ(���%f
�����,I{`H0r ��d�g�ъ8A*VEƎ)�M���t����b���T�J	(SyOF���:1Xbu���yE��]��K�wp>��ڀ�����g����.m��?���\�z�ЅN������9���Q�8��:�O`����v]�y}� 2�>��G�����w�nzN��� ���q�wF6�բ�������%��9W��Z���i������ug8r�7W�!\����V�q�W�ݳpu\�v�e��j�Kc�o��2�pfÕ�9��i!�d���q���������^�]?P6��~�g8]�7�����\ k�oHUҽ��d�{s掜��Ȇ���������ܿ���Uºq���:jaD���a�>�q%3�?��Û�3��P�Q*Hc���p}bm�?R���}>^��?$y*IuH.J�;*��z(������ŕsa��6��Gǵk�*�% G-���5oˤ"��P�%��+E�s����΀Q�����Y�2����.�����~����lo��j��w������=�*z��j���_<���g~�;����w�_P�W|��[����`���w��e����.���P�^,��q�~�X��T��nak�CF�� ��.�ZK=��l���_�>e��X��Qe��Y��Y+=�t��~�:�/��T�yiWH�o +�
=|L���� �_�gm��zj�0M��գ���?Q�9c!�H))TP�X�L�'�	�Z��b_u��4°�#�_����KP��!�i��?���v�d���K���h#`ͽ)̘$s^x�t��~o�'��-��YfXqG��������¶Wx�-�\c���4ast�\Oշ�g�J����*�h���>�D�P�Jt`�{���a �h]_��!�J�Z��x�,���(ϗ�����D�M��6#����06��o��˂@D{��;B~K�2^�3� @��N��c���$�y��8��=1Q��Lꏹ�Fb���f��U�G$����POɢ��~�={�z�%)��,��Evy��:���,����J��B�n��gat���������2F$=�%���h�^ٯd�ݬe_����~i搭�-Bj�t�CqD�
yt�UҩQq��\���ˍ)������z3�KQꘫ���R���W!�X�N�7�VM���!�GF�T��%z�]5��5�]\��b��bk+[q��;��&��<�C��R�L��gfϊ���~�����hXש�,���ª�:/�)��:�x���i6�9���BC�ʙ(��`��Z�̶��I}
<N�7��
=���R�����k��k��k��k��k��k��k��k��k��k�j�o��� P  
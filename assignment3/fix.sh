#!/bin/sh
# This script was generated using Makeself 2.3.0

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="2125551633"
MD5="849cc670f6c77db914c1ad506cc53159"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"; export USER_PWD

label="Extracting fix"
script="echo"
scriptargs="The initial files can be found in the newly created directory: fix"
licensetxt=""
helpheader=''
targetdir="fix"
filesizes="4701"
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
	echo Uncompressed size: 48 KB
	echo Compression: gzip
	echo Date of packaging: Tue Jan 28 20:30:35 CST 2020
	echo Built with Makeself version 2.3.0 on linux-gnu
	echo Build command was: "./makeself/makeself.sh \\
    \"--notemp\" \\
    \"../../questions/Functional_Programming-higherOrderFunctions-code_haskell_autograded-fixpoint_activity/fix\" \\
    \"../../questions/Functional_Programming-higherOrderFunctions-code_haskell_autograded-fixpoint_activity/clientFilesQuestion/fix.sh\" \\
    \"Extracting fix\" \\
    \"echo\" \\
    \"The initial files can be found in the newly created directory: fix\""
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
	echo archdirname=\"fix\"
	echo KEEP=y
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=48
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
	MS_Printf "About to extract 48 KB in $tmpdir ... Proceed ? [Y/n] "
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
        if test "$leftspace" -lt 48; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (48 KB)" >&2
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
�     �[{s�8����8�jc�DJ���N�N�e[U����RS�1DB��!Hۚ{|��n�%;���ř�+�$<����_}�O���O�ը�o�^�O�rkM��6��f�Uŭ��5^�����ǌ�Z�$��_j'b��O�8�D�����۹n������?Z
ϙ�og����s���Z�-�W���+V����?�b)ㄍ�	���/ă��ؾ/�<�+D%�r�ty`=�ܹ��}��~����ww2�]��c?�Z�8Y�]/���u���ה��4>;�	w.���D¸b#�Z G��f��?пޱ�Ĭ��i�x"�U�V�r�pk���p���eQ���b��Ed{��߱���A��B�b�L(h|��u��R,IG���:�G9�O��җ�X�Q����4f�*z*�}ƣU2����+ݬ�Px"�d��WIˈQ�<d3JT� ��o��H\J��OD�dYk��1Oe:	�d�R���G��t�2O��cں��i�=��m~�ğvY���D
���Joҿen����f�p����벪	VM���jb�>��4
C���3���2P	���)M�|:�n��Y���;]jYA"������Kt�
���أ����c?��(؇������*"�p����~�~�W��)��y4�r�,���W*�������_�yʹ�C9cSg�����&�E(��}أ&j7_����߻sV|~����ݭ����Q�������y�`��� ���U�@�H�<�%`�bo�S���^[��H���b!#h��J!�I ���`!"��^� ��@[���u�� �3X{��#)��>�^�b." ���!���k�[bKZ�����I�T�r�(g�՝C��2��E�N���^��'�i0Kc�[������= �D��'%����%�F�����R�e{bĉtU@����U?�@�H��N$8V(�X �R��p3ZϸTN�Ex	�~�"�E�B9�H����6Y)���D�5��Q�y��j�mؕ#��nT���r܊S%Zc�+�^n����r��GA26�n�q��W
���:?�k�������"T	���4�tX$gKR�����;�ַ�&��]9`�r�Z�A�vŅ��ݺS�������[��g�!2���8��2.�2��@�!��@d��P>hi2���6S0�l?���2^Q�sL�,Ox��+�́�͙�S�(A�q����W4%<�����8ͼk�-�2CtE��,]�� a8�;c�VɄ˔�h���8o%��b
��y�+��g	�@́��
U� �>���N�2�`���`�n��z��͂#5fb��$�6��bx�	��ը��~��	i�V��5��H�	i뱫hMj5w��'�t:9�5[��8�N���^^�Y��ىo��~��6 �b����|��y�
�,����4�z�����=P���Bj]��3�<�����2,����1o�I�`Δ)��I��	�e����yh�F��_���i �H�K�̡�Z�D,lXX�,�SArů)�6.	f�͗CXeH�%���e屆�8���M�lS�f6�Vݗ���v{?��:���+��7�S�������V�I�
5�4D!?���V6��fA��x<l�ܬ�(��\�i�A������w'����S�� ��YNd~����3p'
aiG���A$㢒�b0y���٘���T���umM�&B����_��;��G�o������x�i5w��%��\���H�����}�U+Պe����	�q���X�P����$M2Ԋ�?l��a�$�x�"� ���h?e�X��ROh�D�a)b�4�#B���[ �V~���i!��E��o�&W�v͎'a]_���d�'����-$@���I���LqP�����^ȃb��p#��qb��'��r��~f�5K�<?A�2�B���/b��T�wC�LF���2�E@ݱA�� `mˍp�ɪ�4`.e���X�t�	�tz �2��(��f�s	��z��&����hb	P/F犴�)}D�����:�.�������i��d�.;\��/��bpy��X�
���w|3G�^g=�����Ⱥ�~=�Fl0d������N��J��?��9���K��`l]��zch6�hЧ����]u�'�sܻ�?�xg�q�:���ǽ���ΐ]���.C�N{���N�{���0"����ltѹ�ܔ�|�w��zQDv�e����e"!O{����Y;�{�%kt�=���Ed�?��Q�o7�*�i�s��E#`���a�
Y5�n�G���f�e��)�y����l�Wv9��nFݒu�wh` ��j�~|3��z�qw8����0��
�؁����AE���(�t_b.�P>D}��:��h�d\l���ZF��_�λ��.��ʇި{ �ꍰA���Ø7$2����k�aKdH�;c���=d�4ӏz�MHe'Fݎ�y�{�8��������W��.��e������e|���B�GۿZs;��`�4���{�~c�t:@/JF"1?��#};��qV���L�F�Z
ә�c���,˲�<�m��=�ɜ+�F4<������<ł�����<��L�Qo����G�Gt�H�$X�ዙ����|_C�)p �L芽�3srf��f �Z�}e�4��*�y��R�ș��HH@5���&���:�>r��Z^�1��#`�Ձ	�g��=�l�Hj�����r���3/c�F���	��{%�-��`X���cJ�j: ��BVH*�: �f�"x<�KDI~qop(WǤ#��/�^�++ �����������?�x|����W�����n���쾾u�J��:*����` ��̅0�G��r���bũU�J��bX�Kt%�2�3������Q��5��ieڪ��)��Qk:��j-Q�5�ͺ{X�MG�IsZ�G��k��N����f{+UNY���8.�X�|��8��%�]�DZ�����Uoxσ�"�0���F{�DO�ױ��B�h��B,AO٨���5Igv,pU��ӯZXz-���7^�y��I������oA��#���/�ڦ���Z�ǣ�ZVh��`��Z��6�FL�ۏ��X��Z��P�&|��,����dY�5jF
�́cCM�/,Q���5x��<^A/�4�okHdxaѵ�v�5O��gM,�2Yt�M�xߴt�6�����]�i������00+�d�Î��&,nU& d�����B����sZm����n��\/�1Hp+�U������Ad�^&��ӌ��b��fv2Gg������f&����N5��`���芤�f���ڿ"-�YT�?��?����`Z���W��jO���������D)[(h���8����E����p�Wqq���;��"�6R�޵x�7��S[��2d��� �5J�F���&��{T�Cl�ս'xU7}��Y�bN��8�-���]��c���L=�1~���0�G�f
QvK$�*Pҍ�xKV8e��VG �bpv��1Aƒ�{��O�!�K�1��� /����`("sY��$o�&�Jq8��SL ��@��`|�.�����������t��]M���,W�I��>V���UL}D;��2��9�GdYĭ�oR`��,$�$ᥔ8jr�4Іb�S#�'�	_KCt��l�=|�4�E m��5�^��.�ֺbS���9��
�>0h<+����!�`K�m	����Oy/r�3骭���9���9������i������_�R��U�����xl۶�b�Z�D}��K�{8
�{9-��I��o������ؖV]=�� �k����Ѿ����,��K�a��3�1�¢�!LQ�MD_���KC�H��:��֓�MR0Rd�{��/c�{ �b:fI'�h� 0��t>R$Y(aw�Mb�c�=gƄU��co)���Q���G�[�0�(Y��C��L��ƍVǧ�f��HQ���*������"'ā�4Q���[����ϼ�yk�0Fcm��ձ�u`�r����m����3�q
l?HZ5��V
�r[@R����F4�d/�#`�ț[��ƕ���!n@64�)^+��gB[|I��yV���h,RvQ\F+�c��o �¨op�lDqEkC+J���2oe�|���y�.�$�u�^�~@�x��PU��|����'z�VӹP8B+��b�$f��('�I�$�4�VC���X�_��},^����(p)�V:r���'��~�<4�ph�[��1���'�N����J{*���O*�M��\�����������Ll{(�Fp��b��CLG��.@�o��I&u���67L%N.ж���[��o��%	��im�÷��·/�X,��f����<�ыԛ*<��:,h�m�ܒVa��*��Jn��%�Zrk%�^r���ګw�յ�j�)�C4��Ŝ$^�V����+����0r��Z��2��tJ�C�w�|Q���4��J?�%\g�JA+��Rg�cX�=_��#ll��<ܮ�`�]����=�g�|����� P  
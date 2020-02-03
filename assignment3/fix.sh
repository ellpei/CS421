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
‹     í[{sÛ8’Ïßü8§jcçDJÔÓÖN¦N¶e[U¶ä•ääRS©1DBÇ¡!HÛš{|öën€%;ÉìíÅ™›+±$<ığºé”_}ó§O«ÑÀO·Õ¨Ğo·^§Oó¼rkM·î6›­fëUÅ­Ôáƒ5^½À“ª„ÇŒ½Zğ$‘_j'bõêO÷8åD¨¤ü‡±Û¹n½ÖÜÙÿí?Z
Ï™«ogÿ¦¶÷sö¯ÖZ-ûW›­Ú+VÙÙÿ›?Áb)ã„Á	œ³˜/ÄƒŒïØ¾/¦<“+D%†rËty`=ÛÜ¹å}àƒ~œ¿¥ww2Ş]•íc?¨ZŠ8Yå]/ƒÉ•u¬ø×”‡Á4>;å	w.¸šDÂ¸b#ËZ G¬İf½Û?Ğ¿Ş±·Ä¬²¬iğx"ÔUœVí¨rØpkµªÛp›•–eQ¨ûÉbæÉEd{ïÎß±³à‘A÷½B‹bËL(h|ıuÂ¾R,IGê™÷Ø:œG9½Où·Ò—¸XÜQÁïãÄ4f¾*z*ó}Æ£U2¢¡š“+İ¬çPx"¢dÍÊWIËˆQ<d3JTà ºõoïËH\JÁÈODşdYk… 1Oe:	³dÇR†ÅÊGöÎtƒ2O—¼cÚºšÌiÈ=àÈm~äÄŸvY€¢ØD
üıüJoÒ¿en¥Âşşf¢p¬å¦òèë²ª	VM­ÒjbÄ>ÛÏ4
C°ı‘3åâ2P	û‰¿)MŞ|: nàÑY·µ;]jYA"â‚ÄûÿòúKt‹
›¢êØ£ş™Ÿôc?²İ(Ø‡²ƒ¥¬øÂ*"Æpˆÿ~§~­W»Ç)ŸÌy4—ræ,üï²ÿW*§û­²Ûÿ_âyÍ´ıC9cSgÛçë×ì&ŠE(¸‚}Ø£&j7_şŒóüß»sV|~Ëóßæİ­´¶ç½QİÍÿ—™ÿãy `Çüõ ›§‰UÃ@¼HÄ<%`²boÈSş½±^[¯ÙHöóäb!#h›âJ!—I Ïù½`!"À¢^º ˆ•@[Ã…ûu’ì ­3X{¸Ï#)À­>¶^Æb." ¹ŒÇ!˜œk°[bKZª˜¢ÔæI²Tírº(gÎÕCíç2•E„Nˆ³Œ^ÿ³'£i0Kc¢[†µ…’á= DÂÚ'%²âÃÎ%ŞF¤ø†‹øRÍeÂ{bÄ‰tU@åê¬ÛÄU?ğ@¡H€íN$8V(ÀX äR¥€p3ZÏ¸TNûEx	œ~–"òEäB9¤HñÈ 6Y)¶ÍÂDÙ5§±Q³y®ìjÅmØ•#»ênTÏæİrÜŠS%Zcà+”^n¾–Îãr·ÔGA26×n¥qè°¹W
¬ˆâ:?ÓkŒ™§Äæ"T	¤ˆ¿4ötX$gKR§ìÁ¼–;Ö·&™‹]9`‡rÖZ•A‡vÅ…ºç¦İºS­¢£ÜÀ¢[ÈØg’!2ÄŞó8©2.ª2‘ı@è!Òó@dƒúP>hi2²èÏ6S0×l?ˆÁà2^QÑsL¥,Oxÿ³+˜ÍÕÍ™ıSé(AıqªÛéÒW4%<°ÖÃÚ¥8Í¼kµ-è2CtEÀÕ,]ª´ a8œ;cVÉ„Ë”çh‚Ù³8o%•Äb
¶…y³+ …g	Â@Í¼™
Uö Ó>èôN±2Œ`ƒïÌ`µn¹¢z—œÍ‚#5fbˆÇ$æ6Ì£bîŠxÚ	…íÕ¨¬~ÌÓ	išV²Ù5ë‹ÙH¡	ië±«hMj5wêÖ'Şt:9¬5[ß8œN¦Şá¤^^«Y¯ÂÙ‰o³Ä~ú„6 ©b˜Ù›†|Æîy˜
ò,šáÚ4¸z¬© ¦ =PûÿBj]¬É3°<ŸÀª‰Ë2,«°°Ã1oÊI`Î”)°ıIÎÛ	ôŠeˆ“ÌƒyhåF“Ÿ_œàÏi ìHíKÌ¡“Z©D,lXXÚ,‰SArÅ¯)ø6.	f‘Í—CXeH±% üeå±†¤8¥©¯M­lSİf6Vİ—Ôöùv{?¾«:î±‘+ùå±7‡S¨—¤±™´°V±I
5Ó4D!?€°òV6èÚfAí°™ÿx<lşÜ¬Ó(ÚÙ\Æi°A¬Š‹ˆw'™úƒÈSŸ– ÔµYNd~Ê…Áä3p'
aiGâÖA$ã¢’Ñb0yµ­ò…Ù˜ƒíT¶‡·umMÈ&B»“Áÿ_üÙ;éöGİoÿùÒı«Ùxÿi5wøÿ%¹\Åµ®Hìæö–}ï€U+ÕŠeÁÂÁ¨	Şqƒî…ïXÖPøìùÁ$M2ÔŠ‹?lù›aÉ$ˆx¼"¤ ÄÁî‰h?ešXéãROh²D a)bØ4ñ¬#Béã†[ ìV~ ÏØi!’¶E—€oÙ&WŠvÍ'a]_€µñ¢dÂ'ò«ŒÌ-$@—ÀĞI”¯LqPƒĞ×Á ^ÈƒbœÏp#´‘qbú©'ÖÌr–ş~f…5KÛ<?A¿2ØBÒÎÎ/bØÏT®wC…LFÂä2öE@İ±A„ `mËp—ÉªÉ4`.e¤‰ÊX«tĞ	¥tz 2¡³(ÜĞfïs	€’z”œ&èÆÃÖhb	P/FçŠ´›)}D³Æ½ÎÆ:Ã.ƒï×ÃÁûŞi÷”dã‹.;\öÎ/ÆìbpyÚX§
¥ıñ°w|3GÖ^g=÷¨¢ÓÿÈºÿ~=ìFl0d½«ëËêÃNÜëJ¬×?¹¼9íõÏK°ş`l]ö®zch6”hĞ§İØàŒ]u‡'ğ³sÜ»ì?Òxg½qÇ:­»îÇ½“›ËÎ]ß¯£.C±N{£“ËNïª{êÀè0"ë¾ïöÇltÑ¹¼Ü”Ò|èw‡ÈzQDvÜe—½Îñe"!O{ÃîÉ¥Y;Å{—%ktİ=éÁĞEdé?–ÍQ÷o7Ğ*Ùiçªs¢íE#`’“›a÷
Y5ŒnGãŞøfÜeçƒÁ)éyÔ¾‡lôWv9‘²nFİ’uÚwh` š‚jø~|3ê‘Îzıqw8¼¹÷ı0ïĞ
ğØ®§¤ÜAEé†‘(ê€t_b.ºP>D}’¦:¨‚hìd\lãÇÖZFÖï_öÎ»ı“.ÖÊ‡Ş¨{ ¦ê°A†ãÃ˜7$2š¸²èkÁaKdHÖ;cÓ÷=dÛ4ÓzÆMHe'Fİµyÿ{ß8èïÉÿ¨µê¸ÿW¡Ù.ÿãeîÁş—Áä›e|ÿ¹ÕBüGÛ¿Zs;ü÷`°4”•{é~c¶t:@/JF"1?¦Á#};Ğ×qV–°ñLšF²Z
Ó™½c£¼Š,Ë²í<”mãË=ìÉœ+©F4<»ş¡ ã’<Å‚±Ô ÍÃ<ğæLÀQo¨‚¸ØGšGt½HÃ$X†á‹™¾² ±|_CÄ)p ŸLèŠ½…3srfİÊf ¹Zª}eÈ4ôÙ*ğyÂâRóÈ™õÛHH@5äßò&™ğç:Î>rÒÁZ^º1üş#`°Õ	¤gş“=²lèšHj¶ÖàêÙr„ƒ 3/cšFÆå	¿Ã{%Ğ-æû`Xş‘ícJÉj: ‹óBVH*”: Åfæ"x<ÚKDI~qop(WÇ¤#¤‘/¦^Ş++ î¶£·ı‹µ‹×³ü?åx|ÂÃï³şWëÍæ“øÿnı™‡ì¾¾u·JËÁ:*˜¯Ÿë` ¸Ì…0ÅGğòrùbÅ©UJ¶ŠbXî¹Kt%Ã2õ3íğ¦¾ÍÃúQµé5‡•ieÚªòÃ)øËQk:­´j-Q­5§Íº{X¯MGÕIsZãG¼Âkğ§êN¦ËÂÓf{+UNY¹”æ©8.°X±|¡¼8 È%Õ]ç±DZ©†İÎéUoxÏƒä"0°F{ĞDO¨×±àşBühÍåB,AOÙ¨¿³£5Igv,pUíßÓ¯ZXz-ÂÑ7^¿y§ŒI¼ş¦‰¦ñoA‘”#üÔÊ/¼Ú¦ˆÔZÉÇ£ÓZVh£ß`¹Z´è6ÛFL ÛŒÂXúÒZßÏPÕ&|¡î,ô¿˜ŸdY¦5jF
ƒÍcCM£/,Q¶¿ª5xÄ<^A/ñ4…okHdxaÑµÅvÕ5OæêgM,¤2Yt”M·xß´t¤6¯ÂØûñ]İi±¿ü…ıĞ00+dìÃçÛ&,nU& d‡ ”êBª·¢sZm•‰ĞŞnãß\/â1Hp+µUâÒ¿·ĞöAdà^&ûûÓŒ†ñb“Ğfv2GgÆİ¼Š³ñf&ûõÎîN5…¬`­”ÏèŠ¤f‰ÈÏÚ¿"-ŠYTÔ?¢í?ÓşË`ZßéüW©ÔjOòê»üÿ—±¿‡âD)[(h½ıï8ş§ÀÿE÷ğ­pÿWqqş·ª;üÿ"Ï6RÎŞµx–7³†S[ıö2dİ÷ Ä5JÜF¨ºó&¾Ü{T‹ClÀÕ½'xU7}µîYÏbN»€8í-¼ùš]‰„c¦ŒL=Ì1~¤³“0òG—f
QvK$—*PÒæxKV8eàÈVG ¬bpv£ã1AÆ’ñ{øÌO—!ÆK1âÑ /ÀÄõ`("sYôÎ$o„&ÖJq8±˜SL Øø@âà`|—.¢ÂÚè¨ïŞ“²ÀtÉô]MŠìê,W¢IêÜ>V±ÿó³•UL}D;”È2˜È9ÀGdYÄ­˜oR`”÷,$¤$á¥”8jrè4Ğ†bıS#ê'³	_KCt­›lğ=|¹4ÕE mŠì5^—½.ØÖºbS¼¬±9úĞ
½>0h<+Æúğ!Ì`K†m	¶øÿ÷Oy/rş3éª­ãƒıÜ9ÁşÒ9ÁúçÙÿóiû½òêµÂş_¯Rü¯U«ïöÿ—xlÛ¶ğbàZïD}‚ÜK‚{8
…{9-õ–IŸôo–¡äş¬ğØ–V]=´’ ÁkŸ½³àÑ¾¦í¡£é¬ö,Æ¥K¼aÁ­3€1üÂ¢ö!LQMD_øóĞKCHœ™:ûçÖ“ê–MR0RdÉ{ºÁ/cİ{ —b:fI'›h¢ 0ÇÍt>R$Y(awMb¹cÑ=gÆ„U¼Íco)“††QÆ†ĞG˜[š0¥(YôÆCŞöLÌØÆVÇ§„fÇäHQºŠò*àÁúˆ‚ÿ"'Ä¤4QˆÁ°[Œ´ÛÏ¼Üykò£0Fcmô¸Õ±­u`†r†Ùíãmé‹Á‹¢3çq
l?HZ5ÙƒV
”r[@RÊÅÃ×F4»d/Ä#`´È›[ ‰Æ•´µ˜!n@64Ğ)^+†½gB[|Iï¯yVú€Şh,RvQ\F+ªcˆÁo ñÂ¨opælDqEkC+J«Ä¥2oe|Šó¸¡yí.Ç$’u¬^~@ïxØPU‰Ê|©š¬'z‹VÓ¹P8B+ïbÆ$féÁ('…I£$‰4¥VCù•æX§_ø†},^ıÕ¤(p)’V:r‰•›'Ã~Á<4íph¶[‹È1˜ªß'«NÀ‘ïøJ{*¾¸€O*œMò™½\½¸™ˆ„¯®™°Ll{(á„Fp™b’©CLGƒÑ.@¥o”I&uŸô¶67L%N.Ğ¶¬ÛÛ[“Šo½…%	—¥imÊÃ·­çÂ·/ÿX,”ê¥féèûÃ<íÑ‹Ô›*<øŞ:,hÏm–Ü’Va”Ø*–Jn¥äº%·Zrk%·^rŸşÈÚ«wíÕµÖj¨)œC4ÇñÅœ$^á¼V…¹·¢+œâ‚û½0r«ßZˆÅ2¼ÅtJ³CèwÛ|Q¢Ã4ÂÜJ?˜%\gàJA+¦RgŠcX…=_‡Ü#llŒ·<Ü®ó˜`„]ªÀîÙ=»g÷|åùóúƒ P  
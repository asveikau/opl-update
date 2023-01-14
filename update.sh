#!/bin/sh

mkdir -p PSX PS2

if [ ! -d out/POPS ]; then
   # Copy POPS into POPS-tmp.  Temp location followed by mv is for atomicity if the script is
   # interrupted.
   rm -rf out/POPS-tmp
   mkdir -p out/POPS-tmp
   cp submodules/POPS-binaries/* out/POPS-tmp
   cp third-party/popstarter/* out/POPS-tmp
   mv out/POPS-tmp out/POPS
fi

gmake -C submodules/cue2pops clean all 

cd PSX
for cuefile in *.cue; do 
   echo $cuefile
   gameid=""
   grep ^FILE\ \" "$cuefile" | sed s/^FILE\ \"// | sed s/\"\ BINARY.*$// | while read binfile; do
      # Hacky way to parse gameid straight from the ISO, without proper parsing.
      # One advantage is this doesn't require loopback mounting (so you don't need to be root, and it's
      # quite portable.)
      gameid="`head -c $((4*1024*1024)) "$binfile" | strings | grep BOOT | sed -z s/.*cdrom:'\\\\'// | sed s/\;.*$//`"
      if [ "$gameid" != "" ]; then
         echo $gameid
         filename=../out/POPS/"$gameid.`echo $cuefile | sed s/cue$/vcd/`"
         if [ -f "$filename" ]; then
            break;
         fi
         ../submodules/cue2pops/cue2pops "$cuefile" ../out/POPS/"$gameid `echo $cuefile | sed s/cue$/vcd/`"
         break;
      fi
   done
done
cd ..

gmake -C submodules/iso2opl clean all 

for isofile in PS2/*.iso; do
   gameid="`head -c $((10*1024*1024)) "$isofile" | strings | grep BOOT2 | sed -z s/.*cdrom0:'\\\\'// | sed s/\;.*$//`"
   if [ "$gameid" != "" ]; then
      echo $gameid
      if [ `ls out/ul*.$gameid.* 2>/dev/null | wc -l` != 0 ]; then
         continue
      fi 
      submodules/iso2opl/iso2opl "$isofile" out "`echo $isofile | cut -d / -f 2- | sed s/\.iso$// | fold -w 32 | head -n 1`" DVD
   fi
done

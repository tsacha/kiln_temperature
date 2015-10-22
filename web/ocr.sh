i=0;
# Écoute de modifications du snapshot de la webcam
prev1=-1
prev2=-1
last_date=-1
while inotifywait -e close_write output1.jpg; do
  set -o allexport
  source params.txt
  set +o allexport  
  # Évite de flinguer le système en cas d'une méchante requête POST
  echo $cropH | grep -Eo "^[0-9]{1,4}x[0-9]{1,4}\+[0-9]{1,4}\+[0-9]{1,4}"
  if [ ! $? -eq 0 ]; then
    cropH=0;
  fi
  echo $cropV | grep -Eo "^[0-9]{1,4}x[0-9]{1,4}\+[0-9]{1,4}\+[0-9]{1,4}"
  if [ ! $? -eq 0 ]; then
    cropV=0;
  fi
  echo $threshold | grep -Eo "^[0-9]{1,3}"
  if [ ! $? -eq 0 ]; then
    threshold=95;
  fi
  echo $shear | grep -Eo "^-?[0-9]{1,3},-?[0-9]{1,3}"
  if [ ! $? -eq 0 ]; then
    shear=0,0;
  fi  
  # crop + seuil n/b + fond noir pour l'étirement + étirement | nb digits variable, input fond noir texte blanc | parser que les nbs
  convert output1.jpg -crop $cropH -threshold $threshold% -background black -shear $shear data1.jpg
  convert output1.jpg -crop $cropV -threshold $threshold% -background black -shear $shear data2.jpg
  data1=$(./ssocr-2.16.3/ssocr -d -1 -b black -f white data1.jpg | grep -Eo "[0-9]+")
  data2=$(./ssocr-2.16.3/ssocr -d -1 -b black -f white data2.jpg | grep -Eo "[0-9]+")

  # conditionnelle vérifiant le bon format
  echo $data1";"$data2 | grep -E "^[0-9]+;[0-9]+$" > /dev/null
  if [ $? -eq 0 ]; then
    # si la différence entre les deux sondes est trop grande, on drop l'input
    diff1=$(echo "$prev1 - $data1" | bc -l | sed 's/-//')
    diff2=$(echo "$prev2 - $data2" | bc -l | sed 's/-//')
    diffTS=$(echo "$(date +%s) - $last_date" | bc -l | sed 's/-//')
    if [ $last_date -eq -1 ] || [ $(($prev1+$prev2)) -eq -2 ] || [ $diffTS -gt 60 ] || ([ $diff1 -le 3 ] && [ $diff2 -le 3 ]); then
      line=$(date "+%d/%m/%Y %H:%M:%S")";$data1;$data2"
      last_date=$(date +%s)
      # enregistrement csv
      echo $line >> data.csv

      # enregistrement svg toutes les 5 inputs
      echo $i;
      if [ $i -eq 0 ]; then
        gnuplot -e "set terminal svg size 1000,500;set output 'data.svg'; set datafile separator ';';set xdata time;set timefmt '%d/%m/%Y %H:%M:%S';set ylabel 'Température';set xlabel 'Temps';set grid;set style line 101 lc rgb '#808080' lt 1 lw 1;set border 3 front ls 101;set tics nomirror out scale 0.75;set key left top;set samples 500;set style line 11 lt 1 lw 1.5 lc rgb '#0072bd';set style line 16 lt 1 lw 1.5 lc rgb '#4dbeee'; plot 'data.csv' using 1:2 with lines linestyle 11 title 'Sonde haut' smooth sbezier, 'data.csv' using 1:3 with lines linestyle 16 title 'Sonde bas' smooth sbezier"
        ((i++));
      else
        if [ $i -eq 5 ]; then
          i=0;
        else
          ((i++));
        fi;
      fi;
      prev1=$data1
      prev2=$data2
    fi;
  fi;
done;

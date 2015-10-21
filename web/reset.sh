# Force la régénération des graphiques de data/.
# Évite de se retrouver avec un graphique vide à cause d'une coupure brutale.
shopt -s nullglob
for f in data/*.csv; do
  file=$(echo $f | rev | cut -c 5- | rev)
  gnuplot -e "set terminal svg size 1000,500;set output '$file.svg'; set datafile separator ';';set xdata time;set timefmt '%d/%m/%Y %H:%M:%S';set ylabel 'Température';set xlabel 'Temps';set grid;set style line 101 lc rgb '#808080' lt 1 lw 1;set border 3 front ls 101;set tics nomirror out scale 0.75;set key left top;set samples 500;set style line 11 lt 1 lw 1.5 lc rgb '#0072bd';set style line 16 lt 1 lw 1.5 lc rgb '#4dbeee'; plot '$f' using 1:2 with lines linestyle 11 title 'Sonde haut' smooth sbezier, '$f' using 1:3 with lines linestyle 16 title 'Sonde bas' smooth sbezier";
done;

date=$(date +%Y%m%d%H%M%S)

# Copie du contenu des fichiers précédents
cp data.csv data/data.csv.bak 2> /dev/null
cp data.svg data/data.svg.bak 2> /dev/null

# Suppression des liens symbolique
rm -f data.csv 2> /dev/null
rm -f data.svg 2> /dev/null

# Initialisation des fichiers
touch data/data_$date.csv
touch data/data_$date.svg

# Création des liens symboliques fichier horodaté <- input du webservice
ln -s data/data_$date.csv data.csv
ln -s data/data_$date.svg data.svg


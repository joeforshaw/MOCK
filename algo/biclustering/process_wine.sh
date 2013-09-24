for file in wine2
do
awk -vc=$file '{gsub(/no0/,c);print}' R.script.wine.R > R.script.wine.$file.R

R --vanilla < R.script.wine.$file.R

size=`wc $file.mock.dat | awk '{print $2/$1-14}'`
dim=13

fsize=`wc ~/mock_ppsn/mock-vis-cec/$file.dat | awk '{print $1}'`

for name in mock; do java ClusterViz $fsize $dim $size $file.$name.dat > $file.$name.agglomerated.data 2> $file.$name.singleEA.pf; done

for name in single kmeans average; do java ClusterViz $fsize $dim 25 $file.$name.dat > $file.$name.agglomerated.data 2> $file.$name.singleEA.pf; done

for name in combined; do java ClusterViz $fsize $dim 75 $file.$name.dat > $file.$name.agglomerated.data 2> $file.$name.singleEA.pf; done


awk -vc=$file '{gsub(/no0/,c);print}' R.script.wineEA.R > R.script.wineEA.$file.R

R --vanilla < R.script.wineEA.$file.R

for name in single kmeans average mock.averageEA kmeans.averageEA average.averageEA single.averageEA; do java ClusterEval $fsize $dim 25 $file.$name.dat 2> $file.$name.pf; done

for name in combined; do java ClusterEval $fsize $dim 75 $file.$name.dat 2> $file.$name.pf; done

for name in combined.averageEA; do java ClusterEval $fsize $dim 25 $file.$name.dat 2> $file.$name.pf; done

done
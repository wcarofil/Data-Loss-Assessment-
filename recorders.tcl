### Recorders

#eval "recorder Node -file $dataDir/RBaseY.$run.txt -node $Reactions -dof 2 reaction" ;# support reaction
#eval "recorder Node -file $dataDir/RBaseX.$run.txt -node $Reactions -dof 1 reaction" ;# support reaction
# eval "recorder Node -file $dataDir/Displacements.$run.txt -node $nodes -dof 1 disp";#displacements of free node 
# eval "recorder Node -file $dataDir/Accelerations.$run.txt -time -timeSeries $tsTagX -node $nodes -dof 1 accel";#Accelerations of free node 
# eval "recorder Node -file $dataDir/Velocities.$run.txt -time -timeSeries $tsTagX -node $nodes -dof 1 vel";#Velocities of free node 
# eval "recorder Drift -file $dataDir/drftX.$run.txt -iNode $botnodes -jNode $topnodes -dof 1 -perpDirn 2"

# eval "recorder Element 	-file $dataDir/beamd.$run.txt -ele $beams section deformation"
# eval "recorder Element 	-file $dataDir/beamf.$run.txt -ele $beams localForce"

# eval "recorder Element 	-file $dataDir/columnd.$run.txt -ele $columns section deformation"
# eval "recorder Element 	-file $dataDir/columnf.$run.txt -ele $columns localForce"

# eval "recorder Element 	-file $dataDir/Dampf.$run.txt -ele $damper force"
# eval "recorder Element 	-file $dataDir/Dampd.$run.txt -ele $damper deformation"

#eval "recorder Element 	-xml $dataDir/beamd.txt -ele $beams section deformation"
#eval "recorder Element 	-xml $dataDir/beamf.txt -ele $beams localForce"

#eval "recorder Element 	-xml $dataDir/columnd.txt -ele $columns section deformation"
#eval "recorder Element 	-xml $dataDir/columnf.txt -ele $columns localForce"
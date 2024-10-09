# @@@ 3-story Special Moment Resisting Steel Frame @@@@ [FEMA 440]
# [This file executes four type of analysis: model, gravity, modal, pushover, and NLTH]
# start
wipe;



set analysistype "modal"; #[model, gravity, modal, PO, NRHA]
set dataDir "Outputs_${analysistype}"; # set up name of data directory (you can remove this)
file mkdir $dataDir; 				# create data directory

source analysis_type.tcl;
source model_file.tcl
set PO [list 700 1610 600]; #[$tDisp $tNode $nSteps]


run_analysis $analysistype $dataDir $PO $Reactions $nodes $beams $columns $damper $topnodes $botnodes



if {$analysistype!="model"} {
	wipe;} 




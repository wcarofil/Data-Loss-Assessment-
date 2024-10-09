### Analyais Type 


### Pushover
proc singlePush {dref mu ctrlNode nSteps {IOflag 1} {PrintFlag 0}} {
	# --------------------------------------------------
	# Description of Parameters
	# --------------------------------------------------# This has been adapted from a similar script by Dr. Boombastic

	# dref:			Reference displacement to which cycles are run. Corresponds to yield or equivalent other, such as 1mm
	# mu:			Multiple of dref to which the push is run. So pushover can be run to a specified ductility or displacement
	# ctrlNode:		Node to control with the displacement integrator.
	# nSteps:		Number of steps.
	# IOflag:		Option to print details on screen. 2 for print of each step, 1 for basic info (default), 0 for off
	# ---------------------------------------------------

	set dispDir 1; #DOF the loading is applied.

	# Set up the initial analysis
	# Define the Initial Analysis Parameters
	# set testType	NormUnbalance;				# Dont use with Penalty constraints
	set testType	NormDispIncr
	# set testType	EnergyIncr;					# Dont use with Penalty constraints
	# set testType	RelativeNormUnbalance;		# Dont use with Penalty constraints
	# set testType	RelativeNormDispIncr;		# Dont use with Lagrange constraints
	# set testType	RelativeTotalNormDispIncr;	# Dont use with Lagrange constraints
	# set testType	RelativeEnergyIncr;			# Dont use with Penalty constraints

	set 	tolInit 	1.0e-7;			# Set the initial Tolerance, so it can be referred back to
	set 	iterInit 	50;				# Set the initial Max Number of Iterations

	set 	algorithmType KrylovNewton;		# Set the algorithm type
	# set 	algorithmType Newton;		# Set the algorithm type
	# set 	algorithmType Newton;		# Set the algorithm type

	test 		$testType $tolInit $iterInit

	algorithm 	$algorithmType
	set 		disp 				[expr $dref*$mu];
	set 		dU 					[expr $disp/(1.0*$nSteps)];
	integrator 	DisplacementControl $ctrlNode $dispDir $dU
	analysis 	Static

	# Print values
	if {$IOflag >= 1} {
		puts "singlePush: Push $ctrlNode to $mu"
	}

	# Set the initial values to start the while loop
	set ok 		0;
	set step 	1;
	set loadf 	1.0;

	while {$step<=$nSteps && $ok==0 && $loadf>0} {
		set ok 		[analyze 1];
		set loadf 	[getTime];
		set temp 	[nodeDisp $ctrlNode $dispDir];

		# Print the current displacement
		if {$IOflag >=2} {
			puts "Pushed $ctrlNode in $dispDir to $temp with $loadf"
		}

		# If the analysis fails, try the following changes to achieve convergence
		# Analysis will be slower in here though...
		if {$ok != 0} {
			puts "Trying relaxed convergence.."
			test 		$testType [expr $tolInit*0.01] [expr $iterInit*50]
			set ok [analyze 1]
			test 		$testType $tolInit $iterInit
			}
		if {$ok != 0} {
			puts "Trying Newton with initial then current .."
			test 		$testType [expr $tolInit*0.01] [expr $iterInit*50]
			algorithm Newton -initialThenCurrent
			set ok [analyze 1]
			algorithm 	$algorithmType
			test 		$testType $tolInit $iterInit
		}
		if {$ok != 0} {
			puts "Trying ModifiedNewton with initial .."
			test 		$testType [expr $tolInit*0.01] [expr $iterInit*50]
			algorithm ModifiedNewton -initial
			set ok [analyze 1]
			algorithm 	$algorithmType
			test 		$testType $tolInit $iterInit
		}
		if {$ok != 0} {
			puts "Trying KrylovNewton .."
			test 		$testType [expr $tolInit*0.01] [expr $iterInit*50]
			algorithm KrylovNewton
			set ok [analyze 1]
			algorithm 	$algorithmType
			test 		$testType $tolInit $iterInit
		}
		if {$ok != 0} {
			puts "Perform a Hail Mary ...."
			test 	FixedNumIter $iterInit
			set ok [analyze 1]
		}


		set temp 	[nodeDisp $ctrlNode $dispDir];
		set loadf 	[getTime];
		incr step 1;


	}; # Close the while loop

	if {$ok != 0} {
		puts "DispControl Analysis FAILED"
    	#puts "Do you wish to continue y/n ?"; # include if want to pause at analysis failure
    	#gets stdin ans; # not recommended in parameter study
    	#if {$ans == "n"} done; # as it interrupts batch file
		} else {
    	puts "DispControl Analysis SUCCESSFUL"
		}
		if {$loadf<=0} {
    		puts "Stopped because of Load factor below zero: $loadf"
		}
		if {$PrintFlag} {
			file delete singlePush.txt
			print singlePush.txt
		}

}


### NHRA
proc runNRHA {Dt Tmax Dc tNode bNode log {pflag 0}} {
	# This procedure is a simple script that executes the NRHA of a 3D model. It
	# requires that the model has the dynamic analysis objects defined and just the
	# 'analyze' of a regular OpenSees model needs to be executed. Therefore, the model
	# needs to be built to the point where a modal analysis can be conducted. The
	# ground motion timeSeries and pattern need to be setup and the constraints,
	# numberer and system analysis objects also need to be predefined.

	# When conducting the NRHA, this proc will try different options to achieve
	# convergence and finish the ground motin. This allows for a relatively robust
	# analysis algorithm to be implemented with a single command.

	# In addition, the analysis requires that a deformation capacity be specified
	# to define a limit that upon exceedance, will stop the NRHA and mark the
	# analysis as a collapse case. It monitors the current deformation of a number
	# of specified nodes and flags collapse based on their deforormation. This
	# prevents the models getting 'stuck' trying to converge a model that has
	# essentially collapsed, or would be deemed a collapse case in post processing.
	# These are defined in terms of both the local storey drifts and also the roof
	# drift in either direction. For 3D analysis, the absolute maximum drift in
	# either direction is used.

	# Lastly, a log file identifier is also required in the input.  This will log
	# all of the essential information about the maximum storey drifts. This script
	# was developed for analysing buildings so the deformation capacity  typically
	# corresponds to a drift capacity and the top and bottom nodes would typically
	# correspond to the centreline nodes of the floorslabs.

	# WARNING: The acceleration values that are ouput from this are the relative
	# accelerations. For some reason, you cant get the current absolute values with
	# inline commands.

	if {$pflag>0} {puts "Starting runNRHA"};
	# --------------------------------------------------
	# Description of Parameters
	# --------------------------------------------------
	# Dt:		Analysis time step
	# Tmax:	Length of the record (including padding of 0's)
	# Dc:		Drift capacity for both storey and roof drift (%)
	# tNode:	List of top nodes (e.g. {2 3 4 5})
	# bNode:	List of bottom node (e.g. {1 2 3 4})
	# log:	File handle of the logfile
	# --------------------------------------------------

	# Make the control index available outside the proc
	upvar 1 cIndex cIndex

	# Define the initial Analysis parameters
	set 	testType	NormDispIncr;	# Set the test type
	set 	tolInit 	1.0e-7;		# Set the initial tolerance, so it can be referred back to
	set 	iterInit 	50;			# Set the initial max number of iterations
	set 	algorithmType KrylovNewton;	# Set the algorithm type
	test 		$testType $tolInit $iterInit
	algorithm 	$algorithmType
	integrator 	Newmark 0.5 0.25
	analysis 	Transient

	# Set up analysis parameters
	set Nsteps [expr int($Tmax/$Dt)]; 	# integer of the number of steps needed
	set cIndex 		0;			# Initially define the control index (-1 for non-converged, 0 for stable, 1 for global collapse, 2 for local collapse)
	set controlTime 	0.0;			# Start the controlTime
	set ok		0;			# Set the convergence to 0 (initially converged)
	set mdrft 		0.0;			# Set the initial storey drift
	set mflr		0;			# Set the initial storey collapse location

	# Set up the storey drift and acceleration values
	set h 		{};
	set mdrftX 		{};
	set maccelX 	{0.0};
	set bdg_h 		0.0;
	for {set i 1} {$i<=[llength $tNode]} {incr i 1} {
		# Find the coordinates of the nodes in Global Y (2)
		set top2	[nodeCoord [lindex $tNode $i-1] 2];
		set bot2	[nodeCoord [lindex $bNode $i-1] 2];
		set dist [expr $top2-$bot2];

		# Calculate the building height as the running sum of the distances
		# between nodes specified
		set bdg_h [expr $bdg_h+$dist];

		# This means we take the distance in Z (3) in my coordinates systems at least. This is X-Y/Z| so X=1 Y=2 Z=3. (gli altri vacca gare)
		lappend h $dist;
		lappend mdrftX 0.0; # We will populate the lists with zeros initially
		lappend maccelX 0.0;
		if {$dist==0} {puts "WARNING: Zerolength found in drift check"};


	}

	# Run the actual analysis now
	while {$cIndex==0 && $controlTime <= $Tmax && $ok==0} {
		# Runs while the building is stable, time is less
		# than that of the length of the record (plus buffering)
		# and the analysis is still converging

		# Do the analysis
		set ok [analyze 1 $Dt];		# Run a step of the analysis
		set controlTime [getTime];	# Update the control time
		if {$pflag>1} {puts "Completed  $controlTime of $Tmax seconds"}

		# If the analysis fails, try the following changes to achieve convergence
		# Analysis will be slower in here though...

		# First changes are to change algorithm to achieve convergence...
		# Next half the timestep with both algorithm and tolerance reduction, if this doesn't work - in bocca al lupo
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Reduced timestep by half......"
			set Dtt [expr 0.5*$Dt]
			set ok [analyze 1 $Dtt]
		}
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Reduced timestep by quarter......"
			set Dtt [expr 0.25*$Dt]
			set ok [analyze 1 $Dtt]
		}
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Trying Broyden......"
			algorithm Broyden 8
			set ok [analyze 1 $Dt]
			algorithm 	$algorithmType
		}
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Trying Newton with Initial Tangent ......"
			algorithm Newton -initial
			set ok [analyze 1 $Dt]
			algorithm 	$algorithmType
		}
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Trying NewtonWithLineSearch......"
			algorithm NewtonLineSearch .8
			set ok [analyze 1 $Dt]
			algorithm 	$algorithmType
		}
		# Next change both algorithm and tolerance to achieve convergence....
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Trying Newton with Initial Tangent & relaxed convergence......"
			test NormDispIncr [expr $tolInit*0.1] [expr $iterInit*50]
			algorithm Newton -initial
			set ok [analyze 1 $Dt]
			test 		$testType $tolInit $iterInit
			algorithm 	$algorithmType
		}
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Trying Newton with Initial Tangent & relaxed convergence......"
			test NormDispIncr [expr $tolInit*0.1] [expr $iterInit*50]
			algorithm Newton -initial
			set ok [analyze 1 $Dt]
			test 		$testType $tolInit $iterInit
			algorithm 	$algorithmType
		}
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Trying NewtonWithLineSearch & relaxed convergence......"
			test NormDispIncr [expr $tolInit*0.1] [expr $iterInit*50]
			algorithm NewtonLineSearch .8
			set ok [analyze 1 $Dt]
			test 		$testType $tolInit $iterInit
			algorithm 	$algorithmType
		}
		# Next half the timestep with both algorithm and tolerance reduction, if this doesn't work - in bocca al lupo
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Trying Newton with Initial Tangent, reduced timestep & relaxed convergence......"
			test NormDispIncr [expr $tolInit*0.1] [expr $iterInit*50]
			algorithm Newton -initial
			set Dtt [expr 0.5*$Dt]
			set ok [analyze 1 $Dtt]
			test 		$testType $tolInit $iterInit
			algorithm 	$algorithmType
		}
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Trying Newton with Initial Tangent, reduced timestep & relaxed convergence......"
			test NormDispIncr [expr $tolInit*0.1] [expr $iterInit*50]
			algorithm Newton -initial
			set Dtt [expr 0.5*$Dt]
			set ok [analyze 1 $Dtt]
			test 		$testType $tolInit $iterInit
			algorithm 	$algorithmType
		}
		if {$ok != 0} {
			puts " ~~~ Failed at $controlTime - Trying NewtonWithLineSearch, reduced timestep & relaxed convergence......"
			test NormDispIncr [expr $tolInit*0.1] [expr $iterInit*50]
			algorithm NewtonLineSearch .8
			set Dtt [expr 0.5*$Dt]
			set ok [analyze 1 $Dtt]
			test 		$testType $tolInit $iterInit
			algorithm 	$algorithmType
		}
		# Game over......
		if {$ok !=0} {
			puts " ~~~ Failed at $controlTime - exit analysis......"
			# Failed to converge, exit analysis
			# wipe;
			set cIndex -1;
		}

		# Check the actual state of the model with respect to the limits provided
		# Need to get the PGA (this is actually zero since nodeAcce returns relative not absolute values)
		set base_accelX 	[expr [nodeAccel [lindex $bNode 0] 1]/9.81]; 	# Current base node accel in X in g


		if {$base_accelX>[lindex $maccelX 0]} {set maccelX [lreplace $maccelX 0 0 $base_accelX]};
		

		# Check the storey drifts and accelerations
		for {set i 1} {$i<=[llength $tNode]} {incr i 1} {
			set tNode_dispX 	[nodeDisp [lindex $tNode $i-1] 1]; 	# Current top node disp in X
			set bNode_dispX 	[nodeDisp [lindex $bNode $i-1] 1]; 	# Current bottom node disp in X
			set cHt				[lindex $h $i-1];					# Current storey height
			set cdrftX			[expr 100.0*abs($tNode_dispX-$bNode_dispX)/$cHt];	# Current storey drift in X at the current floor in %
			if {$cdrftX>=[lindex $mdrftX $i-1]} {set mdrftX [lreplace $mdrftX $i-1 $i-1 $cdrftX]};
			
			set cdrft $cdrftX

	# 		set cdrft	[expr sqrt(pow($cdrftX,2)+pow($cdrftY,2))]; # square root sum of squares
			
			if {$cdrft>$mdrft} {set mdrft $cdrft; set mflr $i}; # Update the current maximum storey drift and where it is

			# Now get the accelerations
			set Node_accelX 	[expr [nodeAccel [lindex $tNode $i-1] 1]/9.81]; 	# Current top node accel in X in g
			set caccelX			[expr 1.0*abs($Node_accelX)];
			if {$caccelX>=[lindex $maccelX $i]} {set maccelX [lreplace $maccelX $i $i $caccelX]};
			}

		#if {$mdrft>=$Dc} {set cIndex 1; set mdrft $Dc; wipe}; 			# Set the state of the model to local collapse (=1)

	}

	# Create some output
	puts $log [format "FinalState:%d at %.3f of %.3f seconds" $cIndex $controlTime $Tmax]; # Print to the logfile the final state
	puts $log [format "PeakStoreyDrift:%.2f%% at %d" $mdrft $mflr]; 	# Print to the max interstorey drift and where it is


	# Print to the max interstorey drifts
	puts -nonewline $log "PeakStoreyDriftX: ";
	for {set ii 1} {$ii <= [llength $mdrftX]} {incr ii 1} {
		puts -nonewline $log [format "%.2f " [lindex $mdrftX $ii-1]]
	}
	puts $log "%"; 	# Print to the max storey drifts
	

	# Print to the max max floor accelerations
	puts -nonewline $log "PeakFloorAccelerationX: ";
	for {set ii 1} {$ii <= [llength $maccelX]} {incr ii 1} {
		puts -nonewline $log [format "%.2f " [lindex $maccelX $ii-1]]
	}
	puts $log "g"; 	# Print to the max floor accelerations
	
	if {$pflag>0} {
		puts [format "PeakStoreyDrift:%.2f %% at %d" $mdrft $mflr]; 	# Print to the max roof drift
	}
	if {$cIndex == -1} {puts ":::::: ANALYSIS FAILED TO CONVERGE at $controlTime of $Tmax :::::"}
	if {$cIndex == 0} {puts  "######## ANALYSIS COMPLETED SUCCESSFULLY #####"}
	if {$cIndex == 1} { puts "========== LOCAL STRUCTURE COLLAPSE =========="}
}


#### RUN A TYPE OF ANALYSIS 
proc run_analysis {analysistype {dataDir ""} PO Reactions nodes beams columns damper topnodes botnodes} {
		global pi
		global g
		global nfl

	if {$analysistype == "gravity"} {
		puts "Performing Gravity Analysis"

		# Gravity-analysis parameters -- load-controlled static analysis
		# set Tol 1.0e-8;			# convergence tolerance for test
		# variable constraintsTypeGravity Plain;		# default;
		# if {  [info exists RigidDiaphragm] == 1} {
		# 	if {$RigidDiaphragm=="ON"} {
		# 	variable constraintsTypeGravity Lagrange;	#  large model: try Transformation
		# 	};	# if rigid diaphragm is on
		# };	# if rigid diaphragm exists
		# constraints $constraintsTypeGravity ;     		# how it handles boundary conditions
		# numberer RCM;			###renumber dof's to minimize band-width (optimization), if you want to
		# system BandGeneral ;		###how to store and solve the system of equations in the analysis (large model: try UmfPack)
		# test NormDispIncr $Tol 6 ; 		# determine if convergence has been achieved at the end of an iteration step
		# algorithm Newton;			# use Newton's solution algorithm: updates tangent stiffness at every iteration
		# set NstepGravity 10;  		# apply gravity in 10 steps
		# set DGravity [expr 1./$NstepGravity]; 	# first load increment;
		# integrator LoadControl $DGravity;	# determine the next time step for an analysis
		# analysis Static;			# define type of analysis static or transient
		# analyze $NstepGravity;		# apply gravity
		# ###maintain constant gravity loads and reset time to zero
		# loadConst -time 0.0

		# Define gravity load pattern
		#set nfl 3.0
		# pattern Plain 101 Constant {
		# for {set i 1} {$i <=$nfl} {incr i 1} {
		# 	if {$i<$nfl} {
		# 		load 1${i}6 0.0 -116.0  0.0;
		# 		load 2${i}6 0.0 -233.0  0.0;
		# 		load 4${i}6 0.0 -233.0  0.0;
		# 		load 5${i}6 0.0 -116.0  0.0;
		# 		load 6${i} 0.0 -3484.0  0.0;
		# 	}
		# 	if {$i==$nfl} {
		# 		load 1${i}6 0.0 -103.0  0.0;
		# 		load 2${i}6 0.0 -207.0  0.0;
		# 		load 4${i}6 0.0 -207.0  0.0;
		# 		load 5${i}6 0.0 -103.0  0.0;
		# 		load 6${i} 0.0 -3094.0  0.0;
		# 		}
		# 	}
		# }

		# pattern Plain 101 Constant {
		# 	load 116 0.0 -116.0 0.0
		# 	load 216 0.0 -233.0 0.0
		# 	load 416 0.0 -233.0 0.0
		# 	load 516 0.0 -116.0 0.0
		# 	load 61 0.0 -3484.0 0.0

		# 	load 126 0.0 -116.0 0.0
		# 	load 226 0.0 -233.0 0.0
		# 	load 426 0.0 -233.0 0.0
		# 	load 526 0.0 -116.0 0.0
		# 	load 62 0.0 -3484.0 0.0

		# 	load 136 0.0 -103.0 0.0
		# 	load 236 0.0 -207.0 0.0
		# 	load 436 0.0 -207.0 0.0
		# 	load 536 0.0 -103.0 0.0
		# 	load 63 0.0 -3094.0 0.0
		# }

		set tsTagX 1
		set run 0

		source recorders.tcl
		#wipeAnalysis;
		constraints Plain
		numberer RCM
		system UmfPack  
		test EnergyIncr	1e-8 500
		algorithm KrylovNewton
		set nG 100
		integrator LoadControl [expr 1/$nG]
		analysis Static
		analyze $nG
		loadConst -time 0.0


		puts "Gravity Analysis done!"


	} elseif {$analysistype == "modal"} {
		# Perform Gravity analysis
			wipeAnalysis;
			constraints Plain
			numberer RCM
			system UmfPack  
			test EnergyIncr	1e-8 500
			algorithm KrylovNewton
			set nG 100
			integrator LoadControl [expr 1/$nG]
			analysis Static
			analyze $nG
			loadConst -time 0.0
		puts "Gravity Analysis done!"
		puts "Performing Modal Analysis"

		set numModes 4
		set lambda [eigen [expr $numModes]];

		# If this solver doesn't work, try another
		if {[llength $lambda]==0} {set lambda [eigen -fullGenLapack $numModes]};
		if {[llength $lambda]==0} {set lambda [eigen -symmBandLapack $numModes]};

		#fullGenLapack
		#Arpack

		# Record the eigenvectors
		record

		set omega {}
		set f {}
		set T {}

		foreach lam $lambda {
			lappend omega [expr sqrt($lam)]
			lappend f [expr sqrt($lam)/(2*$pi)]
			lappend T [expr (2*$pi)/sqrt($lam)]
		}

		file delete "$dataDir/Periods.txt"
		set period "$dataDir/Periods.txt"
		set Periods [open $period "w"]
		foreach t $T {
			puts $Periods [format "%.3f" $t]
		}
		close $Periods

		# Print the eigenvectors to a text file
		file delete "$dataDir/eigenVectors.txt"
		print "$dataDir/eigenVectors.txt" -node

		for {set i 1} {$i<=$numModes} {incr i 1} {
			puts [format "Mode %d - T=%.3fs   f=%.2fHz  omega:%.1frad/s" $i [lindex $T $i-1] [lindex $f $i-1] [lindex $omega $i-1]] 
			}

		puts "Modal Analysis done!"

		# set w1 [lindex $omega 0]; # Use the first and second modes
		# set w2 [lindex $omega 1];

		# set zeta 0.02;		# percentage of critical damping
		# set a0 [expr $zeta*2.0*$w1*$w2/($w1 + $w2)];	# mass damping coefficient based on first and second modes
		# set a1 [expr $zeta*2.0/($w1 + $w2)];			# stiffness damping coefficient based on first and second modes
		# puts [list $a0 $a1]	

		# set xi1 $zeta
		# set xi2 $zeta
		# set a0 [expr 2*$w1*$w2/($w2*$w2-$w1*$w1)*($w2*$xi1-$w1*$xi2)]
		# set a1 [expr 2*$w1*$w2/($w2*$w2-$w1*$w1)*(-$xi1/$w2+$xi2/$w1)]

		# puts [list $a0 $a1]

	} elseif {$analysistype == "PO" } {
		


		puts "Performing Pushover Analysis"
		set tsTagX 1;
		set N1_PO  {116 216 416 516};
		set N2_PO  {126 226 426 526};
		set N3_PO  {136 236 436 536};
		set N4_PO  {146 246 446 546};
		set N5_PO  {156 256 456 556};
		set N6_PO  {166 266 466 566};
		set run 1

		timeSeries Linear $tsTagX -factor 1
		pattern Plain 1 $tsTagX {
		for {set i 1} {$i <= [llength $N1_PO]} {incr i 1} {
			############# ELEVATION 1 #############
			load [lindex $N1_PO $i-1] 0.224 0.0 0.0
			############# ELEVATION 2 #############
			load [lindex $N2_PO $i-1] 0.379 0.0 0.0
			############# ELEVATION 3 #############
			load [lindex $N3_PO $i-1] 0.535 0.0 0.0
			############# ELEVATION 4 #############
			load [lindex $N4_PO $i-1] 0.690 0.0 0.0
			############# ELEVATION 5 #############
			load [lindex $N5_PO $i-1] 0.846 0.0 0.0
			############# ELEVATION 6 #############
			load [lindex $N6_PO $i-1] 1.0 0.0 0.0
			}
		}

		source recorders.tcl
		constraints 	Penalty 1e14 1e14
		# constraints Transformation
		numberer 		RCM
		system 			UmfPack -lvalueFact 30
		# system 			Mumps

		set tDisp 	[lindex $PO 0];; 	# Target displacement (mm)	
		set tNode	[lindex $PO 1];		# Top Node 
		set nSteps 	[lindex $PO 2];

		singlePush 1.0 $tDisp $tNode $nSteps 1

		puts "Pushover Analysis done!"

	} elseif {$analysistype == "NRHA"} {
		puts "Performing NRHA"
		file mkdir $dataDir;
		file mkdir $dataDir/log;
		set  N_motions 20.0; # Number of ground motions
		set dtsfile 		"C:/Users/wcarofil/Desktop/Waterloo/NS_paper/GM4/dt.txt";
		set dursfile 		"C:/Users/wcarofil/Desktop/Waterloo/NS_paper/GM4/duration.txt";
		
		# set dtsfile 		"C:/Users/wcarofil/Documents/backup_file_wilson/E/Fall2022/ML/Project/3S/bin/FEMA_GMR/dt.txt";
		# set dursfile 		"C:/Users/wcarofil/Documents/backup_file_wilson/E/Fall2022/ML/Project/3S/bin/FEMA_GMR/duration.txt";
		
		set dts_list 		[read [open $dtsfile "r"]];
		set durs_list 		[read [open $dursfile "r"]];

		#### For IDA 
		#set Sa_IDA 		"D:/Waterloo/ConferencePaper_5SPONSE/Bare/bin/FEMA_GMR/Sa_IDA_factor.txt";
		set Sa_IDA 		"C:/Users/wcarofil/Desktop/Waterloo/NS_paper/6S_SCBRB_M1/bin/Outputs_NRHA_GM4/Sa_IDA_factor.txt";
		set Sa_IDA_list 		[read [open $Sa_IDA "r"]];


		for {set r 1} {$r<=$N_motions} {incr r 1} {
			
			set startRTime [clock clicks -milliseconds]; # Start the eq timer
			puts "Record:$r"

			source model_file.tcl
			set dt			[lindex $dts_list $r-1];	# Current dt
			set Tmax		[lindex $durs_list $r-1];	# Current duration
			#set EQnameX	 		"C:/Users/wcarofil/Desktop/Waterloo/NS_paper/GM4/eq${r}.txt";
			set EQnameX	 		"C:/Users/wcarofil/Desktop/Waterloo/NS_paper/GM4/eq${r}.txt";
			
			#et EQnameX		[read [open $EQfile "r"]];
			#set sfX			[expr 1.0*$g];

			### For IDA
			set f_IDA		[lindex $Sa_IDA_list $r-1];	# Scaling factor to 1g
			set num_IDA 	8.0
			set sfX			[expr ($f_IDA*$num_IDA)*$g];


			##Gravity Analysis
			wipeAnalysis;
			constraints Plain
			numberer RCM
			system UmfPack  
			test EnergyIncr	1e-8 500
			algorithm KrylovNewton
			set nG 100
			integrator LoadControl [expr 1/$nG]
			analysis Static
			analyze $nG
			loadConst -time 0.0

			set numModes 3
			set lambda [eigen [expr $numModes]];

			# If this solver doesn't work, try another
			if {[llength $lambda]==0} {set lambda [eigen -fullGenLapack $numModes]};
			if {[llength $lambda]==0} {set lambda [eigen -symmBandLapack $numModes]};

			# Record the eigenvectors
			record

			set omega {}
			set f {}
			set T {}

			foreach lam $lambda {
				lappend omega [expr sqrt($lam)]
				lappend f [expr sqrt($lam)/(2*$pi)]
				lappend T [expr (2*$pi)/sqrt($lam)]
			}

			for {set i 1} {$i<=$numModes} {incr i 1} {
				puts [format "Mode %d - T=%.3fs   f=%.2fHz  omega:%.1frad/s" $i [lindex $T $i-1] [lindex $f $i-1] [lindex $omega $i-1]] 
			}

			###DEFINE DAMPING
			set w1 [lindex $omega 0]; # Use the first and third modes
			# if {$numModes >2} {set Modemax 2
			# 	} else {set Modemax 1}
			set Modemax 1
			set w2 [lindex $omega $Modemax];
			set xi 0.02; #Assume 2% damping for 1 and 2 modes
			set xi1 $xi
			set xi2 $xi
			set a0 [expr 2*$w1*$w2/($w2*$w2-$w1*$w1)*($w2*$xi1-$w1*$xi2)]
			set a1 [expr 2*$w1*$w2/($w2*$w2-$w1*$w1)*(-$xi1/$w2+$xi2/$w1)]
			# rayleigh $alphaM $betaK $betaKinit $betaKcomm
			rayleigh $a0 0.0 0.0 $a1

		# assign damping to frame beams and columns		
		# command: region $regionID -eleRange $elementIDfirst $elementIDlast rayleigh $alpha_mass $alpha_currentStiff $alpha_initialStiff $alpha_committedStiff
		# region 1 -ele 1 7 8 2; #Columns 1 floor
		# region 2 -ele 3 9 10 4; #Columns 2 floor
		# region 3 -ele 5 11 12 6; #Columns 3 floor
		# region 4 -ele 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 -rayleigh 0.0 0.0 0.0 $a1;		# assign stiffness proportional damping to frame beams & columns w/out n modifications
		# region 5 -node 10 1110 1210 1310; #Master nodes
		# region 6 -node 1110 1210 1310; #Master nodes w/o fundation
		# region 7 -node 10 20 40 50; #Foundation
		# rayleigh $a0 0.0 0.0 0.0;              						# assign mass proportional damping to structure (only assigns to nodes with mass)


			###DEFINE TIME SERIES
			#Set a timeseries tag, this is needed for total floor acceleration recorder
			set tsTagX 1

			timeSeries Path $tsTagX -dt $dt -filePath $EQnameX -factor $sfX

			###DEFINE LOAD PATTERN
			# Set a pattern tag
			set pTagX 1

			pattern UniformExcitation  $pTagX 	1 -accel $tsTagX

			###DEFINE ANALYSIS OBJECTS
			# constraints 	Transformation
			constraints 	Penalty 1e14 1e14
			numberer 		RCM
			system 			UmfPack -lvalueFact 40
			#system 			Mumps


			# Open a log file to document salient values
			set run "EQ_${r}"
			set log [open $dataDir/log/log_$run.txt "w"];
			set dataDir 

			###DEFINE RECORDERS
			source recorders.tcl



			# Run the actual records.
			set Dc 10.0; #drift max

			set startRTime [clock clicks -milliseconds]; # Start the eq timer
			puts "Running NRHA"

			runNRHA $dt $Tmax $Dc $topnodes $botnodes $log 1
 
			# Stop the eq timer
			set totalRTime [expr ([clock clicks -milliseconds]-$startRTime)/1000./60.];
			puts $log [format "Total runtime was %.1f minutes" $totalRTime];
			close $log
			puts "NRHA done!"

			wipe;




			}; # end loop of N_motions



		




	} elseif {$analysistype == "model"} {
		### Display Model
		recorder display "Displaced shape" 10 10 1000 500 -wipe
 		prp 200. 50. 1;
 		vup  0  1 0;
 		vpn  0  0 1;
 		display 1 5 40

	}
}



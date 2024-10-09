# @@@ 3-story Special Moment Resisting Steel Frame @@@@ [FEMA 440]
# [This script contains the model, definition of node, elements, contrains, etc.]

# Original Script done by: ###################################################################
# Bryan Chalarca Echeverri. Ph.D. Candidate of Understanding and Managing Extremes. IUSS Pavia.
# Project: Collapse Capacity of Steel Frames equiped with Linear and Nonlinear Viscous Dampers.
# Supervisor: Prof. André Filiatrault.
# Created: 16-Nov-2017.
# Updated: 27-Sep-2019. Panel Zones Added
# Modified by: ###############################################################################
# Wilson Carofilis Ph.D. Student at University of Waterloo, Canada.
# Project: Self-centering energy dissipative brace with prestressed iron-based shape memory 
# alloy rods for increasing the seismic resilience of structures, CSCE 2022.
# Supervisor: Prof. Eugene Kim.
# Created: 31-01-2022
# Updated: 31-01-222
##############################################################################################


# Units: kN, mm, s.

# Start
wipe; # delete any previous model or variables

# Define the model builder, ndm = #dimension, ndf = #dofs
model BasicBuilder -ndm 2 -ndf 3;

# Input Variables ############################################################################
set pi [expr 2.0*asin(1.0)];
set g 9810.0; # Gravity [mm/s2]
set nfl 6.0; # Number of Stories
# Define geometry
set l  7315.0; # bay width
set h1  5486.0; # story heigth 1 floor
set h  3810.0; # story heigth
#Beams and Columns depths/2
set colext1		197.0; #W14x193
set colint1		387.0; #W30x173
set beam1		377.0; #W30x99

set colext3		191.0; #W14x159
set colint3		348.0; #W27x146
set beam3		342.0; #W27x94

set colext5		182.0; #W14x109
set colint5		306.0; #W24x104
set beam5		304.0; #W24x76
# Steel properties
set fy	0.29;	# Steel yield strength
set Es	200.0;	# Steel elastic modulus
set bs	0.02;				# Steel hardening ratio
set muphi	11.00;			# Plastic hinge curvature ductility
set Lpr	0.9;				# Plastic hinge length ratio
set fz [expr pow(25.4,3)*0.29]; #Conversion factor for Mp with Z in inches^3
#	External column
set Z_ec 487.0; # Z of the section Inches^3
set Iz_ec 1415.2e6; # Iz of the section mm^4
set A_ec 48774.1; # Area of the section mm^2 
#	Internal columns
set Z_ic 603.0; # Z of the section Inches^3
set Iz_ic 1802.3e6; # Iz of the section mm^4
set A_ic 58967.6; # Area of the section mm^2 
# Elements Beams From bottom to top [first floor]
set Z_b1 415.0; # Z of the section Inches^3
set Iz_b1 2455.8e6; # Iz of the section mm^4
set A_b1 22387.0; # Area of the section mm^2 
# Elements Beams From bottom to top [Second floor]
set Z_b2 378.0; # Z of the section Inches^3
set Iz_b2 2052.02e6; # Iz of the section mm^4
set A_b2 22064.5; # Area of the section mm^2 
# Elements Beams From bottom to top [Third floor]
set Z_b3 177.0; # Z of the section Inches^3
set Iz_b3 761.7e6; # Iz of the section mm^4
set A_b3 12967.72; # Area of the section mm^2 
# P-Delta Columns
set Iz_p 1.0e13;
set A_p [expr 1.0e8]; # Area of the section mm^2
##############################################################################################

# Define Nodal Coordinates X axys (Column) - Y axis (Floor) ##################################

#Foundations
node 10 	[expr $l*0.0] 		[expr $h1*0.0];
node 20 	[expr $l*1.0] 		[expr $h1*0.0];
node 40 	[expr $l*2.0] 		[expr $h1*0.0];
node 50 	[expr $l*3.0] 		[expr $h1*0.0];
node 60 	[expr $l*3.0+1000] 		[expr $h1*0.0];

#First floor

node 116 	[expr $l*0.0] 		[expr $h1*1.0-$beam1];
node 117 	[expr $l*0.0] 		[expr $h1*1.0+$beam1];
node 216 	[expr $l*1.0] 		[expr $h1*1.0-$beam1];
node 217 	[expr $l*1.0] 		[expr $h1*1.0+$beam1];
node 31 	[expr $l*1.5] 		[expr $h1*1.0];
node 416 	[expr $l*2.0] 		[expr $h1*1.0-$beam1];
node 417 	[expr $l*2.0] 		[expr $h1*1.0+$beam1];
node 516 	[expr $l*3.0] 		[expr $h1*1.0-$beam1];
node 517 	[expr $l*3.0] 		[expr $h1*1.0+$beam1];
node 61		[expr $l*3.0+1000]		[expr $h1*1.0];

#Second floor

node 126 	[expr $l*0.0] 		[expr $h1+$h*1.0-$beam1];
node 127 	[expr $l*0.0] 		[expr $h1+$h*1.0+$beam1];
node 226 	[expr $l*1.0] 		[expr $h1+$h*1.0-$beam1];
node 227 	[expr $l*1.0] 		[expr $h1+$h*1.0+$beam1];
node 32 	[expr $l*1.5] 		[expr $h1+$h*1.0];
node 426 	[expr $l*2.0] 		[expr $h1+$h*1.0-$beam1];
node 427 	[expr $l*2.0] 		[expr $h1+$h*1.0+$beam1];
node 526 	[expr $l*3.0] 		[expr $h1+$h*1.0-$beam1];
node 527 	[expr $l*3.0] 		[expr $h1+$h*1.0+$beam1];
node 62		[expr $l*3.0+1000]		[expr $h1+$h*1.0];

#Third floor

node 136 	[expr $l*0.0] 		[expr $h1+$h*2.0-$beam3];
node 137 	[expr $l*0.0] 		[expr $h1+$h*2.0+$beam3];
node 236 	[expr $l*1.0] 		[expr $h1+$h*2.0-$beam3];
node 237 	[expr $l*1.0] 		[expr $h1+$h*2.0+$beam3];
node 33		[expr $l*1.5] 		[expr $h1+$h*2.0];
node 436 	[expr $l*2.0] 		[expr $h1+$h*2.0-$beam3];
node 437 	[expr $l*2.0] 		[expr $h1+$h*2.0+$beam3];
node 536 	[expr $l*3.0] 		[expr $h1+$h*2.0-$beam3];
node 537 	[expr $l*3.0] 		[expr $h1+$h*2.0+$beam3];
node 63		[expr $l*3.0+1000]		[expr $h1+$h*2.0];

#Forth floor

node 146 	[expr $l*0.0] 		[expr $h1+$h*3.0-$beam3];
node 147 	[expr $l*0.0] 		[expr $h1+$h*3.0+$beam3];
node 246 	[expr $l*1.0] 		[expr $h1+$h*3.0-$beam3];
node 247 	[expr $l*1.0] 		[expr $h1+$h*3.0+$beam3];
node 34		[expr $l*1.5] 		[expr $h1+$h*3.0];
node 446 	[expr $l*2.0] 		[expr $h1+$h*3.0-$beam3];
node 447 	[expr $l*2.0] 		[expr $h1+$h*3.0+$beam3];
node 546 	[expr $l*3.0] 		[expr $h1+$h*3.0-$beam3];
node 547 	[expr $l*3.0] 		[expr $h1+$h*3.0+$beam3];
node 64		[expr $l*3.0+1000]		[expr $h1+$h*3.0];

#Fifth floor

node 156 	[expr $l*0.0] 		[expr $h1+$h*4.0-$beam5];
node 157 	[expr $l*0.0] 		[expr $h1+$h*4.0+$beam5];
node 256 	[expr $l*1.0] 		[expr $h1+$h*4.0-$beam5];
node 257 	[expr $l*1.0] 		[expr $h1+$h*4.0+$beam5];
node 35		[expr $l*1.5] 		[expr $h1+$h*4.0];
node 456 	[expr $l*2.0] 		[expr $h1+$h*4.0-$beam5];
node 457 	[expr $l*2.0] 		[expr $h1+$h*4.0+$beam5];
node 556 	[expr $l*3.0] 		[expr $h1+$h*4.0-$beam5];
node 557 	[expr $l*3.0] 		[expr $h1+$h*4.0+$beam5];
node 65		[expr $l*3.0+1000]		[expr $h1+$h*4.0];

#Sixth floor

node 166 	[expr $l*0.0] 		[expr $h1+$h*5.0-$beam5];
node 167 	[expr $l*0.0] 		[expr $h1+$h*5.0+$beam5];
node 266 	[expr $l*1.0] 		[expr $h1+$h*5.0-$beam5];
node 267 	[expr $l*1.0] 		[expr $h1+$h*5.0+$beam5];
node 36		[expr $l*1.5] 		[expr $h1+$h*5.0];
node 466 	[expr $l*2.0] 		[expr $h1+$h*5.0-$beam5];
node 467 	[expr $l*2.0] 		[expr $h1+$h*5.0+$beam5];
node 566 	[expr $l*3.0] 		[expr $h1+$h*5.0-$beam5];
node 567 	[expr $l*3.0] 		[expr $h1+$h*5.0+$beam5];
node 66		[expr $l*3.0+1000]		[expr $h1+$h*5.0];

# Lumped Masses
for {set i 1} {$i <=$nfl} {incr i 1} {
	if {$i<$nfl} {
		mass 1${i}7 0 					[expr 101.0/$g] 	0;
		mass 2${i}7 0 					[expr 137.0/$g] 	0;
		mass 3${i}  [expr 2515.0/$g] 	0 					0;
		mass 4${i}7 0 					[expr 137.0/$g] 	0;
		mass 5${i}7 0 					[expr 101.0/$g] 	0;
		mass 6${i}  0 					[expr 1949.0/$g] 	0;
	}
    if {$i==$nfl} {
		mass 1${i}7 0 					[expr 77.0/$g] 		0;
		mass 2${i}7 0 					[expr 104.0/$g] 	0;
		mass 3${i}  [expr 1816.0/$g] 	0 					0;
		mass 4${i}7 0 					[expr 104.0/$g] 	0;
		mass 5${i}7 0 					[expr 77.0/$g] 		0;
		mass 6${i}  0 					[expr 1385.0/$g] 	0;
	}
}

# Single point constraints -- Boundary Conditions
fix 10 1 1 1;
fix 20 1 1 1;
fix 40 1 1 1;
fix 50 1 1 1;
fix 60 1 1 0;

# Floor 1
# panel zone at Column 1
	
node 1101 	[expr $l*0.0-$colext1] 		[expr $h1*1.0+$beam1];
node 1102 	[expr $l*0.0-$colext1] 		[expr $h1*1.0+$beam1];
node 1103 	[expr $l*0.0+$colext1] 		[expr $h1*1.0+$beam1];
node 1104 	[expr $l*0.0+$colext1] 		[expr $h1*1.0+$beam1];
node 1105 	[expr $l*0.0+$colext1] 		[expr $h1*1.0];
node 1106 	[expr $l*0.0+$colext1] 		[expr $h1*1.0-$beam1];
node 1107 	[expr $l*0.0+$colext1] 		[expr $h1*1.0-$beam1];
node 1108 	[expr $l*0.0-$colext1] 		[expr $h1*1.0-$beam1];
node 1109 	[expr $l*0.0-$colext1] 		[expr $h1*1.0-$beam1];
node 1110 	[expr $l*0.0-$colext1] 		[expr $h1*1.0];

# panel zone at Column 2
	
node 2101 	[expr $l*1.0-$colint1] 		[expr $h1*1.0+$beam1];
node 2102 	[expr $l*1.0-$colint1] 		[expr $h1*1.0+$beam1];
node 2103 	[expr $l*1.0+$colint1] 		[expr $h1*1.0+$beam1];
node 2104 	[expr $l*1.0+$colint1] 		[expr $h1*1.0+$beam1];
node 2105 	[expr $l*1.0+$colint1] 		[expr $h1*1.0];
node 2106 	[expr $l*1.0+$colint1] 		[expr $h1*1.0-$beam1];
node 2107 	[expr $l*1.0+$colint1] 		[expr $h1*1.0-$beam1];
node 2108 	[expr $l*1.0-$colint1] 		[expr $h1*1.0-$beam1];
node 2109 	[expr $l*1.0-$colint1] 		[expr $h1*1.0-$beam1];
node 2110 	[expr $l*1.0-$colint1] 		[expr $h1*1.0];

# panel zone at Column 3
	
node 4101 	[expr $l*2.0-$colint1] 		[expr $h1*1.0+$beam1];
node 4102 	[expr $l*2.0-$colint1] 		[expr $h1*1.0+$beam1];
node 4103 	[expr $l*2.0+$colint1] 		[expr $h1*1.0+$beam1];
node 4104 	[expr $l*2.0+$colint1] 		[expr $h1*1.0+$beam1];
node 4105 	[expr $l*2.0+$colint1] 		[expr $h1*1.0];
node 4106 	[expr $l*2.0+$colint1] 		[expr $h1*1.0-$beam1];
node 4107 	[expr $l*2.0+$colint1] 		[expr $h1*1.0-$beam1];
node 4108 	[expr $l*2.0-$colint1] 		[expr $h1*1.0-$beam1];
node 4109 	[expr $l*2.0-$colint1] 		[expr $h1*1.0-$beam1];
node 4110 	[expr $l*2.0-$colint1] 		[expr $h1*1.0];

# panel zone at Column 4
	
node 5101 	[expr $l*3.0-$colext1] 		[expr $h1*1.0+$beam1];
node 5102 	[expr $l*3.0-$colext1] 		[expr $h1*1.0+$beam1];
node 5103 	[expr $l*3.0+$colext1] 		[expr $h1*1.0+$beam1];
node 5104 	[expr $l*3.0+$colext1] 		[expr $h1*1.0+$beam1];
node 5105 	[expr $l*3.0+$colext1] 		[expr $h1*1.0];
node 5106 	[expr $l*3.0+$colext1] 		[expr $h1*1.0-$beam1];
node 5107 	[expr $l*3.0+$colext1] 		[expr $h1*1.0-$beam1];
node 5108 	[expr $l*3.0-$colext1] 		[expr $h1*1.0-$beam1];
node 5109 	[expr $l*3.0-$colext1] 		[expr $h1*1.0-$beam1];
node 5110 	[expr $l*3.0-$colext1] 		[expr $h1*1.0];

# Floor 2

# panel zone at Column 1
	
node 1201 	[expr $l*0.0-$colext1] 		[expr $h1+$h*1.0+$beam1];
node 1202 	[expr $l*0.0-$colext1] 		[expr $h1+$h*1.0+$beam1];
node 1203 	[expr $l*0.0+$colext1] 		[expr $h1+$h*1.0+$beam1];
node 1204 	[expr $l*0.0+$colext1] 		[expr $h1+$h*1.0+$beam1];
node 1205 	[expr $l*0.0+$colext1] 		[expr $h1+$h*1.0];
node 1206 	[expr $l*0.0+$colext1] 		[expr $h1+$h*1.0-$beam1];
node 1207 	[expr $l*0.0+$colext1] 		[expr $h1+$h*1.0-$beam1];
node 1208 	[expr $l*0.0-$colext1] 		[expr $h1+$h*1.0-$beam1];
node 1209 	[expr $l*0.0-$colext1] 		[expr $h1+$h*1.0-$beam1];
node 1210 	[expr $l*0.0-$colext1] 		[expr $h1+$h*1.0];

# panel zone at Column 2
	
node 2201 	[expr $l*1.0-$colint1] 		[expr $h1+$h*1.0+$beam1];
node 2202 	[expr $l*1.0-$colint1] 		[expr $h1+$h*1.0+$beam1];
node 2203 	[expr $l*1.0+$colint1] 		[expr $h1+$h*1.0+$beam1];
node 2204 	[expr $l*1.0+$colint1] 		[expr $h1+$h*1.0+$beam1];
node 2205 	[expr $l*1.0+$colint1] 		[expr $h1+$h*1.0];
node 2206 	[expr $l*1.0+$colint1] 		[expr $h1+$h*1.0-$beam1];
node 2207 	[expr $l*1.0+$colint1] 		[expr $h1+$h*1.0-$beam1];
node 2208 	[expr $l*1.0-$colint1] 		[expr $h1+$h*1.0-$beam1];
node 2209 	[expr $l*1.0-$colint1] 		[expr $h1+$h*1.0-$beam1];
node 2210 	[expr $l*1.0-$colint1] 		[expr $h1+$h*1.0];

# panel zone at Column 3
	
node 4201 	[expr $l*2.0-$colint1] 		[expr $h1+$h*1.0+$beam1];
node 4202 	[expr $l*2.0-$colint1] 		[expr $h1+$h*1.0+$beam1];
node 4203 	[expr $l*2.0+$colint1] 		[expr $h1+$h*1.0+$beam1];
node 4204 	[expr $l*2.0+$colint1] 		[expr $h1+$h*1.0+$beam1];
node 4205 	[expr $l*2.0+$colint1] 		[expr $h1+$h*1.0];
node 4206 	[expr $l*2.0+$colint1] 		[expr $h1+$h*1.0-$beam1];
node 4207 	[expr $l*2.0+$colint1] 		[expr $h1+$h*1.0-$beam1];
node 4208 	[expr $l*2.0-$colint1] 		[expr $h1+$h*1.0-$beam1];
node 4209 	[expr $l*2.0-$colint1] 		[expr $h1+$h*1.0-$beam1];
node 4210 	[expr $l*2.0-$colint1] 		[expr $h1+$h*1.0];

# panel zone at Column 4
	
node 5201 	[expr $l*3.0-$colext1] 		[expr $h1+$h*1.0+$beam1];
node 5202 	[expr $l*3.0-$colext1] 		[expr $h1+$h*1.0+$beam1];
node 5203 	[expr $l*3.0+$colext1] 		[expr $h1+$h*1.0+$beam1];
node 5204 	[expr $l*3.0+$colext1] 		[expr $h1+$h*1.0+$beam1];
node 5205 	[expr $l*3.0+$colext1] 		[expr $h1+$h*1.0];
node 5206 	[expr $l*3.0+$colext1] 		[expr $h1+$h*1.0-$beam1];
node 5207 	[expr $l*3.0+$colext1] 		[expr $h1+$h*1.0-$beam1];
node 5208 	[expr $l*3.0-$colext1] 		[expr $h1+$h*1.0-$beam1];
node 5209 	[expr $l*3.0-$colext1] 		[expr $h1+$h*1.0-$beam1];
node 5210 	[expr $l*3.0-$colext1] 		[expr $h1+$h*1.0];

# Floor 3

# panel zone at Column 1
	
node 1301 	[expr $l*0.0-$colext3] 		[expr $h1+$h*2.0+$beam3];
node 1302 	[expr $l*0.0-$colext3] 		[expr $h1+$h*2.0+$beam3];
node 1303 	[expr $l*0.0+$colext3] 		[expr $h1+$h*2.0+$beam3];
node 1304 	[expr $l*0.0+$colext3] 		[expr $h1+$h*2.0+$beam3];
node 1305 	[expr $l*0.0+$colext3] 		[expr $h1+$h*2.0];
node 1306 	[expr $l*0.0+$colext3] 		[expr $h1+$h*2.0-$beam3];
node 1307 	[expr $l*0.0+$colext3] 		[expr $h1+$h*2.0-$beam3];
node 1308 	[expr $l*0.0-$colext3] 		[expr $h1+$h*2.0-$beam3];
node 1309 	[expr $l*0.0-$colext3] 		[expr $h1+$h*2.0-$beam3];
node 1310 	[expr $l*0.0-$colext3] 		[expr $h1+$h*2.0];

# panel zone at Column 2
	
node 2301 	[expr $l*1.0-$colint3] 		[expr $h1+$h*2.0+$beam3];
node 2302 	[expr $l*1.0-$colint3] 		[expr $h1+$h*2.0+$beam3];
node 2303 	[expr $l*1.0+$colint3] 		[expr $h1+$h*2.0+$beam3];
node 2304 	[expr $l*1.0+$colint3] 		[expr $h1+$h*2.0+$beam3];
node 2305 	[expr $l*1.0+$colint3] 		[expr $h1+$h*2.0];
node 2306 	[expr $l*1.0+$colint3] 		[expr $h1+$h*2.0-$beam3];
node 2307 	[expr $l*1.0+$colint3] 		[expr $h1+$h*2.0-$beam3];
node 2308 	[expr $l*1.0-$colint3] 		[expr $h1+$h*2.0-$beam3];
node 2309 	[expr $l*1.0-$colint3] 		[expr $h1+$h*2.0-$beam3];
node 2310	[expr $l*1.0-$colint3] 		[expr $h1+$h*2.0];

# panel zone at Column 3
	
node 4301 	[expr $l*2.0-$colint3] 		[expr $h1+$h*2.0+$beam3];
node 4302 	[expr $l*2.0-$colint3] 		[expr $h1+$h*2.0+$beam3];
node 4303 	[expr $l*2.0+$colint3] 		[expr $h1+$h*2.0+$beam3];
node 4304 	[expr $l*2.0+$colint3] 		[expr $h1+$h*2.0+$beam3];
node 4305 	[expr $l*2.0+$colint3] 		[expr $h1+$h*2.0];
node 4306 	[expr $l*2.0+$colint3] 		[expr $h1+$h*2.0-$beam3];
node 4307 	[expr $l*2.0+$colint3] 		[expr $h1+$h*2.0-$beam3];
node 4308 	[expr $l*2.0-$colint3] 		[expr $h1+$h*2.0-$beam3];
node 4309 	[expr $l*2.0-$colint3] 		[expr $h1+$h*2.0-$beam3];
node 4310 	[expr $l*2.0-$colint3] 		[expr $h1+$h*2.0];

# panel zone at Column 4
	
node 5301 	[expr $l*3.0-$colext3] 		[expr $h1+$h*2.0+$beam3];
node 5302 	[expr $l*3.0-$colext3] 		[expr $h1+$h*2.0+$beam3];
node 5303 	[expr $l*3.0+$colext3] 		[expr $h1+$h*2.0+$beam3];
node 5304 	[expr $l*3.0+$colext3] 		[expr $h1+$h*2.0+$beam3];
node 5305 	[expr $l*3.0+$colext3] 		[expr $h1+$h*2.0];
node 5306 	[expr $l*3.0+$colext3] 		[expr $h1+$h*2.0-$beam3];
node 5307 	[expr $l*3.0+$colext3] 		[expr $h1+$h*2.0-$beam3];
node 5308 	[expr $l*3.0-$colext3] 		[expr $h1+$h*2.0-$beam3];
node 5309 	[expr $l*3.0-$colext3] 		[expr $h1+$h*2.0-$beam3];
node 5310 	[expr $l*3.0-$colext3] 		[expr $h1+$h*2.0];

# Floor 4

# panel zone at Column 1
	
node 1401 	[expr $l*0.0-$colext3] 		[expr $h1+$h*3.0+$beam3];
node 1402 	[expr $l*0.0-$colext3] 		[expr $h1+$h*3.0+$beam3];
node 1403 	[expr $l*0.0+$colext3] 		[expr $h1+$h*3.0+$beam3];
node 1404 	[expr $l*0.0+$colext3] 		[expr $h1+$h*3.0+$beam3];
node 1405 	[expr $l*0.0+$colext3] 		[expr $h1+$h*3.0];
node 1406 	[expr $l*0.0+$colext3] 		[expr $h1+$h*3.0-$beam3];
node 1407 	[expr $l*0.0+$colext3] 		[expr $h1+$h*3.0-$beam3];
node 1408 	[expr $l*0.0-$colext3] 		[expr $h1+$h*3.0-$beam3];
node 1409 	[expr $l*0.0-$colext3] 		[expr $h1+$h*3.0-$beam3];
node 1410 	[expr $l*0.0-$colext3] 		[expr $h1+$h*3.0];

# panel zone at Column 2
	
node 2401 	[expr $l*1.0-$colint3] 		[expr $h1+$h*3.0+$beam3];
node 2402 	[expr $l*1.0-$colint3] 		[expr $h1+$h*3.0+$beam3];
node 2403 	[expr $l*1.0+$colint3] 		[expr $h1+$h*3.0+$beam3];
node 2404 	[expr $l*1.0+$colint3] 		[expr $h1+$h*3.0+$beam3];
node 2405 	[expr $l*1.0+$colint3] 		[expr $h1+$h*3.0];
node 2406 	[expr $l*1.0+$colint3] 		[expr $h1+$h*3.0-$beam3];
node 2407 	[expr $l*1.0+$colint3] 		[expr $h1+$h*3.0-$beam3];
node 2408 	[expr $l*1.0-$colint3] 		[expr $h1+$h*3.0-$beam3];
node 2409 	[expr $l*1.0-$colint3] 		[expr $h1+$h*3.0-$beam3];
node 2410	[expr $l*1.0-$colint3] 		[expr $h1+$h*3.0];

# panel zone at Column 3
	
node 4401 	[expr $l*2.0-$colint3] 		[expr $h1+$h*3.0+$beam3];
node 4402 	[expr $l*2.0-$colint3] 		[expr $h1+$h*3.0+$beam3];
node 4403 	[expr $l*2.0+$colint3] 		[expr $h1+$h*3.0+$beam3];
node 4404 	[expr $l*2.0+$colint3] 		[expr $h1+$h*3.0+$beam3];
node 4405 	[expr $l*2.0+$colint3] 		[expr $h1+$h*3.0];
node 4406 	[expr $l*2.0+$colint3] 		[expr $h1+$h*3.0-$beam3];
node 4407 	[expr $l*2.0+$colint3] 		[expr $h1+$h*3.0-$beam3];
node 4408 	[expr $l*2.0-$colint3] 		[expr $h1+$h*3.0-$beam3];
node 4409 	[expr $l*2.0-$colint3] 		[expr $h1+$h*3.0-$beam3];
node 4410 	[expr $l*2.0-$colint3] 		[expr $h1+$h*3.0];

# panel zone at Column 4
	
node 5401 	[expr $l*3.0-$colext3] 		[expr $h1+$h*3.0+$beam3];
node 5402 	[expr $l*3.0-$colext3] 		[expr $h1+$h*3.0+$beam3];
node 5403 	[expr $l*3.0+$colext3] 		[expr $h1+$h*3.0+$beam3];
node 5404 	[expr $l*3.0+$colext3] 		[expr $h1+$h*3.0+$beam3];
node 5405 	[expr $l*3.0+$colext3] 		[expr $h1+$h*3.0];
node 5406 	[expr $l*3.0+$colext3] 		[expr $h1+$h*3.0-$beam3];
node 5407 	[expr $l*3.0+$colext3] 		[expr $h1+$h*3.0-$beam3];
node 5408 	[expr $l*3.0-$colext3] 		[expr $h1+$h*3.0-$beam3];
node 5409 	[expr $l*3.0-$colext3] 		[expr $h1+$h*3.0-$beam3];
node 5410 	[expr $l*3.0-$colext3] 		[expr $h1+$h*3.0];

# Floor 5

# panel zone at Column 1
	
node 1501 	[expr $l*0.0-$colext5] 		[expr $h1+$h*4.0+$beam5];
node 1502 	[expr $l*0.0-$colext5] 		[expr $h1+$h*4.0+$beam5];
node 1503 	[expr $l*0.0+$colext5] 		[expr $h1+$h*4.0+$beam5];
node 1504 	[expr $l*0.0+$colext5] 		[expr $h1+$h*4.0+$beam5];
node 1505 	[expr $l*0.0+$colext5] 		[expr $h1+$h*4.0];
node 1506 	[expr $l*0.0+$colext5] 		[expr $h1+$h*4.0-$beam5];
node 1507 	[expr $l*0.0+$colext5] 		[expr $h1+$h*4.0-$beam5];
node 1508 	[expr $l*0.0-$colext5] 		[expr $h1+$h*4.0-$beam5];
node 1509 	[expr $l*0.0-$colext5] 		[expr $h1+$h*4.0-$beam5];
node 1510 	[expr $l*0.0-$colext5] 		[expr $h1+$h*4.0];

# panel zone at Column 2
	
node 2501 	[expr $l*1.0-$colint5] 		[expr $h1+$h*4.0+$beam5];
node 2502 	[expr $l*1.0-$colint5] 		[expr $h1+$h*4.0+$beam5];
node 2503 	[expr $l*1.0+$colint5] 		[expr $h1+$h*4.0+$beam5];
node 2504 	[expr $l*1.0+$colint5] 		[expr $h1+$h*4.0+$beam5];
node 2505 	[expr $l*1.0+$colint5] 		[expr $h1+$h*4.0];
node 2506 	[expr $l*1.0+$colint5] 		[expr $h1+$h*4.0-$beam5];
node 2507 	[expr $l*1.0+$colint5] 		[expr $h1+$h*4.0-$beam5];
node 2508 	[expr $l*1.0-$colint5] 		[expr $h1+$h*4.0-$beam5];
node 2509 	[expr $l*1.0-$colint5] 		[expr $h1+$h*4.0-$beam5];
node 2510	[expr $l*1.0-$colint5] 		[expr $h1+$h*4.0];

# panel zone at Column 3
	
node 4501 	[expr $l*2.0-$colint5] 		[expr $h1+$h*4.0+$beam5];
node 4502 	[expr $l*2.0-$colint5] 		[expr $h1+$h*4.0+$beam5];
node 4503 	[expr $l*2.0+$colint5] 		[expr $h1+$h*4.0+$beam5];
node 4504 	[expr $l*2.0+$colint5] 		[expr $h1+$h*4.0+$beam5];
node 4505 	[expr $l*2.0+$colint5] 		[expr $h1+$h*4.0];
node 4506 	[expr $l*2.0+$colint5] 		[expr $h1+$h*4.0-$beam5];
node 4507 	[expr $l*2.0+$colint5] 		[expr $h1+$h*4.0-$beam5];
node 4508 	[expr $l*2.0-$colint5] 		[expr $h1+$h*4.0-$beam5];
node 4509 	[expr $l*2.0-$colint5] 		[expr $h1+$h*4.0-$beam5];
node 4510 	[expr $l*2.0-$colint5] 		[expr $h1+$h*4.0];

# panel zone at Column 4
	
node 5501 	[expr $l*3.0-$colext5] 		[expr $h1+$h*4.0+$beam5];
node 5502 	[expr $l*3.0-$colext5] 		[expr $h1+$h*4.0+$beam5];
node 5503 	[expr $l*3.0+$colext5] 		[expr $h1+$h*4.0+$beam5];
node 5504 	[expr $l*3.0+$colext5] 		[expr $h1+$h*4.0+$beam5];
node 5505 	[expr $l*3.0+$colext5] 		[expr $h1+$h*4.0];
node 5506 	[expr $l*3.0+$colext5] 		[expr $h1+$h*4.0-$beam5];
node 5507 	[expr $l*3.0+$colext5] 		[expr $h1+$h*4.0-$beam5];
node 5508 	[expr $l*3.0-$colext5] 		[expr $h1+$h*4.0-$beam5];
node 5509 	[expr $l*3.0-$colext5] 		[expr $h1+$h*4.0-$beam5];
node 5510 	[expr $l*3.0-$colext5] 		[expr $h1+$h*4.0];

# Floor 6

# panel zone at Column 1
	
node 1601 	[expr $l*0.0-$colext5] 		[expr $h1+$h*5.0+$beam5];
node 1602 	[expr $l*0.0-$colext5] 		[expr $h1+$h*5.0+$beam5];
node 1603 	[expr $l*0.0+$colext5] 		[expr $h1+$h*5.0+$beam5];
node 1604 	[expr $l*0.0+$colext5] 		[expr $h1+$h*5.0+$beam5];
node 1605 	[expr $l*0.0+$colext5] 		[expr $h1+$h*5.0];
node 1606 	[expr $l*0.0+$colext5] 		[expr $h1+$h*5.0-$beam5];
node 1607 	[expr $l*0.0+$colext5] 		[expr $h1+$h*5.0-$beam5];
node 1608 	[expr $l*0.0-$colext5] 		[expr $h1+$h*5.0-$beam5];
node 1609 	[expr $l*0.0-$colext5] 		[expr $h1+$h*5.0-$beam5];
node 1610 	[expr $l*0.0-$colext5] 		[expr $h1+$h*5.0];

# panel zone at Column 2
	
node 2601 	[expr $l*1.0-$colint5] 		[expr $h1+$h*5.0+$beam5];
node 2602 	[expr $l*1.0-$colint5] 		[expr $h1+$h*5.0+$beam5];
node 2603 	[expr $l*1.0+$colint5] 		[expr $h1+$h*5.0+$beam5];
node 2604 	[expr $l*1.0+$colint5] 		[expr $h1+$h*5.0+$beam5];
node 2605 	[expr $l*1.0+$colint5] 		[expr $h1+$h*5.0];
node 2606 	[expr $l*1.0+$colint5] 		[expr $h1+$h*5.0-$beam5];
node 2607 	[expr $l*1.0+$colint5] 		[expr $h1+$h*5.0-$beam5];
node 2608 	[expr $l*1.0-$colint5] 		[expr $h1+$h*5.0-$beam5];
node 2609 	[expr $l*1.0-$colint5] 		[expr $h1+$h*5.0-$beam5];
node 2610	[expr $l*1.0-$colint5] 		[expr $h1+$h*5.0];

# panel zone at Column 3
	
node 4601 	[expr $l*2.0-$colint5] 		[expr $h1+$h*5.0+$beam5];
node 4602 	[expr $l*2.0-$colint5] 		[expr $h1+$h*5.0+$beam5];
node 4603 	[expr $l*2.0+$colint5] 		[expr $h1+$h*5.0+$beam5];
node 4604 	[expr $l*2.0+$colint5] 		[expr $h1+$h*5.0+$beam5];
node 4605 	[expr $l*2.0+$colint5] 		[expr $h1+$h*5.0];
node 4606 	[expr $l*2.0+$colint5] 		[expr $h1+$h*5.0-$beam5];
node 4607 	[expr $l*2.0+$colint5] 		[expr $h1+$h*5.0-$beam5];
node 4608 	[expr $l*2.0-$colint5] 		[expr $h1+$h*5.0-$beam5];
node 4609 	[expr $l*2.0-$colint5] 		[expr $h1+$h*5.0-$beam5];
node 4610 	[expr $l*2.0-$colint5] 		[expr $h1+$h*5.0];

# panel zone at Column 4
	
node 5601 	[expr $l*3.0-$colext5] 		[expr $h1+$h*5.0+$beam5];
node 5602 	[expr $l*3.0-$colext5] 		[expr $h1+$h*5.0+$beam5];
node 5603 	[expr $l*3.0+$colext5] 		[expr $h1+$h*5.0+$beam5];
node 5604 	[expr $l*3.0+$colext5] 		[expr $h1+$h*5.0+$beam5];
node 5605 	[expr $l*3.0+$colext5] 		[expr $h1+$h*5.0];
node 5606 	[expr $l*3.0+$colext5] 		[expr $h1+$h*5.0-$beam5];
node 5607 	[expr $l*3.0+$colext5] 		[expr $h1+$h*5.0-$beam5];
node 5608 	[expr $l*3.0-$colext5] 		[expr $h1+$h*5.0-$beam5];
node 5609 	[expr $l*3.0-$colext5] 		[expr $h1+$h*5.0-$beam5];
node 5610 	[expr $l*3.0-$colext5] 		[expr $h1+$h*5.0];

#Rigid diaphragm by using master-slave nodes, 1st Y axis corresponds to the master nodes.
# equalDOF $MasterNodeID $SlaveNodeID $dof1 $dof2
#First floor
equalDOF 1110 1105	1;
equalDOF 1110 2110	1;
equalDOF 1110 2105	1;
equalDOF 1110 31	1;
equalDOF 1110 4110	1;
equalDOF 1110 4105	1;
equalDOF 1110 5110	1;
equalDOF 1110 5105	1;
equalDOF 1110 61	1;


#Second floor
equalDOF 1210 1205	1;
equalDOF 1210 2210	1;
equalDOF 1210 2205	1;
equalDOF 1210 32	1;
equalDOF 1210 4210	1;
equalDOF 1210 4205	1;
equalDOF 1210 5210	1;
equalDOF 1210 5205	1;
equalDOF 1210 62	1;


#Third floor
equalDOF 1310 1305	1;
equalDOF 1310 2310	1;
equalDOF 1310 2305	1;
equalDOF 1310 33	1;
equalDOF 1310 4310	1;
equalDOF 1310 4305	1;
equalDOF 1310 5310	1;
equalDOF 1310 5305	1;
equalDOF 1310 63	1;

#Forth floor
equalDOF 1410 1405	1;
equalDOF 1410 2410	1;
equalDOF 1410 2405	1;
equalDOF 1410 34	1;
equalDOF 1410 4410	1;
equalDOF 1410 4405	1;
equalDOF 1410 5410	1;
equalDOF 1410 5405	1;
equalDOF 1410 64	1;


#Fifth floor
equalDOF 1510 1505	1;
equalDOF 1510 2510	1;
equalDOF 1510 2505	1;
equalDOF 1510 35	1;
equalDOF 1510 4510	1;
equalDOF 1510 4505	1;
equalDOF 1510 5510	1;
equalDOF 1510 5505	1;
equalDOF 1510 65	1;


#Sixth floor
equalDOF 1610 1605	1;
equalDOF 1610 2610	1;
equalDOF 1610 2605	1;
equalDOF 1610 36	1;
equalDOF 1610 4610	1;
equalDOF 1610 4605	1;
equalDOF 1610 5610	1;
equalDOF 1610 5605	1;
equalDOF 1610 66	1;

#############################################################################################

# Geometric Transformations and rigid offsets
geomTransf PDelta  1;	# Column

# Elements Columns From bottom to top.
#	External columns
#element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $transfTag <-mass $massDens> <-iter $maxIters $tol>

set smat 1;
set smatl [expr $smat*100];
set smata [expr $smat*1000];

set Z 355.0; # Z of the section Inches^3
set Iz 999.0e6; # Iz of the section mm^4
set A 36645.0; # Area of the section mm^2

# uniaxialMaterial Steel02 $matTag $Fy=(Z*fy) $E0=Es*I $b
uniaxialMaterial Steel02 $smat [expr $Z*$fz] [expr $Es*$Iz] $bs;
uniaxialMaterial MinMax $smatl $smat -min [expr -1*$muphi*$Z*$fz/($Es*$Iz)] -max [expr $muphi*$Z*$fz/($Es*$Iz)];
uniaxialMaterial Elastic  $smata  [expr $Es*$A];
section Aggregator $smat $smatl Mz $smata P;
# element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $transfTag
element beamWithHinges 1 10  116 $smat 354 $smat 354 $Es $A $Iz 1; # Left exterior column 1 floor
element beamWithHinges 2 50  516 $smat 354 $smat 354 $Es $A $Iz 1; # Right exterior column 1 floor
element beamWithHinges 3 117 126 $smat 354 $smat 354 $Es $A $Iz 1; # Left exterior column 2 floor
element beamWithHinges 4 517 526 $smat 354 $smat 354 $Es $A $Iz 1; # Right exterior column 2 floor


#	Internal columns 1-2 Floors W30x173

set smat	[expr $smat+1];
set smatl [expr $smat*100];
set smata [expr $smat*1000]; 

set Z 607.0; # Z of the section Inches^3
set Iz 3413.0e6; # Iz of the section mm^4
set A 32774.0; # Area of the section mm^2

# uniaxialMaterial Steel02 $matTag $Fy=(Z*fy) $E0=Es*I $b
uniaxialMaterial Steel02 $smat [expr $Z*$fz] [expr $Es*$Iz] $bs;
uniaxialMaterial MinMax $smatl $smat -min [expr -1*$muphi*$Z*$fz/($Es*$Iz)] -max [expr $muphi*$Z*$fz/($Es*$Iz)];
uniaxialMaterial Elastic  $smata  [expr $Es*$A];
section Aggregator $smat $smatl Mz $smata P;
# element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $transfTag
element beamWithHinges 5 20  216 $smat 696 $smat 696 $Es $A $Iz 1; # Left interior column 1 floor
element beamWithHinges 6 40  416 $smat 696 $smat 696 $Es $A $Iz 1; # Right interior column 1 floor
element beamWithHinges 7 217 226 $smat 696 $smat 696 $Es $A $Iz 1; # Left interior column 2 floor
element beamWithHinges 8 417 426 $smat 696 $smat 696 $Es $A $Iz 1; # Right interior column 2 floor

#	External columns 3-4 Floors W14x159

set smat	[expr $smat+1];
set smatl [expr $smat*100];
set smata [expr $smat*1000]; 

set Z 287.0; # Z of the section Inches^3
set Iz 791.0e6; # Iz of the section mm^4
set A 30129.0; # Area of the section mm^2

# uniaxialMaterial Steel02 $matTag $Fy=(Z*fy) $E0=Es*I $b
uniaxialMaterial Steel02 $smat [expr $Z*$fz] [expr $Es*$Iz] $bs;
uniaxialMaterial MinMax $smatl $smat -min [expr -1*$muphi*$Z*$fz/($Es*$Iz)] -max [expr $muphi*$Z*$fz/($Es*$Iz)];
uniaxialMaterial Elastic  $smata  [expr $Es*$A];
section Aggregator $smat $smatl Mz $smata P;
# element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $transfTag
element beamWithHinges  9 127 136 $smat 343 $smat 343 $Es $A $Iz 1; # Left exterior column 3 floor
element beamWithHinges 10 527 536 $smat 343 $smat 343 $Es $A $Iz 1; # Right exterior column 3 floor
element beamWithHinges 11 137 146 $smat 343 $smat 343 $Es $A $Iz 1; # Left exterior column 4 floor
element beamWithHinges 12 537 546 $smat 343 $smat 343 $Es $A $Iz 1; # Right exterior column 4 floor



#	Internal columns 3-4 Floors W27x146

set smat	[expr $smat+1];
set smatl [expr $smat*100];
set smata [expr $smat*1000]; 

set Z 464.0; # Z of the section Inches^3
set Iz 2343.0e6; # Iz of the section mm^4
set A 27678.0; # Area of the section mm^2

# uniaxialMaterial Steel02 $matTag $Fy=(Z*fy) $E0=Es*I $b
uniaxialMaterial Steel02 $smat [expr $Z*$fz] [expr $Es*$Iz] $bs;
uniaxialMaterial MinMax $smatl $smat -min [expr -1*$muphi*$Z*$fz/($Es*$Iz)] -max [expr $muphi*$Z*$fz/($Es*$Iz)];
uniaxialMaterial Elastic  $smata  [expr $Es*$A];
section Aggregator $smat $smatl Mz $smata P;
# element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $transfTag
element beamWithHinges 13 227 236 $smat 626 $smat 626 $Es $A $Iz 1; # Left interior column 3 floor
element beamWithHinges 14 427 436 $smat 626 $smat 626 $Es $A $Iz 1; # Right interior column 3 floor
element beamWithHinges 15 237 246 $smat 626 $smat 626 $Es $A $Iz 1; # Left interior column 4 floor
element beamWithHinges 16 437 446 $smat 626 $smat 626 $Es $A $Iz 1; # Right interior column 4 floor

#	External columns 5-6 Floors W14x109

set smat	[expr $smat+1];
set smatl [expr $smat*100];
set smata [expr $smat*1000]; 

set Z 192.0; # Z of the section Inches^3
set Iz 516.0e6; # Iz of the section mm^4
set A 20645.0; # Area of the section mm^2

# uniaxialMaterial Steel02 $matTag $Fy=(Z*fy) $E0=Es*I $b
uniaxialMaterial Steel02 $smat [expr $Z*$fz] [expr $Es*$Iz] $bs;
uniaxialMaterial MinMax $smatl $smat -min [expr -1*$muphi*$Z*$fz/($Es*$Iz)] -max [expr $muphi*$Z*$fz/($Es*$Iz)];
uniaxialMaterial Elastic  $smata  [expr $Es*$A];
section Aggregator $smat $smatl Mz $smata P;
# element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $transfTag
element beamWithHinges 17 147 156 $smat 328 $smat 328 $Es $A $Iz 1; # Left exterior column 5 floor
element beamWithHinges 18 547 556 $smat 328 $smat 328 $Es $A $Iz 1; # Right exterior column 5 floor
element beamWithHinges 19 157 166 $smat 328 $smat 328 $Es $A $Iz 1; # Left exterior column 6 floor
element beamWithHinges 20 557 566 $smat 328 $smat 328 $Es $A $Iz 1; # Right exterior column 6 floor

#	Internal columns 5-6 Floors W24x104

set smat	[expr $smat+1];
set smatl [expr $smat*100];
set smata [expr $smat*1000]; 

set Z 289.0; # Z of the section Inches^3
set Iz 1290.0e6; # Iz of the section mm^4
set A 19742.0; # Area of the section mm^2

# uniaxialMaterial Steel02 $matTag $Fy=(Z*fy) $E0=Es*I $b
uniaxialMaterial Steel02 $smat [expr $Z*$fz] [expr $Es*$Iz] $bs;
uniaxialMaterial MinMax $smatl $smat -min [expr -1*$muphi*$Z*$fz/($Es*$Iz)] -max [expr $muphi*$Z*$fz/($Es*$Iz)];
uniaxialMaterial Elastic  $smata  [expr $Es*$A];
section Aggregator $smat $smatl Mz $smata P;
# element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $transfTag
element beamWithHinges 21 247 256 $smat 550 $smat 550 $Es $A $Iz 1; # Left interior column 5 floor
element beamWithHinges 22 447 456 $smat 550 $smat 550 $Es $A $Iz 1; # Right interior column 5 floor
element beamWithHinges 23 257 266 $smat 550 $smat 550 $Es $A $Iz 1; # Left interior column 6 floor
element beamWithHinges 24 457 466 $smat 550 $smat 550 $Es $A $Iz 1; # Right interior column 6 floor


# Elements Beams From bottom to top.

#	1 - 2 floor W30x99

set smat	[expr $smat+1];
set smatl [expr $smat*100];
set smata [expr $smat*1000]; 

set Z 312.0; # Z of the section Inches^3
set Iz 1661.0e6; # Iz of the section mm^4
set A 18774.0; # Area of the section mm^2

# uniaxialMaterial Steel02 $matTag $Fy=(Z*fy) $E0=Es*I $b
uniaxialMaterial Steel02 $smat [expr $Z*$fz] [expr $Es*$Iz] $bs;
uniaxialMaterial MinMax $smatl $smat -min [expr -1*$muphi*$Z*$fz/($Es*$Iz)] -max [expr $muphi*$Z*$fz/($Es*$Iz)];
uniaxialMaterial Elastic  $smata  [expr $Es*$A];
section Aggregator $smat $smatl Mz $smata P;
# element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $transfTag
element beamWithHinges 25 1105 2110 $smat 678 $smat 678 $Es $A $Iz 1; # Left exterior beam 1 floor
element beamWithHinges 26 2105 31 $smat 678 $smat 678 $Es $A $Iz 1; # Left interior beam 1 floor
element beamWithHinges 27 31 4110 $smat 678 $smat 678 $Es $A $Iz 1; # Right interior beam 1 floor
element beamWithHinges 28 4105 5110 $smat 678 $smat 678 $Es $A $Iz 1; # Right exterior beam 1 floor
element beamWithHinges 29 1205 2210 $smat 678 $smat 678 $Es $A $Iz 1; # Left exterior beam 2 floor
element beamWithHinges 30 2205 32 $smat 678 $smat 678 $Es $A $Iz 1; # Left interior beam 2 floor
element beamWithHinges 31 32 4210 $smat 678 $smat 678 $Es $A $Iz 1; # Right interior beam 2 floor
element beamWithHinges 32 4205 5210 $smat 678 $smat 678 $Es $A $Iz 1; # Right exterior beam 2 floor


#	3 - 4 floor W27x94

set smat	[expr $smat+1];
set smatl [expr $smat*100];
set smata [expr $smat*1000]; 

set Z 278.0; # Z of the section Inches^3
set Iz 1361.0e6; # Iz of the section mm^4
set A 17871.0; # Area of the section mm^2

# uniaxialMaterial Steel02 $matTag $Fy=(Z*fy) $E0=Es*I $b
uniaxialMaterial Steel02 $smat [expr $Z*$fz] [expr $Es*$Iz] $bs;
uniaxialMaterial MinMax $smatl $smat -min [expr -1*$muphi*$Z*$fz/($Es*$Iz)] -max [expr $muphi*$Z*$fz/($Es*$Iz)];
uniaxialMaterial Elastic  $smata  [expr $Es*$A];
section Aggregator $smat $smatl Mz $smata P;
# element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $transfTag
element beamWithHinges 33 1305 2310 $smat 616 $smat 616 $Es $A $Iz 1; # Left exterior beam 3 floor
element beamWithHinges 34 2305 33 $smat 616 $smat 616 $Es $A $Iz 1; # Left interior beam 3 floor
element beamWithHinges 35 33 4310 $smat 616 $smat 616 $Es $A $Iz 1; # Right interior beam 3floor
element beamWithHinges 36 4305 5310 $smat 616 $smat 616 $Es $A $Iz 1; # Right exterior beam 3floor
element beamWithHinges 37 1405 2410 $smat 616 $smat 616 $Es $A $Iz 1; # Left exterior beam 4 floor
element beamWithHinges 38 2405 34 $smat 616 $smat 616 $Es $A $Iz 1; # Left interior beam 4 floor
element beamWithHinges 39 34 4410 $smat 616 $smat 616 $Es $A $Iz 1; # Right interior beam 4 floor
element beamWithHinges 40 4405 5410 $smat 616 $smat 616 $Es $A $Iz 1; # Right exterior beam 4 floor


#	5 - 6 floor W24x76

set smat	[expr $smat+1];
set smatl [expr $smat*100];
set smata [expr $smat*1000]; 

set Z 200.0; # Z of the section Inches^3
set Iz 874.1e6; # Iz of the section mm^4
set A 14452.0; # Area of the section mm^2

# uniaxialMaterial Steel02 $matTag $Fy=(Z*fy) $E0=Es*I $b
uniaxialMaterial Steel02 $smat [expr $Z*$fz] [expr $Es*$Iz] $bs;
uniaxialMaterial MinMax $smatl $smat -min [expr -1*$muphi*$Z*$fz/($Es*$Iz)] -max [expr $muphi*$Z*$fz/($Es*$Iz)];
uniaxialMaterial Elastic  $smata  [expr $Es*$A];
section Aggregator $smat $smatl Mz $smata P;
# element beamWithHinges $eleTag $iNode $jNode $secTagI $Lpi $secTagJ $Lpj $E $A $Iz $transfTag
element beamWithHinges 41 1505 2510 $smat 547 $smat 547 $Es $A $Iz 1; # Left exterior beam 5 floor
element beamWithHinges 42 2505 35 $smat 547 $smat 547 $Es $A $Iz 1; # Left interior beam 5 floor
element beamWithHinges 43 35 4510 $smat 547 $smat 547 $Es $A $Iz 1; # Right interior beam 5floor
element beamWithHinges 44 4505 5510 $smat 547 $smat 547 $Es $A $Iz 1; # Right exterior beam 5floor
element beamWithHinges 45 1605 2610 $smat 547 $smat 547 $Es $A $Iz 1; # Left exterior beam 6 floor
element beamWithHinges 46 2605 36 $smat 547 $smat 547 $Es $A $Iz 1; # Left interior beam 6 floor
element beamWithHinges 47 36 4610 $smat 547 $smat 547 $Es $A $Iz 1; # Right interior beam 6 floor
element beamWithHinges 48 4605 5610 $smat 547 $smat 547 $Es $A $Iz 1; # Right exterior beam 6 floor



# P-Delta Columns
set smat	[expr $smat+1];
set smata [expr $smat*1000];

set Iz 1.0e13;
set A 1.0e8; # Area of the section mm^2

uniaxialMaterial Elastic  $smat  1.0e-9;
uniaxialMaterial Elastic  $smata  [expr $Es*$A];
section Aggregator $smat $smat Mz $smata P;

element beamWithHinges 49 60 61 $smat 396 $smat 396 $Es $A $Iz 1; # P-Delta column 1 floor
element beamWithHinges 50 61 62 $smat 396 $smat 396 $Es $A $Iz 1; # P-Delta column 2 floor
element beamWithHinges 51 62 63 $smat 396 $smat 396 $Es $A $Iz 1; # P-Delta column 3 floor
element beamWithHinges 52 63 64 $smat 396 $smat 396 $Es $A $Iz 1; # P-Delta column 4 floor
element beamWithHinges 53 64 65 $smat 396 $smat 396 $Es $A $Iz 1; # P-Delta column 5 floor
element beamWithHinges 54 65 66 $smat 396 $smat 396 $Es $A $Iz 1; # P-Delta column 6 floor

# Truss elements to connect frame to P-Delta columns
set smat	[expr $smat+1];
uniaxialMaterial Elastic  $smat  $Es;
section Aggregator $smat $smat P;

element truss 55 5105 61 $A $smat;
element truss 56 5205 62 $A $smat;
element truss 57 5305 63 $A $smat;
element truss 58 5405 64 $A $smat;
element truss 59 5505 65 $A $smat;
element truss 60 5605 66 $A $smat;
set smat	[expr $smat+1];

# Define elastic panel zone elements (assume rigid)
# elemPanelZone2D creates 8 elastic elements that form a rectangular panel zone
# references provided in elemPanelZone2D.tcl
# note: the nodeID and eleID of the upper left corner of the PZ must be imported
# eleID convention:  500xya, 500 = panel zone element, x = Column #, y = Floor #
# "a" convention: defined in elemPanelZone2D.tcl, but 1 = top left element
set Apz 95.0e5;	# area of panel zone element (make much larger than A of frame elements)
set Ipz 41.0e10;  # moment of intertia of panel zone element (make much larger than I of frame elements)

# Panel zone
source rotPanelZone2D.tcl;
source elemPanelZone2D.tcl;
#Floor 1
elemPanelZone2D   500111 1101 $Es $Apz $Ipz 1;	# Column 1, Floor 1
elemPanelZone2D   500211 2101 $Es $Apz $Ipz 1;	# Column 2, Floor 1
elemPanelZone2D   500411 4101 $Es $Apz $Ipz 1;	# Column 4, Floor 1
elemPanelZone2D   500511 5101 $Es $Apz $Ipz 1;	# Column 5, Floor 1

#Floor 2
elemPanelZone2D   500121 1201 $Es $Apz $Ipz 1;	# Column 1, Floor 1
elemPanelZone2D   500221 2201 $Es $Apz $Ipz 1;	# Column 2, Floor 1
elemPanelZone2D   500421 4201 $Es $Apz $Ipz 1;	# Column 4, Floor 1
elemPanelZone2D   500521 5201 $Es $Apz $Ipz 1;	# Column 5, Floor 1

#Floor 3
elemPanelZone2D   500131 1301 $Es $Apz $Ipz 1;	# Column 1, Floor 1
elemPanelZone2D   500231 2301 $Es $Apz $Ipz 1;	# Column 2, Floor 1
elemPanelZone2D   500431 4301 $Es $Apz $Ipz 1;	# Column 4, Floor 1
elemPanelZone2D   500531 5301 $Es $Apz $Ipz 1;	# Column 5, Floor 1

#Floor 4
elemPanelZone2D   500141 1401 $Es $Apz $Ipz 1;	# Column 1, Floor 1
elemPanelZone2D   500241 2401 $Es $Apz $Ipz 1;	# Column 2, Floor 1
elemPanelZone2D   500441 4401 $Es $Apz $Ipz 1;	# Column 4, Floor 1
elemPanelZone2D   500541 5401 $Es $Apz $Ipz 1;	# Column 5, Floor 1

#Floor 5
elemPanelZone2D   500151 1501 $Es $Apz $Ipz 1;	# Column 1, Floor 1
elemPanelZone2D   500251 2501 $Es $Apz $Ipz 1;	# Column 2, Floor 1
elemPanelZone2D   500451 4501 $Es $Apz $Ipz 1;	# Column 4, Floor 1
elemPanelZone2D   500551 5501 $Es $Apz $Ipz 1;	# Column 5, Floor 1

#Floor 6
elemPanelZone2D   500161 1601 $Es $Apz $Ipz 1;	# Column 1, Floor 1
elemPanelZone2D   500261 2601 $Es $Apz $Ipz 1;	# Column 2, Floor 1
elemPanelZone2D   500461 4601 $Es $Apz $Ipz 1;	# Column 4, Floor 1
elemPanelZone2D   500561 5601 $Es $Apz $Ipz 1;	# Column 5, Floor 1

#define panel zone springs
# rotPanelZone2D creates a uniaxial material spring with a trilinear response based on the Krawinkler Model
# It also constrains the nodes in the corners of the panel zone.
# references provided in rotPanelZone2D.tcl
# note: the upper right corner nodes of the PZ must be imported

set Ry 1.2; 	# expected yield strength multiplier
set as_PZ $bs; # strain hardening of panel zones

# Spring ID: "600xya" where 600 = panel zone spring, x = Column #, y = Floor #
#First Floor
#             ElemID  ndR  ndC  E   Fy   		dc       bf_c   	tf_c    tp        	db      		Ry   as
#             ElemID  ndR  ndC  E   Fy   		dc       bf_c   	tf_c    tp        	db      		Ry   as
rotPanelZone2D 600111 1103 1104 $Es $fy [expr $colext1*2.0] 399.0	37.0	23.0	[expr $beam1*2.0] $Ry $as_PZ;
rotPanelZone2D 600211 2103 2104 $Es $fy [expr $colint1*2.0] 381.0	27.0	17.0	[expr $beam1*2.0] $Ry $as_PZ;
rotPanelZone2D 600411 4103 4104 $Es $fy [expr $colint1*2.0] 381.0	27.0	17.0	[expr $beam1*2.0] $Ry $as_PZ;
rotPanelZone2D 600511 5103 5104 $Es $fy [expr $colext1*2.0] 399.0	37.0	23.0	[expr $beam1*2.0] $Ry $as_PZ;

#Second Floor
#             ElemID  ndR  ndC  E   Fy   		dc       bf_c   	tf_c    tp        	db      		Ry   as
rotPanelZone2D 600121 1203 1204 $Es $fy [expr $colext1*2.0] 399.0	37.0	23.0	[expr $beam1*2.0] $Ry $as_PZ;
rotPanelZone2D 600221 2203 2204 $Es $fy [expr $colint1*2.0] 381.0	27.0	17.0	[expr $beam1*2.0] $Ry $as_PZ;
rotPanelZone2D 600421 4203 4204 $Es $fy [expr $colint1*2.0] 381.0	27.0	17.0	[expr $beam1*2.0] $Ry $as_PZ;
rotPanelZone2D 600521 5203 5204 $Es $fy [expr $colext1*2.0] 399.0	37.0	23.0	[expr $beam1*2.0] $Ry $as_PZ;

#Third Floor
#             ElemID  ndR  ndC  E   Fy   		dc       bf_c   	tf_c    tp        	db      		Ry   as
rotPanelZone2D 600131 1303 1304 $Es $fy [expr $colext3*2.0] 396.0	30.0	19.0	[expr $beam3*2.0] $Ry $as_PZ;
rotPanelZone2D 600231 2303 2304 $Es $fy [expr $colint3*2.0] 356.0	25.0	15.0	[expr $beam3*2.0] $Ry $as_PZ;
rotPanelZone2D 600431 4303 4304 $Es $fy [expr $colint3*2.0] 356.0	25.0	15.0	[expr $beam3*2.0] $Ry $as_PZ;
rotPanelZone2D 600531 5303 5304 $Es $fy [expr $colext3*2.0] 396.0	30.0	19.0	[expr $beam3*2.0] $Ry $as_PZ;

#Forth Floor
#             ElemID  ndR  ndC  E   Fy   		dc       bf_c   	tf_c    tp        	db      		Ry   as
rotPanelZone2D 600141 1403 1404 $Es $fy [expr $colext3*2.0] 396.0	30.0	19.0	[expr $beam3*2.0] $Ry $as_PZ;
rotPanelZone2D 600241 2403 2404 $Es $fy [expr $colint3*2.0] 356.0	25.0	15.0	[expr $beam3*2.0] $Ry $as_PZ;
rotPanelZone2D 600441 4403 4404 $Es $fy [expr $colint3*2.0] 356.0	25.0	15.0	[expr $beam3*2.0] $Ry $as_PZ;
rotPanelZone2D 600541 5403 5404 $Es $fy [expr $colext3*2.0] 396.0	30.0	19.0	[expr $beam3*2.0] $Ry $as_PZ;

#Fifth Floor
#             ElemID  ndR  ndC  E   Fy   		dc       bf_c   	tf_c    tp        	db      		Ry   as
rotPanelZone2D 600151 1503 1504 $Es $fy [expr $colext5*2.0] 371.0	22.0	13.0	[expr $beam5*2.0] $Ry $as_PZ;
rotPanelZone2D 600251 2503 2504 $Es $fy [expr $colint5*2.0] 325.0	19.0	13.0	[expr $beam5*2.0] $Ry $as_PZ;
rotPanelZone2D 600451 4503 4504 $Es $fy [expr $colint5*2.0] 325.0	19.0	13.0	[expr $beam5*2.0] $Ry $as_PZ;
rotPanelZone2D 600551 5503 5504 $Es $fy [expr $colext5*2.0] 371.0	22.0	13.0	[expr $beam5*2.0] $Ry $as_PZ;

#Sixth Floor
#             ElemID  ndR  ndC  E   Fy   		dc       bf_c   	tf_c    tp        	db      		Ry   as
rotPanelZone2D 600161 1603 1604 $Es $fy [expr $colext5*2.0] 371.0	22.0	13.0	[expr $beam5*2.0] $Ry $as_PZ;
rotPanelZone2D 600261 2603 2604 $Es $fy [expr $colint5*2.0] 325.0	19.0	13.0	[expr $beam5*2.0] $Ry $as_PZ;
rotPanelZone2D 600461 4603 4604 $Es $fy [expr $colint5*2.0] 325.0	19.0	13.0	[expr $beam5*2.0] $Ry $as_PZ;
rotPanelZone2D 600561 5603 5604 $Es $fy [expr $colext5*2.0] 371.0	22.0	13.0	[expr $beam5*2.0] $Ry $as_PZ;


puts "Model Built"


### Display Model 
 # recorder display "Displaced shape" 10 10 1000 500 -wipe
 # prp 200. 50. 1;
 # vup  0  1 0;
 # vpn  0  0 1;
 # display 1 5 40

# Define List of elements 
set Reactions {10 20 40 50 60};
set nodes {10 1110 31 1210 32 1310 33 1410 34 1510 35 1610 36};
set N1_PO  {116 216 416 516};
set N2_PO  {126 226 426 526};
set N3_PO  {136 236 436 536};
set N4_PO  {146 246 446 546};
set N5_PO  {156 256 456 556};
set N6_PO  {166 266 466 566};

set columns {1 5 6 2  3 7 8 4 9 13 14 10 11 15 16 12 17 21 22 18 19 23 24 20};
set beams {25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48}; 

set topnodes {1110 1210 1310 1410 1510 1610};
set botnodes {10 1110 1210 1310 1410 1510};
# set braces {361 461};
set damper {10}


pattern Plain 101 Constant {
	for {set i 1} {$i <=$nfl} {incr i 1} {
		if {$i<$nfl} {
			load 1${i}6 0 -162.77 0;
			load 2${i}6 0 -237.56 0;
			load 4${i}6 0 -237.56 0;
			load 5${i}6 0 -162.77 0;
			load 6${i} 0 -1815.64 0;
		}
		if {$i==$nfl} {
			load 1${i}6 0 -76.61 0;
			load 2${i}6 0 -138.76 0;
			load 4${i}6 0 -138.76 0;
			load 5${i}6 0 -76.61 0;
			load 6${i} 0 -1192.86 0;
			}
		}
	}


# pattern Plain 101 Constant {
# 	# load 116 0.0 -116.0 0.0
# 	# load 216 0.0 -233.0 0.0
# 	# load 416 0.0 -233.0 0.0
# 	# load 516 0.0 -116.0 0.0
# 	# load 61 0.0 -3484.0 0.0

# 	# load 126 0.0 -116.0 0.0
# 	# load 226 0.0 -233.0 0.0
# 	# load 426 0.0 -233.0 0.0
# 	# load 526 0.0 -116.0 0.0
# 	# load 62 0.0 -3484.0 0.0

# 	# load 136 0.0 -103.0 0.0
# 	# load 236 0.0 -207.0 0.0
# 	# load 436 0.0 -207.0 0.0
# 	# load 536 0.0 -103.0 0.0
# 	# load 63 0.0 -3094.0 0.0

# 	load 116 0.0 -1.0 0.0
# 	load 216 0.0 -2.0 0.0
# 	load 416 0.0 -2.0 0.0
# 	load 516 0.0 -1.0 0.0
# 	load 61 0.0 -3.0 0.0

# 	load 126 0.0 -1.0 0.0
# 	load 226 0.0 -2.0 0.0
# 	load 426 0.0 -2.0 0.0
# 	load 526 0.0 -1.0 0.0
# 	load 62 0.0 -3.0 0.0

# 	load 136 0.0 -1.0 0.0
# 	load 236 0.0 -2.0 0.0
# 	load 436 0.0 -2.0 0.0
# 	load 536 0.0 -1.0 0.0
# 	load 63 0.0 -3.0 0.0

# }




		# pattern Plain 101 Linear {
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

# recorder Node -file RBase.txt -node 10 20 40 50 -dof 1 reaction

# 		constraints Plain
# 		numberer RCM
# 		system UmfPack  
# 		test EnergyIncr	1e-8 500
# 		algorithm KrylovNewton
# 		set nG 100
# 		integrator LoadControl [expr 1/$nG]
# 		analysis Static
# 		analyze $nG
# 		loadConst -time 0.0

# 		wipe;
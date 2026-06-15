/*[Station]*/
rows=2;
columns=1;
// Could be made thinner but then you should add legs. Make sure the total height/thickness is 9 or more or else the switches will touch the ground.
caseThickness=9;
switch="MX"; // ["MX","ALPS"]
showSwitch=false;

/*[Legs]*/
legs=false;
legWidth=3;
legLength=3;
legHeight=6;

/*[Puzzle]*/
puzzle=false;
leftPuzzle=true;
rightPuzzle=true;
frontPuzzle=true;
backPuzzle=true;



/*[Danger zone]*/
// Measured from key cap center to key cap center
space=19.04;
plateLength=space*1.089;

/*[MX settings]*/
MX_cutXSize=14;
MX_cutYSize=15;
MX_notchX=4;
MX_notchY=0.50;

/*[ALPS settings]*/
ALPS_cutXSize=12.8;
ALPS_cutYSize=16.0;

function legZ(thickness,legHeight) = -(thickness*0.5+legHeight*0.5);

module MXSwitch(){
	// Awesome Cherry MX model created by gcb
	// Lib: Cherry MX switch - reference
	// Download here: https://www.thingiverse.com/thing:421524
	//  p=cherrySize/2+0.53;
	translate([0,0,13.2])
  rotate([0,0,-90])
		import("switch_mx.stl");
}

module ALPSSwitch(){
  // ALPS model created by qwelyt (me)
  // Lib: ALPS switch - reference
  // Download here: https://www.thingiverse.com/thing:3829342
  translate([0,0,-2])
  rotate([0,0,0])
  import("ALPS-switch.stl");
}

module leg(){
  cube([legWidth,legLength,legHeight],center=true);
}


module legs(thickness,rows,cols, row, col){
  x=(space*0.5-legWidth*0.5);
  y=(plateLength*0.5-legLength*0.5);
  z=legZ(thickness,legHeight);
  
  translate([0,0,0])translate([-x,-y,z])leg();
  translate([space*rows,0,0])translate([x,-y,z])leg();
  translate([0,space*cols,0])translate([-x,y,z])leg();
  translate([space*rows,space*cols,0])translate([x,y,z])leg();
  
}

module KeyPlate(w=space,l=plateLength,h=caseThickness,center=true){
	cube([w,l,h],center=center);
}

module MXCut(thickness,x,y,MX_notchX,MX_notchY){
  union(){
    difference(){
      cube([x,y,thickness+2],center=true);
      
      translate([0,y/2,0])
      cube([MX_notchX,MX_notchY,thickness+3],center=true);
      
      translate([0,-y/2,0])
      cube([MX_notchX,MX_notchY,thickness+3],center=true);
    }
  }
}

module ALPSCut(thickness){
  cube([ALPS_cutXSize,ALPS_cutYSize,thickness+2],center=true);
}

module puzzleCut(thickness,hook){
  size = hook ? 9 : 10;
  move = hook ? 1 : 0;
  difference(){
    translate([0,0,0])rotate([0,0,45])cube([size,size,thickness],center=true);
    
    translate([0,size*0.4,0])cube([size*2,size,thickness+2],center=true);
    
    translate([0,-((size*0.8)+move),0])cube([size*2,size,thickness+2],center=true);
  }
}

module plate(){
   union(){
    for(r=[0:rows-1]){
      for(c=[0:columns-1]){
        translate([space*r, space*c,0]){
          difference(){
            KeyPlate();
            if(switch == "MX"){
              MXCut(caseThickness,MX_cutXSize,MX_cutYSize,MX_notchX,MX_notchY*2);
            } else if(switch == "ALPS"){
              ALPSCut(caseThickness);
            } else {
              cube([space*0.8,space*0.8,caseThickness+2],center=true);
            }
          }
          if(showSwitch){
            if(switch == "MX"){
              #translate([0,0,caseThickness/2])MXSwitch();
            } else if(switch == "ALPS"){
              #translate([0,0,caseThickness/2])ALPSSwitch();
            } else {
              #translate([0,0,caseThickness/2])
              cube([space*0.8,space*0.8,caseThickness+2],center=true);
            }
          }
          
          
        }
      }
    }
  }
}

module build_swithes(){
  union(){
    if(puzzle){
      difference(){
        plate();
        if(backPuzzle){
          translate([0,-space*0.39,0])puzzleCut(caseThickness+2,false);
          
          translate([space*(rows-1),-space*0.39,0])puzzleCut(caseThickness+2,false);
        }
    
        if(rightPuzzle){
          translate([-space*0.346,0,0])rotate([0,0,-90])puzzleCut(caseThickness+2,false);
          
          translate([-space*0.346,space*(cols-1),0])rotate([0,0,-90])puzzleCut(caseThickness+2,false);
        }
      }
      
      if(frontPuzzle){
        translate([0,space*cols-space*0.3,0])puzzleCut(caseThickness,true);
        
        translate([space*(rows-1),space*cols-space*0.3,0])puzzleCut(caseThickness,true);
      }
      
      if(leftPuzzle){
        translate([space*rows-space*0.35,0,0])rotate([0,0,-90])puzzleCut(caseThickness,true);
        
        translate([space*rows-space*0.35,space*(cols-1),0])rotate([0,0,-90])puzzleCut(caseThickness,true);
      }
      
    } else {
      plate();
    }
 
    if(legs){
      legs(caseThickness,rows-1,cols-1,0,0);
    }
  }
}




case_w = 85;
case_h = 45;
case_d = 20;
wall = 2;
r = 4;

module rounded_cube(size=[70,40,20], r=4) {
    minkowski() {
        cube([
            size[0] - 2*r,
            size[1] - 2*r,
            size[2] - 2*r
        ], center=true);
        sphere(r=r);
    }
}

module hollow_body() {
    difference() {
        rounded_cube([case_w, case_h, case_d], r);

        translate([0,0,-wall])
            rounded_cube([
                case_w - 2*wall,
                case_h - 2*wall,
                case_d
            ], max(r-wall,1));
    }
}

module switch_holes_only() {
    for(rw=[0:rows-1]) {
        for(cl=[0:columns-1]) {
            translate([space*rw, space*cl, 6])
                MXCut(caseThickness + 4,
                      MX_cutXSize,
                      MX_cutYSize,
                      MX_notchX,
                      MX_notchY*2);
        }
    }
}

// ---------- Feather mount ----------
feather_w = 22.86;
feather_l = 50.8;
feather_hole_d = 2.6;      // clearance for M2-ish screw, tweak if needed
standoff_d = 5.5;
standoff_h = 12;
standoff_z = -case_d/2 + wall + standoff_h/2;

// Approximate mounting hole positions.
// Tune after a print if needed.
feather_hole_x = feather_l/2 - 2.54;
feather_hole_y = feather_w/2 - 2.54;

// Place Feather lengthwise in the case.
// Shift if USB is not aligned.
feather_x_offset = 2;
feather_y_offset = 0;

module feather_standoff(x, y) {
    translate([x + feather_x_offset, y + feather_y_offset, standoff_z])
    difference() {
        cylinder(h=standoff_h, d=standoff_d, center=true);
        cylinder(h=standoff_h + 1, d=feather_hole_d, center=true);
    }
}

module feather_mounts() {
    feather_standoff(-feather_hole_x, -feather_hole_y);
    feather_standoff( feather_hole_x, -feather_hole_y);
    feather_standoff(-feather_hole_x,  feather_hole_y);
    feather_standoff( feather_hole_x,  feather_hole_y);
}




// ---------- Lid screw mounts ----------
lid_screw_d = 2.2;       // hole in lid, clearance for M2
boss_hole_d = 1.6;       // pilot hole in case boss for M2 self-tapper
boss_d = 5.5;
boss_h = 17;

screw_x = case_w/2 - 6;
screw_y = case_h/2 - 6;

module screw_positions() {
    for (x=[-screw_x, screw_x])
    for (y=[-screw_y, screw_y])
        translate([x,y,0])
            children();
}

module case_screw_bosses() {
    screw_positions()
        translate([0,0,-case_d/2 + wall + boss_h/2])
        difference() {
            cylinder(h=boss_h, d=boss_d, center=true);
            cylinder(h=boss_h + 1, d=boss_hole_d, center=true);
        }
}

module lid_screw_holes() {
    screw_positions()
        cylinder(h=lid_thick + 1, d=lid_screw_d, center=true);
}


// ---------- USB slot ----------
// Micro USB on short end of HUZZAH32.
// Increase width/height if your cable plug is chunky.
usb_slot_w = 12;
usb_slot_h = 8;
usb_slot_z = -1;
usb_slot_x = case_w/2;

module usb_slot() {
    translate([usb_slot_x, feather_y_offset, usb_slot_z])
        cube([wall + 4, usb_slot_w, usb_slot_h], center=true);
}

module shell() {
    difference() {
        union() {
    hollow_body();

    translate([0,0,5])
        build_swithes();

    translate([0,-4,5])
        feather_mounts();

    case_screw_bosses();
}

        // cut only switch holes
        switch_holes_only();

        // clearance below switches
        translate([space/2, 0, -1])
            cube([space*1.8, plateLength*0.8, 10], center=true);

        // USB access slot on short edge
        translate([0,0,-2.5])usb_slot();
    }
}



// ---------- Lid ----------
lid_thick = 2;
lid_clearance = 0.6;   // increase if too tight
lid_r = r - wall;      // matches inner corner radius

lid_w = case_w - 2*wall - lid_clearance;
lid_h = case_h - 2*wall - lid_clearance;

module rounded_rect_2d(w, h, rad) {
    offset(r=rad)
        square([w - 2*rad, h - 2*rad], center=true);
}

module lid() {
    difference() {
        linear_extrude(height=lid_thick, center=true)
            rounded_rect_2d(lid_w, lid_h, lid_r);

        lid_screw_holes();
    }
}


//shell();

translate([0, 0, -case_d/2 + lid_thick/2])
translate([0,55,18])lid();

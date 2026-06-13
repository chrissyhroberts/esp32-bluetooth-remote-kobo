/* Kobo BLE Page Turner Enclosure
   Side-face MX switch version
   Hold with narrow long side against index/middle fingers.
*/

$fn = 48;

// ---------- Main dimensions ----------
case_w = 80;      // length
case_h = 40;      // width
case_d = 20;      // thickness / height

wall = 2;
corner_r = 5;

// ---------- MX side switch settings ----------
mx_cut = 14.2;
mx_spacing = 26;          // distance between switch centres along length
mx_z = 2;                 // vertical position on side face
switch_side_y = case_h/2; // switches on upper long side

// ---------- USB cutout on short end ----------
usb_w = 11;
usb_h = 7;
usb_x = case_w/2;

// ---------- Lid ----------
lid_thick = 2;
lid_gap = 0.35;
lip_h = 3;

// ---------- Helpers ----------
module rounded_box(w, h, d, r) {
    hull() {
        for (x=[-w/2+r, w/2-r])
        for (y=[-h/2+r, h/2-r])
            translate([x,y,0])
                cylinder(h=d, r=r, center=true);
    }
}

// MX cutout projected through side wall.
// Shape dimensions: x = switch width along case length,
// z = switch height, y = depth through wall.
module mx_side_cutout() {
    cube([mx_cut, wall + 8, mx_cut], center=true);
}

// ---------- Top shell ----------
module top_shell() {
    difference() {
        // outer body
        rounded_box(case_w, case_h, case_d, corner_r);

        // hollow interior, open from bottom
        translate([0,0,-wall])
            rounded_box(
                case_w - 2*wall,
                case_h - 2*wall,
                case_d,
                max(corner_r - wall, 1)
            );

        // side-face MX cutouts
        translate([-mx_spacing/2, switch_side_y, mx_z])
            mx_side_cutout();

        translate([ mx_spacing/2, switch_side_y, mx_z])
            mx_side_cutout();

        // USB cutout on right short end
        translate([usb_x, 0, -2])
            cube([wall + 3, usb_w, usb_h], center=true);
    }
}

// ---------- Bottom lid ----------
module bottom_lid() {
    union() {
        rounded_box(case_w, case_h, lid_thick, corner_r);

        translate([0,0,lid_thick/2 + lip_h/2])
        difference() {
            rounded_box(
                case_w - 2*wall - lid_gap,
                case_h - 2*wall - lid_gap,
                lip_h,
                max(corner_r - wall, 1)
            );

            rounded_box(
                case_w - 2*wall - 4,
                case_h - 2*wall - 4,
                lip_h + 1,
                max(corner_r - wall - 1, 1)
            );
        }
    }
}

// ---------- Build ----------
top_shell();

translate([0, 48, -case_d/2 + lid_thick/2])
    bottom_lid();
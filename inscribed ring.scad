/* [Ring Parameters] */
// The inside diameter of the ring
Ring_Inside_Diameter = 22.001;

// The height of the ring
Ring_Height = 8.001;

// The thickness of the ring
Ring_Thickness = 2.001;

// A factor determining how much the ring bows out at the center
Ring_Expansion_Factor = 50; // [0: 10: 100]

// The number of facets in the ring (0 for a smooth circle)
Ring_Facets = 0;



/* [Inscription Parameters] */
Inscription_File = "";
Inscription = "INSCRIPTION";
Inscription_Font = "Arial";
Inscription_Depth = 0.501;
Inscription_Horizontal_Stretch_Factor = 0; // [0: 5: 200]
Inscription_Vertical_Stretch_Factor = 0; // [0: 5: 200]



/* [Advanced Parameters] */
// The quality value to use for draft rendering
Draft_Quality_Value = 16;

// The quality value to use for final rendering
Final_Quality_Value = 64;

// A tiny value used to avoid display problems in preview mode
Iota = 0.001;



// Global values
module dummy(){} // Prevent the following variables from showing up in the customizer
$fn = $preview ?  Draft_Quality_Value : Final_Quality_Value;




/* [Calculated Parameters] */
Ring_Fn = (Ring_Facets >= 3 ? Ring_Facets: $fn);


include<curve_lib/curve_lib.scad>
include<ring_lib/ring_lib.scad>



module Generate()
{
    // Generate the ring and carve out the inscription
    difference()
    {
        RingLib_Generate(Ring_Inside_Diameter, Ring_Thickness, Ring_Height, Ring_Expansion_Factor, Ring_Facets);
        Generate_Inscription();
    }

    // Since the inscription cuts into the center of the ring, the core needs to be regenerated
    color("black")
    RingLib_Generate(Ring_Inside_Diameter + Iota, Ring_Thickness - Inscription_Depth - Iota, Ring_Height - Inscription_Depth * 2, Ring_Expansion_Factor, Ring_Facets);
}



module Generate_Inscription()
{
    if (Inscription != "")
    {
        diameter = Ring_Inside_Diameter + Ring_Thickness*2 - Inscription_Depth*2;
        height = RingLib_FlatHeight(Ring_Thickness, Ring_Height);
        thickness = RingLib_OutsideDiameter(Ring_Inside_Diameter, Ring_Height, Ring_Thickness, Ring_Expansion_Factor);
        halign = "left";
        valign = "center";
        hstretch = Inscription_Horizontal_Stretch_Factor > 0 ? Inscription_Horizontal_Stretch_Factor/100 : "none";
        vstretch = Inscription_Vertical_Stretch_Factor > 0 ? Inscription_Vertical_Stretch_Factor/100 : "none";
        font = Inscription_Font;
        size = height;

        CurveLib_WrapToCylinder(d=diameter, height=height, thickness=thickness, halign=halign, valign=valign, hstretch=hstretch, vstretch=vstretch, $fn=Ring_Fn)
        if (Inscription_File == "")
        {
            text(Inscription, font=font, size=size, halign=halign, valign=valign);
        }
        else
        {
            import(Inscription_File);
        }
    }
}



Generate();

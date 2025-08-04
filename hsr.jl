using Beamlines

#-------------------------------------------------------
# Generated Beamline
#-------------------------------------------------------


#-700*mass_of(helion)/anom_moment_he3


#-------------------------------------------------------
#!Snakes

alpha_1 = -30 
alpha_2 = 75
alpha_3 = 60
alpha_4 = -60
alpha_5 = -75
alpha_6 = 90 + alpha_5 + alpha_3 - alpha_4 + alpha_1 - alpha_2

SNAKE1 = LineElement(class="Taylor (Unsupported)",  name = "SNAKE1");
SNAKE2 = LineElement(class="Taylor (Unsupported)",  name = "SNAKE2");
SNAKE3 = LineElement(class="Taylor (Unsupported)",  name = "SNAKE3");
SNAKE4 = LineElement(class="Taylor (Unsupported)",  name = "SNAKE4");
SNAKE5 = LineElement(class="Taylor (Unsupported)",  name = "SNAKE5");
SNAKE6 = LineElement(class="Taylor (Unsupported)",  name = "SNAKE6");



#-------------------------------------------------------
#!Phase trombones

pt1 = LineElement(class="Match (Unsupported)",  name = "pt1");
pt2 = LineElement(class="Match (Unsupported)",  name = "pt2");
pt3 = LineElement(class="Match (Unsupported)",  name = "pt3");
pt4 = LineElement(class="Match (Unsupported)",  name = "pt4");
pt5 = LineElement(class="Match (Unsupported)",  name = "pt5");
pt6 = LineElement(class="Match (Unsupported)",  name = "pt6");

pt = LineElement(class="Overlay",  name = "pt");





#-------------------------------------------------------


LSXT =  7.50000000000000000E-001
LQ =  1.11000000000000010E+000
LQ4 =  1.81194900000000003E+000
G_B2PF =  5.45080369027163992E-003
B1L_Q1A_6W =  1.25844999999999999E+002
B1AVG_Q1_6W =  6.71612377850162972E+001
B1L_Q1B_6W =  8.03400000000000034E+001

#-------------------------------------------------------

IP6D = LineElement(class="Marker",  name = "IP6D");
PB_SOL_R = LineElement(class="Patch (Unsupported)",  name = "PB_SOL_R");
STAR_DETECT_R = Solenoid(L = 2.0, name = "STAR_DETECT_R");
PE_SOL_R = LineElement(class="Patch (Unsupported)",  name = "PE_SOL_R");
O06D_SOL_Q1A = Drift(L = 3.2993748371982, name = "O06D_SOL_Q1A");
Q1APR = Quadrupole(L = 1.8, K1 = -0.0830555376631274, name = "Q1APR");
O06D_Q1A_Q1B = Drift(L = 0.5, name = "O06D_Q1A_Q1B");
Q1BPR = Quadrupole(L = 1.4, K1 = -0.0830555376631274, name = "Q1BPR");
O06D_Q1B_Q2 = Drift(L = 1.5, name = "O06D_Q1B_Q2");
Q2PR = Quadrupole(L = 4.5, K1 = 0.0286643487305129, name = "Q2PR");
O06D_Q2_Q3 = Drift(L = 22.45, name = "O06D_Q2_Q3");
H6_Q3 = Quadrupole(L = 0.75, K1 = 0.0121187009595472, name = "H6_Q3");
OH6_WQ_SPC = Drift(L = 0.15, name = "OH6_WQ_SPC");
H6_QS3 = Quadrupole(tilt1 = 0.785398163397448, L = 0.25, name = "H6_QS3");
H6_TV3 = LineElement(class="Vkicker", L = 0.25, name = "H6_TV3");
O_CRAB_MAG = Drift(L = 1.0, name = "O_CRAB_MAG");
O_CRAB_IP6R = LineElement(class="Pipe", L = 15.06, name = "O_CRAB_IP6R");
OFLQ2A = Drift(L = 0.1740807, name = "OFLQ2A");
H6_Q04 = Quadrupole(L = 3.391633, K1 = 0.018638351432295818, name = "H6_Q04");
OCQ2 = Drift(L = 0.2442035, name = "OCQ2");
H6_COR04 = Multipole(L = 0.5, name = "H6_COR04");
OCFL2 = Drift(L = 0.135819, name = "OCFL2");
O6_45 = Drift(L = 8.68371054546868, name = "O6_45");
OCFL = Drift(L = 0.509283, name = "OCFL");
H6_COR05 = Multipole(L = 0.5, name = "H6_COR05");
OCQ = Drift(L = 0.29525, name = "OCQ");
H6_Q05 = Quadrupole(L = 1.11, K1 = -0.08118157840586145, name = "H6_Q05");
OQS = Drift(L = 0.13105, name = "OQS");
H6_TQ05 = Quadrupole(L = 0.75, K1 = -0.034622269525102396, name = "H6_TQ05");
OSB = Drift(L = 0.2262276, name = "OSB");
OBFL = Drift(L = 0.1973834, name = "OBFL");
OBELABI = Drift(L = 0.295179535906226, name = "OBELABI");
OD5OFL = Drift(L = 0.908956155203, name = "OD5OFL");
H6_DH01 = SBend(L = 8.69844937519207, g = -0.00405560391281842, name = "H6_DH01");
OSB4C = Drift(L = 0.2262396, name = "OSB4C");
H6_TQ06 = Quadrupole(L = 0.75, K1 = 0.05193340428765354, name = "H6_TQ06");
OQS4 = Drift(L = 0.1300755, name = "OQS4");
H6_Q06 = Quadrupole(L = 1.811949, K1 = 0.06133695610657039, name = "H6_Q06");
OCQ4 = Drift(L = 0.2942755, name = "OCQ4");
H6_COR06 = Multipole(L = 0.5, name = "H6_COR06");
ODUM1FL = Drift(L = 0.377825, name = "ODUM1FL");
OSNKE = Drift(L = 0.448012, name = "OSNKE");
H6_ROT_HLX4 = LineElement(class="Pipe", L = 2.4, name = "H6_ROT_HLX4");
OSNKM = Drift(L = 0.212, name = "OSNKM");
H6_ROT_HLX3 = LineElement(class="Pipe", L = 2.4, name = "H6_ROT_HLX3");
OSNKMM = Drift(L = 0.224, name = "OSNKMM");
H6_BROT = LineElement(class="Monitor",  name = "H6_BROT");
H6_ROT_HLX2 = LineElement(class="Pipe", L = 2.4, name = "H6_ROT_HLX2");
H6_ROT_HLX1 = LineElement(class="Pipe", L = 2.4, name = "H6_ROT_HLX1");
OQBMS = Drift(L = 0.2961056, name = "OQBMS");
H6_Q07 = Quadrupole(L = 1.11, K1 = -0.08493014190159959, name = "H6_Q07");
H6_COR07 = Multipole(L = 0.5, name = "H6_COR07");
ODFL = Drift(L = 0.52159658996, name = "ODFL");
H6_DH02 = SBend(L = 9.440656, g = 0.0041230214050564, name = "H6_DH02");
H6_Q08 = Quadrupole(L = 1.11, K1 = 0.06875017585916077, name = "H6_Q08");
H6_COR08 = Multipole(L = 0.5, name = "H6_COR08");
H6_DH03 = SBend(L = 9.440656, g = 0.0041230214050564, name = "H6_DH03");
H6_Q09 = Quadrupole(L = 1.11, K1 = -0.060224840224602054, name = "H6_Q09");
H6_COR09 = Multipole(L = 0.5, name = "H6_COR09");
O6_910 = Drift(L = 8.60466802340594, name = "O6_910");
H6_Q10 = Quadrupole(L = 1.11, K1 = 0.09628023537492506, name = "H6_Q10");
H6_COR10 = Multipole(L = 0.5, name = "H6_COR10");
H6_DH04 = SBend(L = 8.69844937519207, g = 0.0041230214050564, name = "H6_DH04");
YI6_BV10 = LineElement(class="Monitor",  name = "YI6_BV10");
YI6_SXD10 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI6_SXD10");
YI6_QD10 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI6_QD10");
LMP06Y10 = Multipole(L = 0.5, name = "LMP06Y10");
YI6_INT10_1 = Drift(L = 0.295307535906226, name = "YI6_INT10_1");
YI6_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH10");
YI6_INT10_2 = Drift(L = 0.295179535906226, name = "YI6_INT10_2");
YI6_BH11 = LineElement(class="Monitor",  name = "YI6_BH11");
YI6_SXF11 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI6_SXF11");
YI6_QF11 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI6_QF11");
YI6_TH11 = LineElement(class="Hkicker", L = 0.5, name = "YI6_TH11");
YI6_INT11_1 = Drift(L = 0.295307535906226, name = "YI6_INT11_1");
YI6_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH11");
YI6_INT11_2 = Drift(L = 0.295179535906226, name = "YI6_INT11_2");
YI6_BV12 = LineElement(class="Monitor",  name = "YI6_BV12");
YI6_SXD12 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI6_SXD12");
YI6_QD12 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI6_QD12");
YI6_TV12 = LineElement(class="Vkicker", L = 0.5, name = "YI6_TV12");
YI6_INT12_1 = Drift(L = 0.295307535906226, name = "YI6_INT12_1");
YI6_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH12");
YI6_INT12_2 = Drift(L = 0.295179535906226, name = "YI6_INT12_2");
YI6_BH13 = LineElement(class="Monitor",  name = "YI6_BH13");
YI6_SXF13 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI6_SXF13");
YI6_QF13 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI6_QF13");
YI6_TH13 = LineElement(class="Hkicker", L = 0.5, name = "YI6_TH13");
YI6_INT13_1 = Drift(L = 0.295307535906226, name = "YI6_INT13_1");
YI6_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH13");
YI6_INT13_2 = Drift(L = 0.295179535906226, name = "YI6_INT13_2");
YI6_BV14 = LineElement(class="Monitor",  name = "YI6_BV14");
YI6_SXD14 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI6_SXD14");
YI6_QD14 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI6_QD14");
YI6_TV14 = LineElement(class="Vkicker", L = 0.5, name = "YI6_TV14");
YI6_INT14_1 = Drift(L = 0.295307535906226, name = "YI6_INT14_1");
YI6_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH14");
YI6_INT14_2 = Drift(L = 0.295179535906226, name = "YI6_INT14_2");
YI6_BH15 = LineElement(class="Monitor",  name = "YI6_BH15");
YI6_SXF15 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI6_SXF15");
YI6_QF15 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI6_QF15");
YI6_TH15 = LineElement(class="Hkicker", L = 0.5, name = "YI6_TH15");
YI6_INT15_1 = Drift(L = 0.295307535906226, name = "YI6_INT15_1");
YI6_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH15");
YI6_INT15_2 = Drift(L = 0.295179535906226, name = "YI6_INT15_2");
YI6_BV16 = LineElement(class="Monitor",  name = "YI6_BV16");
YI6_SXD16 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI6_SXD16");
YI6_QD16 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI6_QD16");
YI6_TV16 = LineElement(class="Vkicker", L = 0.5, name = "YI6_TV16");
YI6_INT16_1 = Drift(L = 0.295307535906226, name = "YI6_INT16_1");
YI6_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH16");
YI6_INT16_2 = Drift(L = 0.295179535906226, name = "YI6_INT16_2");
YI6_BH17 = LineElement(class="Monitor",  name = "YI6_BH17");
YI6_SXF17 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI6_SXF17");
YI6_QF17 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI6_QF17");
YI6_TH17 = LineElement(class="Hkicker", L = 0.5, name = "YI6_TH17");
YI6_INT17_1 = Drift(L = 0.295307535906226, name = "YI6_INT17_1");
YI6_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH17");
YI6_INT17_2 = Drift(L = 0.295179535906226, name = "YI6_INT17_2");
YI6_BV18 = LineElement(class="Monitor",  name = "YI6_BV18");
YI6_SXD18 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI6_SXD18");
YI6_QD18 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI6_QD18");
YI6_TV18 = LineElement(class="Vkicker", L = 0.5, name = "YI6_TV18");
YI6_INT18_1 = Drift(L = 0.295307535906226, name = "YI6_INT18_1");
YI6_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH18");
YI6_INT18_2 = Drift(L = 0.295179535906226, name = "YI6_INT18_2");
YI6_BH19 = LineElement(class="Monitor",  name = "YI6_BH19");
YI6_SXF19 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI6_SXF19");
YI6_QF19 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI6_QF19");
YI6_TH19 = LineElement(class="Hkicker", L = 0.5, name = "YI6_TH19");
YI6_INT19_1 = Drift(L = 0.295307535906226, name = "YI6_INT19_1");
YI6_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH19");
YI6_INT19_2 = Drift(L = 0.295179535906226, name = "YI6_INT19_2");
YI6_BV20 = LineElement(class="Monitor",  name = "YI6_BV20");
YI6_SXD20 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI6_SXD20");
YI6_QD20 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI6_QD20");
YI6_TV20 = LineElement(class="Vkicker", L = 0.5, name = "YI6_TV20");
YI6_INT20_1 = Drift(L = 0.295307535906226, name = "YI6_INT20_1");
YI6_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI6_DH20");
YI6_INT20_2 = Drift(L = 0.295179535906226, name = "YI6_INT20_2");
YI7_BH21 = LineElement(class="Monitor",  name = "YI7_BH21");
YI7_SXF21 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI7_SXF21");
YI7_QF21 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI7_QF21");
YI7_TH21 = LineElement(class="Hkicker", L = 0.5, name = "YI7_TH21");
YI7_INT20_2 = Drift(L = 0.295307535906226, name = "YI7_INT20_2");
YI7_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH20");
YI7_INT20_1 = Drift(L = 0.295179535906226, name = "YI7_INT20_1");
YI7_BV20 = LineElement(class="Monitor",  name = "YI7_BV20");
YI7_SXD20 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI7_SXD20");
YI7_QD20 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI7_QD20");
YI7_TV20 = LineElement(class="Vkicker", L = 0.5, name = "YI7_TV20");
YI7_INT19_2 = Drift(L = 0.295307535906226, name = "YI7_INT19_2");
YI7_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH19");
YI7_INT19_1 = Drift(L = 0.295179535906226, name = "YI7_INT19_1");
YI7_BH19 = LineElement(class="Monitor",  name = "YI7_BH19");
YI7_SXF19 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI7_SXF19");
YI7_QF19 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI7_QF19");
YI7_TH19 = LineElement(class="Hkicker", L = 0.5, name = "YI7_TH19");
YI7_INT18_2 = Drift(L = 0.295307535906226, name = "YI7_INT18_2");
YI7_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH18");
YI7_INT18_1 = Drift(L = 0.295179535906226, name = "YI7_INT18_1");
YI7_BV18 = LineElement(class="Monitor",  name = "YI7_BV18");
YI7_SXD18 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI7_SXD18");
YI7_QD18 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI7_QD18");
LMP07Y18 = Multipole(L = 0.5, name = "LMP07Y18");
YI7_INT17_2 = Drift(L = 0.295307535906226, name = "YI7_INT17_2");
YI7_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH17");
YI7_INT17_1 = Drift(L = 0.295179535906226, name = "YI7_INT17_1");
YI7_BH17 = LineElement(class="Monitor",  name = "YI7_BH17");
YI7_SXF17 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI7_SXF17");
YI7_QF17 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI7_QF17");
LMP07Y17 = Multipole(L = 0.5, name = "LMP07Y17");
YI7_INT16_2 = Drift(L = 0.295307535906226, name = "YI7_INT16_2");
YI7_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH16");
YI7_INT16_1 = Drift(L = 0.295179535906226, name = "YI7_INT16_1");
YI7_BV16 = LineElement(class="Monitor",  name = "YI7_BV16");
YI7_SXD16 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI7_SXD16");
YI7_QD16 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI7_QD16");
LMP07Y16 = Multipole(L = 0.5, name = "LMP07Y16");
YI7_INT15_2 = Drift(L = 0.295307535906226, name = "YI7_INT15_2");
YI7_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH15");
YI7_INT15_1 = Drift(L = 0.295179535906226, name = "YI7_INT15_1");
YI7_BH15 = LineElement(class="Monitor",  name = "YI7_BH15");
YI7_SXF15 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI7_SXF15");
YI7_QF15 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI7_QF15");
LMP07Y15 = Multipole(L = 0.5, name = "LMP07Y15");
YI7_INT14_2 = Drift(L = 0.295307535906226, name = "YI7_INT14_2");
YI7_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH14");
YI7_INT14_1 = Drift(L = 0.295179535906226, name = "YI7_INT14_1");
YI7_BV14 = LineElement(class="Monitor",  name = "YI7_BV14");
YI7_SXD14 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI7_SXD14");
YI7_QD14 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI7_QD14");
LMP07Y14 = Multipole(L = 0.5, name = "LMP07Y14");
YI7_INT13_2 = Drift(L = 0.295307535906226, name = "YI7_INT13_2");
YI7_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH13");
YI7_INT13_1 = Drift(L = 0.295179535906226, name = "YI7_INT13_1");
YI7_BH13 = LineElement(class="Monitor",  name = "YI7_BH13");
YI7_SXF13 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI7_SXF13");
YI7_QF13 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI7_QF13");
LMP07Y13 = Multipole(L = 0.5, name = "LMP07Y13");
YI7_INT12_2 = Drift(L = 0.295307535906226, name = "YI7_INT12_2");
YI7_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH12");
YI7_INT12_1 = Drift(L = 0.295179535906226, name = "YI7_INT12_1");
YI7_BV12 = LineElement(class="Monitor",  name = "YI7_BV12");
YI7_SXD12 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI7_SXD12");
YI7_QD12 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI7_QD12");
LMP07Y12 = Multipole(L = 0.5, name = "LMP07Y12");
YI7_INT11_2 = Drift(L = 0.295307535906226, name = "YI7_INT11_2");
YI7_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH11");
YI7_INT11_1 = Drift(L = 0.295179535906226, name = "YI7_INT11_1");
YI7_BH11 = LineElement(class="Monitor",  name = "YI7_BH11");
YI7_SXF11 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI7_SXF11");
YI7_QF11 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI7_QF11");
LMP07Y11 = Multipole(L = 0.5, name = "LMP07Y11");
YI7_INT10_2 = Drift(L = 0.295307535906226, name = "YI7_INT10_2");
YI7_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH10");
YI7_INT10_1 = Drift(L = 0.295179535906226, name = "YI7_INT10_1");
YI7_BV10 = LineElement(class="Monitor",  name = "YI7_BV10");
YI7_SXD10 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI7_SXD10");
YI7_QD10 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI7_QD10");
LMP07Y10 = Multipole(L = 0.5, name = "LMP07Y10");
YI7_INT9_3 = Drift(L = 0.302432390362215, name = "YI7_INT9_3");
ODSFL = Drift(L = 0.517281632902, name = "ODSFL");
YI7_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YI7_DH9");
YI7_INT9_2 = Drift(L = 0.302384300392218, name = "YI7_INT9_2");
ODUM2FL = Drift(L = 0.365633, name = "ODUM2FL");
O9DUMMY = Drift(L = 5.458968, name = "O9DUMMY");
YI7_INT9_1 = Drift(L = 0.295148, name = "YI7_INT9_1");
YI7_BH9 = LineElement(class="Monitor",  name = "YI7_BH9");
YI7_SXF9 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI7_SXF9");
YI7_QF9 = Quadrupole(L = 1.11, K1 = 0.08015332161404654, name = "YI7_QF9");
LMP07Y09 = Multipole(L = 0.5, name = "LMP07Y09");
YI7_INT8_2 = Drift(L = 0.295307535906226, name = "YI7_INT8_2");
YI7_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI7_DH8");
YI7_INT8_1 = Drift(L = 0.295307535906226, name = "YI7_INT8_1");
LMP07Y08 = Multipole(L = 0.5, name = "LMP07Y08");
YI7_QD8 = Quadrupole(L = 1.11, K1 = -0.08043575349496115, name = "YI7_QD8");
YI7_B8 = LineElement(class="Monitor",  name = "YI7_B8");
YI7_INT7_2 = Drift(L = 0.29519754785, name = "YI7_INT7_2");
YI7_SNK_HLX4 = LineElement(class="Pipe", L = 2.4, name = "YI7_SNK_HLX4");
YI7_SNK_HLX3 = LineElement(class="Pipe", L = 2.4, name = "YI7_SNK_HLX3");
YI7_BSNK = LineElement(class="Snake1",  name = "YI7_BSNK");
YI7_SNK_HLX2 = LineElement(class="Pipe", L = 2.4, name = "YI7_SNK_HLX2");
YI7_SNK_HLX1 = LineElement(class="Pipe", L = 2.4, name = "YI7_SNK_HLX1");
YI7_INT7_1 = Drift(L = 0.29519754785, name = "YI7_INT7_1");
YI7_B7 = LineElement(class="Monitor",  name = "YI7_B7");
OQBMS7 = Drift(L = 0.2962336, name = "OQBMS7");
YI7_QF7 = Quadrupole(L = 0.929744, K1 = 0.08769319629295928, name = "YI7_QF7");
OCQ7 = Drift(L = 0.295378, name = "OCQ7");
LMP07Y07 = Multipole(L = 0.5, name = "LMP07Y07");
YI7_INT6_3 = Drift(L = 0.302432390362215, name = "YI7_INT6_3");
YI7_DH6 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YI7_DH6");
YI7_INT6_2 = Drift(L = 0.302512300392215, name = "YI7_INT6_2");
O6DUMMY = Drift(L = 5.458968, name = "O6DUMMY");
YI7_INT6_1 = Drift(L = 0.295148, name = "YI7_INT6_1");
LMP07Y06 = Multipole(L = 0.5, name = "LMP07Y06");
YI7_QD6 = Quadrupole(L = 1.11, K1 = -0.0879771431044294, name = "YI7_QD6");
YI7_TQ6 = Quadrupole(L = 0.75, K1 = -0.0005697201407497321, name = "YI7_TQ6");
YI7_BV6 = LineElement(class="Monitor",  name = "YI7_BV6");
YI7_INT5_2 = Drift(L = 0.294936223422579, name = "YI7_INT5_2");
OD5IFL = Drift(L = 1.78544882818, name = "OD5IFL");
YI7_DH5 = SBend(L = 6.91599988052792, g = 0.0041230214050564, name = "YI7_DH5");
YI7_INT5_1 = Drift(L = 0.295064174522407, name = "YI7_INT5_1");
LMP07Y05 = Multipole(L = 0.5, name = "LMP07Y05");
YI7_QF5 = Quadrupole(L = 1.11, K1 = 0.0879771431044294, name = "YI7_QF5");
YI7_TQ5 = Quadrupole(L = 0.75, K1 = 0.0007347257169276499, name = "YI7_TQ5");
YI7_BH5 = LineElement(class="Monitor",  name = "YI7_BH5");
YI7_INT4_2 = Drift(L = 0.302561, name = "YI7_INT4_2");
O4DUMMY = Drift(L = 2.050034, name = "O4DUMMY");
YI7_INT4_1 = Drift(L = 0.302561, name = "YI7_INT4_1");
LMP07Y04 = Multipole(L = 0.5, name = "LMP07Y04");
YI7_QD4 = Quadrupole(L = 1.811949, K1 = -0.0882910610864151, name = "YI7_QD4");
YI7_TQ4 = Quadrupole(L = 0.75, K1 = 0.034622269525102396, name = "YI7_TQ4");
YI7_B4 = LineElement(class="Monitor",  name = "YI7_B4");
YI7_INT3 = Drift(L = 0.295148, name = "YI7_INT3");
YI7_HLX3_4 = LineElement(class="Pipe", L = 2.4, name = "YI7_HLX3_4");
YI7_HLX3_3 = LineElement(class="Pipe", L = 2.4, name = "YI7_HLX3_3");
YI7_B3_1 = LineElement(class="Monitor",  name = "YI7_B3_1");
YI7_HLX3_2 = LineElement(class="Pipe", L = 2.4, name = "YI7_HLX3_2");
YI7_HLX3_1 = LineElement(class="Pipe", L = 2.4, name = "YI7_HLX3_1");
OROTCWT = Drift(L = 0.861927, name = "OROTCWT");
OBSK7IY = Drift(L = 0.042501, name = "OBSK7IY");
YI7_SV3_2 = LineElement(class="Marker",  name = "YI7_SV3_2");
O3Y7C0 = Drift(L = 1.505794, name = "O3Y7C0");
YI7_CH3_2 = LineElement(class="Rcollimator (Unsupported)",  name = "YI7_CH3_2");
O3Y7C1 = Drift(L = 0.48895, name = "O3Y7C1");
YI7_CV3 = LineElement(class="Rcollimator (Unsupported)",  name = "YI7_CV3");
O3Y7C2 = Drift(L = 5.639308, name = "O3Y7C2");
YI7_CH3_1 = LineElement(class="Rcollimator (Unsupported)",  name = "YI7_CH3_1");
O3Y7C3 = Drift(L = 9.247556, name = "O3Y7C3");
YI7_C3 = LineElement(class="Rcollimator (Unsupported)",  name = "YI7_C3");
O3Y7C4 = Drift(L = 2.039335, name = "O3Y7C4");
YI7_KFBH3 = Multipole( name = "YI7_KFBH3");
O3Y7C5 = Drift(L = 0.514617023024205, name = "O3Y7C5");
YI7_SV3_1 = LineElement(class="Marker",  name = "YI7_SV3_1");
OBSK7LY = Drift(L = 0.048141, name = "OBSK7LY");
OBFL3 = Drift(L = 1.53902, name = "OBFL3");
YI7_B3 = LineElement(class="Monitor",  name = "YI7_B3");
OBC3 = Drift(L = 0.22142826, name = "OBC3");
LMP07Y3A = Multipole(L = 0.5, name = "LMP07Y3A");
OCQ3A = Drift(L = 0.347968, name = "OCQ3A");
YI7_QF3 = Quadrupole(L = 2.100484, K1 = 0.054369453070680376, name = "YI7_QF3");
OCQ3X = Drift(L = 0.239778, name = "OCQ3X");
LMP07Y3X = Multipole(L = 0.5, name = "LMP07Y3X");
OCFL3 = Drift(L = 0.1631016, name = "OCFL3");
YI7_INT2 = Drift(L = 0.7837792, name = "YI7_INT2");
YI7_QD2 = Quadrupole(L = 3.391633, K1 = -0.055295588668397, name = "YI7_QD2");
LMP07Y02 = Multipole(L = 0.5, name = "LMP07Y02");
YI7_INT1 = Drift(L = 0.626085, name = "YI7_INT1");
OFLQ1A = Drift(L = 0.170524, name = "OFLQ1A");
YI7_QF1 = Quadrupole(L = 1.44, K1 = 0.05659542906103055, name = "YI7_QF1");
OBQ1 = Drift(L = 0.3369448, name = "OBQ1");
YI7_B1 = LineElement(class="Monitor",  name = "YI7_B1");
OFLQ1X = Drift(L = 0.2015744, name = "OFLQ1X");
OC2W_WD = Drift(L = 0.8308908, name = "OC2W_WD");
OGVFL = Drift(L = 0.2, name = "OGVFL");
VALVE_WD = LineElement(class="Instrument", L = 0.11, name = "VALVE_WD");
OGVWD = Drift(L = 0.42, name = "OGVWD");
DWREV = SBend(e2 = -0.000998153098598143, e1 = -0.000998153098598143, L = 2.00000033210324, g = -0.000998152932853231, name = "DWREV");
OWW2 = Drift(L = 0.4, name = "OWW2");
O08 = Drift(L = 32.921047628902, name = "O08");
DWFWD = SBend(e2 = 0.000998153098598143, e1 = 0.000998153098598143, L = 2.00000033210324, g = 0.000998152932853231, name = "DWFWD");
YO8_B1 = LineElement(class="Monitor",  name = "YO8_B1");
YO8_QD1 = Quadrupole(L = 1.44, K1 = -0.057725240865794364, name = "YO8_QD1");
YO8_INT1 = Drift(L = 0.626085, name = "YO8_INT1");
LMP08Y02 = Multipole(L = 0.5, name = "LMP08Y02");
YO8_QF2 = Quadrupole(L = 3.391633, K1 = 0.05611629714147352, name = "YO8_QF2");
YO8_INT2 = Drift(L = 0.7837792, name = "YO8_INT2");
LMP08Y3X = Multipole(L = 0.5, name = "LMP08Y3X");
YO8_QD3 = Quadrupole(L = 2.100484, K1 = -0.05474893147884991, name = "YO8_QD3");
LMP08Y3A = Multipole(L = 0.5, name = "LMP08Y3A");
YO8_B3 = LineElement(class="Monitor",  name = "YO8_B3");
OBSK8LY = Drift(L = 0.048751, name = "OBSK8LY");
YO8_SV3_1 = LineElement(class="Marker",  name = "YO8_SV3_1");
O3Y8C0 = Drift(L = 0.305617, name = "O3Y8C0");
YO8_KFBH3 = Multipole( name = "YO8_KFBH3");
O3Y8C1 = Drift(L = 15.598474, name = "O3Y8C1");
OMSKHFL = Drift(L = 0.384048, name = "OMSKHFL");
YO8_MSKH3 = LineElement(class="Instrument",  name = "YO8_MSKH3");
O3Y8C2 = Drift(L = 4.89636402302421, name = "O3Y8C2");
YO8_SV3_2 = LineElement(class="Marker",  name = "YO8_SV3_2");
OBSK8IY = Drift(L = 0.0425, name = "OBSK8IY");
YO8_HLX3_1 = LineElement(class="Pipe", L = 2.4, name = "YO8_HLX3_1");
YO8_HLX3_2 = LineElement(class="Pipe", L = 2.4, name = "YO8_HLX3_2");
YO8_B3_1 = LineElement(class="Monitor",  name = "YO8_B3_1");
YO8_HLX3_3 = LineElement(class="Pipe", L = 2.4, name = "YO8_HLX3_3");
YO8_HLX3_4 = LineElement(class="Pipe", L = 2.4, name = "YO8_HLX3_4");
YO8_INT3 = Drift(L = 0.295148, name = "YO8_INT3");
YO8_B4 = LineElement(class="Monitor",  name = "YO8_B4");
YO8_TQ4 = Quadrupole(L = 0.75, K1 = -0.001645077491527167, name = "YO8_TQ4");
YO8_QF4 = Quadrupole(L = 1.811949, K1 = 0.0882910610864151, name = "YO8_QF4");
LMP08Y04 = Multipole(L = 0.5, name = "LMP08Y04");
YO8_INT4_1 = Drift(L = 0.302561, name = "YO8_INT4_1");
YO8_INT4_2 = Drift(L = 0.302561, name = "YO8_INT4_2");
YO8_BV5 = LineElement(class="Monitor",  name = "YO8_BV5");
YO8_TQ5 = Quadrupole(L = 0.75, K1 = -0.016098517954244974, name = "YO8_TQ5");
YO8_QD5 = Quadrupole(L = 1.11, K1 = -0.0879771431044294, name = "YO8_QD5");
LMP08Y05 = Multipole(L = 0.5, name = "LMP08Y05");
YO8_INT5_1 = Drift(L = 0.294586752907152, name = "YO8_INT5_1");
YO8_DH5 = SBend(L = 8.69844937519207, g = 0.0041230214050564, name = "YO8_DH5");
YO8_INT5_2 = Drift(L = 0.29445870400698, name = "YO8_INT5_2");
YO8_BH6 = LineElement(class="Monitor",  name = "YO8_BH6");
YO8_TQ6 = Quadrupole(L = 0.75, K1 = 0.018219935431110154, name = "YO8_TQ6");
YO8_QF6 = Quadrupole(L = 1.11, K1 = 0.0879771431044294, name = "YO8_QF6");
LMP08Y06 = Multipole(L = 0.5, name = "LMP08Y06");
YO8_INT6_1 = Drift(L = 0.295148, name = "YO8_INT6_1");
YO8_INT6_2 = Drift(L = 0.307984615363785, name = "YO8_INT6_2");
YO8_DH6 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO8_DH6");
YO8_INT6_3 = Drift(L = 0.307904705333785, name = "YO8_INT6_3");
LMP08Y07 = Multipole(L = 0.5, name = "LMP08Y07");
YO8_QD7 = Quadrupole(L = 0.929744, K1 = -0.08769319629295928, name = "YO8_QD7");
YO8_B7 = LineElement(class="Monitor",  name = "YO8_B7");
YO8_INT7_1 = Drift(L = 0.29519754785, name = "YO8_INT7_1");
O7DUMMY = Drift(L = 11.368024, name = "O7DUMMY");
YO8_INT7_2 = Drift(L = 0.29519754785, name = "YO8_INT7_2");
YO8_B8 = LineElement(class="Monitor",  name = "YO8_B8");
YO8_QF8 = Quadrupole(L = 1.11, K1 = 0.08035437220718784, name = "YO8_QF8");
LMP08Y08 = Multipole(L = 0.5, name = "LMP08Y08");
YO8_INT8_1 = Drift(L = 0.312825559773772, name = "YO8_INT8_1");
YO8_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH8");
YO8_INT8_2 = Drift(L = 0.312825559773772, name = "YO8_INT8_2");
LMP08Y09 = Multipole(L = 0.5, name = "LMP08Y09");
YO8_QD9 = Quadrupole(L = 1.11, K1 = -0.08043575349496115, name = "YO8_QD9");
YO8_SXD9 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO8_SXD9");
YO8_BV9 = LineElement(class="Monitor",  name = "YO8_BV9");
YO8_INT9_1 = Drift(L = 0.295148, name = "YO8_INT9_1");
YO8_INT9_2 = Drift(L = 0.307856615363788, name = "YO8_INT9_2");
YO8_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO8_DH9");
YO8_INT9_3 = Drift(L = 0.307904705333785, name = "YO8_INT9_3");
LMP08Y10 = Multipole(L = 0.5, name = "LMP08Y10");
YO8_QF10 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO8_QF10");
YO8_SXF10 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO8_SXF10");
YO8_BH10 = LineElement(class="Monitor",  name = "YO8_BH10");
YO8_INT10_1 = Drift(L = 0.312697559773772, name = "YO8_INT10_1");
YO8_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH10");
YO8_INT10_2 = Drift(L = 0.312825559773772, name = "YO8_INT10_2");
YO8_TV11 = LineElement(class="Vkicker", L = 0.5, name = "YO8_TV11");
YO8_QD11 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO8_QD11");
YO8_SXD11 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO8_SXD11");
YO8_BV11 = LineElement(class="Monitor",  name = "YO8_BV11");
YO8_INT11_1 = Drift(L = 0.312697559773772, name = "YO8_INT11_1");
YO8_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH11");
YO8_INT11_2 = Drift(L = 0.312825559773772, name = "YO8_INT11_2");
YO8_TH12 = LineElement(class="Hkicker", L = 0.5, name = "YO8_TH12");
YO8_QF12 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO8_QF12");
YO8_SXF12 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO8_SXF12");
YO8_BH12 = LineElement(class="Monitor",  name = "YO8_BH12");
YO8_INT12_1 = Drift(L = 0.312697559773772, name = "YO8_INT12_1");
YO8_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH12");
YO8_INT12_2 = Drift(L = 0.312825559773772, name = "YO8_INT12_2");
YO8_TV13 = LineElement(class="Vkicker", L = 0.5, name = "YO8_TV13");
YO8_QD13 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO8_QD13");
YO8_SXD13 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO8_SXD13");
YO8_BV13 = LineElement(class="Monitor",  name = "YO8_BV13");
YO8_INT13_1 = Drift(L = 0.312697559773772, name = "YO8_INT13_1");
YO8_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH13");
YO8_INT13_2 = Drift(L = 0.312825559773772, name = "YO8_INT13_2");
YO8_TH14 = LineElement(class="Hkicker", L = 0.5, name = "YO8_TH14");
YO8_QF14 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO8_QF14");
YO8_SXF14 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO8_SXF14");
YO8_BH14 = LineElement(class="Monitor",  name = "YO8_BH14");
YO8_INT14_1 = Drift(L = 0.312697559773772, name = "YO8_INT14_1");
YO8_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH14");
YO8_INT14_2 = Drift(L = 0.312825559773772, name = "YO8_INT14_2");
YO8_TV15 = LineElement(class="Vkicker", L = 0.5, name = "YO8_TV15");
YO8_QD15 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO8_QD15");
YO8_SXD15 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO8_SXD15");
YO8_BV15 = LineElement(class="Monitor",  name = "YO8_BV15");
YO8_INT15_1 = Drift(L = 0.312697559773772, name = "YO8_INT15_1");
YO8_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH15");
YO8_INT15_2 = Drift(L = 0.312825559773772, name = "YO8_INT15_2");
YO8_TH16 = LineElement(class="Hkicker", L = 0.5, name = "YO8_TH16");
YO8_QF16 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO8_QF16");
YO8_SXF16 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO8_SXF16");
YO8_BH16 = LineElement(class="Monitor",  name = "YO8_BH16");
YO8_INT16_1 = Drift(L = 0.312697559773772, name = "YO8_INT16_1");
YO8_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH16");
YO8_INT16_2 = Drift(L = 0.312825559773772, name = "YO8_INT16_2");
YO8_TV17 = LineElement(class="Vkicker", L = 0.5, name = "YO8_TV17");
YO8_QD17 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO8_QD17");
YO8_SXD17 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO8_SXD17");
YO8_BV17 = LineElement(class="Monitor",  name = "YO8_BV17");
YO8_INT17_1 = Drift(L = 0.312697559773772, name = "YO8_INT17_1");
YO8_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH17");
YO8_INT17_2 = Drift(L = 0.312825559773772, name = "YO8_INT17_2");
YO8_TH18 = LineElement(class="Hkicker", L = 0.5, name = "YO8_TH18");
YO8_QF18 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO8_QF18");
YO8_SXF18 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO8_SXF18");
YO8_BH18 = LineElement(class="Monitor",  name = "YO8_BH18");
YO8_INT18_1 = Drift(L = 0.312697559773772, name = "YO8_INT18_1");
YO8_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH18");
YO8_INT18_2 = Drift(L = 0.312825559773772, name = "YO8_INT18_2");
YO8_TV19 = LineElement(class="Vkicker", L = 0.5, name = "YO8_TV19");
YO8_QD19 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO8_QD19");
YO8_SXD19 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO8_SXD19");
YO8_BV19 = LineElement(class="Monitor",  name = "YO8_BV19");
YO8_INT19_1 = Drift(L = 0.312697559773772, name = "YO8_INT19_1");
YO8_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH19");
YO8_INT19_2 = Drift(L = 0.312825559773772, name = "YO8_INT19_2");
YO8_TH20 = LineElement(class="Hkicker", L = 0.5, name = "YO8_TH20");
YO8_QF20 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO8_QF20");
YO8_SXF20 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO8_SXF20");
YO8_BH20 = LineElement(class="Monitor",  name = "YO8_BH20");
YO8_INT20_1 = Drift(L = 0.312697559773772, name = "YO8_INT20_1");
YO8_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO8_DH20");
YO8_INT20_2 = Drift(L = 0.312825559773772, name = "YO8_INT20_2");
YO9_TV21 = LineElement(class="Vkicker", L = 0.5, name = "YO9_TV21");
YO9_QD21 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO9_QD21");
YO9_SXD21 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO9_SXD21");
YO9_BV21 = LineElement(class="Monitor",  name = "YO9_BV21");
YO9_INT20_2 = Drift(L = 0.312697559773772, name = "YO9_INT20_2");
YO9_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH20");
YO9_INT20_1 = Drift(L = 0.312825559773772, name = "YO9_INT20_1");
YO9_TH20 = LineElement(class="Hkicker", L = 0.5, name = "YO9_TH20");
YO9_QF20 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO9_QF20");
YO9_SXF20 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO9_SXF20");
YO9_BH20 = LineElement(class="Monitor",  name = "YO9_BH20");
YO9_INT19_2 = Drift(L = 0.312697559773772, name = "YO9_INT19_2");
YO9_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH19");
YO9_INT19_1 = Drift(L = 0.312825559773772, name = "YO9_INT19_1");
YO9_TV19 = LineElement(class="Vkicker", L = 0.5, name = "YO9_TV19");
YO9_QD19 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO9_QD19");
YO9_SXD19 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO9_SXD19");
YO9_BV19 = LineElement(class="Monitor",  name = "YO9_BV19");
YO9_INT18_2 = Drift(L = 0.312697559773772, name = "YO9_INT18_2");
YO9_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH18");
YO9_INT18_1 = Drift(L = 0.312825559773772, name = "YO9_INT18_1");
LMP09Y18 = Multipole(L = 0.5, name = "LMP09Y18");
YO9_QF18 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO9_QF18");
YO9_SXF18 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO9_SXF18");
YO9_BH18 = LineElement(class="Monitor",  name = "YO9_BH18");
YO9_INT17_2 = Drift(L = 0.312697559773772, name = "YO9_INT17_2");
YO9_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH17");
YO9_INT17_1 = Drift(L = 0.312825559773772, name = "YO9_INT17_1");
LMP09Y17 = Multipole(L = 0.5, name = "LMP09Y17");
YO9_QD17 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO9_QD17");
YO9_SXD17 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO9_SXD17");
YO9_BV17 = LineElement(class="Monitor",  name = "YO9_BV17");
YO9_INT16_2 = Drift(L = 0.312697559773772, name = "YO9_INT16_2");
YO9_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH16");
YO9_INT16_1 = Drift(L = 0.312825559773772, name = "YO9_INT16_1");
LMP09Y16 = Multipole(L = 0.5, name = "LMP09Y16");
YO9_QF16 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO9_QF16");
YO9_SXF16 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO9_SXF16");
YO9_BH16 = LineElement(class="Monitor",  name = "YO9_BH16");
YO9_INT15_2 = Drift(L = 0.312697559773772, name = "YO9_INT15_2");
YO9_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH15");
YO9_INT15_1 = Drift(L = 0.312825559773772, name = "YO9_INT15_1");
LMP09Y15 = Multipole(L = 0.5, name = "LMP09Y15");
YO9_QD15 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO9_QD15");
YO9_SXD15 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO9_SXD15");
YO9_BV15 = LineElement(class="Monitor",  name = "YO9_BV15");
YO9_INT14_2 = Drift(L = 0.312697559773772, name = "YO9_INT14_2");
YO9_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH14");
YO9_INT14_1 = Drift(L = 0.312825559773772, name = "YO9_INT14_1");
LMP09Y14 = Multipole(L = 0.5, name = "LMP09Y14");
YO9_QF14 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO9_QF14");
YO9_SXF14 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO9_SXF14");
YO9_BH14 = LineElement(class="Monitor",  name = "YO9_BH14");
YO9_INT13_2 = Drift(L = 0.312697559773772, name = "YO9_INT13_2");
YO9_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH13");
YO9_INT13_1 = Drift(L = 0.312825559773772, name = "YO9_INT13_1");
LMP09Y13 = Multipole(L = 0.5, name = "LMP09Y13");
YO9_QD13 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO9_QD13");
YO9_SXD13 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO9_SXD13");
YO9_BV13 = LineElement(class="Monitor",  name = "YO9_BV13");
YO9_INT12_2 = Drift(L = 0.312697559773772, name = "YO9_INT12_2");
YO9_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH12");
YO9_INT12_1 = Drift(L = 0.312825559773772, name = "YO9_INT12_1");
LMP09Y12 = Multipole(L = 0.5, name = "LMP09Y12");
YO9_QF12 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO9_QF12");
YO9_SXF12 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO9_SXF12");
YO9_BH12 = LineElement(class="Monitor",  name = "YO9_BH12");
YO9_INT11_2 = Drift(L = 0.312697559773772, name = "YO9_INT11_2");
YO9_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH11");
YO9_INT11_1 = Drift(L = 0.312825559773772, name = "YO9_INT11_1");
LMP09Y11 = Multipole(L = 0.5, name = "LMP09Y11");
YO9_QD11 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO9_QD11");
YO9_SXD11 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO9_SXD11");
YO9_BV11 = LineElement(class="Monitor",  name = "YO9_BV11");
YO9_INT10_2 = Drift(L = 0.312697559773772, name = "YO9_INT10_2");
YO9_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH10");
YO9_INT10_1 = Drift(L = 0.312825559773772, name = "YO9_INT10_1");
LMP09Y10 = Multipole(L = 0.5, name = "LMP09Y10");
YO9_QF10 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO9_QF10");
YO9_SXF10 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO9_SXF10");
YO9_BH10 = LineElement(class="Monitor",  name = "YO9_BH10");
YO9_INT9_3 = Drift(L = 0.307776705333785, name = "YO9_INT9_3");
YO9_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO9_DH9");
YO9_INT9_2 = Drift(L = 0.307856615363788, name = "YO9_INT9_2");
YO9_INT9_1 = Drift(L = 0.295148, name = "YO9_INT9_1");
YO9_BV9 = LineElement(class="Monitor",  name = "YO9_BV9");
OQB = Drift(L = 1.1072776, name = "OQB");
YO9_QD9 = Quadrupole(L = 1.11, K1 = -0.08128223675432418, name = "YO9_QD9");
LMP09Y09 = Multipole(L = 0.5, name = "LMP09Y09");
YO9_INT8_2 = Drift(L = 0.312825559773772, name = "YO9_INT8_2");
YO9_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO9_DH8");
YO9_INT8_1 = Drift(L = 0.312825559773772, name = "YO9_INT8_1");
LMP09Y08 = Multipole(L = 0.5, name = "LMP09Y08");
YO9_QF8 = Quadrupole(L = 1.11, K1 = 0.08120085546655087, name = "YO9_QF8");
YO9_B8 = LineElement(class="Monitor",  name = "YO9_B8");
YO9_INT7_2 = Drift(L = 0.29519754785, name = "YO9_INT7_2");
YO9_HLX7_4 = LineElement(class="Pipe", L = 2.4, name = "YO9_HLX7_4");
YO9_HLX7_3 = LineElement(class="Pipe", L = 2.4, name = "YO9_HLX7_3");
YO9_B7_1 = LineElement(class="Snake2",  name = "YO9_B7_1");
YO9_HLX7_2 = LineElement(class="Pipe", L = 2.4, name = "YO9_HLX7_2");
YO9_HLX7_1 = LineElement(class="Pipe", L = 2.4, name = "YO9_HLX7_1");
YO9_INT7_1 = Drift(L = 0.29519754785, name = "YO9_INT7_1");
YO9_B7 = LineElement(class="Monitor",  name = "YO9_B7");
YO9_QD7 = Quadrupole(L = 0.929744, K1 = -0.08747352389571782, name = "YO9_QD7");
LMP09Y07 = Multipole(L = 0.5, name = "LMP09Y07");
YO9_INT6_3 = Drift(L = 0.307904705333785, name = "YO9_INT6_3");
YO9_DH6 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO9_DH6");
YO9_INT6_2 = Drift(L = 0.307984615363785, name = "YO9_INT6_2");
YO9_INT6_1 = Drift(L = 0.295148, name = "YO9_INT6_1");
LMP09Y06 = Multipole(L = 0.5, name = "LMP09Y06");
YO9_QF6 = Quadrupole(L = 1.11, K1 = 0.08953102791747575, name = "YO9_QF6");
YO9_TQ6 = Quadrupole(L = 0.75, K1 = 0.02215706029184371, name = "YO9_TQ6");
YO9_BH6 = LineElement(class="Monitor",  name = "YO9_BH6");
YO9_INT5_2 = Drift(L = 0.29445870400698, name = "YO9_INT5_2");
YO9_DH5 = SBend(L = 8.69844937519207, g = 0.0041230214050564, name = "YO9_DH5");
YO9_INT5_1 = Drift(L = 0.294586752907152, name = "YO9_INT5_1");
LMP09Y05 = Multipole(L = 0.5, name = "LMP09Y05");
YO9_QD5 = Quadrupole(L = 1.11, K1 = -0.08953102791747575, name = "YO9_QD5");
YO9_TQ5 = Quadrupole(L = 0.75, K1 = -0.014634553858674038, name = "YO9_TQ5");
YO9_BV5 = LineElement(class="Monitor",  name = "YO9_BV5");
YO9_INT4_2 = Drift(L = 0.302561, name = "YO9_INT4_2");
YO9_INT4_1 = Drift(L = 0.302561, name = "YO9_INT4_1");
LMP09Y04 = Multipole(L = 0.5, name = "LMP09Y04");
YO9_QF4 = Quadrupole(L = 1.811949, K1 = 0.08985049043486619, name = "YO9_QF4");
YO9_TQ4 = Quadrupole(L = 0.75, K1 = -0.004967757819974578, name = "YO9_TQ4");
OSB4 = Drift(L = 0.2516396, name = "OSB4");
YO9_B4 = LineElement(class="Monitor",  name = "YO9_B4");
OBFL4 = Drift(L = 0.61279, name = "OBFL4");
OBSK9IY = Drift(L = 0.042501, name = "OBSK9IY");
YO9_SV4 = LineElement(class="Marker",  name = "YO9_SV4");
O3Y9C0 = Drift(L = 1.01786, name = "O3Y9C0");
YO9_DMP3_2 = LineElement(class="Pipe", L = 4.873904, name = "YO9_DMP3_2");
YO9_DMP3_1 = LineElement(class="Pipe", L = 0.736295, name = "YO9_DMP3_1");
O3Y9C1 = Drift(L = 7.531761, name = "O3Y9C1");
YO9_SV3_2 = LineElement(class="Marker",  name = "YO9_SV3_2");
O3Y9C2 = Drift(L = 6.422289, name = "O3Y9C2");
OBABFLA = Drift(L = 0.1905, name = "OBABFLA");
YO9_B3_1 = LineElement(class="Monitor",  name = "YO9_B3_1");
OBABFLX = Drift(L = 0.1905, name = "OBABFLX");
O3Y9C3 = Drift(L = 4.625853, name = "O3Y9C3");
YO9_KFBH3 = Multipole( name = "YO9_KFBH3");
O3Y9C4 = Drift(L = 0.863011, name = "O3Y9C4");
OEKA = Drift(L = 0.2892235, name = "OEKA");
YO9_KA3_5 = SBend(L = 1.22, name = "YO9_KA3_5");
OSKA = Drift(L = 0.1397, name = "OSKA");
YO9_KA3_4 = SBend(L = 1.22, name = "YO9_KA3_4");
YO9_KA3_3 = SBend(L = 1.22, name = "YO9_KA3_3");
YO9_KA3_2 = SBend(L = 1.22, name = "YO9_KA3_2");
YO9_KA3_1 = SBend(L = 1.22, name = "YO9_KA3_1");
O3Y9C5 = Drift(L = 0.341357423024208, name = "O3Y9C5");
YO9_SV3_1 = LineElement(class="Marker",  name = "YO9_SV3_1");
OBSK9LY = Drift(L = 0.048841, name = "OBSK9LY");
YO9_B3 = LineElement(class="Monitor",  name = "YO9_B3");
LMP09Y3A = Multipole(L = 0.5, name = "LMP09Y3A");
YO9_QD3 = Quadrupole(L = 2.100484, K1 = -0.05479385348024793, name = "YO9_QD3");
LMP09Y3X = Multipole(L = 0.5, name = "LMP09Y3X");
YO9_INT2 = Drift(L = 0.7837792, name = "YO9_INT2");
YO9_QF2 = Quadrupole(L = 3.391633, K1 = 0.05613644108516407, name = "YO9_QF2");
LMP09Y02 = Multipole(L = 0.5, name = "LMP09Y02");
YO9_INT1 = Drift(L = 0.626085, name = "YO9_INT1");
YO9_QD1 = Quadrupole(L = 1.44, K1 = -0.057074879033202894, name = "YO9_QD1");
YO9_B1 = LineElement(class="Monitor",  name = "YO9_B1");
OCAVTRP = Drift(L = 8.06791581445102, name = "OCAVTRP");
H10_CAV591_1 = LineElement(class="Rfcavity (Unsupported)",  name = "H10_CAV591_1");
OBEL11 = Drift(L = 0.292608, name = "OBEL11");
H10_CAV591_2 = LineElement(class="Rfcavity (Unsupported)",  name = "H10_CAV591_2");
H10_CAV591_3 = LineElement(class="Rfcavity (Unsupported)",  name = "H10_CAV591_3");
YI10_B1 = LineElement(class="Monitor",  name = "YI10_B1");
YI10_QF1 = Quadrupole(L = 1.44, K1 = 0.05608207659263406, name = "YI10_QF1");
YI10_INT1 = Drift(L = 0.626085, name = "YI10_INT1");
LMP10Y02 = Multipole(L = 0.5, name = "LMP10Y02");
YI10_QD2 = Quadrupole(L = 3.391633, K1 = -0.05527305807386799, name = "YI10_QD2");
YI10_INT2 = Drift(L = 0.7837792, name = "YI10_INT2");
LMP10Y3X = Multipole(L = 0.5, name = "LMP10Y3X");
YI10_QF3 = Quadrupole(L = 2.100484, K1 = 0.05468287239259289, name = "YI10_QF3");
LMP10Y3A = Multipole(L = 0.5, name = "LMP10Y3A");
YI10_B3 = LineElement(class="Monitor",  name = "YI10_B3");
OBSK10LY = Drift(L = 0.048892, name = "OBSK10LY");
YI10_SV3 = LineElement(class="Marker",  name = "YI10_SV3");
O3Y10C0 = Drift(L = 8.199617, name = "O3Y10C0");
YI10_KFBH3 = Multipole( name = "YI10_KFBH3");
O3Y10C1 = Drift(L = 25.8309104230242, name = "O3Y10C1");
YI10_SV4 = LineElement(class="Marker",  name = "YI10_SV4");
OBSK10IY = Drift(L = 0.0425, name = "OBSK10IY");
YI10_B4 = LineElement(class="Monitor",  name = "YI10_B4");
YI10_TQ4 = Quadrupole(L = 0.75, K1 = 0.032757929662037916, name = "YI10_TQ4");
YI10_QD4 = Quadrupole(L = 1.811949, K1 = -0.09061582300527359, name = "YI10_QD4");
LMP10Y04 = Multipole(L = 0.5, name = "LMP10Y04");
YI10_INT4_1 = Drift(L = 0.302561, name = "YI10_INT4_1");
YI10_INT4_2 = Drift(L = 0.302561, name = "YI10_INT4_2");
YI10_BH5 = LineElement(class="Monitor",  name = "YI10_BH5");
YI10_TQ5 = Quadrupole(L = 0.75, K1 = 0.0002547624250772958, name = "YI10_TQ5");
YI10_QF5 = Quadrupole(L = 1.11, K1 = 0.09029363935560665, name = "YI10_QF5");
LMP10Y05 = Multipole(L = 0.5, name = "LMP10Y05");
YI10_INT5_1 = Drift(L = 0.295064174522407, name = "YI10_INT5_1");
YI10_DH5 = SBend(L = 6.91599988052792, g = 0.0041230214050564, name = "YI10_DH5");
YI10_INT5_2 = Drift(L = 0.294936223422579, name = "YI10_INT5_2");
YI10_BV6 = LineElement(class="Monitor",  name = "YI10_BV6");
YI10_TQ6 = Quadrupole(L = 0.75, K1 = 0.00023861073452741306, name = "YI10_TQ6");
YI10_QD6 = Quadrupole(L = 1.11, K1 = -0.09029363935560665, name = "YI10_QD6");
LMP10Y06 = Multipole(L = 0.5, name = "LMP10Y06");
YI10_INT6_1 = Drift(L = 0.295148, name = "YI10_INT6_1");
YI10_INT6_2 = Drift(L = 0.302512300392215, name = "YI10_INT6_2");
YI10_DH6 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YI10_DH6");
YI10_INT6_3 = Drift(L = 0.302432390362215, name = "YI10_INT6_3");
LMP10Y07 = Multipole(L = 0.5, name = "LMP10Y07");
YI10_QF7 = Quadrupole(L = 0.929744, K1 = 0.08827032959499767, name = "YI10_QF7");
YI10_B7 = LineElement(class="Monitor",  name = "YI10_B7");
YI10_INT7_1 = Drift(L = 0.29519754785, name = "YI10_INT7_1");
YI10_INT7_2 = Drift(L = 0.29519754785, name = "YI10_INT7_2");
YI10_B8 = LineElement(class="Monitor",  name = "YI10_B8");
YI10_QD8 = Quadrupole(L = 1.11, K1 = -0.07976481972062939, name = "YI10_QD8");
LMP10Y08 = Multipole(L = 0.5, name = "LMP10Y08");
YI10_INT8_1 = Drift(L = 0.295307535906226, name = "YI10_INT8_1");
YI10_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH8");
YI10_INT8_2 = Drift(L = 0.295307535906226, name = "YI10_INT8_2");
LMP10Y09 = Multipole(L = 0.5, name = "LMP10Y09");
YI10_QF9 = Quadrupole(L = 1.11, K1 = 0.0796834384328561, name = "YI10_QF9");
YI10_BH9 = LineElement(class="Monitor",  name = "YI10_BH9");
YI10_INT9_1 = Drift(L = 0.295148, name = "YI10_INT9_1");
YI10_INT9_2 = Drift(L = 0.302384300392218, name = "YI10_INT9_2");
YI10_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YI10_DH9");
YI10_INT9_3 = Drift(L = 0.302304390362215, name = "YI10_INT9_3");
YI10_BV10 = LineElement(class="Monitor",  name = "YI10_BV10");
YI10_SXD10 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI10_SXD10");
YI10_QD10 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI10_QD10");
LMP10Y10 = Multipole(L = 0.5, name = "LMP10Y10");
YI10_INT10_1 = Drift(L = 0.295307535906226, name = "YI10_INT10_1");
YI10_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH10");
YI10_INT10_2 = Drift(L = 0.295179535906226, name = "YI10_INT10_2");
YI10_BH11 = LineElement(class="Monitor",  name = "YI10_BH11");
YI10_SXF11 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI10_SXF11");
YI10_QF11 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI10_QF11");
YI10_TH11 = LineElement(class="Hkicker", L = 0.5, name = "YI10_TH11");
YI10_INT11_1 = Drift(L = 0.295307535906226, name = "YI10_INT11_1");
YI10_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH11");
YI10_INT11_2 = Drift(L = 0.295179535906226, name = "YI10_INT11_2");
YI10_BV12 = LineElement(class="Monitor",  name = "YI10_BV12");
YI10_SXD12 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI10_SXD12");
YI10_QD12 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI10_QD12");
YI10_TV12 = LineElement(class="Vkicker", L = 0.5, name = "YI10_TV12");
YI10_INT12_1 = Drift(L = 0.295307535906226, name = "YI10_INT12_1");
YI10_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH12");
YI10_INT12_2 = Drift(L = 0.295179535906226, name = "YI10_INT12_2");
YI10_BH13 = LineElement(class="Monitor",  name = "YI10_BH13");
YI10_SXF13 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI10_SXF13");
YI10_QF13 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI10_QF13");
YI10_TH13 = LineElement(class="Hkicker", L = 0.5, name = "YI10_TH13");
YI10_INT13_1 = Drift(L = 0.295307535906226, name = "YI10_INT13_1");
YI10_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH13");
YI10_INT13_2 = Drift(L = 0.295179535906226, name = "YI10_INT13_2");
YI10_BV14 = LineElement(class="Monitor",  name = "YI10_BV14");
YI10_SXD14 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI10_SXD14");
YI10_QD14 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI10_QD14");
YI10_TV14 = LineElement(class="Vkicker", L = 0.5, name = "YI10_TV14");
YI10_INT14_1 = Drift(L = 0.295307535906226, name = "YI10_INT14_1");
YI10_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH14");
YI10_INT14_2 = Drift(L = 0.295179535906226, name = "YI10_INT14_2");
YI10_BH15 = LineElement(class="Monitor",  name = "YI10_BH15");
YI10_SXF15 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI10_SXF15");
YI10_QF15 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI10_QF15");
YI10_TH15 = LineElement(class="Hkicker", L = 0.5, name = "YI10_TH15");
YI10_INT15_1 = Drift(L = 0.295307535906226, name = "YI10_INT15_1");
YI10_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH15");
YI10_INT15_2 = Drift(L = 0.295179535906226, name = "YI10_INT15_2");
YI10_BV16 = LineElement(class="Monitor",  name = "YI10_BV16");
YI10_SXD16 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI10_SXD16");
YI10_QD16 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI10_QD16");
YI10_TV16 = LineElement(class="Vkicker", L = 0.5, name = "YI10_TV16");
YI10_INT16_1 = Drift(L = 0.295307535906226, name = "YI10_INT16_1");
YI10_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH16");
YI10_INT16_2 = Drift(L = 0.295179535906226, name = "YI10_INT16_2");
YI10_BH17 = LineElement(class="Monitor",  name = "YI10_BH17");
YI10_SXF17 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI10_SXF17");
YI10_QF17 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI10_QF17");
YI10_TH17 = LineElement(class="Hkicker", L = 0.5, name = "YI10_TH17");
YI10_INT17_1 = Drift(L = 0.295307535906226, name = "YI10_INT17_1");
YI10_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH17");
YI10_INT17_2 = Drift(L = 0.295179535906226, name = "YI10_INT17_2");
YI10_BV18 = LineElement(class="Monitor",  name = "YI10_BV18");
YI10_SXD18 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI10_SXD18");
YI10_QD18 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI10_QD18");
YI10_TV18 = LineElement(class="Vkicker", L = 0.5, name = "YI10_TV18");
YI10_INT18_1 = Drift(L = 0.295307535906226, name = "YI10_INT18_1");
YI10_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH18");
YI10_INT18_2 = Drift(L = 0.295179535906226, name = "YI10_INT18_2");
YI10_BH19 = LineElement(class="Monitor",  name = "YI10_BH19");
YI10_SXF19 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI10_SXF19");
YI10_QF19 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI10_QF19");
YI10_TH19 = LineElement(class="Hkicker", L = 0.5, name = "YI10_TH19");
YI10_INT19_1 = Drift(L = 0.295307535906226, name = "YI10_INT19_1");
YI10_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH19");
YI10_INT19_2 = Drift(L = 0.295179535906226, name = "YI10_INT19_2");
YI10_BV20 = LineElement(class="Monitor",  name = "YI10_BV20");
YI10_SXD20 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI10_SXD20");
YI10_QD20 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI10_QD20");
YI10_TV20 = LineElement(class="Vkicker", L = 0.5, name = "YI10_TV20");
YI10_INT20_1 = Drift(L = 0.295307535906226, name = "YI10_INT20_1");
YI10_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI10_DH20");
YI10_INT20_2 = Drift(L = 0.295179535906226, name = "YI10_INT20_2");
YI11_BH21 = LineElement(class="Monitor",  name = "YI11_BH21");
YI11_SXF21 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI11_SXF21");
YI11_QF21 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI11_QF21");
YI11_TH21 = LineElement(class="Hkicker", L = 0.5, name = "YI11_TH21");
YI11_INT20_2 = Drift(L = 0.295307535906226, name = "YI11_INT20_2");
YI11_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH20");
YI11_INT20_1 = Drift(L = 0.295179535906226, name = "YI11_INT20_1");
YI11_BV20 = LineElement(class="Monitor",  name = "YI11_BV20");
YI11_SXD20 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI11_SXD20");
YI11_QD20 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI11_QD20");
YI11_TV20 = LineElement(class="Vkicker", L = 0.5, name = "YI11_TV20");
YI11_INT19_2 = Drift(L = 0.295307535906226, name = "YI11_INT19_2");
YI11_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH19");
YI11_INT19_1 = Drift(L = 0.295179535906226, name = "YI11_INT19_1");
YI11_BH19 = LineElement(class="Monitor",  name = "YI11_BH19");
YI11_SXF19 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI11_SXF19");
YI11_QF19 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI11_QF19");
YI11_TH19 = LineElement(class="Hkicker", L = 0.5, name = "YI11_TH19");
YI11_INT18_2 = Drift(L = 0.295307535906226, name = "YI11_INT18_2");
YI11_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH18");
YI11_INT18_1 = Drift(L = 0.295179535906226, name = "YI11_INT18_1");
YI11_BV18 = LineElement(class="Monitor",  name = "YI11_BV18");
YI11_SXD18 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI11_SXD18");
YI11_QD18 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI11_QD18");
LMP11Y18 = Multipole(L = 0.5, name = "LMP11Y18");
YI11_INT17_2 = Drift(L = 0.295307535906226, name = "YI11_INT17_2");
YI11_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH17");
YI11_INT17_1 = Drift(L = 0.295179535906226, name = "YI11_INT17_1");
YI11_BH17 = LineElement(class="Monitor",  name = "YI11_BH17");
YI11_SXF17 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI11_SXF17");
YI11_QF17 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI11_QF17");
LMP11Y17 = Multipole(L = 0.5, name = "LMP11Y17");
YI11_INT16_2 = Drift(L = 0.295307535906226, name = "YI11_INT16_2");
YI11_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH16");
YI11_INT16_1 = Drift(L = 0.295179535906226, name = "YI11_INT16_1");
YI11_BV16 = LineElement(class="Monitor",  name = "YI11_BV16");
YI11_SXD16 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI11_SXD16");
YI11_QD16 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI11_QD16");
LMP11Y16 = Multipole(L = 0.5, name = "LMP11Y16");
YI11_INT15_2 = Drift(L = 0.295307535906226, name = "YI11_INT15_2");
YI11_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH15");
YI11_INT15_1 = Drift(L = 0.295179535906226, name = "YI11_INT15_1");
YI11_BH15 = LineElement(class="Monitor",  name = "YI11_BH15");
YI11_SXF15 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI11_SXF15");
YI11_QF15 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI11_QF15");
LMP11Y15 = Multipole(L = 0.5, name = "LMP11Y15");
YI11_INT14_2 = Drift(L = 0.295307535906226, name = "YI11_INT14_2");
YI11_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH14");
YI11_INT14_1 = Drift(L = 0.295179535906226, name = "YI11_INT14_1");
YI11_BV14 = LineElement(class="Monitor",  name = "YI11_BV14");
YI11_SXD14 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI11_SXD14");
YI11_QD14 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI11_QD14");
LMP11Y14 = Multipole(L = 0.5, name = "LMP11Y14");
YI11_INT13_2 = Drift(L = 0.295307535906226, name = "YI11_INT13_2");
YI11_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH13");
YI11_INT13_1 = Drift(L = 0.295179535906226, name = "YI11_INT13_1");
YI11_BH13 = LineElement(class="Monitor",  name = "YI11_BH13");
YI11_SXF13 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI11_SXF13");
YI11_QF13 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI11_QF13");
LMP11Y13 = Multipole(L = 0.5, name = "LMP11Y13");
YI11_INT12_2 = Drift(L = 0.295307535906226, name = "YI11_INT12_2");
YI11_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH12");
YI11_INT12_1 = Drift(L = 0.295179535906226, name = "YI11_INT12_1");
YI11_BV12 = LineElement(class="Monitor",  name = "YI11_BV12");
YI11_SXD12 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI11_SXD12");
YI11_QD12 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI11_QD12");
LMP11Y12 = Multipole(L = 0.5, name = "LMP11Y12");
YI11_INT11_2 = Drift(L = 0.295307535906226, name = "YI11_INT11_2");
YI11_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH11");
YI11_INT11_1 = Drift(L = 0.295179535906226, name = "YI11_INT11_1");
YI11_BH11 = LineElement(class="Monitor",  name = "YI11_BH11");
YI11_SXF11 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI11_SXF11");
YI11_QF11 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI11_QF11");
LMP11Y11 = Multipole(L = 0.5, name = "LMP11Y11");
YI11_INT10_2 = Drift(L = 0.295307535906226, name = "YI11_INT10_2");
YI11_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH10");
YI11_INT10_1 = Drift(L = 0.295179535906226, name = "YI11_INT10_1");
YI11_BV10 = LineElement(class="Monitor",  name = "YI11_BV10");
YI11_SXD10 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI11_SXD10");
YI11_QD10 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI11_QD10");
LMP11Y10 = Multipole(L = 0.5, name = "LMP11Y10");
YI11_INT9_3 = Drift(L = 0.302432390362215, name = "YI11_INT9_3");
YI11_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YI11_DH9");
YI11_INT9_2 = Drift(L = 0.302384300392218, name = "YI11_INT9_2");
YI11_INT9_1 = Drift(L = 0.295148, name = "YI11_INT9_1");
YI11_BH9 = LineElement(class="Monitor",  name = "YI11_BH9");
YI11_SXF9 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI11_SXF9");
YI11_QF9 = Quadrupole(L = 1.11, K1 = 0.08009031926946382, name = "YI11_QF9");
LMP11Y09 = Multipole(L = 0.5, name = "LMP11Y09");
YI11_INT8_2 = Drift(L = 0.295307535906226, name = "YI11_INT8_2");
YI11_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI11_DH8");
YI11_INT8_1 = Drift(L = 0.295307535906226, name = "YI11_INT8_1");
LMP11Y08 = Multipole(L = 0.5, name = "LMP11Y08");
YI11_QD8 = Quadrupole(L = 1.11, K1 = -0.08037984559409996, name = "YI11_QD8");
YI11_B8 = LineElement(class="Monitor",  name = "YI11_B8");
YI11_INT7_2 = Drift(L = 0.29519754785, name = "YI11_INT7_2");
YI11_SNK_HLX4 = LineElement(class="Pipe", L = 2.4, name = "YI11_SNK_HLX4");
YI11_SNK_HLX3 = LineElement(class="Pipe", L = 2.4, name = "YI11_SNK_HLX3");
YI11_BSNK = LineElement(class="Snake3",  name = "YI11_BSNK");
YI11_SNK_HLX2 = LineElement(class="Pipe", L = 2.4, name = "YI11_SNK_HLX2");
YI11_SNK_HLX1 = LineElement(class="Pipe", L = 2.4, name = "YI11_SNK_HLX1");
YI11_INT7_1 = Drift(L = 0.29519754785, name = "YI11_INT7_1");
YI11_B7 = LineElement(class="Monitor",  name = "YI11_B7");
YI11_QF7 = Quadrupole(L = 0.929744, K1 = 0.08808311799979637, name = "YI11_QF7");
LMP11Y07 = Multipole(L = 0.5, name = "LMP11Y07");
YI11_INT6_3 = Drift(L = 0.302432390362215, name = "YI11_INT6_3");
YI11_DH6 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YI11_DH6");
YI11_INT6_2 = Drift(L = 0.302512300392215, name = "YI11_INT6_2");
YI11_INT6_1 = Drift(L = 0.295148, name = "YI11_INT6_1");
LMP11Y06 = Multipole(L = 0.5, name = "LMP11Y06");
YI11_QD6 = Quadrupole(L = 1.11, K1 = -0.08975332806704577, name = "YI11_QD6");
YI11_TQ6 = Quadrupole(L = 0.75, K1 = -0.00037810933145654, name = "YI11_TQ6");
YI11_BV6 = LineElement(class="Monitor",  name = "YI11_BV6");
YI11_INT5_2 = Drift(L = 0.294936223422579, name = "YI11_INT5_2");
YI11_DH5 = SBend(L = 6.91599988052792, g = 0.0041230214050564, name = "YI11_DH5");
YI11_INT5_1 = Drift(L = 0.295064174522407, name = "YI11_INT5_1");
LMP11Y05 = Multipole(L = 0.5, name = "LMP11Y05");
YI11_QF5 = Quadrupole(L = 1.11, K1 = 0.08975332806704577, name = "YI11_QF5");
YI11_TQ5 = Quadrupole(L = 0.75, K1 = -0.000484560943867828, name = "YI11_TQ5");
YI11_BH5 = LineElement(class="Monitor",  name = "YI11_BH5");
YI11_INT4_2 = Drift(L = 0.302561, name = "YI11_INT4_2");
YI11_INT4_1 = Drift(L = 0.302561, name = "YI11_INT4_1");
LMP11Y04 = Multipole(L = 0.5, name = "LMP11Y04");
YI11_QD4 = Quadrupole(L = 1.811949, K1 = -0.0900735837906246, name = "YI11_QD4");
YI11_TQ4 = Quadrupole(L = 0.75, K1 = 0.03457229542101407, name = "YI11_TQ4");
YI11_B4 = LineElement(class="Monitor",  name = "YI11_B4");
OBSK11IY = Drift(L = 0.042507, name = "OBSK11IY");
YI11_SV4 = LineElement(class="Marker",  name = "YI11_SV4");
O3Y11C0 = Drift(L = 1.065111, name = "O3Y11C0");
OCKTLFL = Drift(L = 0.594233, name = "OCKTLFL");
YI11_KSCL3_3 = LineElement(class="Instrument",  name = "YI11_KSCL3_3");
O3Y11C1 = Drift(L = 0.292608, name = "O3Y11C1");
YI11_KSCL3_2 = LineElement(class="Instrument",  name = "YI11_KSCL3_2");
O3Y11C2 = Drift(L = 0.292608, name = "O3Y11C2");
YI11_KSCL3_1 = LineElement(class="Instrument",  name = "YI11_KSCL3_1");
O3Y11C3 = Drift(L = 28.300026, name = "O3Y11C3");
YI11_KFBH3 = Multipole( name = "YI11_KFBH3");
O3Y11C4 = Drift(L = 0.515135423024206, name = "O3Y11C4");
YI11_SV3 = LineElement(class="Marker",  name = "YI11_SV3");
OBSK11LY = Drift(L = 0.048526, name = "OBSK11LY");
YI11_B3 = LineElement(class="Monitor",  name = "YI11_B3");
LMP11Y3A = Multipole(L = 0.5, name = "LMP11Y3A");
YI11_QF3 = Quadrupole(L = 2.100484, K1 = 0.054692790653775795, name = "YI11_QF3");
LMP11Y3X = Multipole(L = 0.5, name = "LMP11Y3X");
YI11_INT2 = Drift(L = 0.7837792, name = "YI11_INT2");
YI11_QD2 = Quadrupole(L = 3.391633, K1 = -0.05512604580604082, name = "YI11_QD2");
LMP11Y02 = Multipole(L = 0.5, name = "LMP11Y02");
YI11_INT1 = Drift(L = 0.626085, name = "YI11_INT1");
YI11_QF1 = Quadrupole(L = 1.44, K1 = 0.05548969327826606, name = "YI11_QF1");
YI11_B1 = LineElement(class="Monitor",  name = "YI11_B1");
OH12 = Drift(L = 32.921047628902, name = "OH12");
YO12_B1 = LineElement(class="Monitor",  name = "YO12_B1");
YO12_QD1 = Quadrupole(L = 1.44, K1 = -0.05773924955002271, name = "YO12_QD1");
YO12_INT1 = Drift(L = 0.626085, name = "YO12_INT1");
LMP12Y02 = Multipole(L = 0.5, name = "LMP12Y02");
YO12_QF2 = Quadrupole(L = 3.391633, K1 = 0.05606287021385731, name = "YO12_QF2");
YO12_INT2 = Drift(L = 0.7837792, name = "YO12_INT2");
LMP12Y3X = Multipole(L = 0.5, name = "LMP12Y3X");
YO12_QD3 = Quadrupole(L = 2.100484, K1 = -0.05472852627502216, name = "YO12_QD3");
LMP12Y3A = Multipole(L = 0.5, name = "LMP12Y3A");
YO12_B3 = LineElement(class="Monitor",  name = "YO12_B3");
OBSK12LY = Drift(L = 0.048638, name = "OBSK12LY");
YO12_SV3_1 = LineElement(class="Marker",  name = "YO12_SV3_1");
O3Y12C0 = Drift(L = 0.514617, name = "O3Y12C0");
YO12_KFBH3 = Multipole( name = "YO12_KFBH3");
O3Y12C1 = Drift(L = 0.507358, name = "O3Y12C1");
OCPUFL = Drift(L = 0.3937, name = "OCPUFL");
YO12_CPUH3 = LineElement(class="Instrument",  name = "YO12_CPUH3");
O3Y12C2 = Drift(L = 4.235704, name = "O3Y12C2");
OIPMFLL = Drift(L = 0.282284, name = "OIPMFLL");
YO12_IPM3 = LineElement(class="Instrument",  name = "YO12_IPM3");
OIPMFLS = Drift(L = 0.886116, name = "OIPMFLS");
O3Y12C3 = Drift(L = 4.049268, name = "O3Y12C3");
OELDFL = Drift(L = 0.119634, name = "OELDFL");
YO12_ELD3 = LineElement(class="Instrument",  name = "YO12_ELD3");
O3Y12C4 = Drift(L = 18.897778, name = "O3Y12C4");
YO12_CPUV3 = LineElement(class="Instrument",  name = "YO12_CPUV3");
O3Y12C5 = Drift(L = 0.150352, name = "O3Y12C5");
YO12_SV3_2 = LineElement(class="Marker",  name = "YO12_SV3_2");
O3Y12C6 = Drift(L = 0.048749, name = "O3Y12C6");
OPOLFLL = Drift(L = 0.837184, name = "OPOLFLL");
YO12_POL3_1 = LineElement(class="Instrument",  name = "YO12_POL3_1");
OPOLFLM = Drift(L = 0.508, name = "OPOLFLM");
YO12_POL3_2 = LineElement(class="Instrument",  name = "YO12_POL3_2");
OPOLFLS = Drift(L = 0.760984, name = "OPOLFLS");
O3Y12C7 = Drift(L = 0.538274423024216, name = "O3Y12C7");
YO12_SV4 = LineElement(class="Marker",  name = "YO12_SV4");
OBSK12IY = Drift(L = 0.042545, name = "OBSK12IY");
YO12_B4 = LineElement(class="Monitor",  name = "YO12_B4");
YO12_TQ4 = Quadrupole(L = 0.75, K1 = -0.007416042794898802, name = "YO12_TQ4");
YO12_QF4 = Quadrupole(L = 1.811949, K1 = 0.0900735837906246, name = "YO12_QF4");
LMP12Y04 = Multipole(L = 0.5, name = "LMP12Y04");
YO12_INT4_1 = Drift(L = 0.302561, name = "YO12_INT4_1");
YO12_INT4_2 = Drift(L = 0.302561, name = "YO12_INT4_2");
YO12_BV5 = LineElement(class="Monitor",  name = "YO12_BV5");
YO12_TQ5 = Quadrupole(L = 0.75, K1 = -0.012527156277838913, name = "YO12_TQ5");
YO12_QD5 = Quadrupole(L = 1.11, K1 = -0.08975332806704577, name = "YO12_QD5");
LMP12Y05 = Multipole(L = 0.5, name = "LMP12Y05");
YO12_INT5_1 = Drift(L = 0.294586752907152, name = "YO12_INT5_1");
YO12_DH5 = SBend(L = 8.69844937519207, g = 0.0041230214050564, name = "YO12_DH5");
YO12_INT5_2 = Drift(L = 0.29445870400698, name = "YO12_INT5_2");
YO12_BH6 = LineElement(class="Monitor",  name = "YO12_BH6");
YO12_TQ6 = Quadrupole(L = 0.75, K1 = 0.014135819127545517, name = "YO12_TQ6");
YO12_QF6 = Quadrupole(L = 1.11, K1 = 0.08975332806704577, name = "YO12_QF6");
LMP12Y06 = Multipole(L = 0.5, name = "LMP12Y06");
YO12_INT6_1 = Drift(L = 0.295148, name = "YO12_INT6_1");
YO12_INT6_2 = Drift(L = 0.307984615363785, name = "YO12_INT6_2");
YO12_DH6 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO12_DH6");
YO12_INT6_3 = Drift(L = 0.307904705333785, name = "YO12_INT6_3");
LMP12Y07 = Multipole(L = 0.5, name = "LMP12Y07");
YO12_QD7 = Quadrupole(L = 0.929744, K1 = -0.08808311799979637, name = "YO12_QD7");
YO12_B7 = LineElement(class="Monitor",  name = "YO12_B7");
YO12_INT7_1 = Drift(L = 0.29519754785, name = "YO12_INT7_1");
YO12_INT7_2 = Drift(L = 0.29519754785, name = "YO12_INT7_2");
YO12_B8 = LineElement(class="Monitor",  name = "YO12_B8");
YO12_QF8 = Quadrupole(L = 1.11, K1 = 0.08029846430632664, name = "YO12_QF8");
LMP12Y08 = Multipole(L = 0.5, name = "LMP12Y08");
YO12_INT8_1 = Drift(L = 0.312825559773772, name = "YO12_INT8_1");
YO12_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH8");
YO12_INT8_2 = Drift(L = 0.312825559773772, name = "YO12_INT8_2");
LMP12Y09 = Multipole(L = 0.5, name = "LMP12Y09");
YO12_QD9 = Quadrupole(L = 1.11, K1 = -0.08037984559409996, name = "YO12_QD9");
YO12_SXD9 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO12_SXD9");
YO12_BV9 = LineElement(class="Monitor",  name = "YO12_BV9");
YO12_INT9_1 = Drift(L = 0.295148, name = "YO12_INT9_1");
YO12_INT9_2 = Drift(L = 0.307856615363788, name = "YO12_INT9_2");
YO12_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO12_DH9");
YO12_INT9_3 = Drift(L = 0.307904705333785, name = "YO12_INT9_3");
LMP12Y10 = Multipole(L = 0.5, name = "LMP12Y10");
YO12_QF10 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO12_QF10");
YO12_SXF10 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO12_SXF10");
YO12_BH10 = LineElement(class="Monitor",  name = "YO12_BH10");
YO12_INT10_1 = Drift(L = 0.312697559773772, name = "YO12_INT10_1");
YO12_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH10");
YO12_INT10_2 = Drift(L = 0.312825559773772, name = "YO12_INT10_2");
YO12_TV11 = LineElement(class="Vkicker", L = 0.5, name = "YO12_TV11");
YO12_QD11 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO12_QD11");
YO12_SXD11 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO12_SXD11");
YO12_BV11 = LineElement(class="Monitor",  name = "YO12_BV11");
YO12_INT11_1 = Drift(L = 0.312697559773772, name = "YO12_INT11_1");
YO12_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH11");
YO12_INT11_2 = Drift(L = 0.312825559773772, name = "YO12_INT11_2");
YO12_TH12 = LineElement(class="Hkicker", L = 0.5, name = "YO12_TH12");
YO12_QF12 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO12_QF12");
YO12_SXF12 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO12_SXF12");
YO12_BH12 = LineElement(class="Monitor",  name = "YO12_BH12");
YO12_INT12_1 = Drift(L = 0.312697559773772, name = "YO12_INT12_1");
YO12_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH12");
YO12_INT12_2 = Drift(L = 0.312825559773772, name = "YO12_INT12_2");
YO12_TV13 = LineElement(class="Vkicker", L = 0.5, name = "YO12_TV13");
YO12_QD13 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO12_QD13");
YO12_SXD13 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO12_SXD13");
YO12_BV13 = LineElement(class="Monitor",  name = "YO12_BV13");
YO12_INT13_1 = Drift(L = 0.312697559773772, name = "YO12_INT13_1");
YO12_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH13");
YO12_INT13_2 = Drift(L = 0.312825559773772, name = "YO12_INT13_2");
YO12_TH14 = LineElement(class="Hkicker", L = 0.5, name = "YO12_TH14");
YO12_QF14 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO12_QF14");
YO12_SXF14 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO12_SXF14");
YO12_BH14 = LineElement(class="Monitor",  name = "YO12_BH14");
YO12_INT14_1 = Drift(L = 0.312697559773772, name = "YO12_INT14_1");
YO12_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH14");
YO12_INT14_2 = Drift(L = 0.312825559773772, name = "YO12_INT14_2");
YO12_TV15 = LineElement(class="Vkicker", L = 0.5, name = "YO12_TV15");
YO12_QD15 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO12_QD15");
YO12_SXD15 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO12_SXD15");
YO12_BV15 = LineElement(class="Monitor",  name = "YO12_BV15");
YO12_INT15_1 = Drift(L = 0.312697559773772, name = "YO12_INT15_1");
YO12_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH15");
YO12_INT15_2 = Drift(L = 0.312825559773772, name = "YO12_INT15_2");
YO12_TH16 = LineElement(class="Hkicker", L = 0.5, name = "YO12_TH16");
YO12_QF16 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO12_QF16");
YO12_SXF16 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO12_SXF16");
YO12_BH16 = LineElement(class="Monitor",  name = "YO12_BH16");
YO12_INT16_1 = Drift(L = 0.312697559773772, name = "YO12_INT16_1");
YO12_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH16");
YO12_INT16_2 = Drift(L = 0.312825559773772, name = "YO12_INT16_2");
YO12_TV17 = LineElement(class="Vkicker", L = 0.5, name = "YO12_TV17");
YO12_QD17 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO12_QD17");
YO12_SXD17 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO12_SXD17");
YO12_BV17 = LineElement(class="Monitor",  name = "YO12_BV17");
YO12_INT17_1 = Drift(L = 0.312697559773772, name = "YO12_INT17_1");
YO12_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH17");
YO12_INT17_2 = Drift(L = 0.312825559773772, name = "YO12_INT17_2");
YO12_TH18 = LineElement(class="Hkicker", L = 0.5, name = "YO12_TH18");
YO12_QF18 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO12_QF18");
YO12_SXF18 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO12_SXF18");
YO12_BH18 = LineElement(class="Monitor",  name = "YO12_BH18");
YO12_INT18_1 = Drift(L = 0.312697559773772, name = "YO12_INT18_1");
YO12_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH18");
YO12_INT18_2 = Drift(L = 0.312825559773772, name = "YO12_INT18_2");
YO12_TV19 = LineElement(class="Vkicker", L = 0.5, name = "YO12_TV19");
YO12_QD19 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO12_QD19");
YO12_SXD19 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO12_SXD19");
YO12_BV19 = LineElement(class="Monitor",  name = "YO12_BV19");
YO12_INT19_1 = Drift(L = 0.312697559773772, name = "YO12_INT19_1");
YO12_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH19");
YO12_INT19_2 = Drift(L = 0.312825559773772, name = "YO12_INT19_2");
YO12_TH20 = LineElement(class="Hkicker", L = 0.5, name = "YO12_TH20");
YO12_QF20 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO12_QF20");
YO12_SXF20 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO12_SXF20");
YO12_BH20 = LineElement(class="Monitor",  name = "YO12_BH20");
YO12_INT20_1 = Drift(L = 0.312697559773772, name = "YO12_INT20_1");
YO12_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO12_DH20");
YO12_INT20_2 = Drift(L = 0.312825559773772, name = "YO12_INT20_2");
YO1_TV21 = LineElement(class="Vkicker", L = 0.5, name = "YO1_TV21");
YO1_QD21 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO1_QD21");
YO1_SXD21 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO1_SXD21");
YO1_BV21 = LineElement(class="Monitor",  name = "YO1_BV21");
YO1_INT20_2 = Drift(L = 0.312697559773772, name = "YO1_INT20_2");
YO1_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH20");
YO1_INT20_1 = Drift(L = 0.312825559773772, name = "YO1_INT20_1");
YO1_TH20 = LineElement(class="Hkicker", L = 0.5, name = "YO1_TH20");
YO1_QF20 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO1_QF20");
YO1_SXF20 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO1_SXF20");
YO1_BH20 = LineElement(class="Monitor",  name = "YO1_BH20");
YO1_INT19_2 = Drift(L = 0.312697559773772, name = "YO1_INT19_2");
YO1_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH19");
YO1_INT19_1 = Drift(L = 0.312825559773772, name = "YO1_INT19_1");
YO1_TV19 = LineElement(class="Vkicker", L = 0.5, name = "YO1_TV19");
YO1_QD19 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO1_QD19");
YO1_SXD19 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO1_SXD19");
YO1_BV19 = LineElement(class="Monitor",  name = "YO1_BV19");
YO1_INT18_2 = Drift(L = 0.312697559773772, name = "YO1_INT18_2");
YO1_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH18");
YO1_INT18_1 = Drift(L = 0.312825559773772, name = "YO1_INT18_1");
LMP01Y18 = Multipole(L = 0.5, name = "LMP01Y18");
YO1_QF18 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO1_QF18");
YO1_SXF18 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO1_SXF18");
YO1_BH18 = LineElement(class="Monitor",  name = "YO1_BH18");
YO1_INT17_2 = Drift(L = 0.312697559773772, name = "YO1_INT17_2");
YO1_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH17");
YO1_INT17_1 = Drift(L = 0.312825559773772, name = "YO1_INT17_1");
LMP01Y17 = Multipole(L = 0.5, name = "LMP01Y17");
YO1_QD17 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO1_QD17");
YO1_SXD17 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO1_SXD17");
YO1_BV17 = LineElement(class="Monitor",  name = "YO1_BV17");
YO1_INT16_2 = Drift(L = 0.312697559773772, name = "YO1_INT16_2");
YO1_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH16");
YO1_INT16_1 = Drift(L = 0.312825559773772, name = "YO1_INT16_1");
LMP01Y16 = Multipole(L = 0.5, name = "LMP01Y16");
YO1_QF16 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO1_QF16");
YO1_SXF16 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO1_SXF16");
YO1_BH16 = LineElement(class="Monitor",  name = "YO1_BH16");
YO1_INT15_2 = Drift(L = 0.312697559773772, name = "YO1_INT15_2");
YO1_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH15");
YO1_INT15_1 = Drift(L = 0.312825559773772, name = "YO1_INT15_1");
LMP01Y15 = Multipole(L = 0.5, name = "LMP01Y15");
YO1_QD15 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO1_QD15");
YO1_SXD15 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO1_SXD15");
YO1_BV15 = LineElement(class="Monitor",  name = "YO1_BV15");
YO1_INT14_2 = Drift(L = 0.312697559773772, name = "YO1_INT14_2");
YO1_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH14");
YO1_INT14_1 = Drift(L = 0.312825559773772, name = "YO1_INT14_1");
LMP01Y14 = Multipole(L = 0.5, name = "LMP01Y14");
YO1_QF14 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO1_QF14");
YO1_SXF14 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO1_SXF14");
YO1_BH14 = LineElement(class="Monitor",  name = "YO1_BH14");
YO1_INT13_2 = Drift(L = 0.312697559773772, name = "YO1_INT13_2");
YO1_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH13");
YO1_INT13_1 = Drift(L = 0.312825559773772, name = "YO1_INT13_1");
LMP01Y13 = Multipole(L = 0.5, name = "LMP01Y13");
YO1_QD13 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO1_QD13");
YO1_SXD13 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO1_SXD13");
YO1_BV13 = LineElement(class="Monitor",  name = "YO1_BV13");
YO1_INT12_2 = Drift(L = 0.312697559773772, name = "YO1_INT12_2");
YO1_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH12");
YO1_INT12_1 = Drift(L = 0.312825559773772, name = "YO1_INT12_1");
LMP01Y12 = Multipole(L = 0.5, name = "LMP01Y12");
YO1_QF12 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO1_QF12");
YO1_SXF12 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO1_SXF12");
YO1_BH12 = LineElement(class="Monitor",  name = "YO1_BH12");
YO1_INT11_2 = Drift(L = 0.312697559773772, name = "YO1_INT11_2");
YO1_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH11");
YO1_INT11_1 = Drift(L = 0.312825559773772, name = "YO1_INT11_1");
LMP01Y11 = Multipole(L = 0.5, name = "LMP01Y11");
YO1_QD11 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO1_QD11");
YO1_SXD11 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO1_SXD11");
YO1_BV11 = LineElement(class="Monitor",  name = "YO1_BV11");
YO1_INT10_2 = Drift(L = 0.312697559773772, name = "YO1_INT10_2");
YO1_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH10");
YO1_INT10_1 = Drift(L = 0.312825559773772, name = "YO1_INT10_1");
LMP01Y10 = Multipole(L = 0.5, name = "LMP01Y10");
YO1_QF10 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO1_QF10");
YO1_SXF10 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO1_SXF10");
YO1_BH10 = LineElement(class="Monitor",  name = "YO1_BH10");
YO1_INT9_3 = Drift(L = 0.307776705333785, name = "YO1_INT9_3");
YO1_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO1_DH9");
YO1_INT9_2 = Drift(L = 0.307856615363788, name = "YO1_INT9_2");
YO1_INT9_1 = Drift(L = 0.295148, name = "YO1_INT9_1");
YO1_BV9 = LineElement(class="Monitor",  name = "YO1_BV9");
YO1_QD9 = Quadrupole(L = 1.11, K1 = -0.08010569669485972, name = "YO1_QD9");
LMP01Y09 = Multipole(L = 0.5, name = "LMP01Y09");
YO1_INT8_2 = Drift(L = 0.312825559773772, name = "YO1_INT8_2");
YO1_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO1_DH8");
YO1_INT8_1 = Drift(L = 0.312825559773772, name = "YO1_INT8_1");
LMP01Y08 = Multipole(L = 0.5, name = "LMP01Y08");
YO1_QF8 = Quadrupole(L = 1.11, K1 = 0.08002431540708642, name = "YO1_QF8");
YO1_B8 = LineElement(class="Monitor",  name = "YO1_B8");
YO1_INT7_2 = Drift(L = 0.29519754785, name = "YO1_INT7_2");
YI1_SNK_HLX4 = LineElement(class="Pipe", L = 2.4, name = "YI1_SNK_HLX4");
YI1_SNK_HLX3 = LineElement(class="Pipe", L = 2.4, name = "YI1_SNK_HLX3");
YI1_BSNK = LineElement(class="Snake4",  name = "YI1_BSNK");
YI1_SNK_HLX2 = LineElement(class="Pipe", L = 2.4, name = "YI1_SNK_HLX2");
YI1_SNK_HLX1 = LineElement(class="Pipe", L = 2.4, name = "YI1_SNK_HLX1");
YO1_INT7_1 = Drift(L = 0.29519754785, name = "YO1_INT7_1");
YO1_B7 = LineElement(class="Monitor",  name = "YO1_B7");
YO1_QD7 = Quadrupole(L = 0.929744, K1 = -0.08844900335689784, name = "YO1_QD7");
LMP01Y07 = Multipole(L = 0.5, name = "LMP01Y07");
YO1_INT6_3 = Drift(L = 0.307904705333785, name = "YO1_INT6_3");
YO1_DH6 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO1_DH6");
YO1_INT6_2 = Drift(L = 0.307984615363785, name = "YO1_INT6_2");
YO1_INT6_1 = Drift(L = 0.295148, name = "YO1_INT6_1");
LMP01Y06 = Multipole(L = 0.5, name = "LMP01Y06");
YO1_QF6 = Quadrupole(L = 1.11, K1 = 0.08873343350187166, name = "YO1_QF6");
YO1_TQ6 = Quadrupole(L = 0.75, K1 = 0.010411258221434098, name = "YO1_TQ6");
YO1_BH6 = LineElement(class="Monitor",  name = "YO1_BH6");
YO1_INT5_2 = Drift(L = 0.29445870400698, name = "YO1_INT5_2");
YO1_DH5 = SBend(L = 8.69844937519207, g = 0.0041230214050564, name = "YO1_DH5");
YO1_INT5_1 = Drift(L = 0.294586752907152, name = "YO1_INT5_1");
LMP01Y05 = Multipole(L = 0.5, name = "LMP01Y05");
YO1_QD5 = Quadrupole(L = 1.11, K1 = -0.08873343350187166, name = "YO1_QD5");
YO1_TQ5 = Quadrupole(L = 0.75, K1 = -0.01208099318501487, name = "YO1_TQ5");
YO1_BV5 = LineElement(class="Monitor",  name = "YO1_BV5");
YO1_INT4_2 = Drift(L = 0.302561, name = "YO1_INT4_2");
YO1_INT4_1 = Drift(L = 0.302561, name = "YO1_INT4_1");
LMP01Y04 = Multipole(L = 0.5, name = "LMP01Y04");
YO1_QF4 = Quadrupole(L = 1.811949, K1 = 0.08905005006154446, name = "YO1_QF4");
YO1_TQ4 = Quadrupole(L = 0.75, K1 = -0.009573799391033639, name = "YO1_TQ4");
YO1_B4 = LineElement(class="Monitor",  name = "YO1_B4");
OBSK1IY = Drift(L = 0.042546, name = "OBSK1IY");
YO1_SV4 = LineElement(class="Marker",  name = "YO1_SV4");
O3Y1C0 = Drift(L = 5.107812, name = "O3Y1C0");
ODCOMPFL = Drift(L = 0.136233, name = "ODCOMPFL");
YO1_COOL_DCOMP1_2 = Multipole( name = "YO1_COOL_DCOMP1_2");
O3Y1C1 = Drift(L = 0.135585, name = "O3Y1C1");
YO1_COOL_DCOMP1_1 = Multipole( name = "YO1_COOL_DCOMP1_1");
O3Y1C2 = Drift(L = 1.414019, name = "O3Y1C2");
YO1_SV3_2 = LineElement(class="Marker",  name = "YO1_SV3_2");
O3Y1C3 = Drift(L = 0.534669, name = "O3Y1C3");
OYAGFL = Drift(L = 0.092964, name = "OYAGFL");
YO1_COOL_YAG3 = LineElement(class="Instrument",  name = "YO1_COOL_YAG3");
O3Y1C4 = Drift(L = 0.508381, name = "O3Y1C4");
D2_COOLY = Drift(L = 0.80137, name = "D2_COOLY");
OYAGSLITFL = Drift(L = 0.088011, name = "OYAGSLITFL");
YO1_COOL_YAG2SLIT = LineElement(class="Instrument",  name = "YO1_COOL_YAG2SLIT");
O3Y1C5 = Drift(L = 0.29845, name = "O3Y1C5");
OBCOOLFL = Drift(L = 0.079756, name = "OBCOOLFL");
YO1_COOL_B8 = LineElement(class="Monitor",  name = "YO1_COOL_B8");
YO1_COOL_Q2 = Quadrupole(L = 0.181619, name = "YO1_COOL_Q2");
YO1_COOL_SOL8 = Solenoid(L = 0.266421, name = "YO1_COOL_SOL8");
O3Y1C6 = Drift(L = 2.301926, name = "O3Y1C6");
YO1_COOL_B7 = LineElement(class="Monitor",  name = "YO1_COOL_B7");
YO1_COOL_SOL7 = Solenoid(L = 0.266421, name = "YO1_COOL_SOL7");
O3Y1C7 = Drift(L = 2.601443, name = "O3Y1C7");
YO1_COOL_B6 = LineElement(class="Monitor",  name = "YO1_COOL_B6");
YO1_COOL_SOL6 = Solenoid(L = 0.266421, name = "YO1_COOL_SOL6");
O3Y1C8 = Drift(L = 2.601443, name = "O3Y1C8");
YO1_COOL_B5 = LineElement(class="Monitor",  name = "YO1_COOL_B5");
YO1_COOL_SOL5 = Solenoid(L = 0.266421, name = "YO1_COOL_SOL5");
O3Y1C9 = Drift(L = 2.601417, name = "O3Y1C9");
YO1_COOL_B4 = LineElement(class="Monitor",  name = "YO1_COOL_B4");
YO1_COOL_SOL4 = Solenoid(L = 0.266421, name = "YO1_COOL_SOL4");
O3Y1C10 = Drift(L = 2.601443, name = "O3Y1C10");
YO1_COOL_B3 = LineElement(class="Monitor",  name = "YO1_COOL_B3");
YO1_COOL_SOL3 = Solenoid(L = 0.266421, name = "YO1_COOL_SOL3");
O3Y1C11 = Drift(L = 2.601417, name = "O3Y1C11");
YO1_COOL_B2 = LineElement(class="Monitor",  name = "YO1_COOL_B2");
YO1_COOL_SOL2 = Solenoid(L = 0.266421, name = "YO1_COOL_SOL2");
YO1_COOL_YAG1 = LineElement(class="Instrument",  name = "YO1_COOL_YAG1");
O3Y1C12 = Drift(L = 2.142515, name = "O3Y1C12");
YO1_COOL_B1 = LineElement(class="Monitor",  name = "YO1_COOL_B1");
OSLITFL = Drift(L = 0.117475, name = "OSLITFL");
YO1_COOL_SLIT = LineElement(class="Instrument",  name = "YO1_COOL_SLIT");
O3Y1C13 = Drift(L = 0.102108, name = "O3Y1C13");
YO1_COOL_SOL1 = Solenoid(L = 0.266421, name = "YO1_COOL_SOL1");
O3Y1C14 = Drift(L = 0.403987, name = "O3Y1C14");
YO1_COOL_Q1 = Quadrupole(L = 0.181619, name = "YO1_COOL_Q1");
O3Y1C15 = Drift(L = 0.127, name = "O3Y1C15");
D1_COOLY = Drift(L = 0.893318, name = "D1_COOLY");
O3Y1C16 = Drift(L = 1.10508942302421, name = "O3Y1C16");
OBSK1LY = Drift(L = 0.048769, name = "OBSK1LY");
YO1_SV3_1 = LineElement(class="Marker",  name = "YO1_SV3_1");
OBELSKL = Drift(L = 0.04875, name = "OBELSKL");
YO1_B3 = LineElement(class="Monitor",  name = "YO1_B3");
LMP01Y3A = Multipole(L = 0.5, name = "LMP01Y3A");
YO1_QD3 = Quadrupole(L = 2.100484, K1 = -0.054609668906617836, name = "YO1_QD3");
LMP01Y3X = Multipole(L = 0.5, name = "LMP01Y3X");
YO1_INT2 = Drift(L = 0.7837792, name = "YO1_INT2");
YO1_QF2 = Quadrupole(L = 3.391633, K1 = 0.05596193162126347, name = "YO1_QF2");
LMP01Y02 = Multipole(L = 0.5, name = "LMP01Y02");
YO1_INT1 = Drift(L = 0.626085, name = "YO1_INT1");
YO1_QD1 = Quadrupole(L = 1.44, K1 = -0.058064370434617, name = "YO1_QD1");
YO1_B1 = LineElement(class="Monitor",  name = "YO1_B1");
O02 = Drift(L = 32.921047628902, name = "O02");
YI2_B1 = LineElement(class="Monitor",  name = "YI2_B1");
YI2_QF1 = Quadrupole(L = 1.44, K1 = 0.055993131937483405, name = "YI2_QF1");
YI2_INT1 = Drift(L = 0.626085, name = "YI2_INT1");
LMP02Y02 = Multipole(L = 0.5, name = "LMP02Y02");
YI2_QD2 = Quadrupole(L = 3.391633, K1 = -0.05520138421159465, name = "YI2_QD2");
YI2_INT2 = Drift(L = 0.7837792, name = "YI2_INT2");
LMP02Y3X = Multipole(L = 0.5, name = "LMP02Y3X");
YI2_QF3 = Quadrupole(L = 2.100484, K1 = 0.0545935710911708, name = "YI2_QF3");
LMP02Y3A = Multipole(L = 0.5, name = "LMP02Y3A");
YI2_B3 = LineElement(class="Monitor",  name = "YI2_B3");
OBSK2LY = Drift(L = 0.048761, name = "OBSK2LY");
YI2_SV3 = LineElement(class="Marker",  name = "YI2_SV3");
O3Y2C0 = Drift(L = 0.5146, name = "O3Y2C0");
YI2_KFBH3 = Multipole( name = "YI2_KFBH3");
O3Y2C1 = Drift(L = 1.560833, name = "O3Y2C1");
OMVBFL = Drift(L = 0.1905, name = "OMVBFL");
YI2_SPU3_1 = LineElement(class="Instrument",  name = "YI2_SPU3_1");
OMVBFLS = Drift(L = 0.188468, name = "OMVBFLS");
YI2_SPU3_2 = LineElement(class="Instrument",  name = "YI2_SPU3_2");
O3Y2C2 = Drift(L = 0.3937, name = "O3Y2C2");
YI2_IPM3 = LineElement(class="Instrument",  name = "YI2_IPM3");
O3Y2C3 = Drift(L = 0.438912, name = "O3Y2C3");
OQMMS = Drift(L = 0.125, name = "OQMMS");
YI2_KQM3 = Multipole( name = "YI2_KQM3");
O3Y2C4 = Drift(L = 3.299206, name = "O3Y2C4");
OTMKGCK = Drift(L = 0.999998, name = "OTMKGCK");
YI2_DMPTH3_1 = LineElement(class="Instrument",  name = "YI2_DMPTH3_1");
YI2_DMPTH3_2 = LineElement(class="Instrument",  name = "YI2_DMPTH3_2");
O3Y2C5 = Drift(L = 0.292608, name = "O3Y2C5");
YI2_DMPTV3_1 = LineElement(class="Instrument",  name = "YI2_DMPTV3_1");
YI2_DMPTV3_2 = LineElement(class="Instrument",  name = "YI2_DMPTV3_2");
O3Y2C6 = Drift(L = 5.887974, name = "O3Y2C6");
OQMM = Drift(L = 0.499999, name = "OQMM");
YI2_KTUN3_1 = Multipole( name = "YI2_KTUN3_1");
YI2_BQM3_1 = LineElement(class="Instrument",  name = "YI2_BQM3_1");
O3Y2C7 = Drift(L = 0.33528, name = "O3Y2C7");
YI2_BHT3 = LineElement(class="Instrument",  name = "YI2_BHT3");
YI2_BQM3_2 = LineElement(class="Instrument",  name = "YI2_BQM3_2");
YI2_KTUN3_2 = Multipole( name = "YI2_KTUN3_2");
O3Y2C8 = Drift(L = 1.74371, name = "O3Y2C8");
OBBPMFL = Drift(L = 0.250001687789, name = "OBBPMFL");
YI2_BB3 = LineElement(class="Instrument",  name = "YI2_BB3");
OWCMFL = Drift(L = 0.499999, name = "OWCMFL");
YI2_WCM3 = LineElement(class="Instrument",  name = "YI2_WCM3");
OXFFL = Drift(L = 0.250001687789, name = "OXFFL");
YI2_XF3 = LineElement(class="Instrument",  name = "YI2_XF3");
OSCAVFL = Drift(L = 0.500003375578, name = "OSCAVFL");
YI2_SPU3_3 = LineElement(class="Instrument",  name = "YI2_SPU3_3");
O3Y2C9 = Drift(L = 2.88750992071221, name = "O3Y2C9");
YI2_SV4 = LineElement(class="Marker",  name = "YI2_SV4");
OBSK2IY = Drift(L = 0.0425, name = "OBSK2IY");
YI2_B4 = LineElement(class="Monitor",  name = "YI2_B4");
YI2_TQ4 = Quadrupole(L = 0.75, K1 = 0.034622269525102396, name = "YI2_TQ4");
YI2_QD4 = Quadrupole(L = 1.811949, K1 = -0.08905005006154446, name = "YI2_QD4");
LMP02Y04 = Multipole(L = 0.5, name = "LMP02Y04");
YI2_INT4_1 = Drift(L = 0.302561, name = "YI2_INT4_1");
YI2_INT4_2 = Drift(L = 0.302561, name = "YI2_INT4_2");
YI2_BH5 = LineElement(class="Monitor",  name = "YI2_BH5");
YI2_TQ5 = Quadrupole(L = 0.75, K1 = 0.00035463568049921536, name = "YI2_TQ5");
YI2_QF5 = Quadrupole(L = 1.11, K1 = 0.08873343350187166, name = "YI2_QF5");
LMP02Y05 = Multipole(L = 0.5, name = "LMP02Y05");
YI2_INT5_1 = Drift(L = 0.295064174522407, name = "YI2_INT5_1");
YI2_DH5 = SBend(L = 6.91599988052792, g = 0.0041230214050564, name = "YI2_DH5");
YI2_INT5_2 = Drift(L = 0.294936223422579, name = "YI2_INT5_2");
YI2_BV6 = LineElement(class="Monitor",  name = "YI2_BV6");
YI2_TQ6 = Quadrupole(L = 0.75, K1 = -0.0001395289853119684, name = "YI2_TQ6");
YI2_QD6 = Quadrupole(L = 1.11, K1 = -0.08873343350187166, name = "YI2_QD6");
LMP02Y06 = Multipole(L = 0.5, name = "LMP02Y06");
YI2_INT6_1 = Drift(L = 0.295148, name = "YI2_INT6_1");
YI2_INT6_2 = Drift(L = 0.302512300392215, name = "YI2_INT6_2");
YI2_DH6 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YI2_DH6");
YI2_INT6_3 = Drift(L = 0.302432390362215, name = "YI2_INT6_3");
LMP02Y07 = Multipole(L = 0.5, name = "LMP02Y07");
YI2_QF7 = Quadrupole(L = 0.929744, K1 = 0.08844900335689784, name = "YI2_QF7");
YI2_B7 = LineElement(class="Monitor",  name = "YI2_B7");
YI2_INT7_1 = Drift(L = 0.29519754785, name = "YI2_INT7_1");
YI2_INT7_2 = Drift(L = 0.29519754785, name = "YI2_INT7_2");
YI2_B8 = LineElement(class="Monitor",  name = "YI2_B8");
YI2_QD8 = Quadrupole(L = 1.11, K1 = -0.08010569669485972, name = "YI2_QD8");
LMP02Y08 = Multipole(L = 0.5, name = "LMP02Y08");
YI2_INT8_1 = Drift(L = 0.295307535906226, name = "YI2_INT8_1");
YI2_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH8");
YI2_INT8_2 = Drift(L = 0.295307535906226, name = "YI2_INT8_2");
LMP02Y09 = Multipole(L = 0.5, name = "LMP02Y09");
YI2_QF9 = Quadrupole(L = 1.11, K1 = 0.08002431540708642, name = "YI2_QF9");
YI2_BH9 = LineElement(class="Monitor",  name = "YI2_BH9");
YI2_INT9_1 = Drift(L = 0.295148, name = "YI2_INT9_1");
YI2_INT9_2 = Drift(L = 0.302384300392218, name = "YI2_INT9_2");
YI2_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YI2_DH9");
YI2_INT9_3 = Drift(L = 0.302304390362215, name = "YI2_INT9_3");
YI2_BV10 = LineElement(class="Monitor",  name = "YI2_BV10");
YI2_SXD10 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI2_SXD10");
YI2_QD10 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI2_QD10");
LMP02Y10 = Multipole(L = 0.5, name = "LMP02Y10");
YI2_INT10_1 = Drift(L = 0.295307535906226, name = "YI2_INT10_1");
YI2_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH10");
YI2_INT10_2 = Drift(L = 0.295179535906226, name = "YI2_INT10_2");
YI2_BH11 = LineElement(class="Monitor",  name = "YI2_BH11");
YI2_SXF11 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI2_SXF11");
YI2_QF11 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI2_QF11");
YI2_TH11 = LineElement(class="Hkicker", L = 0.5, name = "YI2_TH11");
YI2_INT11_1 = Drift(L = 0.295307535906226, name = "YI2_INT11_1");
YI2_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH11");
YI2_INT11_2 = Drift(L = 0.295179535906226, name = "YI2_INT11_2");
YI2_BV12 = LineElement(class="Monitor",  name = "YI2_BV12");
YI2_SXD12 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI2_SXD12");
YI2_QD12 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI2_QD12");
YI2_TV12 = LineElement(class="Vkicker", L = 0.5, name = "YI2_TV12");
YI2_INT12_1 = Drift(L = 0.295307535906226, name = "YI2_INT12_1");
YI2_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH12");
YI2_INT12_2 = Drift(L = 0.295179535906226, name = "YI2_INT12_2");
YI2_BH13 = LineElement(class="Monitor",  name = "YI2_BH13");
YI2_SXF13 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI2_SXF13");
YI2_QF13 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI2_QF13");
YI2_TH13 = LineElement(class="Hkicker", L = 0.5, name = "YI2_TH13");
YI2_INT13_1 = Drift(L = 0.295307535906226, name = "YI2_INT13_1");
YI2_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH13");
YI2_INT13_2 = Drift(L = 0.295179535906226, name = "YI2_INT13_2");
YI2_BV14 = LineElement(class="Monitor",  name = "YI2_BV14");
YI2_SXD14 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI2_SXD14");
YI2_QD14 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI2_QD14");
YI2_TV14 = LineElement(class="Vkicker", L = 0.5, name = "YI2_TV14");
YI2_INT14_1 = Drift(L = 0.295307535906226, name = "YI2_INT14_1");
YI2_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH14");
YI2_INT14_2 = Drift(L = 0.295179535906226, name = "YI2_INT14_2");
YI2_BH15 = LineElement(class="Monitor",  name = "YI2_BH15");
YI2_SXF15 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI2_SXF15");
YI2_QF15 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI2_QF15");
YI2_TH15 = LineElement(class="Hkicker", L = 0.5, name = "YI2_TH15");
YI2_INT15_1 = Drift(L = 0.295307535906226, name = "YI2_INT15_1");
YI2_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH15");
YI2_INT15_2 = Drift(L = 0.295179535906226, name = "YI2_INT15_2");
YI2_BV16 = LineElement(class="Monitor",  name = "YI2_BV16");
YI2_SXD16 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI2_SXD16");
YI2_QD16 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI2_QD16");
YI2_TV16 = LineElement(class="Vkicker", L = 0.5, name = "YI2_TV16");
YI2_INT16_1 = Drift(L = 0.295307535906226, name = "YI2_INT16_1");
YI2_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH16");
YI2_INT16_2 = Drift(L = 0.295179535906226, name = "YI2_INT16_2");
YI2_BH17 = LineElement(class="Monitor",  name = "YI2_BH17");
YI2_SXF17 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI2_SXF17");
YI2_QF17 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI2_QF17");
YI2_TH17 = LineElement(class="Hkicker", L = 0.5, name = "YI2_TH17");
YI2_INT17_1 = Drift(L = 0.295307535906226, name = "YI2_INT17_1");
YI2_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH17");
YI2_INT17_2 = Drift(L = 0.295179535906226, name = "YI2_INT17_2");
YI2_BV18 = LineElement(class="Monitor",  name = "YI2_BV18");
YI2_SXD18 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI2_SXD18");
YI2_QD18 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI2_QD18");
YI2_TV18 = LineElement(class="Vkicker", L = 0.5, name = "YI2_TV18");
YI2_INT18_1 = Drift(L = 0.295307535906226, name = "YI2_INT18_1");
YI2_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH18");
YI2_INT18_2 = Drift(L = 0.295179535906226, name = "YI2_INT18_2");
YI2_BH19 = LineElement(class="Monitor",  name = "YI2_BH19");
YI2_SXF19 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI2_SXF19");
YI2_QF19 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI2_QF19");
YI2_TH19 = LineElement(class="Hkicker", L = 0.5, name = "YI2_TH19");
YI2_INT19_1 = Drift(L = 0.295307535906226, name = "YI2_INT19_1");
YI2_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH19");
YI2_INT19_2 = Drift(L = 0.295179535906226, name = "YI2_INT19_2");
YI2_BV20 = LineElement(class="Monitor",  name = "YI2_BV20");
YI2_SXD20 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI2_SXD20");
YI2_QD20 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI2_QD20");
YI2_TV20 = LineElement(class="Vkicker", L = 0.5, name = "YI2_TV20");
YI2_INT20_1 = Drift(L = 0.295307535906226, name = "YI2_INT20_1");
YI2_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI2_DH20");
YI2_INT20_2 = Drift(L = 0.295179535906226, name = "YI2_INT20_2");
YI3_BH21 = LineElement(class="Monitor",  name = "YI3_BH21");
YI3_SXF21 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI3_SXF21");
YI3_QF21 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI3_QF21");
YI3_TH21 = LineElement(class="Hkicker", L = 0.5, name = "YI3_TH21");
YI3_INT20_2 = Drift(L = 0.295307535906226, name = "YI3_INT20_2");
YI3_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH20");
YI3_INT20_1 = Drift(L = 0.295179535906226, name = "YI3_INT20_1");
YI3_BV20 = LineElement(class="Monitor",  name = "YI3_BV20");
YI3_SXD20 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI3_SXD20");
YI3_QD20 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI3_QD20");
YI3_TV20 = LineElement(class="Vkicker", L = 0.5, name = "YI3_TV20");
YI3_INT19_2 = Drift(L = 0.295307535906226, name = "YI3_INT19_2");
YI3_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH19");
YI3_INT19_1 = Drift(L = 0.295179535906226, name = "YI3_INT19_1");
YI3_BH19 = LineElement(class="Monitor",  name = "YI3_BH19");
YI3_SXF19 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI3_SXF19");
YI3_QF19 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI3_QF19");
YI3_TH19 = LineElement(class="Hkicker", L = 0.5, name = "YI3_TH19");
YI3_INT18_2 = Drift(L = 0.295307535906226, name = "YI3_INT18_2");
YI3_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH18");
YI3_INT18_1 = Drift(L = 0.295179535906226, name = "YI3_INT18_1");
YI3_BV18 = LineElement(class="Monitor",  name = "YI3_BV18");
YI3_SXD18 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI3_SXD18");
YI3_QD18 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI3_QD18");
LMP03Y18 = Multipole(L = 0.5, name = "LMP03Y18");
YI3_INT17_2 = Drift(L = 0.295307535906226, name = "YI3_INT17_2");
YI3_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH17");
YI3_INT17_1 = Drift(L = 0.295179535906226, name = "YI3_INT17_1");
YI3_BH17 = LineElement(class="Monitor",  name = "YI3_BH17");
YI3_SXF17 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI3_SXF17");
YI3_QF17 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI3_QF17");
LMP03Y17 = Multipole(L = 0.5, name = "LMP03Y17");
YI3_INT16_2 = Drift(L = 0.295307535906226, name = "YI3_INT16_2");
YI3_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH16");
YI3_INT16_1 = Drift(L = 0.295179535906226, name = "YI3_INT16_1");
YI3_BV16 = LineElement(class="Monitor",  name = "YI3_BV16");
YI3_SXD16 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI3_SXD16");
YI3_QD16 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI3_QD16");
LMP03Y16 = Multipole(L = 0.5, name = "LMP03Y16");
YI3_INT15_2 = Drift(L = 0.295307535906226, name = "YI3_INT15_2");
YI3_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH15");
YI3_INT15_1 = Drift(L = 0.295179535906226, name = "YI3_INT15_1");
YI3_BH15 = LineElement(class="Monitor",  name = "YI3_BH15");
YI3_SXF15 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI3_SXF15");
YI3_QF15 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI3_QF15");
LMP03Y15 = Multipole(L = 0.5, name = "LMP03Y15");
YI3_INT14_2 = Drift(L = 0.295307535906226, name = "YI3_INT14_2");
YI3_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH14");
YI3_INT14_1 = Drift(L = 0.295179535906226, name = "YI3_INT14_1");
YI3_BV14 = LineElement(class="Monitor",  name = "YI3_BV14");
YI3_SXD14 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI3_SXD14");
YI3_QD14 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI3_QD14");
LMP03Y14 = Multipole(L = 0.5, name = "LMP03Y14");
YI3_INT13_2 = Drift(L = 0.295307535906226, name = "YI3_INT13_2");
YI3_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH13");
YI3_INT13_1 = Drift(L = 0.295179535906226, name = "YI3_INT13_1");
YI3_BH13 = LineElement(class="Monitor",  name = "YI3_BH13");
YI3_SXF13 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI3_SXF13");
YI3_QF13 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI3_QF13");
LMP03Y13 = Multipole(L = 0.5, name = "LMP03Y13");
YI3_INT12_2 = Drift(L = 0.295307535906226, name = "YI3_INT12_2");
YI3_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH12");
YI3_INT12_1 = Drift(L = 0.295179535906226, name = "YI3_INT12_1");
YI3_BV12 = LineElement(class="Monitor",  name = "YI3_BV12");
YI3_SXD12 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI3_SXD12");
YI3_QD12 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI3_QD12");
LMP03Y12 = Multipole(L = 0.5, name = "LMP03Y12");
YI3_INT11_2 = Drift(L = 0.295307535906226, name = "YI3_INT11_2");
YI3_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH11");
YI3_INT11_1 = Drift(L = 0.295179535906226, name = "YI3_INT11_1");
YI3_BH11 = LineElement(class="Monitor",  name = "YI3_BH11");
YI3_SXF11 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI3_SXF11");
YI3_QF11 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YI3_QF11");
LMP03Y11 = Multipole(L = 0.5, name = "LMP03Y11");
YI3_INT10_2 = Drift(L = 0.295307535906226, name = "YI3_INT10_2");
YI3_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH10");
YI3_INT10_1 = Drift(L = 0.295179535906226, name = "YI3_INT10_1");
YI3_BV10 = LineElement(class="Monitor",  name = "YI3_BV10");
YI3_SXD10 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YI3_SXD10");
YI3_QD10 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YI3_QD10");
LMP03Y10 = Multipole(L = 0.5, name = "LMP03Y10");
YI3_INT9_3 = Drift(L = 0.302432390362215, name = "YI3_INT9_3");
YI3_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YI3_DH9");
YI3_INT9_2 = Drift(L = 0.302384300392218, name = "YI3_INT9_2");
YI3_INT9_1 = Drift(L = 0.295148, name = "YI3_INT9_1");
YI3_BH9 = LineElement(class="Monitor",  name = "YI3_BH9");
YI3_SXF9 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YI3_SXF9");
YI3_QF9 = Quadrupole(L = 1.11, K1 = 0.07688565231961, name = "YI3_QF9");
LMP03Y09 = Multipole(L = 0.5, name = "LMP03Y09");
YI3_INT8_2 = Drift(L = 0.295307535906226, name = "YI3_INT8_2");
YI3_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YI3_DH8");
YI3_INT8_1 = Drift(L = 0.295307535906226, name = "YI3_INT8_1");
LMP03Y08 = Multipole(L = 0.5, name = "LMP03Y08");
YI3_QD8 = Quadrupole(L = 1.11, K1 = -0.07707736220023842, name = "YI3_QD8");
YI3_B8 = LineElement(class="Monitor",  name = "YI3_B8");
YI3_INT7_2 = Drift(L = 0.29519754785, name = "YI3_INT7_2");
YI3_HLX7_4 = LineElement(class="Pipe", L = 2.4, name = "YI3_HLX7_4");
YI3_HLX7_3 = LineElement(class="Pipe", L = 2.4, name = "YI3_HLX7_3");
YI3_B7_1 = LineElement(class="Snake5",  name = "YI3_B7_1");
YI3_HLX7_2 = LineElement(class="Pipe", L = 2.4, name = "YI3_HLX7_2");
YI3_HLX7_1 = LineElement(class="Pipe", L = 2.4, name = "YI3_HLX7_1");
YI3_INT7_1 = Drift(L = 0.29519754785, name = "YI3_INT7_1");
YI3_B7 = LineElement(class="Monitor",  name = "YI3_B7");
YI3_QF7 = Quadrupole(L = 0.929744, K1 = 0.08644052617712873, name = "YI3_QF7");
LMP03Y07 = Multipole(L = 0.5, name = "LMP03Y07");
YI3_INT6_3 = Drift(L = 0.302432390362215, name = "YI3_INT6_3");
YI3_DH6 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YI3_DH6");
YI3_INT6_2 = Drift(L = 0.302512300392215, name = "YI3_INT6_2");
YI3_INT6_1 = Drift(L = 0.295148, name = "YI3_INT6_1");
LMP03Y06 = Multipole(L = 0.5, name = "LMP03Y06");
YI3_QD6 = Quadrupole(L = 1.11, K1 = -0.08868853289265344, name = "YI3_QD6");
YI3_TQ6 = Quadrupole(L = 0.75, K1 = -0.010803586479433209, name = "YI3_TQ6");
YI3_BV6 = LineElement(class="Monitor",  name = "YI3_BV6");
YI3_INT5_2 = Drift(L = 0.294936223422579, name = "YI3_INT5_2");
YI3_DH5 = SBend(L = 6.91599988052792, g = 0.0041230214050564, name = "YI3_DH5");
YI3_INT5_1 = Drift(L = 0.295064174522407, name = "YI3_INT5_1");
LMP03Y05 = Multipole(L = 0.5, name = "LMP03Y05");
YI3_QF5 = Quadrupole(L = 1.11, K1 = 0.08868853289265344, name = "YI3_QF5");
YI3_TQ5 = Quadrupole(L = 0.75, K1 = 0.013635833646541274, name = "YI3_TQ5");
YI3_BH5 = LineElement(class="Monitor",  name = "YI3_BH5");
YI3_INT4_2 = Drift(L = 0.302561, name = "YI3_INT4_2");
YI3_INT4_1 = Drift(L = 0.302561, name = "YI3_INT4_1");
LMP03Y04 = Multipole(L = 0.5, name = "LMP03Y04");
YI3_QD4 = Quadrupole(L = 1.811949, K1 = -0.08900498923902388, name = "YI3_QD4");
YI3_TQ4 = Quadrupole(L = 0.75, K1 = 0.033935479021386945, name = "YI3_TQ4");
YI3_B4 = LineElement(class="Monitor",  name = "YI3_B4");
OBSK3IY = Drift(L = 0.042508, name = "OBSK3IY");
YI3_SV4 = LineElement(class="Marker",  name = "YI3_SV4");
O3Y3C0 = Drift(L = 0.995513, name = "O3Y3C0");
OCKTXFL = Drift(L = 0.964311, name = "OCKTXFL");
YI3_KSCV3 = LineElement(class="Instrument",  name = "YI3_KSCV3");
O3Y3C1 = Drift(L = 1.406906, name = "O3Y3C1");
OCKTUFL = Drift(L = 0.485013, name = "OCKTUFL");
YI3_KSCH3_2 = LineElement(class="Instrument",  name = "YI3_KSCH3_2");
O3Y3C2 = Drift(L = 0.292608, name = "O3Y3C2");
YI3_KSCH3_1 = LineElement(class="Instrument",  name = "YI3_KSCH3_1");
O3KWD = Drift(L = 14.8033224230242, name = "O3KWD");
YI3_DW0 = SBend(e2 = -0.000949620821839259, e1 = -0.000949620821839259, L = 2.00000030059327, g = -0.000949620679114468, name = "YI3_DW0");
OWDFL = Drift(L = 0.198, name = "OWDFL");
OWDTRANS = Drift(L = 0.438, name = "OWDTRANS");
OBELW7 = Drift(L = 0.194818, name = "OBELW7");
OWPUMP = Drift(L = 0.333248, name = "OWPUMP");
OVALVE = Drift(L = 0.097536, name = "OVALVE");
OJETTRANS = Drift(L = 0.320675, name = "OJETTRANS");
OJETFL = Drift(L = 0.024638, name = "OJETFL");
DET_POL_HPOL_HJET = LineElement(class="Instrument", L = 0.6223, name = "DET_POL_HPOL_HJET");
OHE3JET = LineElement(class="Pipe", L = 1.702562, name = "OHE3JET");
DET_POL_HPOL_PC1_2 = LineElement(class="Instrument", L = 2.106168, name = "DET_POL_HPOL_PC1_2");
OK10HZH = Drift(L = 0.031115, name = "OK10HZH");
YI3_KFBH3 = Multipole( name = "YI3_KFBH3");
YI3_B3W = LineElement(class="Monitor", L = 0.128524, name = "YI3_B3W");
YI3_B3 = LineElement(class="Monitor",  name = "YI3_B3");
LMP03Y3A = Multipole(L = 0.5, name = "LMP03Y3A");
YI3_QF3 = Quadrupole(L = 2.100484, K1 = 0.05369350111403127, name = "YI3_QF3");
LMP03Y3X = Multipole(L = 0.5, name = "LMP03Y3X");
YI3_INT2 = Drift(L = 0.7837792, name = "YI3_INT2");
YI3_QD2 = Quadrupole(L = 3.391633, K1 = -0.054124974406001454, name = "YI3_QD2");
LMP03Y02 = Multipole(L = 0.5, name = "LMP03Y02");
YI3_INT1 = Drift(L = 0.626085, name = "YI3_INT1");
YI3_QF1 = Quadrupole(L = 1.44, K1 = 0.055287476556399075, name = "YI3_QF1");
YI3_B1 = LineElement(class="Monitor",  name = "YI3_B1");
YI3_B1W = LineElement(class="Monitor", L = 0.128524, name = "YI3_B1W");
CAV100_4 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV100_4");
O100 = Drift(L = 0.194818, name = "O100");
CAV100_3 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV100_3");
CAV100_2 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV100_2");
CAV100_1 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV100_1");
O_KICK_ASSY = Drift(L = 0.1, name = "O_KICK_ASSY");
SL_KICK_MOD18 = Multipole(L = 0.9, name = "SL_KICK_MOD18");
SL_KICK_MOD17 = Multipole(L = 0.9, name = "SL_KICK_MOD17");
SL_KICK_MOD16 = Multipole(L = 0.9, name = "SL_KICK_MOD16");
SL_KICK_MOD15 = Multipole(L = 0.9, name = "SL_KICK_MOD15");
SL_KICK_MOD14 = Multipole(L = 0.9, name = "SL_KICK_MOD14");
SL_KICK_MOD13 = Multipole(L = 0.9, name = "SL_KICK_MOD13");
SL_KICK_MOD12 = Multipole(L = 0.9, name = "SL_KICK_MOD12");
SL_KICK_MOD11 = Multipole(L = 0.9, name = "SL_KICK_MOD11");
SL_KICK_MOD10 = Multipole(L = 0.9, name = "SL_KICK_MOD10");
SL_KICK_MOD09 = Multipole(L = 0.9, name = "SL_KICK_MOD09");
SL_KICK_MOD08 = Multipole(L = 0.9, name = "SL_KICK_MOD08");
SL_KICK_MOD07 = Multipole(L = 0.9, name = "SL_KICK_MOD07");
SL_KICK_MOD06 = Multipole(L = 0.9, name = "SL_KICK_MOD06");
SL_KICK_MOD05 = Multipole(L = 0.9, name = "SL_KICK_MOD05");
SL_KICK_MOD04 = Multipole(L = 0.9, name = "SL_KICK_MOD04");
SL_KICK_MOD03 = Multipole(L = 0.9, name = "SL_KICK_MOD03");
SL_KICK_MOD02 = Multipole(L = 0.9, name = "SL_KICK_MOD02");
SL_KICK_MOD01 = Multipole(L = 0.9, name = "SL_KICK_MOD01");
O04 = Drift(L = 9.98778266373315, name = "O04");
YO4_DW0 = SBend(e2 = 0.000949620821839259, e1 = 0.000949620821839259, L = 2.00000030059327, g = 0.000949620679114468, name = "YO4_DW0");
CAV50_3 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV50_3");
O50 = Drift(L = 0.194818, name = "O50");
CAV50_2 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV50_2");
CAV50_1 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV50_1");
YO4_B1W = LineElement(class="Monitor", L = 0.128524, name = "YO4_B1W");
YO4_B1 = LineElement(class="Monitor",  name = "YO4_B1");
YO4_QD1 = Quadrupole(L = 1.44, K1 = -0.056865502983360086, name = "YO4_QD1");
YO4_INT1 = Drift(L = 0.626085, name = "YO4_INT1");
LMP04Y02 = Multipole(L = 0.5, name = "LMP04Y02");
YO4_QF2 = Quadrupole(L = 3.391633, K1 = 0.05564641087077616, name = "YO4_QF2");
YO4_INT2 = Drift(L = 0.7837792, name = "YO4_INT2");
LMP04Y3X = Multipole(L = 0.5, name = "LMP04Y3X");
YO4_QD3 = Quadrupole(L = 2.100484, K1 = -0.054541121614985914, name = "YO4_QD3");
LMP04Y3A = Multipole(L = 0.5, name = "LMP04Y3A");
YO4_B3 = LineElement(class="Monitor",  name = "YO4_B3");
YO4_B3W = LineElement(class="Monitor", L = 0.128524, name = "YO4_B3W");
CAV25_4 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV25_4");
O25 = Drift(L = 0.194818, name = "O25");
CAV25_3 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV25_3");
CAV25_2 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV25_2");
CAV25_1 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV25_1");
O25_197 = Drift(L = 0.292354, name = "O25_197");
CAV197_9 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV197_9");
O197 = Drift(L = 0.194818, name = "O197");
CAV197_8 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV197_8");
CAV197_7 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV197_7");
CAV197_6 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV197_6");
CAV197_5 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV197_5");
CAV197_4 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV197_4");
CAV197_3 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV197_3");
CAV197_2 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV197_2");
CAV197_1 = LineElement(class="Rfcavity (Unsupported)",  name = "CAV197_1");
OS197 = Drift(L = 0.120143023024214, name = "OS197");
SEPTUM_IR4 = LineElement(class="Pipe", L = 4.0, name = "SEPTUM_IR4");
OSV4 = Drift(L = 4.9861604, name = "OSV4");
YO4_SV4 = LineElement(class="Marker",  name = "YO4_SV4");
OBSK4IY = Drift(L = 0.0425, name = "OBSK4IY");
YO4_B4 = LineElement(class="Monitor",  name = "YO4_B4");
YO4_TQ4 = Quadrupole(L = 0.75, K1 = -0.015254710791052551, name = "YO4_TQ4");
YO4_QF4 = Quadrupole(L = 1.811949, K1 = 0.08900498923902388, name = "YO4_QF4");
LMP04Y04 = Multipole(L = 0.5, name = "LMP04Y04");
YO4_INT4_1 = Drift(L = 0.302561, name = "YO4_INT4_1");
YO4_INT4_2 = Drift(L = 0.302561, name = "YO4_INT4_2");
YO4_BV5 = LineElement(class="Monitor",  name = "YO4_BV5");
YO4_TQ5 = Quadrupole(L = 0.75, K1 = -0.023393640346928528, name = "YO4_TQ5");
YO4_QD5 = Quadrupole(L = 1.11, K1 = -0.08868853289265344, name = "YO4_QD5");
LMP04Y05 = Multipole(L = 0.5, name = "LMP04Y05");
YO4_INT5_1 = Drift(L = 0.294586752907152, name = "YO4_INT5_1");
YO4_DH5 = SBend(L = 8.69844937519207, g = 0.0041230214050564, name = "YO4_DH5");
YO4_INT5_2 = Drift(L = 0.29445870400698, name = "YO4_INT5_2");
YO4_BH6 = LineElement(class="Monitor",  name = "YO4_BH6");
YO4_TQ6 = Quadrupole(L = 0.75, K1 = 0.017972760586054806, name = "YO4_TQ6");
YO4_QF6 = Quadrupole(L = 1.11, K1 = 0.08868853289265344, name = "YO4_QF6");
LMP04Y06 = Multipole(L = 0.5, name = "LMP04Y06");
YO4_INT6_1 = Drift(L = 0.295148, name = "YO4_INT6_1");
YO4_INT6_2 = Drift(L = 0.307984615363785, name = "YO4_INT6_2");
YO4_DH6 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO4_DH6");
YO4_INT6_3 = Drift(L = 0.307904705333785, name = "YO4_INT6_3");
LMP04Y07 = Multipole(L = 0.5, name = "LMP04Y07");
YO4_QD7 = Quadrupole(L = 0.929744, K1 = -0.08644052617712873, name = "YO4_QD7");
YO4_B7 = LineElement(class="Monitor",  name = "YO4_B7");
YO4_INT7_1 = Drift(L = 0.29519754785, name = "YO4_INT7_1");
YO4_INT7_2 = Drift(L = 0.29519754785, name = "YO4_INT7_2");
YO4_B8 = LineElement(class="Monitor",  name = "YO4_B8");
YO4_QF8 = Quadrupole(L = 1.11, K1 = 0.07677685307119243, name = "YO4_QF8");
LMP04Y08 = Multipole(L = 0.5, name = "LMP04Y08");
YO4_INT8_1 = Drift(L = 0.312825559773772, name = "YO4_INT8_1");
YO4_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH8");
YO4_INT8_2 = Drift(L = 0.312825559773772, name = "YO4_INT8_2");
LMP04Y09 = Multipole(L = 0.5, name = "LMP04Y09");
YO4_QD9 = Quadrupole(L = 1.11, K1 = -0.07707736220023842, name = "YO4_QD9");
YO4_SXD9 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO4_SXD9");
YO4_BV9 = LineElement(class="Monitor",  name = "YO4_BV9");
YO4_INT9_1 = Drift(L = 0.295148, name = "YO4_INT9_1");
YO4_INT9_2 = Drift(L = 0.307856615363788, name = "YO4_INT9_2");
YO4_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO4_DH9");
YO4_INT9_3 = Drift(L = 0.307904705333785, name = "YO4_INT9_3");
LMP04Y10 = Multipole(L = 0.5, name = "LMP04Y10");
YO4_QF10 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO4_QF10");
YO4_SXF10 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO4_SXF10");
YO4_BH10 = LineElement(class="Monitor",  name = "YO4_BH10");
YO4_INT10_1 = Drift(L = 0.312697559773772, name = "YO4_INT10_1");
YO4_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH10");
YO4_INT10_2 = Drift(L = 0.312825559773772, name = "YO4_INT10_2");
YO4_TV11 = LineElement(class="Vkicker", L = 0.5, name = "YO4_TV11");
YO4_QD11 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO4_QD11");
YO4_SXD11 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO4_SXD11");
YO4_BV11 = LineElement(class="Monitor",  name = "YO4_BV11");
YO4_INT11_1 = Drift(L = 0.312697559773772, name = "YO4_INT11_1");
YO4_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH11");
YO4_INT11_2 = Drift(L = 0.312825559773772, name = "YO4_INT11_2");
YO4_TH12 = LineElement(class="Hkicker", L = 0.5, name = "YO4_TH12");
YO4_QF12 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO4_QF12");
YO4_SXF12 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO4_SXF12");
YO4_BH12 = LineElement(class="Monitor",  name = "YO4_BH12");
YO4_INT12_1 = Drift(L = 0.312697559773772, name = "YO4_INT12_1");
YO4_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH12");
YO4_INT12_2 = Drift(L = 0.312825559773772, name = "YO4_INT12_2");
YO4_TV13 = LineElement(class="Vkicker", L = 0.5, name = "YO4_TV13");
YO4_QD13 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO4_QD13");
YO4_SXD13 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO4_SXD13");
YO4_BV13 = LineElement(class="Monitor",  name = "YO4_BV13");
YO4_INT13_1 = Drift(L = 0.312697559773772, name = "YO4_INT13_1");
YO4_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH13");
YO4_INT13_2 = Drift(L = 0.312825559773772, name = "YO4_INT13_2");
YO4_TH14 = LineElement(class="Hkicker", L = 0.5, name = "YO4_TH14");
YO4_QF14 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO4_QF14");
YO4_SXF14 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO4_SXF14");
YO4_BH14 = LineElement(class="Monitor",  name = "YO4_BH14");
YO4_INT14_1 = Drift(L = 0.312697559773772, name = "YO4_INT14_1");
YO4_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH14");
YO4_INT14_2 = Drift(L = 0.312825559773772, name = "YO4_INT14_2");
YO4_TV15 = LineElement(class="Vkicker", L = 0.5, name = "YO4_TV15");
YO4_QD15 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO4_QD15");
YO4_SXD15 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO4_SXD15");
YO4_BV15 = LineElement(class="Monitor",  name = "YO4_BV15");
YO4_INT15_1 = Drift(L = 0.312697559773772, name = "YO4_INT15_1");
YO4_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH15");
YO4_INT15_2 = Drift(L = 0.312825559773772, name = "YO4_INT15_2");
YO4_TH16 = LineElement(class="Hkicker", L = 0.5, name = "YO4_TH16");
YO4_QF16 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO4_QF16");
YO4_SXF16 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO4_SXF16");
YO4_BH16 = LineElement(class="Monitor",  name = "YO4_BH16");
YO4_INT16_1 = Drift(L = 0.312697559773772, name = "YO4_INT16_1");
YO4_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH16");
YO4_INT16_2 = Drift(L = 0.312825559773772, name = "YO4_INT16_2");
YO4_TV17 = LineElement(class="Vkicker", L = 0.5, name = "YO4_TV17");
YO4_QD17 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO4_QD17");
YO4_SXD17 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO4_SXD17");
YO4_BV17 = LineElement(class="Monitor",  name = "YO4_BV17");
YO4_INT17_1 = Drift(L = 0.312697559773772, name = "YO4_INT17_1");
YO4_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH17");
YO4_INT17_2 = Drift(L = 0.312825559773772, name = "YO4_INT17_2");
YO4_TH18 = LineElement(class="Hkicker", L = 0.5, name = "YO4_TH18");
YO4_QF18 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO4_QF18");
YO4_SXF18 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO4_SXF18");
YO4_BH18 = LineElement(class="Monitor",  name = "YO4_BH18");
YO4_INT18_1 = Drift(L = 0.312697559773772, name = "YO4_INT18_1");
YO4_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH18");
YO4_INT18_2 = Drift(L = 0.312825559773772, name = "YO4_INT18_2");
YO4_TV19 = LineElement(class="Vkicker", L = 0.5, name = "YO4_TV19");
YO4_QD19 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO4_QD19");
YO4_SXD19 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO4_SXD19");
YO4_BV19 = LineElement(class="Monitor",  name = "YO4_BV19");
YO4_INT19_1 = Drift(L = 0.312697559773772, name = "YO4_INT19_1");
YO4_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH19");
YO4_INT19_2 = Drift(L = 0.312825559773772, name = "YO4_INT19_2");
YO4_TH20 = LineElement(class="Hkicker", L = 0.5, name = "YO4_TH20");
YO4_QF20 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO4_QF20");
YO4_SXF20 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO4_SXF20");
YO4_BH20 = LineElement(class="Monitor",  name = "YO4_BH20");
YO4_INT20_1 = Drift(L = 0.312697559773772, name = "YO4_INT20_1");
YO4_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO4_DH20");
YO4_INT20_2 = Drift(L = 0.312825559773772, name = "YO4_INT20_2");
YO5_TV21 = LineElement(class="Vkicker", L = 0.5, name = "YO5_TV21");
YO5_QD21 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO5_QD21");
YO5_SXD21 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO5_SXD21");
YO5_BV21 = LineElement(class="Monitor",  name = "YO5_BV21");
YO5_INT20_2 = Drift(L = 0.312697559773772, name = "YO5_INT20_2");
YO5_DH20 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH20");
YO5_INT20_1 = Drift(L = 0.312825559773772, name = "YO5_INT20_1");
YO5_TH20 = LineElement(class="Hkicker", L = 0.5, name = "YO5_TH20");
YO5_QF20 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO5_QF20");
YO5_SXF20 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO5_SXF20");
YO5_BH20 = LineElement(class="Monitor",  name = "YO5_BH20");
YO5_INT19_2 = Drift(L = 0.312697559773772, name = "YO5_INT19_2");
YO5_DH19 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH19");
YO5_INT19_1 = Drift(L = 0.312825559773772, name = "YO5_INT19_1");
YO5_TV19 = LineElement(class="Vkicker", L = 0.5, name = "YO5_TV19");
YO5_QD19 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO5_QD19");
YO5_SXD19 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO5_SXD19");
YO5_BV19 = LineElement(class="Monitor",  name = "YO5_BV19");
YO5_INT18_2 = Drift(L = 0.312697559773772, name = "YO5_INT18_2");
YO5_DH18 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH18");
YO5_INT18_1 = Drift(L = 0.312825559773772, name = "YO5_INT18_1");
LMP05Y18 = Multipole(L = 0.5, name = "LMP05Y18");
YO5_QF18 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO5_QF18");
YO5_SXF18 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO5_SXF18");
YO5_BH18 = LineElement(class="Monitor",  name = "YO5_BH18");
YO5_INT17_2 = Drift(L = 0.312697559773772, name = "YO5_INT17_2");
YO5_DH17 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH17");
YO5_INT17_1 = Drift(L = 0.312825559773772, name = "YO5_INT17_1");
LMP05Y17 = Multipole(L = 0.5, name = "LMP05Y17");
YO5_QD17 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO5_QD17");
YO5_SXD17 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO5_SXD17");
YO5_BV17 = LineElement(class="Monitor",  name = "YO5_BV17");
YO5_INT16_2 = Drift(L = 0.312697559773772, name = "YO5_INT16_2");
YO5_DH16 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH16");
YO5_INT16_1 = Drift(L = 0.312825559773772, name = "YO5_INT16_1");
LMP05Y16 = Multipole(L = 0.5, name = "LMP05Y16");
YO5_QF16 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO5_QF16");
YO5_SXF16 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO5_SXF16");
YO5_BH16 = LineElement(class="Monitor",  name = "YO5_BH16");
YO5_INT15_2 = Drift(L = 0.312697559773772, name = "YO5_INT15_2");
YO5_DH15 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH15");
YO5_INT15_1 = Drift(L = 0.312825559773772, name = "YO5_INT15_1");
LMP05Y15 = Multipole(L = 0.5, name = "LMP05Y15");
YO5_QD15 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO5_QD15");
YO5_SXD15 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO5_SXD15");
YO5_BV15 = LineElement(class="Monitor",  name = "YO5_BV15");
YO5_INT14_2 = Drift(L = 0.312697559773772, name = "YO5_INT14_2");
YO5_DH14 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH14");
YO5_INT14_1 = Drift(L = 0.312825559773772, name = "YO5_INT14_1");
LMP05Y14 = Multipole(L = 0.5, name = "LMP05Y14");
YO5_QF14 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO5_QF14");
YO5_SXF14 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO5_SXF14");
YO5_BH14 = LineElement(class="Monitor",  name = "YO5_BH14");
YO5_INT13_2 = Drift(L = 0.312697559773772, name = "YO5_INT13_2");
YO5_DH13 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH13");
YO5_INT13_1 = Drift(L = 0.312825559773772, name = "YO5_INT13_1");
LMP05Y13 = Multipole(L = 0.5, name = "LMP05Y13");
YO5_QD13 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO5_QD13");
YO5_SXD13 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO5_SXD13");
YO5_BV13 = LineElement(class="Monitor",  name = "YO5_BV13");
YO5_INT12_2 = Drift(L = 0.312697559773772, name = "YO5_INT12_2");
YO5_DH12 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH12");
YO5_INT12_1 = Drift(L = 0.312825559773772, name = "YO5_INT12_1");
LMP05Y12 = Multipole(L = 0.5, name = "LMP05Y12");
YO5_QF12 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO5_QF12");
YO5_SXF12 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO5_SXF12");
YO5_BH12 = LineElement(class="Monitor",  name = "YO5_BH12");
YO5_INT11_2 = Drift(L = 0.312697559773772, name = "YO5_INT11_2");
YO5_DH11 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH11");
YO5_INT11_1 = Drift(L = 0.312825559773772, name = "YO5_INT11_1");
LMP05Y11 = Multipole(L = 0.5, name = "LMP05Y11");
YO5_QD11 = Quadrupole(L = 1.11, K1 = -0.08020471531760652, name = "YO5_QD11");
YO5_SXD11 = Sextupole(K2 = -0.4818602185171464, L = 0.75, name = "YO5_SXD11");
YO5_BV11 = LineElement(class="Monitor",  name = "YO5_BV11");
YO5_INT10_2 = Drift(L = 0.312697559773772, name = "YO5_INT10_2");
YO5_DH10 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH10");
YO5_INT10_1 = Drift(L = 0.312825559773772, name = "YO5_INT10_1");
LMP05Y10 = Multipole(L = 0.5, name = "LMP05Y10");
YO5_QF10 = Quadrupole(L = 1.11, K1 = 0.08051789353290868, name = "YO5_QF10");
YO5_SXF10 = Sextupole(K2 = 0.28236691924274687, L = 0.75, name = "YO5_SXF10");
YO5_BH10 = LineElement(class="Monitor",  name = "YO5_BH10");
OBELSKI = Drift(L = 0.0425, name = "OBELSKI");
YO5_SV9_2 = LineElement(class="Marker",  name = "YO5_SV9_2");
OBELLKI = Drift(L = 0.447974, name = "OBELLKI");
YO5_DU9W = Drift(L = 3.10091565822204, name = "YO5_DU9W");
H5_TQ11 = Quadrupole(L = 0.75, name = "H5_TQ11");
H5_Q11 = Quadrupole(L = 1.11, K1 = -0.0017607891846558668, name = "H5_Q11");
H5_COR11 = Multipole(L = 0.5, name = "H5_COR11");
YO5_SV9_1 = LineElement(class="Marker",  name = "YO5_SV9_1");
ODSWL = Drift(L = 0.998116795902, name = "ODSWL");
YO5_DH9 = SBend(L = 2.94942686017, g = 0.0041230214050564, name = "YO5_DH9");
YO5_INT9_6 = Drift(L = 0.307776705333785, name = "YO5_INT9_6");
OBWK = Drift(L = 0.637679192, name = "OBWK");
YO5_BV9 = LineElement(class="Monitor",  name = "YO5_BV9");
OQBWM = Drift(L = 0.2960016, name = "OQBWM");
YO5_QD9 = Quadrupole(L = 1.11, K1 = -0.05076647098297764, name = "YO5_QD9");
LMP05Y09 = Multipole(L = 0.5, name = "LMP05Y09");
YO5_INT8_2 = Drift(L = 0.312825559773772, name = "YO5_INT8_2");
YO5_DH8 = SBend(L = 9.440656, g = 0.0041230214050564, name = "YO5_DH8");
YO5_INT8_1 = Drift(L = 0.312825559773772, name = "YO5_INT8_1");
LMP05Y08 = Multipole(L = 0.5, name = "LMP05Y08");
YO5_QF8 = Quadrupole(L = 1.11, K1 = -0.012525288077042668, name = "YO5_QF8");
YO5_B8 = LineElement(class="Monitor",  name = "YO5_B8");
YO5_INT7_2 = Drift(L = 0.29519754785, name = "YO5_INT7_2");
YO5_SNK_HLX4 = LineElement(class="Pipe", L = 2.4, name = "YO5_SNK_HLX4");
YO5_SNK_HLX3 = LineElement(class="Pipe", L = 2.4, name = "YO5_SNK_HLX3");
YO5_BSNK = LineElement(class="Snake6",  name = "YO5_BSNK");
YO5_SNK_HLX2 = LineElement(class="Pipe", L = 2.4, name = "YO5_SNK_HLX2");
YO5_SNK_HLX1 = LineElement(class="Pipe", L = 2.4, name = "YO5_SNK_HLX1");
YO5_INT7_1 = Drift(L = 0.29519754785, name = "YO5_INT7_1");
YO5_B7 = LineElement(class="Monitor",  name = "YO5_B7");
YO5_QD7 = Quadrupole(L = 0.929744, K1 = 0.06313021085203148, name = "YO5_QD7");
LMP05Y07 = Multipole(L = 0.5, name = "LMP05Y07");
YO5_INTROT = Drift(L = 0.29519754785, name = "YO5_INTROT");
YO5_ROT_HLX4 = LineElement(class="Pipe", L = 2.4, name = "YO5_ROT_HLX4");
YO5_ROT_HLX3 = LineElement(class="Pipe", L = 2.4, name = "YO5_ROT_HLX3");
YO5_BROT = LineElement(class="Monitor",  name = "YO5_BROT");
YO5_ROT_HLX2 = LineElement(class="Pipe", L = 2.4, name = "YO5_ROT_HLX2");
YO5_ROT_HLX1 = LineElement(class="Pipe", L = 2.4, name = "YO5_ROT_HLX1");
LMP05B08 = Multipole(L = 0.5, name = "LMP05B08");
BI5_QD8 = Quadrupole(L = 1.11, K1 = -0.07911679634263588, name = "BI5_QD8");
BI5_B8 = LineElement(class="Monitor",  name = "BI5_B8");
OINT = Drift(L = 0.3, name = "OINT");
H5_DH4 = SBend(L = 6.91599988052792, g = 0.0041230214050564, name = "H5_DH4");
LMP05Y04 = Multipole(L = 0.5, name = "LMP05Y04");
YO5_QF4 = Quadrupole(L = 1.811949, K1 = 0.09581349202058179, name = "YO5_QF4");
YO5_TQ4 = Quadrupole(L = 0.75, K1 = 0.05193340428765354, name = "YO5_TQ4");
YO5_B4 = LineElement(class="Monitor",  name = "YO5_B4");
YO5_DH5 = SBend(L = 8.69844937519207, g = 0.0041230214050564, name = "YO5_DH5");
LMP03B08 = Multipole(L = 0.5, name = "LMP03B08");
BO3_QF8 = Quadrupole(L = 1.11, K1 = -0.09705706979429374, name = "BO3_QF8");
BO3_B8 = LineElement(class="Monitor",  name = "BO3_B8");
D9_PF = Drift(L = 1.55089650046537, name = "D9_PF");
LMP06Y02 = Multipole(L = 0.5, name = "LMP06Y02");
YI6_QD2 = Quadrupole(L = 3.391633, K1 = 0.032339907628137286, name = "YI6_QD2");
O_CRAB_IP6F = LineElement(class="Pipe", L = 15.06, name = "O_CRAB_IP6F");
B2PF = SBend(e2 = 0.00838724716310613, e1 = 0.00838724716310613, L = 3.07743504983507, g = 0.00545080369027164, name = "B2PF");
OW2C = Drift(L = 1.0, name = "OW2C");
H5_TV3 = LineElement(class="Vkicker", L = 0.25, name = "H5_TV3");
H5_QS3 = Quadrupole(tilt1 = 0.785398163397448, L = 0.25, name = "H5_QS3");
Q3PF = Quadrupole(L = 0.75, K1 = 0.0105398184991687, name = "Q3PF");
O_FFDET_WQ = Drift(L = 0.3, name = "O_FFDET_WQ");
O06W_FFDET!1 = Drift(L = 9.59619108414389, name = "O06W_FFDET!1");
O_ROMAN_POT_IP6_2 = LineElement(class="Instrument", L = 0.4, name = "O_ROMAN_POT_IP6_2");
O06W_FFDET!2 = Drift(L = 1.60200901584312, name = "O06W_FFDET!2");
O_ROMAN_POT_IP6_1 = LineElement(class="Instrument", L = 0.4, name = "O_ROMAN_POT_IP6_1");
O06W_FFDET!3 = Drift(L = 1.10150676188277, name = "O06W_FFDET!3");
O_OFF_MOM_IP6_2 = LineElement(class="Instrument", L = 0.4, name = "O_OFF_MOM_IP6_2");
O06W_FFDET!4 = Drift(L = 1.60200901584312, name = "O06W_FFDET!4");
O_OFF_MOM_IP6_1 = LineElement(class="Instrument", L = 0.4, name = "O_OFF_MOM_IP6_1");
O06W_FFDET!5 = Drift(L = 0.230920926540421, name = "O06W_FFDET!5");
PBR_B1APF = LineElement(class="Patch (Unsupported)",  name = "PBR_B1APF");
PBT_B1APF = LineElement(class="Patch (Unsupported)",  name = "PBT_B1APF");
B1APF = SBend(L = 1.5, name = "B1APF");
PET_B1APF = LineElement(class="Patch (Unsupported)",  name = "PET_B1APF");
PER_B1APF = LineElement(class="Patch (Unsupported)",  name = "PER_B1APF");
O06W_B1_B1A = Drift(L = 0.50168508374684, name = "O06W_B1_B1A");
PBR_B1PF = LineElement(class="Patch (Unsupported)",  name = "PBR_B1PF");
PBT_B1PF = LineElement(class="Patch (Unsupported)",  name = "PBT_B1PF");
B1PF = SBend(L = 3.0, name = "B1PF");
PET_B1PF = LineElement(class="Patch (Unsupported)",  name = "PET_B1PF");
PER_B1PF = LineElement(class="Patch (Unsupported)",  name = "PER_B1PF");
O06W_Q2_B1 = Drift(L = 0.501544459683321, name = "O06W_Q2_B1");
PBR_Q2PF = LineElement(class="Patch (Unsupported)",  name = "PBR_Q2PF");
PBT_Q2PF = LineElement(class="Patch (Unsupported)",  name = "PBT_Q2PF");
Q2PF = Quadrupole(L = 3.8, K1 = 0.0376078408315903, name = "Q2PF");
PET_Q2PF = LineElement(class="Patch (Unsupported)",  name = "PET_Q2PF");
PER_Q2PF = LineElement(class="Patch (Unsupported)",  name = "PER_Q2PF");
O06W_Q1B_Q2 = Drift(L = 0.40102132474581, name = "O06W_Q1B_Q2");
PBR_Q1BPF = LineElement(class="Patch (Unsupported)",  name = "PBR_Q1BPF");
PBT_Q1BPF = LineElement(class="Patch (Unsupported)",  name = "PBT_Q1BPF");
Q1BPF = Quadrupole(L = 1.61, K1 = -0.0524400252820484, name = "Q1BPF");
PET_Q1BPF = LineElement(class="Patch (Unsupported)",  name = "PET_Q1BPF");
PER_Q1BPF = LineElement(class="Patch (Unsupported)",  name = "PER_Q1BPF");
O06W_Q1A_Q1B = Drift(L = 0.400595774121126, name = "O06W_Q1A_Q1B");
PBR_Q1APF = LineElement(class="Patch (Unsupported)",  name = "PBR_Q1APF");
PBT_Q1APF = LineElement(class="Patch (Unsupported)",  name = "PBT_Q1APF");
Q1APF = Quadrupole(L = 1.46, K1 = -0.0905816130794057, name = "Q1APF");
PET_Q1APF = LineElement(class="Patch (Unsupported)",  name = "PET_Q1APF");
PER_Q1APF = LineElement(class="Patch (Unsupported)",  name = "PER_Q1APF");
O06W_B0A_Q1A = Drift(L = 0.400625972111453, name = "O06W_B0A_Q1A");
PBR_B0APF = LineElement(class="Patch (Unsupported)",  name = "PBR_B0APF");
PBT_B0APF = LineElement(class="Patch (Unsupported)",  name = "PBT_B0APF");
B0APF = SBend(L = 0.6, name = "B0APF");
PET_B0APF = LineElement(class="Patch (Unsupported)",  name = "PET_B0APF");
PER_B0APF = LineElement(class="Patch (Unsupported)",  name = "PER_B0APF");
O06W_B0_B0A = Drift(L = 0.90135549892096, name = "O06W_B0_B0A");
PB_B0PF = LineElement(class="Patch (Unsupported)",  name = "PB_B0PF");
B0PF = SBend(L = 1.2, K1 = -0.008854545281644113, name = "B0PF");
PE_B0PF = LineElement(class="Patch (Unsupported)",  name = "PE_B0PF");
D1_PF = Drift(L = 3.8024379395738, name = "D1_PF");
PB_SOL_F = LineElement(class="Patch (Unsupported)",  name = "PB_SOL_F");
STAR_DETECT_F = Solenoid(L = 2.0, name = "STAR_DETECT_F");
PE_SOL_F = LineElement(class="Patch (Unsupported)",  name = "PE_SOL_F");
IP6W = LineElement(class="Marker",  name = "IP6W");

#-------------------------------------------------------
# Overlays, groups, rampers, and superimpose


#-------------------------------------------------------
# Lattice lines


HSR_HI_N = Beamline([IP6D, PB_SOL_R, STAR_DETECT_R, PE_SOL_R, O06D_SOL_Q1A, Q1APR, 
  O06D_Q1A_Q1B, Q1BPR, O06D_Q1B_Q2, Q2PR, O06D_Q2_Q3, H6_Q3, OH6_WQ_SPC, H6_QS3, H6_TV3, 
  O_CRAB_MAG, O_CRAB_IP6R, OFLQ2A, H6_Q04, OCQ2, H6_COR04, OCFL2, O6_45, OCFL, H6_COR05, 
  OCQ, H6_Q05, OQS, H6_TQ05, OSB, OBFL, OBELABI, OD5OFL, H6_DH01, OSB4C, H6_TQ06, OQS4, 
  H6_Q06, OCQ4, H6_COR06, ODUM1FL, OSNKE, H6_ROT_HLX4, OSNKM, H6_ROT_HLX3, OSNKMM, H6_BROT, 
  H6_ROT_HLX2, H6_ROT_HLX1, OQBMS, H6_Q07, H6_COR07, ODFL, H6_DH02, H6_Q08, H6_COR08, 
  H6_DH03, H6_Q09, H6_COR09, O6_910, H6_Q10, H6_COR10, H6_DH04, YI6_BV10, YI6_SXD10, 
  YI6_QD10, LMP06Y10, YI6_INT10_1, YI6_DH10, YI6_INT10_2, YI6_BH11, YI6_SXF11, YI6_QF11, 
  YI6_TH11, YI6_INT11_1, YI6_DH11, YI6_INT11_2, YI6_BV12, YI6_SXD12, YI6_QD12, YI6_TV12, 
  YI6_INT12_1, YI6_DH12, YI6_INT12_2, YI6_BH13, YI6_SXF13, YI6_QF13, YI6_TH13, YI6_INT13_1, 
  YI6_DH13, YI6_INT13_2, YI6_BV14, YI6_SXD14, YI6_QD14, YI6_TV14, YI6_INT14_1, YI6_DH14, 
  YI6_INT14_2, YI6_BH15, YI6_SXF15, YI6_QF15, YI6_TH15, YI6_INT15_1, YI6_DH15, YI6_INT15_2, 
  YI6_BV16, YI6_SXD16, YI6_QD16, YI6_TV16, YI6_INT16_1, YI6_DH16, YI6_INT16_2, YI6_BH17, 
  YI6_SXF17, YI6_QF17, YI6_TH17, YI6_INT17_1, YI6_DH17, YI6_INT17_2, YI6_BV18, YI6_SXD18, 
  YI6_QD18, YI6_TV18, YI6_INT18_1, YI6_DH18, YI6_INT18_2, YI6_BH19, YI6_SXF19, YI6_QF19, 
  YI6_TH19, YI6_INT19_1, YI6_DH19, YI6_INT19_2, YI6_BV20, YI6_SXD20, YI6_QD20, YI6_TV20, 
  YI6_INT20_1, YI6_DH20, YI6_INT20_2, YI7_BH21, YI7_SXF21, YI7_QF21, YI7_TH21, YI7_INT20_2, 
  YI7_DH20, YI7_INT20_1, YI7_BV20, YI7_SXD20, YI7_QD20, YI7_TV20, YI7_INT19_2, YI7_DH19, 
  YI7_INT19_1, YI7_BH19, YI7_SXF19, YI7_QF19, YI7_TH19, YI7_INT18_2, YI7_DH18, YI7_INT18_1, 
  YI7_BV18, YI7_SXD18, YI7_QD18, LMP07Y18, YI7_INT17_2, YI7_DH17, YI7_INT17_1, YI7_BH17, 
  YI7_SXF17, YI7_QF17, LMP07Y17, YI7_INT16_2, YI7_DH16, YI7_INT16_1, YI7_BV16, YI7_SXD16, 
  YI7_QD16, LMP07Y16, YI7_INT15_2, YI7_DH15, YI7_INT15_1, YI7_BH15, YI7_SXF15, YI7_QF15, 
  LMP07Y15, YI7_INT14_2, YI7_DH14, YI7_INT14_1, YI7_BV14, YI7_SXD14, YI7_QD14, LMP07Y14, 
  YI7_INT13_2, YI7_DH13, YI7_INT13_1, YI7_BH13, YI7_SXF13, YI7_QF13, LMP07Y13, YI7_INT12_2, 
  YI7_DH12, YI7_INT12_1, YI7_BV12, YI7_SXD12, YI7_QD12, LMP07Y12, YI7_INT11_2, YI7_DH11, 
  YI7_INT11_1, YI7_BH11, YI7_SXF11, YI7_QF11, LMP07Y11, YI7_INT10_2, YI7_DH10, YI7_INT10_1, 
  YI7_BV10, YI7_SXD10, YI7_QD10, LMP07Y10, YI7_INT9_3, ODSFL, YI7_DH9, YI7_INT9_2, ODUM2FL, 
  O9DUMMY, YI7_INT9_1, YI7_BH9, YI7_SXF9, YI7_QF9, LMP07Y09, YI7_INT8_2, YI7_DH8, 
  YI7_INT8_1, LMP07Y08, YI7_QD8, YI7_B8, YI7_INT7_2, YI7_SNK_HLX4, YI7_SNK_HLX3, YI7_BSNK, 
  YI7_SNK_HLX2, YI7_SNK_HLX1, YI7_INT7_1, YI7_B7, OQBMS7, YI7_QF7, OCQ7, LMP07Y07, 
  YI7_INT6_3, YI7_DH6, YI7_INT6_2, O6DUMMY, YI7_INT6_1, LMP07Y06, YI7_QD6, YI7_TQ6, 
  YI7_BV6, YI7_INT5_2, OD5IFL, YI7_DH5, YI7_INT5_1, LMP07Y05, YI7_QF5, YI7_TQ5, YI7_BH5, 
  YI7_INT4_2, O4DUMMY, YI7_INT4_1, LMP07Y04, YI7_QD4, YI7_TQ4, YI7_B4, YI7_INT3, 
  YI7_HLX3_4, YI7_HLX3_3, YI7_B3_1, YI7_HLX3_2, YI7_HLX3_1, OROTCWT, OBSK7IY, YI7_SV3_2, 
  O3Y7C0, YI7_CH3_2, O3Y7C1, YI7_CV3, O3Y7C2, YI7_CH3_1, O3Y7C3, YI7_C3, O3Y7C4, YI7_KFBH3, 
  O3Y7C5, YI7_SV3_1, OBSK7LY, OBFL3, YI7_B3, OBC3, LMP07Y3A, OCQ3A, YI7_QF3, OCQ3X, 
  LMP07Y3X, OCFL3, YI7_INT2, YI7_QD2, LMP07Y02, YI7_INT1, OFLQ1A, YI7_QF1, OBQ1, YI7_B1, 
  OFLQ1X, OC2W_WD, OGVFL, VALVE_WD, OGVWD, DWREV, OWW2, O08, DWFWD, YO8_B1, YO8_QD1, 
  YO8_INT1, LMP08Y02, YO8_QF2, YO8_INT2, LMP08Y3X, YO8_QD3, LMP08Y3A, YO8_B3, OBSK8LY, 
  YO8_SV3_1, O3Y8C0, YO8_KFBH3, O3Y8C1, OMSKHFL, YO8_MSKH3, O3Y8C2, YO8_SV3_2, OBSK8IY, 
  YO8_HLX3_1, YO8_HLX3_2, YO8_B3_1, YO8_HLX3_3, YO8_HLX3_4, YO8_INT3, YO8_B4, YO8_TQ4, 
  YO8_QF4, LMP08Y04, YO8_INT4_1, YO8_INT4_2, YO8_BV5, YO8_TQ5, YO8_QD5, LMP08Y05, 
  YO8_INT5_1, YO8_DH5, YO8_INT5_2, YO8_BH6, YO8_TQ6, YO8_QF6, LMP08Y06, YO8_INT6_1, 
  YO8_INT6_2, YO8_DH6, YO8_INT6_3, LMP08Y07, YO8_QD7, YO8_B7, YO8_INT7_1, O7DUMMY, 
  YO8_INT7_2, YO8_B8, YO8_QF8, LMP08Y08, YO8_INT8_1, YO8_DH8, YO8_INT8_2, LMP08Y09, 
  YO8_QD9, YO8_SXD9, YO8_BV9, YO8_INT9_1, YO8_INT9_2, YO8_DH9, YO8_INT9_3, LMP08Y10, 
  YO8_QF10, YO8_SXF10, YO8_BH10, YO8_INT10_1, YO8_DH10, YO8_INT10_2, YO8_TV11, YO8_QD11, 
  YO8_SXD11, YO8_BV11, YO8_INT11_1, YO8_DH11, YO8_INT11_2, YO8_TH12, YO8_QF12, YO8_SXF12, 
  YO8_BH12, YO8_INT12_1, YO8_DH12, YO8_INT12_2, YO8_TV13, YO8_QD13, YO8_SXD13, YO8_BV13, 
  YO8_INT13_1, YO8_DH13, YO8_INT13_2, YO8_TH14, YO8_QF14, YO8_SXF14, YO8_BH14, YO8_INT14_1, 
  YO8_DH14, YO8_INT14_2, YO8_TV15, YO8_QD15, YO8_SXD15, YO8_BV15, YO8_INT15_1, YO8_DH15, 
  YO8_INT15_2, YO8_TH16, YO8_QF16, YO8_SXF16, YO8_BH16, YO8_INT16_1, YO8_DH16, YO8_INT16_2, 
  YO8_TV17, YO8_QD17, YO8_SXD17, YO8_BV17, YO8_INT17_1, YO8_DH17, YO8_INT17_2, YO8_TH18, 
  YO8_QF18, YO8_SXF18, YO8_BH18, YO8_INT18_1, YO8_DH18, YO8_INT18_2, YO8_TV19, YO8_QD19, 
  YO8_SXD19, YO8_BV19, YO8_INT19_1, YO8_DH19, YO8_INT19_2, YO8_TH20, YO8_QF20, YO8_SXF20, 
  YO8_BH20, YO8_INT20_1, YO8_DH20, YO8_INT20_2, YO9_TV21, YO9_QD21, YO9_SXD21, YO9_BV21, 
  YO9_INT20_2, YO9_DH20, YO9_INT20_1, YO9_TH20, YO9_QF20, YO9_SXF20, YO9_BH20, YO9_INT19_2, 
  YO9_DH19, YO9_INT19_1, YO9_TV19, YO9_QD19, YO9_SXD19, YO9_BV19, YO9_INT18_2, YO9_DH18, 
  YO9_INT18_1, LMP09Y18, YO9_QF18, YO9_SXF18, YO9_BH18, YO9_INT17_2, YO9_DH17, YO9_INT17_1, 
  LMP09Y17, YO9_QD17, YO9_SXD17, YO9_BV17, YO9_INT16_2, YO9_DH16, YO9_INT16_1, LMP09Y16, 
  YO9_QF16, YO9_SXF16, YO9_BH16, YO9_INT15_2, YO9_DH15, YO9_INT15_1, LMP09Y15, YO9_QD15, 
  YO9_SXD15, YO9_BV15, YO9_INT14_2, YO9_DH14, YO9_INT14_1, LMP09Y14, YO9_QF14, YO9_SXF14, 
  YO9_BH14, YO9_INT13_2, YO9_DH13, YO9_INT13_1, LMP09Y13, YO9_QD13, YO9_SXD13, YO9_BV13, 
  YO9_INT12_2, YO9_DH12, YO9_INT12_1, LMP09Y12, YO9_QF12, YO9_SXF12, YO9_BH12, YO9_INT11_2, 
  YO9_DH11, YO9_INT11_1, LMP09Y11, YO9_QD11, YO9_SXD11, YO9_BV11, YO9_INT10_2, YO9_DH10, 
  YO9_INT10_1, LMP09Y10, YO9_QF10, YO9_SXF10, YO9_BH10, YO9_INT9_3, YO9_DH9, YO9_INT9_2, 
  YO9_INT9_1, YO9_BV9, OQB, YO9_QD9, LMP09Y09, YO9_INT8_2, YO9_DH8, YO9_INT8_1, LMP09Y08, 
  YO9_QF8, YO9_B8, YO9_INT7_2, YO9_HLX7_4, YO9_HLX7_3, YO9_B7_1, YO9_HLX7_2, YO9_HLX7_1, 
  YO9_INT7_1, YO9_B7, YO9_QD7, LMP09Y07, YO9_INT6_3, YO9_DH6, YO9_INT6_2, YO9_INT6_1, 
  LMP09Y06, YO9_QF6, YO9_TQ6, YO9_BH6, YO9_INT5_2, YO9_DH5, YO9_INT5_1, LMP09Y05, YO9_QD5, 
  YO9_TQ5, YO9_BV5, YO9_INT4_2, YO9_INT4_1, LMP09Y04, YO9_QF4, YO9_TQ4, OSB4, YO9_B4, 
  OBFL4, OBSK9IY, YO9_SV4, O3Y9C0, YO9_DMP3_2, YO9_DMP3_1, O3Y9C1, YO9_SV3_2, O3Y9C2, 
  OBABFLA, YO9_B3_1, OBABFLX, O3Y9C3, YO9_KFBH3, O3Y9C4, OEKA, YO9_KA3_5, OSKA, YO9_KA3_4, 
  YO9_KA3_3, YO9_KA3_2, YO9_KA3_1, O3Y9C5, YO9_SV3_1, OBSK9LY, YO9_B3, LMP09Y3A, YO9_QD3, 
  LMP09Y3X, YO9_INT2, YO9_QF2, LMP09Y02, YO9_INT1, YO9_QD1, YO9_B1, OCAVTRP, H10_CAV591_1, 
  OBEL11, H10_CAV591_2, H10_CAV591_3, YI10_B1, YI10_QF1, YI10_INT1, LMP10Y02, YI10_QD2, 
  YI10_INT2, LMP10Y3X, YI10_QF3, LMP10Y3A, YI10_B3, OBSK10LY, YI10_SV3, O3Y10C0, 
  YI10_KFBH3, O3Y10C1, YI10_SV4, OBSK10IY, YI10_B4, YI10_TQ4, YI10_QD4, LMP10Y04, 
  YI10_INT4_1, YI10_INT4_2, YI10_BH5, YI10_TQ5, YI10_QF5, LMP10Y05, YI10_INT5_1, YI10_DH5, 
  YI10_INT5_2, YI10_BV6, YI10_TQ6, YI10_QD6, LMP10Y06, YI10_INT6_1, YI10_INT6_2, YI10_DH6, 
  YI10_INT6_3, LMP10Y07, YI10_QF7, YI10_B7, YI10_INT7_1, YI10_INT7_2, YI10_B8, YI10_QD8, 
  LMP10Y08, YI10_INT8_1, YI10_DH8, YI10_INT8_2, LMP10Y09, YI10_QF9, YI10_BH9, YI10_INT9_1, 
  YI10_INT9_2, YI10_DH9, YI10_INT9_3, YI10_BV10, YI10_SXD10, YI10_QD10, LMP10Y10, 
  YI10_INT10_1, YI10_DH10, YI10_INT10_2, YI10_BH11, YI10_SXF11, YI10_QF11, YI10_TH11, 
  YI10_INT11_1, YI10_DH11, YI10_INT11_2, YI10_BV12, YI10_SXD12, YI10_QD12, YI10_TV12, 
  YI10_INT12_1, YI10_DH12, YI10_INT12_2, YI10_BH13, YI10_SXF13, YI10_QF13, YI10_TH13, 
  YI10_INT13_1, YI10_DH13, YI10_INT13_2, YI10_BV14, YI10_SXD14, YI10_QD14, YI10_TV14, 
  YI10_INT14_1, YI10_DH14, YI10_INT14_2, YI10_BH15, YI10_SXF15, YI10_QF15, YI10_TH15, 
  YI10_INT15_1, YI10_DH15, YI10_INT15_2, YI10_BV16, YI10_SXD16, YI10_QD16, YI10_TV16, 
  YI10_INT16_1, YI10_DH16, YI10_INT16_2, YI10_BH17, YI10_SXF17, YI10_QF17, YI10_TH17, 
  YI10_INT17_1, YI10_DH17, YI10_INT17_2, YI10_BV18, YI10_SXD18, YI10_QD18, YI10_TV18, 
  YI10_INT18_1, YI10_DH18, YI10_INT18_2, YI10_BH19, YI10_SXF19, YI10_QF19, YI10_TH19, 
  YI10_INT19_1, YI10_DH19, YI10_INT19_2, YI10_BV20, YI10_SXD20, YI10_QD20, YI10_TV20, 
  YI10_INT20_1, YI10_DH20, YI10_INT20_2, YI11_BH21, YI11_SXF21, YI11_QF21, YI11_TH21, 
  YI11_INT20_2, YI11_DH20, YI11_INT20_1, YI11_BV20, YI11_SXD20, YI11_QD20, YI11_TV20, 
  YI11_INT19_2, YI11_DH19, YI11_INT19_1, YI11_BH19, YI11_SXF19, YI11_QF19, YI11_TH19, 
  YI11_INT18_2, YI11_DH18, YI11_INT18_1, YI11_BV18, YI11_SXD18, YI11_QD18, LMP11Y18, 
  YI11_INT17_2, YI11_DH17, YI11_INT17_1, YI11_BH17, YI11_SXF17, YI11_QF17, LMP11Y17, 
  YI11_INT16_2, YI11_DH16, YI11_INT16_1, YI11_BV16, YI11_SXD16, YI11_QD16, LMP11Y16, 
  YI11_INT15_2, YI11_DH15, YI11_INT15_1, YI11_BH15, YI11_SXF15, YI11_QF15, LMP11Y15, 
  YI11_INT14_2, YI11_DH14, YI11_INT14_1, YI11_BV14, YI11_SXD14, YI11_QD14, LMP11Y14, 
  YI11_INT13_2, YI11_DH13, YI11_INT13_1, YI11_BH13, YI11_SXF13, YI11_QF13, LMP11Y13, 
  YI11_INT12_2, YI11_DH12, YI11_INT12_1, YI11_BV12, YI11_SXD12, YI11_QD12, LMP11Y12, 
  YI11_INT11_2, YI11_DH11, YI11_INT11_1, YI11_BH11, YI11_SXF11, YI11_QF11, LMP11Y11, 
  YI11_INT10_2, YI11_DH10, YI11_INT10_1, YI11_BV10, YI11_SXD10, YI11_QD10, LMP11Y10, 
  YI11_INT9_3, YI11_DH9, YI11_INT9_2, YI11_INT9_1, YI11_BH9, YI11_SXF9, YI11_QF9, LMP11Y09, 
  YI11_INT8_2, YI11_DH8, YI11_INT8_1, LMP11Y08, YI11_QD8, YI11_B8, YI11_INT7_2, 
  YI11_SNK_HLX4, YI11_SNK_HLX3, YI11_BSNK, YI11_SNK_HLX2, YI11_SNK_HLX1, YI11_INT7_1, 
  YI11_B7, YI11_QF7, LMP11Y07, YI11_INT6_3, YI11_DH6, YI11_INT6_2, YI11_INT6_1, LMP11Y06, 
  YI11_QD6, YI11_TQ6, YI11_BV6, YI11_INT5_2, YI11_DH5, YI11_INT5_1, LMP11Y05, YI11_QF5, 
  YI11_TQ5, YI11_BH5, YI11_INT4_2, YI11_INT4_1, LMP11Y04, YI11_QD4, YI11_TQ4, YI11_B4, 
  OBSK11IY, YI11_SV4, O3Y11C0, OCKTLFL, YI11_KSCL3_3, O3Y11C1, YI11_KSCL3_2, O3Y11C2, 
  YI11_KSCL3_1, O3Y11C3, YI11_KFBH3, O3Y11C4, YI11_SV3, OBSK11LY, YI11_B3, LMP11Y3A, 
  YI11_QF3, LMP11Y3X, YI11_INT2, YI11_QD2, LMP11Y02, YI11_INT1, YI11_QF1, YI11_B1, OH12, 
  YO12_B1, YO12_QD1, YO12_INT1, LMP12Y02, YO12_QF2, YO12_INT2, LMP12Y3X, YO12_QD3, 
  LMP12Y3A, YO12_B3, OBSK12LY, YO12_SV3_1, O3Y12C0, YO12_KFBH3, O3Y12C1, OCPUFL, 
  YO12_CPUH3, O3Y12C2, OIPMFLL, YO12_IPM3, OIPMFLS, O3Y12C3, OELDFL, YO12_ELD3, O3Y12C4, 
  YO12_CPUV3, O3Y12C5, YO12_SV3_2, O3Y12C6, OPOLFLL, YO12_POL3_1, OPOLFLM, YO12_POL3_2, 
  OPOLFLS, O3Y12C7, YO12_SV4, OBSK12IY, YO12_B4, YO12_TQ4, YO12_QF4, LMP12Y04, YO12_INT4_1, 
  YO12_INT4_2, YO12_BV5, YO12_TQ5, YO12_QD5, LMP12Y05, YO12_INT5_1, YO12_DH5, YO12_INT5_2, 
  YO12_BH6, YO12_TQ6, YO12_QF6, LMP12Y06, YO12_INT6_1, YO12_INT6_2, YO12_DH6, YO12_INT6_3, 
  LMP12Y07, YO12_QD7, YO12_B7, YO12_INT7_1, YO12_INT7_2, YO12_B8, YO12_QF8, LMP12Y08, 
  YO12_INT8_1, YO12_DH8, YO12_INT8_2, LMP12Y09, YO12_QD9, YO12_SXD9, YO12_BV9, YO12_INT9_1, 
  YO12_INT9_2, YO12_DH9, YO12_INT9_3, LMP12Y10, YO12_QF10, YO12_SXF10, YO12_BH10, 
  YO12_INT10_1, YO12_DH10, YO12_INT10_2, YO12_TV11, YO12_QD11, YO12_SXD11, YO12_BV11, 
  YO12_INT11_1, YO12_DH11, YO12_INT11_2, YO12_TH12, YO12_QF12, YO12_SXF12, YO12_BH12, 
  YO12_INT12_1, YO12_DH12, YO12_INT12_2, YO12_TV13, YO12_QD13, YO12_SXD13, YO12_BV13, 
  YO12_INT13_1, YO12_DH13, YO12_INT13_2, YO12_TH14, YO12_QF14, YO12_SXF14, YO12_BH14, 
  YO12_INT14_1, YO12_DH14, YO12_INT14_2, YO12_TV15, YO12_QD15, YO12_SXD15, YO12_BV15, 
  YO12_INT15_1, YO12_DH15, YO12_INT15_2, YO12_TH16, YO12_QF16, YO12_SXF16, YO12_BH16, 
  YO12_INT16_1, YO12_DH16, YO12_INT16_2, YO12_TV17, YO12_QD17, YO12_SXD17, YO12_BV17, 
  YO12_INT17_1, YO12_DH17, YO12_INT17_2, YO12_TH18, YO12_QF18, YO12_SXF18, YO12_BH18, 
  YO12_INT18_1, YO12_DH18, YO12_INT18_2, YO12_TV19, YO12_QD19, YO12_SXD19, YO12_BV19, 
  YO12_INT19_1, YO12_DH19, YO12_INT19_2, YO12_TH20, YO12_QF20, YO12_SXF20, YO12_BH20, 
  YO12_INT20_1, YO12_DH20, YO12_INT20_2, YO1_TV21, YO1_QD21, YO1_SXD21, YO1_BV21, 
  YO1_INT20_2, YO1_DH20, YO1_INT20_1, YO1_TH20, YO1_QF20, YO1_SXF20, YO1_BH20, YO1_INT19_2, 
  YO1_DH19, YO1_INT19_1, YO1_TV19, YO1_QD19, YO1_SXD19, YO1_BV19, YO1_INT18_2, YO1_DH18, 
  YO1_INT18_1, LMP01Y18, YO1_QF18, YO1_SXF18, YO1_BH18, YO1_INT17_2, YO1_DH17, YO1_INT17_1, 
  LMP01Y17, YO1_QD17, YO1_SXD17, YO1_BV17, YO1_INT16_2, YO1_DH16, YO1_INT16_1, LMP01Y16, 
  YO1_QF16, YO1_SXF16, YO1_BH16, YO1_INT15_2, YO1_DH15, YO1_INT15_1, LMP01Y15, YO1_QD15, 
  YO1_SXD15, YO1_BV15, YO1_INT14_2, YO1_DH14, YO1_INT14_1, LMP01Y14, YO1_QF14, YO1_SXF14, 
  YO1_BH14, YO1_INT13_2, YO1_DH13, YO1_INT13_1, LMP01Y13, YO1_QD13, YO1_SXD13, YO1_BV13, 
  YO1_INT12_2, YO1_DH12, YO1_INT12_1, LMP01Y12, YO1_QF12, YO1_SXF12, YO1_BH12, YO1_INT11_2, 
  YO1_DH11, YO1_INT11_1, LMP01Y11, YO1_QD11, YO1_SXD11, YO1_BV11, YO1_INT10_2, YO1_DH10, 
  YO1_INT10_1, LMP01Y10, YO1_QF10, YO1_SXF10, YO1_BH10, YO1_INT9_3, YO1_DH9, YO1_INT9_2, 
  YO1_INT9_1, YO1_BV9, YO1_QD9, LMP01Y09, YO1_INT8_2, YO1_DH8, YO1_INT8_1, LMP01Y08, 
  YO1_QF8, YO1_B8, YO1_INT7_2, YI1_SNK_HLX4, YI1_SNK_HLX3, YI1_BSNK, YI1_SNK_HLX2, 
  YI1_SNK_HLX1, YO1_INT7_1, YO1_B7, YO1_QD7, LMP01Y07, YO1_INT6_3, YO1_DH6, YO1_INT6_2, 
  YO1_INT6_1, LMP01Y06, YO1_QF6, YO1_TQ6, YO1_BH6, YO1_INT5_2, YO1_DH5, YO1_INT5_1, 
  LMP01Y05, YO1_QD5, YO1_TQ5, YO1_BV5, YO1_INT4_2, YO1_INT4_1, LMP01Y04, YO1_QF4, YO1_TQ4, 
  YO1_B4, OBSK1IY, YO1_SV4, O3Y1C0, ODCOMPFL, YO1_COOL_DCOMP1_2, O3Y1C1, YO1_COOL_DCOMP1_1, 
  O3Y1C2, YO1_SV3_2, O3Y1C3, OYAGFL, YO1_COOL_YAG3, O3Y1C4, D2_COOLY, OYAGSLITFL, 
  YO1_COOL_YAG2SLIT, O3Y1C5, OBCOOLFL, YO1_COOL_B8, YO1_COOL_Q2, YO1_COOL_SOL8, O3Y1C6, 
  YO1_COOL_B7, YO1_COOL_SOL7, O3Y1C7, YO1_COOL_B6, YO1_COOL_SOL6, O3Y1C8, YO1_COOL_B5, 
  YO1_COOL_SOL5, O3Y1C9, YO1_COOL_B4, YO1_COOL_SOL4, O3Y1C10, YO1_COOL_B3, YO1_COOL_SOL3, 
  O3Y1C11, YO1_COOL_B2, YO1_COOL_SOL2, YO1_COOL_YAG1, O3Y1C12, YO1_COOL_B1, OSLITFL, 
  YO1_COOL_SLIT, O3Y1C13, YO1_COOL_SOL1, O3Y1C14, YO1_COOL_Q1, O3Y1C15, D1_COOLY, O3Y1C16, 
  OBSK1LY, YO1_SV3_1, OBELSKL, YO1_B3, LMP01Y3A, YO1_QD3, LMP01Y3X, YO1_INT2, YO1_QF2, 
  LMP01Y02, YO1_INT1, YO1_QD1, YO1_B1, O02, YI2_B1, YI2_QF1, YI2_INT1, LMP02Y02, YI2_QD2, 
  YI2_INT2, LMP02Y3X, YI2_QF3, LMP02Y3A, YI2_B3, OBSK2LY, YI2_SV3, O3Y2C0, YI2_KFBH3, 
  O3Y2C1, OMVBFL, YI2_SPU3_1, OMVBFLS, YI2_SPU3_2, O3Y2C2, YI2_IPM3, O3Y2C3, OQMMS, 
  YI2_KQM3, O3Y2C4, OTMKGCK, YI2_DMPTH3_1, YI2_DMPTH3_2, O3Y2C5, YI2_DMPTV3_1, 
  YI2_DMPTV3_2, O3Y2C6, OQMM, YI2_KTUN3_1, YI2_BQM3_1, O3Y2C7, YI2_BHT3, YI2_BQM3_2, 
  YI2_KTUN3_2, O3Y2C8, OBBPMFL, YI2_BB3, OWCMFL, YI2_WCM3, OXFFL, YI2_XF3, OSCAVFL, 
  YI2_SPU3_3, O3Y2C9, YI2_SV4, OBSK2IY, YI2_B4, YI2_TQ4, YI2_QD4, LMP02Y04, YI2_INT4_1, 
  YI2_INT4_2, YI2_BH5, YI2_TQ5, YI2_QF5, LMP02Y05, YI2_INT5_1, YI2_DH5, YI2_INT5_2, 
  YI2_BV6, YI2_TQ6, YI2_QD6, LMP02Y06, YI2_INT6_1, YI2_INT6_2, YI2_DH6, YI2_INT6_3, 
  LMP02Y07, YI2_QF7, YI2_B7, YI2_INT7_1, YI2_INT7_2, YI2_B8, YI2_QD8, LMP02Y08, YI2_INT8_1, 
  YI2_DH8, YI2_INT8_2, LMP02Y09, YI2_QF9, YI2_BH9, YI2_INT9_1, YI2_INT9_2, YI2_DH9, 
  YI2_INT9_3, YI2_BV10, YI2_SXD10, YI2_QD10, LMP02Y10, YI2_INT10_1, YI2_DH10, YI2_INT10_2, 
  YI2_BH11, YI2_SXF11, YI2_QF11, YI2_TH11, YI2_INT11_1, YI2_DH11, YI2_INT11_2, YI2_BV12, 
  YI2_SXD12, YI2_QD12, YI2_TV12, YI2_INT12_1, YI2_DH12, YI2_INT12_2, YI2_BH13, YI2_SXF13, 
  YI2_QF13, YI2_TH13, YI2_INT13_1, YI2_DH13, YI2_INT13_2, YI2_BV14, YI2_SXD14, YI2_QD14, 
  YI2_TV14, YI2_INT14_1, YI2_DH14, YI2_INT14_2, YI2_BH15, YI2_SXF15, YI2_QF15, YI2_TH15, 
  YI2_INT15_1, YI2_DH15, YI2_INT15_2, YI2_BV16, YI2_SXD16, YI2_QD16, YI2_TV16, YI2_INT16_1, 
  YI2_DH16, YI2_INT16_2, YI2_BH17, YI2_SXF17, YI2_QF17, YI2_TH17, YI2_INT17_1, YI2_DH17, 
  YI2_INT17_2, YI2_BV18, YI2_SXD18, YI2_QD18, YI2_TV18, YI2_INT18_1, YI2_DH18, YI2_INT18_2, 
  YI2_BH19, YI2_SXF19, YI2_QF19, YI2_TH19, YI2_INT19_1, YI2_DH19, YI2_INT19_2, YI2_BV20, 
  YI2_SXD20, YI2_QD20, YI2_TV20, YI2_INT20_1, YI2_DH20, YI2_INT20_2, YI3_BH21, YI3_SXF21, 
  YI3_QF21, YI3_TH21, YI3_INT20_2, YI3_DH20, YI3_INT20_1, YI3_BV20, YI3_SXD20, YI3_QD20, 
  YI3_TV20, YI3_INT19_2, YI3_DH19, YI3_INT19_1, YI3_BH19, YI3_SXF19, YI3_QF19, YI3_TH19, 
  YI3_INT18_2, YI3_DH18, YI3_INT18_1, YI3_BV18, YI3_SXD18, YI3_QD18, LMP03Y18, YI3_INT17_2, 
  YI3_DH17, YI3_INT17_1, YI3_BH17, YI3_SXF17, YI3_QF17, LMP03Y17, YI3_INT16_2, YI3_DH16, 
  YI3_INT16_1, YI3_BV16, YI3_SXD16, YI3_QD16, LMP03Y16, YI3_INT15_2, YI3_DH15, YI3_INT15_1, 
  YI3_BH15, YI3_SXF15, YI3_QF15, LMP03Y15, YI3_INT14_2, YI3_DH14, YI3_INT14_1, YI3_BV14, 
  YI3_SXD14, YI3_QD14, LMP03Y14, YI3_INT13_2, YI3_DH13, YI3_INT13_1, YI3_BH13, YI3_SXF13, 
  YI3_QF13, LMP03Y13, YI3_INT12_2, YI3_DH12, YI3_INT12_1, YI3_BV12, YI3_SXD12, YI3_QD12, 
  LMP03Y12, YI3_INT11_2, YI3_DH11, YI3_INT11_1, YI3_BH11, YI3_SXF11, YI3_QF11, LMP03Y11, 
  YI3_INT10_2, YI3_DH10, YI3_INT10_1, YI3_BV10, YI3_SXD10, YI3_QD10, LMP03Y10, YI3_INT9_3, 
  YI3_DH9, YI3_INT9_2, YI3_INT9_1, YI3_BH9, YI3_SXF9, YI3_QF9, LMP03Y09, YI3_INT8_2, 
  YI3_DH8, YI3_INT8_1, LMP03Y08, YI3_QD8, YI3_B8, YI3_INT7_2, YI3_HLX7_4, YI3_HLX7_3, 
  YI3_B7_1, YI3_HLX7_2, YI3_HLX7_1, YI3_INT7_1, YI3_B7, YI3_QF7, LMP03Y07, YI3_INT6_3, 
  YI3_DH6, YI3_INT6_2, YI3_INT6_1, LMP03Y06, YI3_QD6, YI3_TQ6, YI3_BV6, YI3_INT5_2, 
  YI3_DH5, YI3_INT5_1, LMP03Y05, YI3_QF5, YI3_TQ5, YI3_BH5, YI3_INT4_2, YI3_INT4_1, 
  LMP03Y04, YI3_QD4, YI3_TQ4, YI3_B4, OBSK3IY, YI3_SV4, O3Y3C0, OCKTXFL, YI3_KSCV3, O3Y3C1, 
  OCKTUFL, YI3_KSCH3_2, O3Y3C2, YI3_KSCH3_1, O3KWD, YI3_DW0, OWDFL, OWDTRANS, OBELW7, 
  OWPUMP, OVALVE, OJETTRANS, OJETFL, DET_POL_HPOL_HJET, OHE3JET, DET_POL_HPOL_PC1_2, 
  OK10HZH, YI3_KFBH3, YI3_B3W, YI3_B3, LMP03Y3A, YI3_QF3, LMP03Y3X, YI3_INT2, YI3_QD2, 
  LMP03Y02, YI3_INT1, YI3_QF1, YI3_B1, YI3_B1W, CAV100_4, O100, CAV100_3, CAV100_2, 
  CAV100_1, O_KICK_ASSY, SL_KICK_MOD18, SL_KICK_MOD17, SL_KICK_MOD16, SL_KICK_MOD15, 
  SL_KICK_MOD14, SL_KICK_MOD13, SL_KICK_MOD12, SL_KICK_MOD11, SL_KICK_MOD10, SL_KICK_MOD09, 
  SL_KICK_MOD08, SL_KICK_MOD07, SL_KICK_MOD06, SL_KICK_MOD05, SL_KICK_MOD04, SL_KICK_MOD03, 
  SL_KICK_MOD02, SL_KICK_MOD01, O04, YO4_DW0, CAV50_3, O50, CAV50_2, CAV50_1, YO4_B1W, 
  YO4_B1, YO4_QD1, YO4_INT1, LMP04Y02, YO4_QF2, YO4_INT2, LMP04Y3X, YO4_QD3, LMP04Y3A, 
  YO4_B3, YO4_B3W, CAV25_4, O25, CAV25_3, CAV25_2, CAV25_1, O25_197, CAV197_9, O197, 
  CAV197_8, CAV197_7, CAV197_6, CAV197_5, CAV197_4, CAV197_3, CAV197_2, CAV197_1, OS197, 
  SEPTUM_IR4, OSV4, YO4_SV4, OBSK4IY, YO4_B4, YO4_TQ4, YO4_QF4, LMP04Y04, YO4_INT4_1, 
  YO4_INT4_2, YO4_BV5, YO4_TQ5, YO4_QD5, LMP04Y05, YO4_INT5_1, YO4_DH5, YO4_INT5_2, 
  YO4_BH6, YO4_TQ6, YO4_QF6, LMP04Y06, YO4_INT6_1, YO4_INT6_2, YO4_DH6, YO4_INT6_3, 
  LMP04Y07, YO4_QD7, YO4_B7, YO4_INT7_1, YO4_INT7_2, YO4_B8, YO4_QF8, LMP04Y08, YO4_INT8_1, 
  YO4_DH8, YO4_INT8_2, LMP04Y09, YO4_QD9, YO4_SXD9, YO4_BV9, YO4_INT9_1, YO4_INT9_2, 
  YO4_DH9, YO4_INT9_3, LMP04Y10, YO4_QF10, YO4_SXF10, YO4_BH10, YO4_INT10_1, YO4_DH10, 
  YO4_INT10_2, YO4_TV11, YO4_QD11, YO4_SXD11, YO4_BV11, YO4_INT11_1, YO4_DH11, YO4_INT11_2, 
  YO4_TH12, YO4_QF12, YO4_SXF12, YO4_BH12, YO4_INT12_1, YO4_DH12, YO4_INT12_2, YO4_TV13, 
  YO4_QD13, YO4_SXD13, YO4_BV13, YO4_INT13_1, YO4_DH13, YO4_INT13_2, YO4_TH14, YO4_QF14, 
  YO4_SXF14, YO4_BH14, YO4_INT14_1, YO4_DH14, YO4_INT14_2, YO4_TV15, YO4_QD15, YO4_SXD15, 
  YO4_BV15, YO4_INT15_1, YO4_DH15, YO4_INT15_2, YO4_TH16, YO4_QF16, YO4_SXF16, YO4_BH16, 
  YO4_INT16_1, YO4_DH16, YO4_INT16_2, YO4_TV17, YO4_QD17, YO4_SXD17, YO4_BV17, YO4_INT17_1, 
  YO4_DH17, YO4_INT17_2, YO4_TH18, YO4_QF18, YO4_SXF18, YO4_BH18, YO4_INT18_1, YO4_DH18, 
  YO4_INT18_2, YO4_TV19, YO4_QD19, YO4_SXD19, YO4_BV19, YO4_INT19_1, YO4_DH19, YO4_INT19_2, 
  YO4_TH20, YO4_QF20, YO4_SXF20, YO4_BH20, YO4_INT20_1, YO4_DH20, YO4_INT20_2, YO5_TV21, 
  YO5_QD21, YO5_SXD21, YO5_BV21, YO5_INT20_2, YO5_DH20, YO5_INT20_1, YO5_TH20, YO5_QF20, 
  YO5_SXF20, YO5_BH20, YO5_INT19_2, YO5_DH19, YO5_INT19_1, YO5_TV19, YO5_QD19, YO5_SXD19, 
  YO5_BV19, YO5_INT18_2, YO5_DH18, YO5_INT18_1, LMP05Y18, YO5_QF18, YO5_SXF18, YO5_BH18, 
  YO5_INT17_2, YO5_DH17, YO5_INT17_1, LMP05Y17, YO5_QD17, YO5_SXD17, YO5_BV17, YO5_INT16_2, 
  YO5_DH16, YO5_INT16_1, LMP05Y16, YO5_QF16, YO5_SXF16, YO5_BH16, YO5_INT15_2, YO5_DH15, 
  YO5_INT15_1, LMP05Y15, YO5_QD15, YO5_SXD15, YO5_BV15, YO5_INT14_2, YO5_DH14, YO5_INT14_1, 
  LMP05Y14, YO5_QF14, YO5_SXF14, YO5_BH14, YO5_INT13_2, YO5_DH13, YO5_INT13_1, LMP05Y13, 
  YO5_QD13, YO5_SXD13, YO5_BV13, YO5_INT12_2, YO5_DH12, YO5_INT12_1, LMP05Y12, YO5_QF12, 
  YO5_SXF12, YO5_BH12, YO5_INT11_2, YO5_DH11, YO5_INT11_1, LMP05Y11, YO5_QD11, YO5_SXD11, 
  YO5_BV11, YO5_INT10_2, YO5_DH10, YO5_INT10_1, LMP05Y10, YO5_QF10, YO5_SXF10, YO5_BH10, 
  OBELSKI, YO5_SV9_2, OBELLKI, YO5_DU9W, H5_TQ11, H5_Q11, H5_COR11, YO5_SV9_1, ODSWL, 
  YO5_DH9, YO5_INT9_6, OBWK, YO5_BV9, OQBWM, YO5_QD9, LMP05Y09, YO5_INT8_2, YO5_DH8, 
  YO5_INT8_1, LMP05Y08, YO5_QF8, YO5_B8, YO5_INT7_2, YO5_SNK_HLX4, YO5_SNK_HLX3, YO5_BSNK, 
  YO5_SNK_HLX2, YO5_SNK_HLX1, YO5_INT7_1, YO5_B7, YO5_QD7, LMP05Y07, YO5_INTROT, 
  YO5_ROT_HLX4, YO5_ROT_HLX3, YO5_BROT, YO5_ROT_HLX2, YO5_ROT_HLX1, LMP05B08, BI5_QD8, 
  BI5_B8, OINT, H5_DH4, LMP05Y04, YO5_QF4, YO5_TQ4, YO5_B4, YO5_DH5, LMP03B08, BO3_QF8, 
  BO3_B8, D9_PF, LMP06Y02, YI6_QD2, O_CRAB_IP6F, B2PF, OW2C, H5_TV3, H5_QS3, Q3PF, 
  O_FFDET_WQ, O06W_FFDET!1, O_ROMAN_POT_IP6_2, O06W_FFDET!2, O_ROMAN_POT_IP6_1, 
  O06W_FFDET!3, O_OFF_MOM_IP6_2, O06W_FFDET!4, O_OFF_MOM_IP6_1, O06W_FFDET!5, PBR_B1APF, 
  PBT_B1APF, B1APF, PET_B1APF, PER_B1APF, O06W_B1_B1A, PBR_B1PF, PBT_B1PF, B1PF, PET_B1PF, 
  PER_B1PF, O06W_Q2_B1, PBR_Q2PF, PBT_Q2PF, Q2PF, PET_Q2PF, PER_Q2PF, O06W_Q1B_Q2, 
  PBR_Q1BPF, PBT_Q1BPF, Q1BPF, PET_Q1BPF, PER_Q1BPF, O06W_Q1A_Q1B, PBR_Q1APF, PBT_Q1APF, 
  Q1APF, PET_Q1APF, PER_Q1APF, O06W_B0A_Q1A, PBR_B0APF, PBT_B0APF, B0APF, PET_B0APF, 
  PER_B0APF, O06W_B0_B0A, PB_B0PF, B0PF, PE_B0PF, D1_PF, PB_SOL_F, STAR_DETECT_F, PE_SOL_F, 
  IP6W], R_ref = 400.0);


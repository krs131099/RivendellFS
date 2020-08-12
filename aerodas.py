#!/usr/bin/env python3

import math
import matplotlib.pyplot as plt


# START HERE

# AERODAS model is a technique developed by NASA, to calculate the airfoil
#  lift and drag coefficients in the fully stall engine.

# TERMINOLOGY
# f1 and f2 are empirical functions of t/c
# g1 and g2 are empirical fucntions of aspect ratio
# cl2max and cd2max are maximum lift and drag coefficients in post stall regime
# acl1 : angle of attack at maximum pre-stall lift
# a0 : angle of attack at which pre-stall lift coefficient worth 0
# alpha : angle of attack
# ar : aspect ratio
# tc : thickness to chord ratio


ar = 7.2
tc = 0.12

f1 = 1.190 * ( 1 - (tc)**2 ) 
f2 = 0.65 + 0.35*math.exp( -(9/ar)**2.3 )

g1 = 2.300 * math.exp(-(0.65*0.12)**0.90)
g2 = 0.52 + 0.48 * math.exp(-(6.5/ar)**1.1 )

cl2max = f1 * f2
cd2max = g1 * g2


#TODO recheck a0 and cd1max and uncomment cd2 plot.
acl1 = 15
a0 = 0
cd1max = 0


def postcl2(alpha : float) -> float:
   """ This fucntion takes the angle of attack(alpha) as input parameter
   and calculates the post-stall coefficient of lift(CL2) using AERODAS model.
   input : alpha( in degrees)
   output: cl2 (non dimensional number)
   """

   #  rcl2 : reduction from extension of linear segment of lift curve to cl2max
   rcl2 = 1.632 - cl2max
   # n2 : exponent defining shape of lift curve at cl2max
   n2 = 1 + cl2max/rcl2

   #for negative alpha
   if alpha < 0:
      cl2 = - postcl2(2*a0 - alpha)

   # for postitive alpha
   if 0 <= alpha and alpha < acl1 :
      cl2 = 0
   elif acl1 <= alpha and alpha <= 92 :
      cl2 = -0.032*(alpha - 92) - rcl2 * ((92-alpha)/51)**n2

   else:
      cl2 = -0.032* (alpha - 92) + rcl2 * ((alpha - 92)/51)**n2

   
   return cl2



def postcd2(alpha : float) -> float:
   """ This function takes the angle of attack (alpha) as input parameter
   and calculates the post-stall coefficient of drag (CD2) using AERODAS model."""

   # for positive alpha
   if (2*a0 - acl1) < alpha and alpha < acl1 :
      cd2 = 0

   elif alpha >= acd1 :
      angle = math.radians(90* ((alpha-acd1)/(90 - acd1)) )

      cd2 = cd1max + (cd2max - cd1max) * sin(angle)

   # negative angle of attack
   if alpha <= (2*a0 - acd1) :
      cd2 = postcd2( -alpha + 2*a0)

   return cd2



#plot cl2 vs alpha
x = list(range(-180,181))
y = []
#z = []

for c in x:
   if c > 0:
      cl2 = postcl2(c)
   else:
      cl2 = -postcl2(-c)

   y.append(cl2)
   #z.append(plotcd2(x))


plt.plot(x,y,color='g',linewidth=2,label='CL')
plt.xlabel('Angle of attack, alpha (deg)')
plt.ylabel('Lift Coefficient, CL')
plt.title('CL vs Alpha')
plt.show()
# CD are commented.
#plt.plot(x,z,color='r', linewidth=2,label='cd')
#print("done")
# print(y)

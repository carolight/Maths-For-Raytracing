import UIKit
import simd
let π = CGFloat(M_PI)

/*:
 
 ## Barycentric Coordinates
 
 In geometry, the barycentric coordinate system is a coordinate system in which the location of a point of a simplex (a triangle, tetrahedron, etc.) is specified as the center of mass, or barycenter, of usually unequal masses placed at its vertices. Coordinates also extend outside the simplex, where one or more coordinates become negative. The system was introduced (1827) by August Ferdinand Möbius.

 \- Wikipedia
 */

//: ![Triangle Center](Barycentric1.png)

/*:
 
 Barycentric coordinates always add up to 1. So the equally balanced center of a triangle has barycentric coordinates of <1/3, 1/3, 1/3>
 */

/*:
 Barycentric coordinates are useful in ray tracing because any point that is outside the simplex has a negative coordinate.
 */

/*:
 Let's create a triangle
*/

let pointA = CGPoint(x:100, y:0)
let pointB = CGPoint(x:0, y:140)
let pointC = CGPoint(x:200, y:90)

//: Visualize the triangle
let path = UIBezierPath()
path.moveToPoint(pointA)
path.addLineToPoint(pointB)
path.addLineToPoint(pointC)
path.closePath()
path

//: Work out the center of mass.

func calculateCenterPoint() -> CGPoint {
  // separate out calculation because
  // it's too complex for playground
  let pointPX = 1/3*pointA.x + 1/3*pointB.x + 1/3*pointC.x
  let pointPY = 1/3*pointA.y + 1/3*pointB.y + 1/3*pointC.y
  
  let pointP = CGPoint(x: pointPX,
                       y: pointPY)
  return pointP
}

let pointP = calculateCenterPoint()

/*:
 * callout(Visualize):
 Visualize the triangle with center of mass
*/
var visualizePointPath = UIBezierPath(CGPath:path.CGPath)
visualizePointPath.moveToPoint(pointA)
visualizePointPath.addLineToPoint(pointP)
visualizePointPath.moveToPoint(pointB)
visualizePointPath.addLineToPoint(pointP)
visualizePointPath.moveToPoint(pointC)
visualizePointPath.addLineToPoint(pointP)

visualizePointPath.addArcWithCenter(pointP, radius: 4, startAngle: 0, endAngle: 2*π, clockwise: true)

/*: 
 Now we'll see whether a specified point is inside the triangle.

 * experiment:
 Change `pointQ` to test whether it is inside or outside the triangle.
 */
let pointQ = CGPoint(x: 20, y: 60)

path.moveToPoint(pointQ)
path.addArcWithCenter(pointQ, radius: 4, startAngle: 0, endAngle: 2*π, clockwise: true)
path


/*:
 <Thanks to [John Calsbeek](http://gamedev.stackexchange.com/a/23745) for this method.>
 */

func barycentric(p: CGPoint, a: CGPoint, b: CGPoint, c: CGPoint) -> float3 {
  
  let tv0 = b - a
  let tv1 = c - a
  let tv2 = p - a
  let v0 = float2(Float(tv0.x), Float(tv0.y))
  let v1 = float2(Float(tv1.x), Float(tv1.y))
  let v2 = float2(Float(tv2.x), Float(tv2.y))
  
  let d00 = dot(v0, v0)
  let d01 = dot(v0, v1)
  let d11 = dot(v1, v1)
  let d20 = dot(v2, v0)
  let d21 = dot(v2, v1)
  
  let denom = d00 * d11 - d01 * d01
  let v = (d11 * d20 - d01 * d21) / denom
  let w = (d00 * d21 - d01 * d20) / denom
  let u = 1.0 - v - w
  
  return float3(u, v, w)
}

// utility function to subtract CGPoints
func -(left: CGPoint, right: CGPoint) -> CGPoint {
  var point: CGPoint = .zero
  point.x = left.x - right.x
  point.y = left.y - right.y
  return point
}

/*:
 Test the barycentric function with `pointP`.
 The result should be (1/3, 1/3, 1/3)
 */

var result = barycentric(pointP, a: pointA, b: pointB, c: pointC)
result.x
result.y
result.z

/*: 
 Now plug in `pointQ` to see if it is inside or outside the simplex
 */

result = barycentric(pointQ, a: pointA, b: pointB, c: pointC)
result.x
result.y
result.z

if result.x > 0 && result.y > 0 && result.z > 0 {
  print("Point is INSIDE the triangle")
}

if result.x < 0 || result.y < 0 || result.z < 0 {
  print("Point is OUTSIDE the triangle")
}

if result.x == 0 || result.y == 0 || result.z == 0 {
  print("Point is ON THE EDGE of the triangle")
}

/*:
 * note:
 When moving to the third dimension, `pointQ` is assumed to be co-planar with the triangle.
 */

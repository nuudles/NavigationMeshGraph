//
//  Delaunay.swift
//  Pods
//
//  Created by Christopher Luu on 7/6/15.
//
//

import Foundation

internal class Delaunay {
	let maxTriangleRadius = 10000
	
	private var points: Array<CGPoint>
	
	init(points : Array<CGPoint>) {
		self.points = points
	}
	
	func compute () -> Array<Int>? {
		let numberOfPoints = points.count
		
		if numberOfPoints < 3 {
			return nil
		}
		
		points.append(CGPoint(x: 0, y: -maxTriangleRadius))
		points.append(CGPoint(x: maxTriangleRadius, y: maxTriangleRadius))
		points.append(CGPoint(x: -maxTriangleRadius, y: maxTriangleRadius))
		
		var indices = [
			points.count - 3,
			points.count - 2,
			points.count - 1,
		]
		
		let circleList = CircleList(points: [0.0, 0.0, Float(maxTriangleRadius)])
		var edgeList = Array<Int>()
		
		var id0 = 0
		var id1 = 0
		var id2 = 0
		
		for i in 0..<numberOfPoints {
			for var j = 0; j < indices.count; j+=3 {
				if circleList.contains(j, point: points[i]) {
					id0 = indices[j]
					id1 = indices[j + 1]
					id2 = indices[j + 2]
					
					edgeList.append(id0)
					edgeList.append(id1)
					edgeList.append(id1)
					edgeList.append(id2)
					edgeList.append(id2)
					edgeList.append(id0)
					
					indices.removeRange(j..<j+3)
					circleList.remove(j, howMany: 3)
					
					j -= 3
				}
			}
			
			for var j = 0; j < edgeList.count; j+=2 {
				for var k = j + 2; k < edgeList.count; k+=2 {
					if Delaunay.edgesMatch(edgeList, j: j, k: k) {
						
						edgeList.removeRange(k..<k+2)
						edgeList.removeRange(j..<j+2)
						
						j -= 2
						k -= 2
						
						if j < 0 || k < 0 {
							break
						}
					}
				}
			}
			
			for var j = 0; j < edgeList.count; j+=2 {
				indices.append(edgeList[j])
				indices.append(edgeList[j + 1])
				indices.append(i)
				circleList.add(points[edgeList[j]], point2: points[edgeList[j + 1]], point3: points[i])
			}
			
			edgeList = []
		}
		
		for var i = 0; i < indices.count; i+=3 {
			if Delaunay.indicesMatch(indices, i: i, id0: id0, id1: id1, id2: id2) {
				indices.removeRange(i..<i+3)
				i -= 3
				continue
			}
		}
		
		points.removeLast()
		points.removeLast()
		points.removeLast()
		
		return indices
	}
	
	private class func edgesMatch(edgeList: Array<Int>, j: Int, k: Int) -> Bool {
		return (edgeList[j] == edgeList[k] && edgeList[j + 1] == edgeList[k + 1]) ||
			(edgeList[j + 1] == edgeList[k] && edgeList[j] == edgeList[k + 1])
	}
	
	private class func indicesMatch(indices: Array<Int>, i: Int, id0: Int, id1: Int, id2: Int) -> Bool {
		let index0 = indices[i]
		let index1 = indices[i + 1]
		let index2 = indices[i + 2]
		
		return index0 == id0 || index0 == id1 || index0 == id2 ||
			index1 == id0 || index1 == id1 || index1 == id2 ||
			index2 == id0 || index2 == id1 || index2 == id2
	}
}

internal class CircleList {
	private var list: Array<Float>
	
	init(points: Array<Float>) {
		self.list = points
	}
	
	func add(point1: CGPoint, point2: CGPoint, point3: CGPoint) {
		let a = point2.x - point1.x
		let b = point2.y - point1.y
		
		let c = point3.x - point1.x
		let d = point3.y - point1.y
		
		let e = a * (point1.x + point2.x) + b * (point1.y + point2.y)
		let f = c * (point1.x + point3.x) + d * (point1.y + point3.y)
		
		let g = 2.0 * (a * (point3.y - point2.y) - b * (point3.x - point2.x))
		
		var x = (d * e - b * f) / g
		var y = (a * f - c * e) / g
		
		list.append(Float(x))
		list.append(Float(y))
		
		x -= point1.x
		y -= point1.y
		
		list.append(Float(x * x + y * y))
	}
	
	func remove(index: Int, howMany: Int) {
		list.removeRange(index..<index + howMany)
	}
	
	func contains(circleIndex: Int, point: CGPoint) -> Bool {
		if !CircleList.suitableValue(list[circleIndex + 2]) {
			return false
		}
		
		let dx = list[circleIndex] - Float(point.x)
		let dy = list[circleIndex + 1] - Float(point.y)
		
		return list[circleIndex + 2] > dx * dx + dy * dy
	}
	
	class func suitableValue(value: Float) -> Bool {
		return value > FLT_EPSILON
	}
}

//
//  NavigationMeshPolygon.swift
//  Pods
//
//  Created by Christopher Luu on 7/6/15.
//
//

import simd
import GameplayKit

public class NavigationMeshPolygon
{
	public let points: [float2]
	public var graphNodes: [GKGraphNode2D] = []

	public init(points: [float2])
	{
		self.points = points
	}

	public func contains(point: float2) -> Bool
	{
		// This code is ported from http://stackoverflow.com/questions/8721406/how-to-determine-if-a-point-is-inside-a-2d-convex-polygon

		var contains = false
		for var i = 0, j = points.count - 1; i < points.count; j = i++
		{
			if ((points[i].y > point.y) != (points[j].y > point.y)) && (point.x < (points[j].x - points[i].x) * (point.y - points[i].y) / (points[j].y - points[i].y) + points[i].x)
			{
				contains = !contains
			}
		}
		return contains
	}
}

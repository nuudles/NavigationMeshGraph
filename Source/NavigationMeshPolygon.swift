//
//  NavigationMeshPolygon.swift
//  Pods
//
//  Created by Christopher Luu on 7/6/15.
//
//

import simd
import GameplayKit

/// A class to describe a convex polygon based on a set of points
public class NavigationMeshPolygon
{
	/// The points that make up the polygon
	public let points: [float2]
	/// The graph nodes associated with this polygon
	public var graphNodes: [GKGraphNode2D] = []

	// MARK: - Initialization methods
	/// - parameter points The points that make up the polygon
	public init(points: [float2])
	{
		self.points = points
	}

	// MARK: - Public methods
	/// Determines if a given point is contained within this polygon
	/// - parameter point The given point
	/// - returns: Bool representing if the point is contained within this polygon
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

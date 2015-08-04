//
//  NavigationMeshGraph.swift
//  Pods
//
//  Created by Christopher Luu on 7/2/15.
//
//

import GameplayKit

public class NavigationMeshGraph: GKGraph
{
	// MARK: - Public properties
	public var polygons: [NavigationMeshPolygon]
	{
		didSet
		{
			resetNodesForPolygons()
		}
	}

	// MARK: - Initialization methods
	public init(polygons: [NavigationMeshPolygon])
	{
		self.polygons = polygons
		super.init()

		resetNodesForPolygons()
	}

	// MARK: - Public methods
	public func connectNodeToClosestPointOnNavigationMesh(node: GKGraphNode2D)
	{
		var minDistance = FLT_MAX
		var intersection: float2!
		var containingPolygon: NavigationMeshPolygon!

		let nodePoint = float2(node.position.x, node.position.y)
		for polygon in polygons
		{
			if polygon.contains(nodePoint)
			{
				intersection = nodePoint
				containingPolygon = polygon
				break
			}

			var lastPoint = polygon.points.last!
			for point in polygon.points
			{
				if let distanceAndIntersection = distanceSquaredAndIntersectionFromPoint(nodePoint, toLine: (p1: lastPoint, p2: point))
				{
					if distanceAndIntersection.distanceSquared < minDistance
					{
						intersection = distanceAndIntersection.intersection
						minDistance = distanceAndIntersection.distanceSquared
						containingPolygon = polygon
					}
				}
				lastPoint = point
			}
		}

		node.position = intersection
		node.addConnectionsToNodes(containingPolygon.graphNodes, bidirectional: true)
	}

	// MARK: - Overridden methods
	public override func findPathFromNode(startNode: GKGraphNode, toNode endNode: GKGraphNode) -> [GKGraphNode]
	{
		guard let start = startNode as? GKGraphNode2D, end = endNode as? GKGraphNode2D else { return super.findPathFromNode(startNode, toNode: endNode) }
		for polygon in polygons
		{
			if polygon.contains(float2(start.position.x, start.position.y)) && polygon.contains(float2(end.position.x, end.position.y))
			{
				// If both points are in the same polygon, just go straight there
				return [start, end]
			}
		}
		return super.findPathFromNode(startNode, toNode: endNode)
	}
	
	// MARK: - Private methods
	private func resetNodesForPolygons()
	{
		if let nodes = nodes
		{
			removeNodes(nodes)
		}

		var pointToNode: [String: GKGraphNode2D] = [:]
		for polygon in polygons
		{
			var lastPoint = polygon.points.last!
			
			var totalPoint = float2(0, 0)
			for point in polygon.points
			{
				addPoint(point, polygon: polygon, pointToNode: &pointToNode)
				
				let midPoint = float2((point.x + lastPoint.x) / 2.0, (point.y + lastPoint.y) / 2.0)
				addPoint(midPoint, polygon: polygon, pointToNode: &pointToNode)
				
				lastPoint = point
				totalPoint.x += point.x
				totalPoint.y += point.y
			}
			// Add the centroid
			addPoint(float2(totalPoint.x / Float(polygon.points.count), totalPoint.y / Float(polygon.points.count)), polygon: polygon, pointToNode: &pointToNode)
		}
	}

	private func addPoint(point: float2, polygon: NavigationMeshPolygon, inout pointToNode: [String: GKGraphNode2D])
	{
		let graphNode: GKGraphNode2D
		if let node = pointToNode["\(point)"]
		{
			graphNode = node
		}
		else
		{
			graphNode = NavigationMeshGraphNode(point: point)
			addNodes([graphNode])
		}
		graphNode.addConnectionsToNodes(polygon.graphNodes, bidirectional: true)
		polygon.graphNodes.append(graphNode)
		pointToNode["\(point)"] = graphNode
	}

	private func distanceSquaredAndIntersectionFromPoint(point: float2, toLine line: (p1: float2, p2: float2)) -> (distanceSquared: Float, intersection: float2)?
	{
		// This code is ported from: http://paulbourke.net/geometry/pointlineplane/
		let (l1, l2) = line
		let lineMagnitude = distance_squared(l1, y: l2)
		let u = (((point.x - l1.x) * (l2.x - l1.x) + (point.y - l1.y) * (l2.y - l1.y)) / lineMagnitude)
		if u < 0.0 || u > 1.0
		{
			return nil
		}

		let intersection = float2(l1.x + u * (l2.x - l1.x), l1.y + u * (l2.y - l1.y))
		return (distanceSquared: distance_squared(point, y: intersection), intersection: intersection)
	}
}

class NavigationMeshGraphNode: GKGraphNode2D
{
	// TODO: Revisit this? Find out why GKGraphNode2D's cost isn't related to distance as I thought it should be
	override func costToNode(node: GKGraphNode) -> Float
	{
		guard let graphNode = node as? GKGraphNode2D else { return super.costToNode(node) }
		return distance_squared(position, y: graphNode.position)
	}
}

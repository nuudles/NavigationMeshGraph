//
//  GameScene.swift
//  NavigationMeshGraphExample
//
//  Created by Christopher Luu on 7/2/15.
//  Copyright (c) 2015 Nuudles. All rights reserved.
//

import SpriteKit
import GameplayKit
import NavigationMeshGraph
import SwiftyJSON

// Extend `CGPoint` to add an initializer from a `float2` representation of a point.
extension CGPoint {
	// MARK: Initializers
	
	/// Initialize with a `float2` type.
	init(_ point: float2) {
		x = CGFloat(point.x)
		y = CGFloat(point.y)
	}
}

// Extend `float2` to add an initializer from a `CGPoint`.
extension float2 {
	// MARK: Initialization
	
	/// Initialize with a `CGPoint` type.
	init(_ point: CGPoint) {
		self.init(x: Float(point.x), y: Float(point.y))
	}
}

class GameScene: SKScene
{
	let shipSprite = SKSpriteNode(imageNamed: "Spaceship")
	lazy var graph: NavigationMeshGraph =
	{
		let json = JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("Testing", ofType: "json")!)!)

		var polygons: [NavigationMeshPolygon] = []
		for polygon in json["rigidBodies"][0]["polygons"].arrayValue
		{
			var points: [float2] = []
			for point in polygon.arrayValue
			{
				points.append(float2(point["x"].floatValue * Float(self.size.width) + 50, point["y"].floatValue * Float(self.size.height) + 300))
			}
			polygons.append(NavigationMeshPolygon(points: points))
		}

		let graph = NavigationMeshGraph(polygons: polygons)
		return graph
	}()

	var lastTime: NSTimeInterval = 0
	var path: [GKGraphNode2D]?
	var nextPosition: float2?

	let pathNode = SKShapeNode()

	override func didMoveToView(view: SKView)
	{
		super.didMoveToView(view)

		let polygonPath = CGPathCreateMutable()
		for polygon in graph.polygons
		{
			let points = polygon.points
			CGPathMoveToPoint(polygonPath, nil, CGFloat(points[0].x), CGFloat(points[0].y))
			for point in points
			{
				CGPathAddLineToPoint(polygonPath, nil, CGFloat(point.x), CGFloat(point.y))
			}
		}

		let polygonNode = SKShapeNode()
		polygonNode.path = polygonPath
		polygonNode.fillColor = .blueColor()
		polygonNode.strokeColor = .greenColor()
		addChild(polygonNode)

		/*
		// Uncomment this to draw the graph connections
		for node in graph.nodes as! [GKGraphNode2D]
		{
			let path = CGPathCreateMutable()
			for connectedNode in node.connectedNodes as! [GKGraphNode2D]
			{
				CGPathMoveToPoint(path, nil, CGFloat(node.position.x), CGFloat(node.position.y))
				CGPathAddLineToPoint(path, nil, CGFloat(connectedNode.position.x), CGFloat(connectedNode.position.y))
			}
			let shapeNode = SKShapeNode()
			shapeNode.path = path
			shapeNode.strokeColor = UIColor.yellowColor()
			addChild(shapeNode)
		}
		*/

		pathNode.strokeColor = UIColor.redColor()
		pathNode.lineWidth = 10
		addChild(pathNode)

		shipSprite.position = CGPoint(x: 200, y: 400)
		shipSprite.xScale = 0.1
		shipSprite.yScale = 0.1
		addChild(shipSprite)
	}

	override func didChangeSize(oldSize: CGSize)
	{
		super.didChangeSize(oldSize)
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
		guard let touch = touches.first else { return }

		let startPosition = shipSprite.position
		let endPosition = touch.locationInNode(self)

		let startNode = NavigationMeshGraphNode(point: float2(startPosition))
		let endNode = NavigationMeshGraphNode(point: float2(endPosition))

		graph.connectNodeToClosestPointOnNavigationMesh(startNode)
		graph.connectNodeToClosestPointOnNavigationMesh(endNode)

		if let path = graph.findPathFromNode(startNode, toNode: endNode) as? [GKGraphNode2D]
		{
			nextPosition = nil
			self.path = path.count > 0 ? path : nil

			if path.count > 0
			{
				let linePath = CGPathCreateMutable()
				CGPathMoveToPoint(linePath, nil, CGFloat(path[0].position.x), CGFloat(path[0].position.y))
				for node in path
				{
					CGPathAddLineToPoint(linePath, nil, CGFloat(node.position.x), CGFloat(node.position.y))
				}
				pathNode.path = linePath
			}
		}

		graph.removeNodes([startNode, endNode])
	}

	override func update(currentTime: CFTimeInterval)
	{
		let deltaTime = currentTime - lastTime

		if path != nil && nextPosition == nil
		{
			nextPosition = path![0].position
			path!.removeAtIndex(0)
			if path!.count == 0
			{
				path = nil
			}
		}

		if let nextPosition = self.nextPosition
		{
			let movementSpeed = CGFloat(300)
			
			let displacement = nextPosition - float2(shipSprite.position)
			let angle = CGFloat(atan2(displacement.y, displacement.x))
			let maxPossibleDistanceToMove = movementSpeed * CGFloat(deltaTime)
			
			let normalizedDisplacement: float2
			if length(displacement) > 0.0
			{
				normalizedDisplacement = normalize(displacement)
			}
			else
			{
				normalizedDisplacement = displacement
			}
			let actualDistanceToMove = CGFloat(length(normalizedDisplacement)) * maxPossibleDistanceToMove
			
			// Find the x and y components of the distance based on the angle.
			let dx = actualDistanceToMove * cos(angle)
			let dy = actualDistanceToMove * sin(angle)
			shipSprite.position = CGPoint(x: shipSprite.position.x + dx, y: shipSprite.position.y + dy)
			shipSprite.zRotation = atan2(-dx, dy)

			if length(displacement) <= Float(maxPossibleDistanceToMove)
			{
				self.nextPosition = nil
			}
		}

		lastTime = currentTime
	}
}

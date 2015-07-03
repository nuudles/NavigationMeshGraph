//
//  GameScene.swift
//  NavigationMeshGraphExample
//
//  Created by Christopher Luu on 7/2/15.
//  Copyright (c) 2015 Nuudles. All rights reserved.
//

import SpriteKit
import GameplayKit

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
		x = Float(point.x)
		y = Float(point.y)
	}
}

class GameScene: SKScene
{
	let shipSprite = SKSpriteNode(imageNamed: "Spaceship")
	lazy var graph: GKObstacleGraph =
	{
		let points = UnsafeMutablePointer<float2>.alloc(4)
		points[0] = float2(Float(self.size.width / 2 - 50), Float(self.size.height / 2 - 50))
		points[1] = float2(Float(self.size.width / 2 - 50), Float(self.size.height / 2 + 50))
		points[2] = float2(Float(self.size.width / 2 + 50), Float(self.size.height / 2 + 50))
		points[3] = float2(Float(self.size.width / 2 + 50), Float(self.size.height / 2 - 50))

		let obstacle = GKPolygonObstacle(points: points, count: 4)
		let graph = GKObstacleGraph(obstacles: [obstacle], bufferRadius: Float(self.shipSprite.size.width))

		points.destroy()

		return graph
	}()

	var lastTime: NSTimeInterval = 0
	var path: [GKGraphNode2D]?
	var nextPosition: float2?

	let obstacleNode = SKSpriteNode()

	override func didMoveToView(view: SKView)
	{
		super.didMoveToView(view)

		shipSprite.xScale = 0.5
		shipSprite.yScale = 0.5
		addChild(shipSprite)

		obstacleNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
		obstacleNode.size = CGSize(width: 100, height: 100)
		obstacleNode.color = UIColor.redColor()
		addChild(obstacleNode)
	}

	override func didChangeSize(oldSize: CGSize)
	{
		super.didChangeSize(oldSize)

		var position = shipSprite.position
		position.y = size.height / 2
		shipSprite.position = position

		obstacleNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
		guard let touch = touches.first else { return }

		let startPosition = shipSprite.position
		let endPosition = touch.locationInNode(self)

		let startNode = GKGraphNode2D(point: float2(startPosition))
		let endNode = GKGraphNode2D(point: float2(endPosition))

		graph.connectNodeUsingObstacles(startNode)
		graph.connectNodeUsingObstacles(endNode)

		if let path = graph.findPathFromNode(startNode, toNode: endNode) as? [GKGraphNode2D]
		{
			nextPosition = nil
			self.path = path
		}
	}

	override func update(currentTime: CFTimeInterval)
	{
		let deltaTime = currentTime - lastTime

		if path != nil && nextPosition == nil && path!.count > 0
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

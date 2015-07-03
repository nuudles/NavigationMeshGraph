//
//  GameViewController.swift
//  NavigationMeshGraphExample
//
//  Created by Christopher Luu on 7/2/15.
//  Copyright (c) 2015 Nuudles. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    override func viewDidLoad()
	{
		super.viewDidLoad()

		if let scene = GameScene(fileNamed:"GameScene")
		{
			// Configure the view.
			let skView = self.view as! SKView
			skView.showsFPS = true
			skView.showsNodeCount = true
			
			/* Sprite Kit applies additional optimizations to improve rendering performance */
			skView.ignoresSiblingOrder = true
			
			/* Set the scale mode to scale to fit the window */
			scene.scaleMode = .AspectFill
			
			skView.presentScene(scene)
		}
	}

    override func shouldAutorotate() -> Bool
	{
		return true
	}

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
	{
		if UIDevice.currentDevice().userInterfaceIdiom == .Phone
		{
			return .AllButUpsideDown
		}
		else
		{
			return .All
		}
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Release any cached data, images, etc that aren't in use.
	}

	override func prefersStatusBarHidden() -> Bool
	{
		return true
	}
}

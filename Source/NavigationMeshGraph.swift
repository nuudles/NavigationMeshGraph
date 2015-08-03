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
	var polygons: [NavigationMeshPolygon]

	init(polygons: [NavigationMeshPolygon])
	{
		self.polygons = polygons
		super.init()
	}
}

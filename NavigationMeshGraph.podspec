Pod::Spec.new do |s|
  s.name = 'NavigationMeshGraph'
  s.version = '0.0.3'
  s.license = 'MIT'
  s.summary = 'Added pathfinding graph for Navigation Meshes'
  s.homepage = 'https://github.com/nuudles/NavigationMeshGraph'
  s.authors = { 'Christopher Luu' => 'nuudles@gmail.com' }
  s.source = { :git => 'https://github.com/nuudles/NavigationMeshGraph.git', :tag => s.version }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

  s.source_files = 'Source/*.swift'

  s.framework = 'GameplayKit'
  s.requires_arc = true
end

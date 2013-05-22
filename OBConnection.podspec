Pod::Spec.new do |s|
  s.name         = "OBConnection"
  s.version      = "2.2"
  s.author       = { "Oriol Blanc" => "oriolblanc@gmail.com" }
  s.homepage     = "https://github.com/oriolblanc/OBConnection"
  s.summary      = "OBConnection"
  s.description  = "Need a description"
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.source_files = 'OBConnection/*.{h,m}'
  s.requires_arc = true
  s.dependency 'AFNetworking'
  s.dependency 'EGOCache'
  s.dependency 'JSONKit'
end

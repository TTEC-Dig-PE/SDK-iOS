Pod::Spec.new do |s|
  s.name = 'EXPERTconnect'
  s.version = '6.5.8'
  s.license = 'MIT'
  s.summary = 'Ttec Customer Service Native SDK'
  s.homepage = 'http://www.teletech.com/'
  s.authors = { 'Mike Schmoyer' => 'michael.schmoyer@ttec.com' }
  s.source = { :git => 'https://github.com/humanifydev/SDK-iOS.git', :tag => s.version }

  s.platform         = :ios, '9.1'
  s.requires_arc = true
  s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS[config=Debug]' => '-D DEBUG' }

  s.source_files = 'ExpertConnect/**/*.{m,h,mm,hpp,cpp,c}'

  s.resources = 'ExpertConnect/**/*.{xcassets,xib,nib}'

  s.resource_bundles = {
	  'EXPERTconnect' => ['ExpertConnect/**/*.{json,imageset,png,lproj}']
  }

  # Dependencies
  s.frameworks = 'UIKit', 'MediaPlayer', 'MobileCoreServices', 'SystemConfiguration', 'CoreText', 'AVFoundation', 'Foundation', 'MapKit', 'Security'
  s.libraries	= 'icucore'

end

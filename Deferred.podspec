Pod::Spec.new do |spec|
  spec.name = 'Deferred'
  spec.version = '0.1.2'
  spec.summary = 'Promises in Swift'
  spec.homepage = 'https://github.com/remarkableio/Deferred'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = {
    'Giles Van Gruisen' => 'giles@vangruisen.com',
  }
  spec.source = { :git => 'https://github.com/remarkableio/Deferred.git', :tag => "v#{spec.version}" }
  spec.source_files = 'Source/**/*.{h,swift}'
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
end
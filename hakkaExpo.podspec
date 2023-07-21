Pod::Spec.new do |spec|
  spec.name         = 'HakkaExpo2023-iOS'
  spec.version      = '1.2.4'
  spec.authors      = { 
    'Ray' => 'ray@omniguider.com'
  }
  spec.license      = { 
    :type => 'MIT',
    :file => 'LICENSE' 
  }
  spec.homepage     = 'https://github.com/raylei0226/HakkaExpoSDK'
  spec.source       = { 
    :git => 'https://github.com/raylei0226/HakkaExpoSDK.git', 
    :branch => 'main',
    :tag => spec.version.to_s 
  }
  spec.summary      = 'Custom SDK by Omniguider'
  spec.source_files = '**/*.swift', '*.swift'
  spec.swift_versions = '5.0'
  spec.ios.deployment_target = '11.0'
end
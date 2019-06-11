
Pod::Spec.new do |spec|

spec.name         = 'SwiftRefresh'
spec.version      = '0.0.3'
spec.summary      = 'swift语言开发的轻量级下拉刷新框架，使用简单方便。'
spec.license      = 'MIT'
spec.homepage     = 'https://github.com/SmartPear/SwiftRefresh'
spec.author       = {"王欣" => "=573385822@qq.com" }
spec.platform     = :ios, '9.0'
spec.source       = {:git => "https://github.com/SmartPear/SwiftRefresh.git", :tag => spec.version}
spec.frameworks = 'Foundation'
spec.source_files  = 'SwiftRefresh/*.swift'
spec.swift_version = '5.0'

end

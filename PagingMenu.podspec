Pod::Spec.new do |s|
  s.name         = "PagingMenu"
  s.version      = "2.0.0"
  s.summary      = "A paging menu controller built from other view controllers placed inside a scroll view."
  s.homepage     = "https://github.com/iLiuChang/PagingMenu"
  s.license      = "MIT"
  s.authors      = { "iLiuChang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/iLiuChang/PagingMenu.git", :tag => s.version }
  s.requires_arc = true
  s.swift_version = "5.0"
  s.source_files = "Source/*.{swift}"
  s.resource_bundles = { 'PagingMenu' => ['PrivacyInfo.xcprivacy'] }
end
